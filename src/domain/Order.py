from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional
from datetime import datetime

# Order Management

@dataclass
class CartItem:
    product_id: str  # Reference to Product
    quantity: int
    price: Money

    def calculate_subtotal(self) -> Money:
        return Money(amount=self.quantity * self.price.amount, currency=self.price.currency)

@dataclass
class ShoppingCart:
    cart_id: str
    user_id: str
    items: List[CartItem]
    created_at: datetime
    updated_at: datetime

    def add_item(self, item: CartItem):
        self.items.append(item)

    def remove_item(self, product_id: str):
        self.items = [item for item in self.items if item.product_id != product_id]

    def calculate_total(self) -> Money:
        total_amount = sum(item.calculate_subtotal().amount for item in self.items)
        currency = self.items[0].price.currency if self.items else "USD"
        return Money(amount=total_amount, currency=currency)
