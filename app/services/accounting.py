# services/accounting.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, case, and_
from datetime import date
from typing import List, Dict, Any, Optional
from app.models import Account, JournalItems
from app.models.enum_types import AccountTypeEnum
from app.models.enum_types import AccountAction

class AccountingService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def generate_trial_balance(self, as_of_date: date = None) -> List[Dict[str, Any]]:
        """Generate trial balance data for report generation"""
        stmt = select(
            Account.account_id.label("account_id"),
            Account.account_name.label("account_name"),
            Account.code.label("account_code"),
            Account.account_type.label("account_type"),
            Account.nature_type.label("nature_type"),
            func.sum(
                case(
                    (JournalItems.debitcredit == AccountAction.DEBIT, JournalItems.amount),
                    (JournalItems.debitcredit == AccountAction.CREDIT, -JournalItems.amount),
                    else_=0
                )
            ).label("balance")
        ).join(JournalItems, Account.account_id == JournalItems.account_id)
        
        if as_of_date:
            stmt = stmt.where(JournalItems.created_at <= as_of_date)
        
        stmt = stmt.group_by(
            Account.account_id,
            Account.account_name,
            Account.code,
            Account.account_type,
            Account.nature_type
        )
        
        result = await self.db.execute(stmt)
        rows = result.all()
        print("Hello")
        print(rows)
        return [{
            "account_id": r.account_id,
            "account_name": r.account_name,
            "account_code": r.account_code,
            "account_type": r.account_type.value,  # Get the string value of the enum
            "nature_type": r.nature_type.value,    # Get the string value of the enum
            "balance": float(r.balance) if r.balance else 0.0
        } for r in rows]
    
    async def get_account_balance(
        self, 
        account_id: int, 
        start_date: date = None, 
        end_date: date = None
    ) -> float:
        """Get the balance of a specific account within a date range"""
        stmt = select(
            func.sum(
                case(
                    (JournalItems.debitcredit == AccountAction.DEBIT, JournalItems.amount),
                    (JournalItems.debitcredit == AccountAction.CREDIT, -JournalItems.amount),
                    else_=0
                )
            )
        ).where(JournalItems.account_id == account_id)
        
        if start_date:
            stmt = stmt.where(JournalItems.created_at >= start_date)
        if end_date:
            stmt = stmt.where(JournalItems.created_at <= end_date)
        
        result = await self.db.execute(stmt)
        balance = result.scalar()
        return float(balance) if balance else 0.0
    
    async def get_account_balances_by_type(
        self,
        account_type: AccountTypeEnum,
        as_of_date: date = None
    ) -> List[Dict[str, Any]]:
        """Get all account balances of a specific type"""
        stmt = select(
            Account.account_id.label("account_id"),
            Account.account_name.label("account_name"),
            Account.code.label("account_code"),
            func.sum(
                case(
                    (JournalItems.debitcredit == AccountAction.DEBIT, JournalItems.amount),
                    (JournalItems.debitcredit == AccountAction.CREDIT, -JournalItems.amount),
                    else_=0
                )
            ).label("balance")
        ).join(JournalItems, Account.account_id == JournalItems.account_id) \
         .where(Account.account_type == account_type)
        
        if as_of_date:
            stmt = stmt.where(JournalItems.created_at <= as_of_date)
        
        stmt = stmt.group_by(Account.account_id, Account.account_name, Account.code)
        
        result = await self.db.execute(stmt)
        rows = result.all()
        
        return [{
            "account_id": r.account_id,
            "account_name": r.account_name,
            "account_code": r.account_code,
            "balance": float(r.balance) if r.balance else 0.0
        } for r in rows]