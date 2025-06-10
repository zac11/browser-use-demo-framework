import pytest
from browser_use import Controller
from pydantic import BaseModel
from tests.models.llm_config import get_llm

class ValidateResult(BaseModel):
    success: bool
    message: str

def pytest_addoption(parser):
    """Add command line options for pytest."""
    parser.addoption(
        "--model",
        action="store",
        default="Google",
        choices=["OpenAI", "Google"],
        help="Select the model to use (OpenAI or Google)"
    )

@pytest.fixture
def browser_controller():
    """Fixture to create a browser controller instance."""
    return Controller(output_model=ValidateResult)

@pytest.fixture
def llm(request):
    """Fixture to create a language model instance based on command line option."""
    model_type = request.config.getoption("--model")
    return get_llm(model_type) 