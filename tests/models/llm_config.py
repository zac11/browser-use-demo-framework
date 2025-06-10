import os
from typing import Literal
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_openai import ChatOpenAI
from pydantic import SecretStr

ModelType = Literal["OpenAI", "Google"]

def get_llm(model_type: ModelType = "Google"):
    """
    Get the appropriate language model based on the model type.
    
    Args:
        model_type (ModelType): Type of model to use ("OpenAI" or "Google")
        
    Returns:
        The configured language model instance
        
    Raises:
        ValueError: If required environment variables are not set
    """
    if model_type == "OpenAI":
        api_key = os.getenv("OPENAI_API_KEY")
        
        if not api_key:
            raise ValueError(
                "OPENAI_API_KEY environment variable is not set. "
                "Please set it using 'export OPENAI_API_KEY=your_api_key_here'"
            )
            
        return ChatOpenAI(
            model="gpt-4o-mini",
            openai_api_key=SecretStr(api_key),
            temperature=0.6
        )
    else:  # Default to Google
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key:
            raise ValueError(
                "GOOGLE_API_KEY environment variable is not set. "
                "Please set it using 'export GOOGLE_API_KEY=your_api_key_here'"
            )
            
        return ChatGoogleGenerativeAI(
            model="gemini-2.0-flash",
            google_api_key=SecretStr(api_key),
            temperature=0.6
        ) 