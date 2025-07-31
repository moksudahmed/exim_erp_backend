from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from decimal import Decimal

from app.models.enum_types import LCStatusEnum

class LCGoodsShipmentCreate(BaseModel):
    lc_id: int
    shipment_date: date
    bl_number: Optional[str]
    shipping_company: Optional[str]
    port_of_loading: Optional[str]
    port_of_discharge: Optional[str]

class LCGoodsShipmentResponse(LCGoodsShipmentCreate):
    shipment_id: int
    created_at: datetime
