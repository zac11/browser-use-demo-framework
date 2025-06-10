import os
import yaml
import asyncio
import pandas as pd
from datetime import datetime
from browser_use import Controller
from browser_use.agent.service import Agent
from models.llm_config import get_llm
from conftest import ValidateResult
import json
from utils.get_all_test_files import get_test_files

async def run_test_case(scenario, model_type="Google"):
    """Run a single test case and return its results."""
    print(f"\nRunning test case: {scenario['title']}")
    print("-" * 80)
    
    # Initialize components
    controller = Controller(output_model=ValidateResult)
    llm = get_llm(model_type)
    
    try:
        # Create agent with the scenario steps
        agent = Agent(
            task=scenario['steps'],
            llm=llm,
            use_vision=True,
            controller=controller,
            enable_memory=True
        )
        
        # Run the test
        history = await agent.run()
        test_result = history.final_result()
        print(f"Raw result: {test_result}")
        
        # Parse the result
        result_dict = json.loads(test_result)
        validate_result = ValidateResult(**result_dict)
        
        return {
            "Scenario ID": scenario["id"],
            "Title": scenario["title"],
            "Status": "PASSED" if validate_result.success else "FAILED",
            "Message": validate_result.message
        }
    except Exception as e:
        return {
            "Scenario ID": scenario["id"],
            "Title": scenario["title"],
            "Status": "ERROR",
            "Message": str(e)
        }

async def main():
    """Main function to run all tests and generate report."""
    # Get command line arguments
    import sys
    model_type = "Google"  # Default model
    if len(sys.argv) > 1 and sys.argv[1] == "--model=OpenAI":
        model_type = "OpenAI"
    
    # Get all test files
    test_files = get_test_files()
    if not test_files:
        print("No test files found in scenarios directory.")
        return
    
    print(f"Found {len(test_files)} test files to run.")
    
    # Run all tests
    results = []
    for yaml_file in test_files:
        # Use the root scenarios directory
        yaml_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'scenarios', yaml_file)
        
        # Read YAML file
        with open(yaml_path, 'r') as file:
            scenario = yaml.safe_load(file)
        
        # Run the test case
        result = await run_test_case(scenario, model_type)
        results.append(result)
    
    # Generate timestamp for the report
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save results to Excel
    df = pd.DataFrame(results)
    excel_file = f"test_results_{timestamp}.xlsx"
    df.to_excel(excel_file, index=False)
    print(f"\nTest results saved to {excel_file}")
    
    # Print summary
    print("\nTest Summary:")
    print("-" * 80)
    for result in results:
        print(f"{result['Scenario ID']} - {result['Title']}: {result['Status']}")
        if result['Status'] != "PASSED":
            print(f"  Message: {result['Message']}")

if __name__ == '__main__':
    asyncio.run(main()) 