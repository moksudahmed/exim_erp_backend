from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.enum_types import PaymentMethod

# Payment models
class PaymentBase(BaseModel):
    amount: float
    payment_method:  Optional[PaymentMethod]
    reference_number: Optional[str] = None
    notes: Optional[str] = None

class Payment(PaymentBase):
    id: int
    business_id: int
    sale_id: Optional[int] = None
    purchase_id: Optional[int] = None
    payment_date: datetime

    class Config:
        orm_mode = True
        from_attributes = True  


class PaymentCreate(BaseModel):
    business_id: Optional[int] = None
    amount: float
    payment_method: Optional[PaymentMethod]
    reference_number: Optional[str] = None
    notes: Optional[str] = None
    sale_id: Optional[int] = None
    purchase_id: Optional[int] = None

class PaymentSchema(PaymentCreate):
    id: int
    payment_date: datetime

    class Config:
        orm_mode = True


class PaymentResponse(BaseModel):
    business_id: Optional[int] = None
    amount: float
    payment_method: Optional[PaymentMethod]
    reference_number: Optional[str] = None
    notes: Optional[str] = None
    sale_id: Optional[int] = None
    purchase_id: Optional[int] = None

    class Config:
        orm_mode = True

