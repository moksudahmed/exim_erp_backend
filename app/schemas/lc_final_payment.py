from pydantic import BaseModel
from typing import Optional
from datetime import date
from decimal import Decimal

# LC Final Payment
class LCFinalPaymentBase(BaseModel):
    lc_id: int
    payment_date: date
    amount: Decimal
    payment_method: str
    account_id: Optional[int]
    reference_no: str
    remarks: Optional[str]

class LCFinalPaymentCreate(LCFinalPaymentBase):
    pass

class LCFinalPaymentRead(LCFinalPaymentBase):
    #id: int
    lc_id: int
    payment_date: date
    amount: Decimal
    payment_method: str
    account_id: Optional[int]
    reference_no: str
    remarks: Optional[str]


    class Config:
        orm_mode = True
