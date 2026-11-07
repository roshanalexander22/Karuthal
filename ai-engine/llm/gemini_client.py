import os
import google.generativeai as genai

class GeminiClient:
    def __init__(self):
        api_key = os.getenv("GEMINI_API_KEY", "")
        if api_key:
            genai.configure(api_key=api_key)

    async def generate_response(self, prompt: str, system_instruction: str = "") -> str:
        return "Gemini API client response placeholder."
