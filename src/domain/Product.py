from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Product Management

class ProductStatus(Enum):
    AVAILABLE = "AVAILABLE"
    OUT_OF_STOCK = "OUT_OF_STOCK"
    DISCONTINUED = "DISCONTINUED"

@dataclass
class Money:
    amount: float
    currency: str

    def add(self, other):
        pass

    def subtract(self, other):
        pass

    def multiply_by(self, factor: float):
        pass

@dataclass
class Product:
    product_id: str
    store_id: str  # Reference to Store
    name: str
    description: str
    price: Money
    category: str
    tags: List[str]
    images: List[ImageData]
    stock: int
    status: ProductStatus

    def create(self):
        pass

    def update(self):
        pass

    def update_stock(self, new_stock: int):
        self.stock = new_stock