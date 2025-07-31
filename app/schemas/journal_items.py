from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from enum import Enum

class JournalItemsBase(BaseModel):
    narration: Optional[str]
    debitcredit: Optional[str]   
    amount: Optional[float]    
    created_at: Optional[datetime]
    journal_entries_id: Optional[int]    
    account_id: Optional[int]
    subsidiary_account_id: int

class JournalItemsCreate(BaseModel):
    narration: str
    debitcredit: str
    amount: float
    journal_entries_id: int
    account_id: int
    subsidiary_account_id: int


class JournalItemsUpdate(BaseModel):
    narration: Optional[str] = None
    debitcredit: Optional[str] = None  
    amount: Optional[float] = None    
    

class JournalItems(JournalItemsBase):
    narration: str
    debitcredit: str
    amount: float
    subsidiary_account_id: int
    account_id: int

    class Config:
        orm_mode = True