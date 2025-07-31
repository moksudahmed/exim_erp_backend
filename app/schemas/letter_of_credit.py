from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from decimal import Decimal

from app.models.enum_types import LCStatusEnum

# ----------- Base Schema -------------
class LetterOfCreditBase(BaseModel):
    lc_number: str = Field(..., max_length=50)
    applicant: Optional[str] = Field(None, max_length=100)
    beneficiary: Optional[str] = Field(None, max_length=100)
    issue_date: date
    expiry_date: Optional[date]
    amount: Optional[float]
    currency: Optional[str] = Field(None, max_length=10)
    #businesses_id: Optional[int]
    status: Optional[LCStatusEnum] = LCStatusEnum.OPEN


# ----------- Create Schema -------------
class LetterOfCreditCreate(LetterOfCreditBase):
    pass


# ----------- Update Schema -------------
class LetterOfCreditUpdate(BaseModel):
    lc_number: Optional[str]
    applicant: Optional[str]
    beneficiary: Optional[str]
    issue_date: Optional[date]
    expiry_date: Optional[date]
    amount: Optional[float]
    currency: Optional[str]
    businesses_id: Optional[int]
    status: Optional[LCStatusEnum]



# ----------- Response / Read Schema -------------

# Nested references (optional, depending on your use case)
class SubsidiaryAccountResponse(BaseModel):
    subsidiary_account_id: int
    account_name: str

    class Config:
        orm_mode = True


class ClientResponse(BaseModel):
    client_id: int
    client_name: str

    class Config:
        orm_mode = True


class LCGoodsResponse(BaseModel):
    id: int
    description: str
    quantity: int
    value: Decimal

    class Config:
        orm_mode = True


class LCChargeResponse(BaseModel):
    id: int
    charge_type: str
    amount: Decimal

    class Config:
        orm_mode = True


class LetterOfCreditResponse(LetterOfCreditBase):
    id: int
   # created_at: datetime

    lc_number: Optional[str]= None
    applicant: Optional[str] = None
    beneficiary: Optional[str] = None
    issue_date: Optional[date] = None
    expiry_date: Optional[date] = None
    amount: Optional[float] = None
    currency: Optional[str] = None
    businesses_id: Optional[int] = None
    status: Optional[LCStatusEnum] = None
    
    class Config:
        orm_mode = True
