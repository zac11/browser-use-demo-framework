#!/bin/bash

# --- Environment Setup and Test Runner for macOS ---

# --- Step 1: Check for Python 3.11.12 or newer ---
PYTHON_VERSION="3.11.12"
PYTHON_CMD=""

echo "Checking for Python ${PYTHON_VERSION} or newer..."

# Check if python3 command exists and is the correct version
if command -v python3 &> /dev/null; then
    INSTALLED_VERSION=$(python3 -c "import sys; print('.'.join(map(str, sys.version_info[:3])))")
    if [[ "$(printf '%s\n' "$PYTHON_VERSION" "$INSTALLED_VERSION" | sort -V | head -n 1)" == "$PYTHON_VERSION" ]]; then
        echo "Python ${INSTALLED_VERSION} found: $(which python3)"
        PYTHON_CMD="python3"
    else
        echo "Found older Python version (${INSTALLED_VERSION}), looking for specific ${PYTHON_VERSION}."
        # Try specific version command if available (e.g., from pyenv or Homebrew linking)
        if command -v python${PYTHON_VERSION} &> /dev/null; then
             echo "Python ${PYTHON_VERSION} found: $(command -v python${PYTHON_VERSION})"
             PYTHON_CMD="python${PYTHON_VERSION}"
        fi
    fi
fi

# If not found via standard commands, check pyenv specific path if pyenv is likely used
if [ -z "$PYTHON_CMD" ]; then
    if command -v pyenv &> /dev/null; then
        PYENV_PYTHON_PATH=$(pyenv which python${PYTHON_VERSION} 2>/dev/null)
        if [ -f "$PYENV_PYTHON_PATH" ]; then
            echo "Python ${PYTHON_VERSION} found via pyenv: ${PYENV_PYTHON_PATH}"
            PYTHON_CMD="$PYENV_PYTHON_PATH"
        fi
    fi
fi

# --- Step 2: Install Python if not found ---
if [ -z "$PYTHON_CMD" ]; then
    echo "Python ${PYTHON_VERSION} or newer not found."
    echo "Attempting to install Python ${PYTHON_VERSION} using Homebrew..."
    # Check for Homebrew
    if ! command -v brew &> /dev/null; then
        echo "Homebrew not found. Installing Homebrew first."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Attempt to source Homebrew environment variables (may need manual step)
        if [ -f "~/.zshrc" ]; then
            echo "Attempting to source ~/.zshrc... Please open a new terminal or manually source if commands are not found."
            source ~/.zshrc || echo "Warning: Failed to source ~/.zshrc. Homebrew commands might not be available." # Attempt sourcing but don't fail script
        elif [ -f "~/.bash_profile" ]; then
             echo "Attempting to source ~/.bash_profile... Please open a new terminal or manually source if commands are not found."
             source ~/.bash_profile || echo "Warning: Failed to source ~/.bash_profile. Homebrew commands might not be available." # Attempt sourcing but don't fail script
        else
             echo "Could not find ~/.zshrc or ~/.bash_profile to source. Please ensure Homebrew is in your PATH after installation."
        fi

        # Re-check if brew command is available after potential sourcing/installation
        if ! command -v brew &> /dev/null; then
             echo "Error: Homebrew command not found after installation attempt. Please install Homebrew manually or ensure it's in your PATH." # This error might happen if sourcing failed
             exit 1
        fi
    fi
    # Install Python
    brew install python@${PYTHON_VERSION}
    # After installation, try to find the command again
    if command -v python3 &> /dev/null; then
        PYTHON_CMD="python3"
        echo "Python installed and found: $(which python3)"
    elif command -v python${PYTHON_VERSION} &> /dev/null; then
         PYTHON_CMD="python${PYTHON_VERSION}"
         echo "Python installed and found: $(command -v python${PYTHON_VERSION})"
    else
         echo "Error: Python installation via Homebrew might have failed or is not in PATH. Please try running 'brew install python@${PYTHON_VERSION}' manually."
         exit 1
    fi
fi

# Ensure we have a Python command to use
if [ -z "$PYTHON_CMD" ]; then
    echo "Fatal error: Could not find or install a suitable Python interpreter."
    exit 1
fi

# --- Step 3: Install uv ---
echo "Installing uv..."
# Ensure pip is up to date before installing uv
"$PYTHON_CMD" -m pip install --upgrade pip
if ! "$PYTHON_CMD" -m pip install uv; then
    echo "Error: Failed to install uv."
    exit 1
fi

# uv should now be available via python -m uv or in the user's PATH if site-packages scripts are included
# UV_CMD="$PYTHON_CMD -m uv" # Prefer running via python -m uv for reliability

# --- Step 4: Create Virtual Environment ---
echo "Creating virtual environment (.venv)..."
# Using the system-installed uv to create the venv
if ! "$PYTHON_CMD" -m uv venv --python "$PYTHON_CMD"; then
    echo "Error: Failed to create virtual environment."
    exit 1
fi

# --- Step 5: Install Packages from requirements.txt into the Virtual Environment ---
echo "Installing packages from requirements.txt into the virtual environment..."

VENV_DIR=".venv"
VENV_PYTHON="$VENV_DIR/bin/python" # Path to python executable inside the venv

# Check if the virtual environment directory and python executable exist
if [ ! -d "$VENV_DIR" ]; then
     echo "Error: Virtual environment directory not found at $VENV_DIR."
     exit 1
fi

if [ ! -f "$VENV_PYTHON" ]; then
     echo "Error: Python executable not found inside the virtual environment at $VENV_PYTHON."
     echo "Virtual environment creation might have failed."
     exit 1
fi

# Install requirements using the pip module from inside the virtual environment's python
# This is the standard and most reliable way to install packages into an existing venv.
if ! "$PYTHON_CMD" -m uv pip install -r requirements.txt; then
    echo "Error: Failed to install dependencies from requirements.txt into the virtual environment."
    exit 1
fi

echo "Environment setup complete. Dependencies installed."

# --- Step 6: Run All Tests ---
echo "Running all test scenarios..."

# Execute the test runner using the python interpreter from the activated venv
# PYTHONPATH is set, and 'python' command now refers to the venv's python
# Pass along any arguments provided to the script (like --model=OpenAI)
TEST_RUNNER_ARGS=""
if [ "$#" -gt 0 ]; then
    TEST_RUNNER_ARGS="$@"
fi

if ! PYTHONPATH=. python tests/run_all_tests.py $TEST_RUNNER_ARGS; then
    echo "Tests completed with errors."
    exit 1 # Exit with a non-zero code to indicate failure
else
    echo "All tests completed successfully."
    exit 0 # Exit with zero code to indicate success
fi

echo "Setup and test run script finished." 