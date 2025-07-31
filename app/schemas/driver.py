from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

class DriverBase(BaseModel):
    name: str = Field(..., max_length=255)
    phone_no: Optional[str] = Field(None, max_length=255)
    truck_no: Optional[str] = Field(None, max_length=255)
    measurment: float = Field(..., gt=0)

class DriverCreate(BaseModel):
    name: str
    phone_no: Optional[str] = None
    truck_no: Optional[str] = None
    measurment: float
    user_id: int

class DriverUpdate(BaseModel):
    name: Optional[str] = Field(None, max_length=255)
    phone_no: Optional[str] = Field(None, max_length=255)
    truck_no: Optional[str] = Field(None, max_length=255)
    measurment: Optional[float] = Field(None, gt=0)

class Driver(DriverBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True
class DriverOut(DriverCreate):
    id: int
    class Config:
        orm_mode = True

class Driver(DriverBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True