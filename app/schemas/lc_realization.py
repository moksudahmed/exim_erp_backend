from pydantic import BaseModel
from typing import Optional
from datetime import date
from decimal import Decimal


# LC Realization
class LCRealizationBase(BaseModel):
    lc_id: int
    realization_date: date
    amount: Decimal
    receiving_account_id: Optional[int]
    document_reference: str
    remarks: Optional[str]

class LCRealizationCreate(LCRealizationBase):
    pass

class LCRealizationRead(LCRealizationBase):
    id: int

    class Config:
        orm_mode = True
