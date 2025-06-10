import os

def get_test_files():
    """Get all YAML test files from the scenarios directory."""
    scenarios_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'scenarios')
    if not os.path.exists(scenarios_dir):
        os.makedirs(scenarios_dir)
        print(f"Created scenarios directory at {scenarios_dir}")
        return []
    
    yaml_files = [f for f in os.listdir(scenarios_dir) if f.endswith('.yaml')]
    print(f"Found {len(yaml_files)} YAML test files")
    return yaml_files 