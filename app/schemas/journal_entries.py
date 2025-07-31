from pydantic import BaseModel, ValidationError, ValidationInfo, field_validator
from typing import Optional
from datetime import datetime
from enum import Enum
from app.models.enum_types import AccountAction
from typing import List, Optional
# Enum for AccountType

# Enum for AccountType
class AccountTypeEnum(str, Enum):
    ASSET = 'asset'
    LIABILITY = 'liability'
    EQUITY = 'equity'
    REVENUE = 'revenue'
    EXPENSE = 'expense'

# Define JournalItemCreate as a nested model
class JournalItemsCreate(BaseModel):
    narration: str
    debitcredit: Optional[AccountAction]
    amount: float
    account_id: int
    description: Optional[str] = None
    subsidiary_account_id: Optional[int] = None

    class Config:
        orm_mode = True


# Define JournalEntryCreate as a nested model
class JournalEntryCreate(BaseModel):
    ref_no: str
    account_type: AccountTypeEnum
    company: str
    transaction_date: datetime
    user_id: int
    description: Optional[str] = None

    class Config:
        orm_mode = True
  
class CreateLedgerWithEntry(BaseModel):
    journal_entries: JournalEntryCreate    
    journal_items: List[JournalItemsCreate]



class LedgerWithEntryRequest(BaseModel):
    ref_no: str
    account_type: AccountTypeEnum
    company: str
    description: Optional[str] = None
    #transaction_date: datetime
    user_id: int
    journal_items: List[JournalItemsCreate]  # Matches the original JSON key

    class Config:
            orm_mode = True
            
class JournalEntryUpdate(BaseModel):
    pass

class JournalItems(BaseModel):
    narration: Optional[str] 
    debitcredit: Optional[AccountAction]
    amount: Optional[float]    
    created_at: Optional[datetime]
    journal_entries_id: Optional[int]    
    account_id: Optional[int]
    class Config:
        orm_mode = True  # Old config for Pydantic 1.x

class JournalEntry(BaseModel):
    id: int
    ref_no: Optional[str] = None
    account_type: Optional[AccountTypeEnum]
    company: Optional[str] = None
    description: Optional[str] = None
    transaction_date: datetime = None
    user_id: int
    created_at: datetime
    journal_items:List[JournalItems]

    class Config:
        orm_mode = True  # Old config for Pydantic 1.x
