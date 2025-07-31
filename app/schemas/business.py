from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional, List
from app.models import Branch  # Import related models if needed
from app.models.enum_types import CurrencyCode  # Import if needed for currency

class BusinessBase(BaseModel):
    name: str
    tax_id: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    default_currency: Optional[str] = "USD"
    fiscal_year_start: Optional[date] = None

class BusinessCreate(BusinessBase):
    pass

class BusinessUpdate(BaseModel):
    name: Optional[str] = None
    tax_id: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    default_currency: Optional[str] = None
    fiscal_year_start: Optional[date] = None

class Business(BusinessBase):
    id: int
    name: Optional[str] = None    
    address: Optional[str] = None
    phone: Optional[str] = None
    #branches: List[Branch]
   # branches: Optional[List[Branch]] = None  # Include relationships if needed
    
    class Config:
        orm_mode = True

class BusinessResponse(BusinessBase):
    id: int
    name: Optional[str] = None    
    address: Optional[str] = None
    phone: Optional[str] = None
    
    class Config:
        orm_mode = True