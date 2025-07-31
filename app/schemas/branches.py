from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class BranchBase(BaseModel):
    branchname: str
    branchaddress: Optional[str] = None
    contactno: Optional[str] = None
    emailaddress: Optional[str] = None
    business_id: int
    employee_id: Optional[int] = None
    city: Optional[str] = None
    country: Optional[str] = None
   
class BranchCreate(BranchBase):
    pass

class BranchUpdate(BaseModel):
    branchname: Optional[str] = None
    branchaddress: Optional[str] = None
    contactno: Optional[str] = None
    emailaddress: Optional[str] = None
    employee_id: Optional[int] = None
    city: Optional[str] = None
    country: Optional[str] = None

class Branch(BranchBase):
    id: int
    updatedAt: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class BranchSchema(BranchBase):
   class Config:
        orm_mode = True


class BranchResponse(BranchBase):
    id: int
    branchname: Optional[str] = None
    branchaddress: Optional[str] = None
    contactno: Optional[str] = None
    emailaddress: Optional[str] = None
    employee_id: Optional[int] = None
    city: Optional[str] = None
    country: Optional[str] = None
    
    class Config:
        orm_mode = True