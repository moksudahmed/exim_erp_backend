from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional
from enum import Enum
from app.models.enum_types import AccountAction

class LedgerBase(BaseModel):
    account_id: int
    journal_item_id: int
    entry_date: date
    amount: float
    balance: float
    type: Optional[AccountAction]

class LedgerCreate(LedgerBase):
    pass

class Ledger(LedgerBase):
    id: int
    created_at: datetime
    
    class Config:
        orm_mode = True

class LedgerSchema(BaseModel):
    account_id: int
    journal_item_id: int
    entry_date: date
    amount: float
    balance: float
    type: Optional[AccountAction]
    
    class Config:
        orm_mode = True  # Old config for Pydantic 1.x
