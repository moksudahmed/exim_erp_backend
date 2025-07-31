from pydantic import BaseModel
from typing import Optional
from datetime import date

class ExpenseCreate(BaseModel):
    ref_no: Optional[str]
    account_id: int
    subsidiary_account_id: Optional[int]
    client_id: Optional[int]
    amount: float
    narration: str
    description: Optional[str]
    transaction_date: date
