from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
from app.models.enum_types import PaymentStatus

class SaleProductCreate(BaseModel):
    product_id: int = Field(..., description="The ID of the product being sold")
    quantity: int = Field(..., description="The quantity of the product being sold")
    price_per_unit: float = Field(..., description="The total price for this quantity of the product")
    total_price: float = Field(..., description="The total price for this quantity of the product")
    #itemwise_discount: int = Field(..., description="The quantity of the product being sold")

class SaleCreate(BaseModel):
    user_id: int = Field(..., description="The ID of the user making the purchase")
    client_id: int = Field(..., description="The ID of the user making the purchase") 
    total: float = Field(..., description="The total amount of the sale")
    sale_products: List[SaleProductCreate] = Field(..., description="A list of products being sold in this sale")
    discount: int = Field(..., description="The discount amount of the sale")
    business_id : Optional[int] = None
    payment_status: Optional[PaymentStatus]
    
class SaleProductUpdate(BaseModel):
    product_id: int
    quantity: int
    price_per_unit: float
    total_price: float
    #itemwise_discount: int

class SaleUpdate(BaseModel):
    user_id: Optional[int]
    client_id: Optional[int] 
    total: Optional[float]
    sale_products: List[SaleProductUpdate]
    discount: Optional[int]
    

class SaleProduct(BaseModel):
    id: int
    product_id: int
    quantity: int
    price_per_unit: float
    total_price: float
    #itemwise_discount: int

    class Config:
        orm_mode = True

class SaleProductSchema(BaseModel):
    product_id: int
    quantity: int
    price_per_unit: float
    total_price: float

    class Config:
        orm_mode = True
        
class Sale(BaseModel):
    id: int
    user_id: int
    client_id: Optional[int] = None
    total: float
    sale_products: List[SaleProduct]
    discount: int
    created_at: datetime
    business_id : Optional[int] = None
    payment_status: Optional[PaymentStatus]

    class Config:
        orm_mode = True
