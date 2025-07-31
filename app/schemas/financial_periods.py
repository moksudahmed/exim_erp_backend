from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal
from typing import List, Dict
from pydantic import BaseModel
from datetime import date, datetime
from typing import Optional

class FinancialPeriodBase(BaseModel):
    name: str
    start_date: date
    end_date: date

class FinancialPeriodCreate(FinancialPeriodBase):
    pass

class FinancialPeriod(FinancialPeriodBase):
    id: int
    is_closed: bool
    closed_at: Optional[datetime]
    closed_by: Optional[int]
    
    class Config:
        orm_mode = True