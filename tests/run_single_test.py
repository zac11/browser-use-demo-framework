import pytest
import asyncio
from browser_use import Controller
from browser_use.agent.service import Agent
from pydantic import BaseModel
import json
from tests.models.llm_config import get_llm, ModelType

class ValidateResult(BaseModel):
    success: bool
    message: str

@pytest.fixture
def browser_controller():
    """Fixture to create a browser controller instance."""
    return Controller(output_model=ValidateResult)

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
def llm(request):
    """Fixture to create a language model instance based on command line option."""
    model_type = request.config.getoption("--model")
    return get_llm(model_type)

@pytest.mark.asyncio
async def test_etf_option_exists(browser_controller, llm):
    """
    Test to verify that the ETFs option exists in the Product View filter.
    The test should fail (success=False) when ETFs option is found.
    """
    task = (
        "You are a UI Automation Agent. You are given a task and you need to validate if the task is complete. "
        "You have to report the success or failure of the task."
        "1. Go to ishares.com/us"
        "2. Go to Our Funds , then View All Funds"
        "3. Click on Product View filter"
        "4. Check that there is no option named ETFs"
        "5. If ETFs exist, then mark this as failed"
    )

    agent = Agent(
        task=task,
        llm=llm,
        use_vision=True,
        controller=browser_controller
    )
    
    history = await agent.run()
    test_result = history.final_result()
    print(f"Raw result: {test_result}")
    
    # Parse the result into ValidateResult object using json.loads
    result_dict = json.loads(test_result)  # Convert string to dict
    validate_result = ValidateResult(**result_dict)
    
    assert validate_result.success == False, "Expected test to fail when ETFs option exists"
    print(f"Test passed: Successfully verified that ETFs option exists") 