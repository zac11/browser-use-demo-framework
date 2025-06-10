import os
from typing import Literal
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_openai import ChatOpenAI
from pydantic import SecretStr

ModelType = Literal["OpenAI", "Google"]

def get_llm(model_type: ModelType = "Google"):
    """Gets the appropriate language model based on the model_type."""
    if model_type == "OpenAI":
        openai_api_key = os.getenv("OPENAI_API_KEY")
        # Removed dependency on OPENAI_ENDPOINT
        # openai_api_base = os.getenv("OPENAI_ENDPOINT", "https://api.openai.com/v1")

        if not openai_api_key:
            raise ValueError("OPENAI_API_KEY environment variable not set.")

        # Langchain ChatOpenAI automatically picks up OPENAI_API_KEY and OPENAI_API_BASE from env vars
        # Passing key explicitly for clarity, but endpoint will default if env var not set
        return ChatOpenAI(api_key=openai_api_key)

    elif model_type == "Google":
        google_api_key = os.getenv("GOOGLE_API_KEY")

        if not google_api_key:
            raise ValueError("GOOGLE_API_KEY environment variable not set.")

        # Passing key explicitly
        return ChatGoogleGenerativeAI(google_api_key=google_api_key)

    else:
        raise ValueError(f"Unsupported model type: {model_type}") 