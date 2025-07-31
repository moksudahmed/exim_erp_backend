from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime



class SaleProduct(BaseModel):
    id: int
    product_id: int
    quantity: int
    price_per_unit: float
    total_price: float
    #itemwise_discount: int

    class Config:
        orm_mode = True
        
class Sale(BaseModel):
    id: int
    user_id: int
    customer_id: int
    total: float
    sale_products: List[SaleProduct]
    discount: int
    created_at: datetime
    business_id : Optional[int] = None

    class Config:
        orm_mode = True

# -----------------------------
# SaleProduct Schemas
# -----------------------------

class SaleProductCreate(BaseModel):
    product_id: int = Field(..., description="The ID of the product being sold")
    quantity: int = Field(..., description="The quantity of the product being sold")
    price_per_unit: float = Field(..., description="Price per unit of the product")
    total_price: float = Field(..., description="Total price for the quantity sold")
    # itemwise_discount: Optional[int] = Field(None, description="Optional item-wise discount")

class SaleProductUpdate(BaseModel):
    product_id: int
    quantity: int
    price_per_unit: float
    total_price: float
    # itemwise_discount: Optional[int]

class SaleProductSchema(SaleProductCreate):
    id: int

    class Config:
        orm_mode = True

# -----------------------------
# Sale Schemas
# -----------------------------

class SaleCreate(BaseModel):
    user_id: int = Field(..., description="The ID of the user making the sale")
    customer_id: int = Field(..., description="The ID of the customer")
    total: float = Field(..., description="The total amount of the sale")
    discount: int = Field(..., description="The discount amount applied to the sale")
    business_id: Optional[int] = Field(None, description="Optional business ID")
    sale_products: List[SaleProductCreate] = Field(..., description="List of products in the sale")

class SaleUpdate(BaseModel):
    user_id: Optional[int]
    customer_id: Optional[int]
    total: Optional[float]
    discount: Optional[int]
    sale_products: List[SaleProductUpdate]

class SaleSchema(BaseModel):
    id: int
    user_id: int
    customer_id: int
    total: float
    discount: int
    business_id: Optional[int]
    sale_products: List[SaleProductSchema]
    created_at: datetime

    class Config:
        orm_mode = True

# -----------------------------
# Composite Sale + Transaction Schemas
# -----------------------------

# You must define TransactionCreate and TransactionSchema/Transaction separately
# Here's a placeholder for TransactionCreate and Transaction

class TransactionCreate(BaseModel):
    amount: float
    account_id: int
    reference_type: Optional[str]
    reference_id: Optional[int]
    transaction_type: str  # E.g., "SALE", "EXPENSE"
    business_id: Optional[int]

class Transaction(BaseModel):
    id: int
    amount: float
    account_id: int
    reference_type: Optional[str]
    reference_id: Optional[int]
    transaction_type: str
    business_id: Optional[int]
    created_at: datetime

    class Config:
        orm_mode = True

class SaleWithTransactionCreate(BaseModel):
    sale: SaleCreate
    transaction: TransactionCreate

class SaleWithTransactionResponse(BaseModel):
    sale: SaleSchema
    transaction: Transaction

    class Config:
        orm_mode = True



class SaleWithTransactionCreate(BaseModel):
    sale: SaleCreate
    transaction: TransactionCreate

class SaleWithTransactionResponse(BaseModel):
    sale: SaleSchema
    transaction: Transaction

    class Config:
        orm_mode = True