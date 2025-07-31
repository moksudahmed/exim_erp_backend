from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class SubsidiaryAccountBase(BaseModel):
   # account_id: Optional[int] = None
   # client_id: Optional[int] = None
    account_name: Optional[str] = None
    account_no: Optional[str] = None
    address: Optional[str] = None
    branch: Optional[str] = None
    account_holder: Optional[str] = None
    type: Optional[str] = None

class SubsidiaryAccountCreate(SubsidiaryAccountBase):
    account_id: Optional[int] = None   
    account_name: Optional[str] = None
    account_no: Optional[str] = None    
    type: Optional[str] = None

class SubsidiaryAccountUpdate(SubsidiaryAccountBase):
    pass

class SubsidiaryAccountResponse(SubsidiaryAccountBase):
    account_id: Optional[int] = None
    client_id: Optional[int] = None
    account_name: Optional[str] = None
    subsidiary_account_id: int
    type: Optional[str] = None
    
    class Config:
        orm_mode = True

class SubsidiaryAccountBankResponse(BaseModel):
    subsidiary_account_id: Optional[int] = None
    account_id: Optional[int] = None
    account_name: Optional[str]= None
    account_no: Optional[str]= None
    address: Optional[str]= None
    branch: Optional[str]= None
    account_holder: Optional[str]= None
    type: Optional[str]= None

    class Config:
        orm_mode = True