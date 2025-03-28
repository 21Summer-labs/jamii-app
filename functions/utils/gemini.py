import os
import enum
import logging
from PIL import Image
import google.generativeai as genai
from typing_extensions import TypedDict
from typing import Optional, List, Any, Type, TypeVar, Union, Dict


# Define the TypeVar 'T' at the top
T = TypeVar('T')

class GeminiHandler:
    def __init__(self,):
        
        api_key = "AIzaSyBUbJ72Ki9Rgiit1w2nHr8V6BS3veCJhHs"
        model_name: str = "gemini-1.5-flash"
        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel(model_name)
        self.chat = None
    
    def process_content(self,
                             schema: Type[T],
                             text: Optional[str] = None,
                             image_path: Optional[str] = None,
                             audio_path: Optional[str] = None,
                             use_json: bool = True) -> Union[str, T]:
        
        content_parts = []
        
        if text:
            content_parts.append(text)
            
        if image_path and os.path.exists(image_path):
            image = Image.open(image_path)
            content_parts.append(image)
            
        if audio_path and os.path.exists(audio_path):
            audio_file = genai.upload_file(audio_path)
            content_parts.append(audio_file)
            
        if not content_parts:
            raise ValueError("At least one content type (text/image/audio) must be provided")

        # Configure response type based on schema and format preference
        if issubclass(schema, enum.Enum):
            mime_type = "application/json" if use_json else "text/x.enum"
        else:
            mime_type = "application/json"
            
        response = self.model.generate_content(
            content_parts,
            generation_config=genai.GenerationConfig(
                response_mime_type=mime_type,
                response_schema=schema
            )
        )
        
        return response.text


