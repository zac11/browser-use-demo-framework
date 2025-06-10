from asyncio import Task
import asyncio
from browser_use import Controller
from browser_use.agent.service import Agent
import os
from langchain_google_genai import ChatGoogleGenerativeAI
from pydantic import SecretStr
from pydantic import BaseModel
import json

class ValidateResult(BaseModel):
    success: bool
    message: str

browserUserController = Controller(output_model=ValidateResult)

async def taskValidation():
    task = (
        "You are a UI Automation Agent. You are given a task and you need to validate if the task is complete. "
        "You have to report the success or failure of the task."
        "1. Go to ishares.com/us"
        "2. Go to Our Funds , then View All Funds"
        "3. Click on Product View filter"
        "4. Check that there is no option named ETFs"
        "5. If ETFs exist, then mark this as failed"
    )
    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        raise ValueError("GOOGLE_API_KEY environment variable is not set. Please set it using 'export GEMINI_API_KEY=your_api_key_here'")
    model = "gemini-2.0-flash"

    llm = ChatGoogleGenerativeAI(
        model=model,
        google_api_key=SecretStr(api_key),
        temperature=0.0
    )

    agent = Agent(
        task=task,
        llm=llm,
        use_vision=True,
        controller=browserUserController
    )
    history = await agent.run()
    test_result = history.final_result()
    print(f"Raw result: {test_result}")
    
    # Parse the result into ValidateResult object using json.loads
    result_dict = json.loads(test_result)  # Convert string to dict
    validate_result = ValidateResult(**result_dict)
    
    assert validate_result.success == False, "Expected test to fail when ETFs option exists"
    print(f"Test passed: Successfully verified that ETFs option exists")


asyncio.run(taskValidation())





