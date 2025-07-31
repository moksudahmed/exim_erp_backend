from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.enum_types import TransactionType

# Base Transaction schema with optional fields
class TransactionBase(BaseModel):
    #transaction_type: Optional[str] = None  # SALE, EXPENSE, INCOME, CASH_FLOW
    amount: Optional[float] = None
    description: Optional[str] = None
    type: Optional[TransactionType]
    transaction_date: Optional[datetime] = None
    user_id: Optional[int] = None
    business_id : Optional[int] = None
    reference_type :  Optional[str] = None
    reference_id : Optional[int]


# Schema for creating a transaction
class TransactionCreate(BaseModel):
    description: Optional[str] = None  # Optional description
    transaction_date:  Optional[datetime] = None
    amount: float
    type: Optional[TransactionType]
    account_id: Optional[int]
    user_id: Optional[int]
    business_id : Optional[int] = None
    reference_type :  Optional[str] = None
    reference_id : Optional[int]

class Transaction(BaseModel):
    transaction_id: int
    user_id: int
    #transaction_type: str
    amount: float
    type: Optional[TransactionType]
    description: str
    transaction_date:  Optional[datetime] = None
    business_id : Optional[int] = None
    reference_type :  Optional[str] = None
    reference_id : Optional[int]


    class Config:
        orm_mode = True
        from_attributes = True

# Schema for updating a transaction (allows partial updates)
class TransactionUpdate(TransactionBase):
    pass

# Schema for retrieving a transaction, includes ID and related user_id
"""class Transaction(TransactionBase):
    transaction_id: int  # Unique identifier of the transaction
    user_id: Optional[int] = None

    class Config:
        orm_mode = True
        from_attributes = True
"""
class TransactionResponse(BaseModel):
    transaction_id: int  # Ensure this field is included
    description: str
    transaction_date: datetime
    amount: float
    type: Optional[TransactionType]
    account_id: int
    user_id: Optional[int]
    reference_type :  Optional[str] = None
    reference_id : Optional[int]

    class Config:
        orm_mode = True  # Ensure the model can be converted from an ORM object
