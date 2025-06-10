# Environment Setup Guide

This document outlines the steps to set up the Python development environment using `pyenv` and `uv`.

## Prerequisites

Before proceeding, ensure you have Python 3.11 installed on your system.


### Check if Python is Installed

Open a terminal (macOS) or Command Prompt/PowerShell (Windows) and run:

```bash
python --version
```

or

```bash
python3 --version
```

If Python 3.11.x is installed, you will see output similar to:

```
Python 3.11.12
```

If Python is **not installed** or the version is lower than 3.11, follow the steps below for your operating system.

### Installing Python 3.11

#### macOS

1. **Using Homebrew (recommended):**
    ```bash
    brew install python@3.11
    ```
    After installation, you may need to add Python 3.11 to your PATH. Follow any instructions provided by Homebrew after installation.

2. **Direct Download:**
    You can also download the macOS installer from the [official Python downloads page](https://www.python.org/downloads/release/python-3110/).

#### Windows

1. Go to the [official Python 3.11.0 release page](https://www.python.org/downloads/release/python-3110/).
2. Download the appropriate Windows installer (64-bit is recommended for most users).
3. Run the installer and **make sure to check the box that says "Add Python to PATH"** during installation.
4. Complete the installation and verify by running `python --version` in Command Prompt or PowerShell.

---

### Install pyenv (optional, for advanced users)

If you want to manage multiple Python versions, you can use `pyenv`.

#### macOS
Install `pyenv` using Homebrew:
```bash
brew install pyenv
```
After installation, follow any instructions provided by Homebrew to add `pyenv` to your shell profile (e.g., `.zshrc` or `.bash_profile`).

#### Windows
For Windows, use [pyenv-win](https://github.com/pyenv-win/pyenv-win):
```powershell
git clone https://github.com/pyenv-win/pyenv-win.git $HOME/.pyenv
setx PYENV $HOME\.pyenv
setx PATH "%PYENV%\pyenv-win\bin;%PYENV%\pyenv-win\shims;%PATH%"
```
Refer to the [pyenv-win documentation](https://github.com/pyenv-win/pyenv-win) for more details.


## Setup Steps

Follow these steps to get the environment ready:

1.  **Manage Python Version using `pyenv` (optional, for advanced users)**
    If you use `pyenv` to manage multiple Python versions, set the Python version for the project:
    ```bash
    pyenv local 3.11.12
    ```

2.  **Install `uv`**
    Install the `uv` package installer and resolver:
    ```bash
    pip install uv
    ```

3.  **Create Virtual Environment**
    Create a virtual environment named `.venv` using `uv`, specifying the Python version:
    ```bash
    uv venv --python 3.11.12
    ```

4.  **Activate Virtual Environment**
    Activate the created virtual environment:
    ```bash
    source .venv/bin/activate
    ```

5.  **Install Packages**
    Install the project dependencies from `requirements.txt` using `uv`:
    ```bash
    uv pip install -r requirements.txt
    ```

## Setting up API Keys
Before running the tests, you need to set up the API keys for the AI model that you're going to use - be it OpenAI, Gemini or local models like LLama models from Meta.


Create a file named `.env`, which is similar to the `.env.example` file 

Provide the API key for the Model - for eg for OpenAI models set 

```
OPENAI_API_KEY=sk-proj-xxxxxxxx
```

## Running Tests

After setting up the environment and activating the virtual environment, you can run the tests.

### Running a Single Test File

To run the `run_single_test.py` file, use the following command:

```bash
PYTHONPATH=. python tests/run_single_test.py
```

### Running All Test Scenarios

To run all test scenarios located in the `scenarios` directory, use the `run_all_tests.py` script. By default, it uses the Google model. You can specify the model using the `--model` flag.

```bash
PYTHONPATH=. python tests/run_all_tests.py
```

To run with the OpenAI model:

```bash
PYTHONPATH=. python tests/run_all_tests.py --model=OpenAI
```

To use these scripts:

On macOS: 
Open a terminal, navigate to the project root, and run 
```bash
chmod +x shellscripts/setupMacOS.sh
``` 
to make the script executable. Then run 
```bash
./shellscripts/setupMacOS.sh
```

On Windows: 
Open PowerShell, navigate to the project root, and run 
```bash
./shellscripts/setUpWindows.ps1
```

 You might need to adjust PowerShell execution policies (Set-ExecutionPolicy RemoteSigned) to run local scripts if you haven't already.