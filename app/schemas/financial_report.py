from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from decimal import Decimal
from typing import List, Dict
from datetime import date, datetime

# schemas/report.py
from datetime import date
from typing import Optional
from pydantic import BaseModel

class FinancialReportBase(BaseModel):
    name: str
    type: str
    period_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    data: dict

class FinancialReportCreate(FinancialReportBase):
    generated_by: int

"""class FinancialReport(FinancialReportBase):
    id: int
    generated_at: date
    generated_by: int
    
    class Config:
        orm_mode = True"""

class FinancialReportRequest(BaseModel):
    start_date: date
    end_date: date
    save_report: bool = False

# Financial Report Schema

"""class FinancialReportCreate(FinancialReportBase):
    report_type: str
    data: Dict
    user_id: int  # Added user_id"""

class FinancialReport(FinancialReportBase):
    name: str
    type: str
    period_id: Optional[int]
    start_date: Optional[date]
    end_date: Optional[date]
    data: dict
    
    class Config:
        orm_mode = True


class FinancialReportOut(BaseModel):    
    name: str
    type: str
    period_id: Optional[int]
    start_date: Optional[date]
    end_date: Optional[date]
    data: dict
    
    class Config:
        orm_mode = True  # Old config for Pydantic 1.x


class TrialBalanceAccount(BaseModel):
    """Represents an account in the trial balance"""
    account_id: int
    name: str
    code: str
    type: str
    debit: float
    credit: float

class TrialBalanceResponse(BaseModel):
    """Response model for trial balance report"""
    date: date
    accounts: List[TrialBalanceAccount]
    total_debit: float
    total_credit: float

class BalanceSheetSection(BaseModel):
    """Represents a line item in a balance sheet section"""
    account_id: int
    name: str
    code: str
    amount: float

class BalanceSheetResponse(BaseModel):
    """Response model for balance sheet report"""
    date: date
    assets: List[BalanceSheetSection]
    liabilities: List[BalanceSheetSection]
    equity: List[BalanceSheetSection]
    total_assets: float
    total_liabilities: float
    total_equity: float
    total_liabilities_equity: float

class IncomeStatementSection(BaseModel):
    """Represents a line item in the income statement"""
    account_id: int
    name: str
    code: str
    amount: float

class IncomeStatementResponse(BaseModel):
    """Response model for income statement report"""
    start_date: date
    end_date: date
    revenues: List[IncomeStatementSection]
    expenses: List[IncomeStatementSection]
    total_revenue: float
    total_expenses: float
    net_income: float

class CashFlowSection(BaseModel):
    """Represents a line item in a cash flow section"""
    account_id: int
    name: str
    code: str
    amount: float

class CashFlowResponse(BaseModel):
    """Response model for cash flow statement"""
    start_date: date
    end_date: date
    operating: List[CashFlowSection]
    investing: List[CashFlowSection]
    financing: List[CashFlowSection]
    net_operating: float
    net_investing: float
    net_financing: float
    net_cash_change: float
    beginning_cash_balance: float
    ending_cash_balance: float


class FinancialReportResponse(BaseModel):
    """Response model for a saved financial report"""
    id: int
    name: str
    type: str
    start_date: Optional[date] = None
    end_date: Optional[date] = None    
    generated_at: datetime
    generated_by: int
    data: dict

    class Config:
        orm_mode = True