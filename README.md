# Environment Setup Guide

This document outlines the steps to set up the Python development environment using `pyenv` and `uv`.

## Prerequisites

Ensure you have `pyenv` installed and configured on your system.

## Setup Steps

Follow these steps to get the environment ready:

1.  **Check Python Version**
    ```bash
    python --version
    ```

2.  **Install Python (3.11.12)**
    Use `pyenv` to install the specified Python version.
    ```bash
    pyenv install 3.11.12
    ```

3.  **Manage using `pyenv`**
    Set the Python version for the project using `pyenv`.
    ```bash
    pyenv local 3.11.12
    ```

4.  **Install `uv`**
    Install the `uv` package installer and resolver.
    ```bash
    pip install uv
    ```

5.  **Create Virtual Environment**
    Create a virtual environment named `.venv` using `uv`, specifying the Python version.
    ```bash
    uv venv --python 3.11.12
    ```

6.  **Activate Virtual Environment**
    Activate the created virtual environment.
    ```bash
    source .venv/bin/activate
    ```

7.  **Install Packages**
    Install the project dependencies from `requirements.txt` using `uv`.
    ```bash
    uv pip install -r requirements.txt
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