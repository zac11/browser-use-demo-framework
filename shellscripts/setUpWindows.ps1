# --- Environment Setup and Test Runner for Windows (PowerShell) ---

# --- Step 1: Check for Python 3.11.12 or newer ---
$pythonVersion = "3.11.12"
$pythonCmd = ""

Write-Host "Checking for Python ${pythonVersion} or newer..."

# Check if python command exists and is the correct version
# Use `where.exe` or `Get-Command` to find python executable
$pythonPath = Get-Command python3 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $pythonPath) {
    $pythonPath = Get-Command python -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
}

if ($pythonPath -and (Test-Path $pythonPath)) {
    Write-Host "Found Python executable at: $($pythonPath)"
    $installedVersion = & "$pythonPath" -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"
    Write-Host "Detected Python version: $($installedVersion)"

    # Compare versions (simplified check, assumes standard versioning)
    $versionComparison = [System.Version]::Parse($installedVersion).CompareTo([System.Version]::Parse($pythonVersion))

    if ($versionComparison -ge 0) {
        Write-Host "Python ${installedVersion} (>= ${pythonVersion}) found."
        $pythonCmd = "`"$pythonPath`"" # Quote path for execution
    } else {
        Write-Host "Found older Python version (${installedVersion}). Python ${pythonVersion} or newer is required."
    }
} else {
    Write-Host "Python executable not found in PATH."
}

# --- Step 2: Inform user if Python not found ---
if (-not $pythonCmd) {
    Write-Host "Python ${pythonVersion} or newer is not installed or not found in your PATH."
    Write-Host "Please download and install Python from the official website:"
    Write-Host "https://www.python.org/downloads/"
    Write-Host "Make sure to check the 'Add Python to PATH' option during installation."
    exit 1
}

# --- Step 3: Install uv ---
Write-Host "Installing uv..."
# Ensure pip is up to date before installing uv
& $pythonCmd -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { Write-Host "Error upgrading pip."; exit 1 }

& $pythonCmd -m pip install uv
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install uv."
    exit 1
}

# uv should now be available via python -m uv or in the user's site-packages scripts dir
$uvCmd = "$pythonCmd -m uv" # Prefer running via python -m uv for reliability

# --- Step 4: Create Virtual Environment ---
Write-Host "Creating virtual environment (.venv)..."
# Use the detected Python command to create the venv
& $uvCmd venv --python $pythonCmd
if (-not (Test-Path ".venv")) {
    Write-Host "Error: Failed to create virtual environment."
    exit 1
}

# --- Step 5: Activate Virtual Environment and Install Packages ---
Write-Host "Activating virtual environment and installing packages from requirements.txt..."

$venvPython = ".venv\Scripts\python.exe" # Windows path

# Ensure the venv python executable exists
if (-not (Test-Path $venvPython)) {
     Write-Host "Error: Virtual environment Python executable not found at $venvPython."
     exit 1
}

# Install requirements using uv via the venv python
# Use Invoke-Expression or call directly - calling directly is safer
& "$venvPython" -m uv pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install dependencies from requirements.txt."
    exit 1
}

Write-Host "Environment setup complete. Dependencies installed."

# --- Step 6: Run All Tests ---
Write-Host "Running all test scenarios..."

$venvPython = ".venv\Scripts\python.exe" # Windows path

# Ensure the venv python executable exists
if (-not (Test-Path $venvPython)) {
     Write-Host "Error: Virtual environment Python executable not found at $venvPython."
     exit 1
}

# Pass along any arguments provided to the script (like --model=OpenAI)
$testRunnerArgs = $Args

# Execute the test runner using the venv python interpreter
# Set PYTHONPATH environment variable for the current command
$env:PYTHONPATH = ".";
& "$venvPython" tests\run_all_tests.py @testRunnerArgs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests completed with errors."
    exit 1 # Exit with a non-zero code to indicate failure
} else {
    Write-Host "All tests completed successfully."
    exit 0 # Exit with zero code to indicate success
}

Write-Host "Setup and test run script finished." 