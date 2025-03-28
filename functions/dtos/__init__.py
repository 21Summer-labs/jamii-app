from dataclasses import dataclass
from typing import List, Optional, Dict, Any
from datetime import datetime


@dataclass
class SearchProductsDTO:
    """
    DTO for searching products
    """
    query: str
    store_id: Optional[str] = None
    limit: int = 20

@dataclass
class GetStoreProductsDTO:
    """
    DTO for retrieving products from a store
    """
    store_id: str
    category: Optional[str] = None
    page: int = 1
    page_size: int = 20

@dataclass
class GetProductDTO:
    """
    DTO for retrieving a specific product
    """
    product_id: str

@dataclass
class CreateUserDTO:
    """
    DTO for creating a new user
    """
    email: str
    password: str
    display_name: Optional[str] = None

@dataclass
class CreateStoreDTO:
    """
    DTO for creating a new store
    """
    name: str
    owner_id: str
    description: Optional[str] = None
    address: Optional[str] = None
    contact_info: Optional[Dict[str, str]] = None
    categories: Optional[List[str]] = None
    business_hours: Optional[Dict[str, str]] = None

@dataclass
class CreateProductDTO:
    """
    DTO for creating a new product
    """
    store_id: str
    name: str
    description: str
    price: float
    category: str
    temp_image_paths: List[str]
    temp_audio_path: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None
    stock: int = 0
    tags: Optional[List[str]] = None
    additional_details: Optional[Dict[str, Any]] = None


@dataclass
class CreateOrderDTO:
    """
    DTO for creating an order
    Corresponds to CreateOrder.execute() method
    """
    user_id: str
    store_id: str
    total_price: float
    delivery_fee: float

@dataclass
class GetContractsDTO:
    """
    DTO for getting available contracts
    Corresponds to GetContracts.get_available_contracts() method
    """
    delivery_agent_id: Optional[str] = None

@dataclass
class SelectContractDTO:
    """
    DTO for selecting a contract
    Corresponds to GetContracts.select_contract() method
    """
    delivery_agent_id: str
    order_id: str

@dataclass
class AcceptDeliveryDTO:
    """
    DTO for accepting delivery
    Corresponds to AcceptDelivery.execute() method
    """
    order_id: str
    delivery_agent_id: str

@dataclass
class ConfirmPickupDTO:
    """
    DTO for confirming pickup
    Corresponds to ConfirmPickup.execute() method
    """
    order_id: str
    delivery_agent_id: str

@dataclass
class ConfirmDeliveryDTO:
    """
    DTO for confirming delivery
    Corresponds to ConfirmDelivery.execute() method
    """
    order_id: str
    customer_id: str

@dataclass
class RateDeliveryDTO:
    """
    DTO for rating delivery
    Corresponds to ConfirmDelivery.rate_delivery() method
    """
    order_id: str
    customer_id: str
    rating: int
    review: Optional[str] = None