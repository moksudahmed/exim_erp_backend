from pydantic import BaseModel
from datetime import date
from typing import Optional

class LCMarginPaymentBase(BaseModel):
    lc_id: int
    amount: float
    payment_date: date
    account_id: Optional[int] = None

class LCMarginPaymentCreate(LCMarginPaymentBase):
    pass

class LCMarginPaymentResponse(LCMarginPaymentBase):
    id: int
    lc_id: int
    amount: float
    payment_date: date
    account_id: Optional[int] = None


    class Config:
        orm_mode = True
