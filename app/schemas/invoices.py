from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from app.models.enum_types import InvoiceStatus


# Invoice models
class InvoiceBase(BaseModel):
    customer_id: int
    invoice_number: str
    issue_date:  datetime
    due_date:  datetime
    status: InvoiceStatus
    total_amount: float

class InvoiceCreate(InvoiceBase):
    business_id: int
    sale_id: Optional[int] = None

class Invoice(InvoiceBase):
    id: int
    business_id: int
    sale_id: Optional[int] = None
    amount_paid: float
    balance_due: float

    class Config:
        orm_mode = True
        from_attributes = True  
