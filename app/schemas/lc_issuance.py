from pydantic import BaseModel
from typing import Optional
from datetime import date

class LCIssuanceBase(BaseModel):
    lc_id: int
    issuing_bank: Optional[str] = None
    issue_date: Optional[date] = None
    remarks: Optional[str] = None


# ----------- Create Schema -------------
class LCIssuanceCreate(LCIssuanceBase):
    pass

class LCIssuanceUpdate(BaseModel):
    issuing_bank: Optional[str] = None
    issue_date: Optional[date] = None
    remarks: Optional[str] = None

class LCIssuanceResponse(BaseModel):
    id: int
    lc_id: int
    issuing_bank: Optional[str] = None
    issue_date: Optional[date] = None
    remarks: Optional[str] = None

    class Config:
        orm_mode = True