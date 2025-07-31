from pydantic import BaseModel
from typing import Optional
from datetime import date
from decimal import Decimal

# LC Goods Receipt
class LCGoodsReceiptBase(BaseModel):
    lc_id: int
    receipt_date: date
    warehouse_id: Optional[int]
    receiver_name: str
    remarks: Optional[str]

class LCGoodsReceiptCreate(LCGoodsReceiptBase):
    pass

class LCGoodsReceiptRead(LCGoodsReceiptBase):
    #id: int
    lc_id: int
    receipt_date: date
    warehouse_id: Optional[int]
    receiver_name: str
    remarks: Optional[str]


    class Config:
        orm_mode = True
