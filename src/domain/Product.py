from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Product Management

@dataclass
class Product:
    product_id: str
    store_id: str  # Reference to Store
    name: str
    description: str
    price: float
    category: str
    tags: List[str]
    images: List[ImageData]
    stock: int

    def create(self):
        '''
        for the product tagging service, we should utilize computer vision.
        The store owner sends an image with an audio recording which acts as context for the image
        we transcript the audio recording - send the text with the image with a prompt to the LLM
        the LLM will return a json object of its description of the product which we will store
        we store the LLM output
        '''
        pass

    def update(self):
        # interfaces with firestore repo update 
        pass

    def update_stock(self, new_stock: int):
        self.stock = new_stock