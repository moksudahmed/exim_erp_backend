
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class DeliveryBase(BaseModel):
    sale_id: int
    driver_id: int
    fare: float
    other_cost: Optional[float] = 0
    note: Optional[str] = None
    total_cost: float

class DeliveryCreate(DeliveryBase):
    pass

class DeliveryRead(DeliveryBase):
    id: int
    delivery_date: datetime
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True