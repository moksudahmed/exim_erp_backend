from pydantic import BaseModel
from typing import Optional
from datetime import date
from decimal import Decimal

# Warehouse
class WarehouseBase(BaseModel):
    warehouse_name: str
    location: str
    branch_id: Optional[int]

class WarehouseCreate(WarehouseBase):
    pass

class WarehouseRead(WarehouseBase):
    id: int
    warehouse_name: str
    location: str

    class Config:
        orm_mode = True

