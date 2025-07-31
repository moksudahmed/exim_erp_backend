from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime
from typing import Dict, List, Optional
from app.models import FinancialReport
from app.schemas.financial_report import FinancialReportCreate, FinancialReportResponse
from app.models.enum_types import AccountTypeEnum
from sqlalchemy.future import select
from app.services.accounting import AccountingService
from app.models.financial_report import FinancialReport

class FinancialReportService:
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def create_report(self, report_data: FinancialReportCreate) -> FinancialReport:
        db_report = FinancialReport(**report_data.dict())
        self.db.add(db_report)
        await self.db.commit()
        await self.db.refresh(db_report)
        return db_report
    
    async def get_report(self, report_id: int) -> Optional[FinancialReport]:
        result = await self.db.execute(
            select(FinancialReport).where(FinancialReport.id == report_id))
        return result.scalars().first()
    
    async def get_reports_by_type(self, report_type: str, limit: int = 100) -> List[FinancialReportResponse]:
       skip: int = 0       
       result = await self.db.execute(
            select(FinancialReport)
            .where(FinancialReport.type == report_type)
            .order_by(FinancialReport.generated_at.desc())
            .limit(limit)
        )              
       return result.scalars().all()

    async def generate_balance_sheet(self, request_data: Dict, user_id: int) -> Dict:
        """Generate a balance sheet report with actual accounting data"""
        
        accounting_service = AccountingService(self.db)
        as_of_date = request_data['end_date']
        
        # Get account balances (await the async call)
        trial_balance = await accounting_service.generate_trial_balance(as_of_date)
        
        # Categorize accounts with proper type checking
        assets = [item for item in trial_balance 
                 if AccountTypeEnum(item['account_type']) == AccountTypeEnum.ASSET]
        liabilities = [item for item in trial_balance 
                      if AccountTypeEnum(item['account_type']) == AccountTypeEnum.LIABILITY]
        equity = [item for item in trial_balance 
                 if AccountTypeEnum(item['account_type']) == AccountTypeEnum.EQUITY]
        
        # Calculate totals
        total_assets = sum(item['balance'] for item in assets 
                       if item['nature_type'] == 'DEBIT')
        total_liabilities = sum(item['balance'] for item in liabilities 
                           if item['nature_type'] == 'CREDIT')
        total_equity = sum(item['balance'] for item in equity 
                         if item['nature_type'] == 'CREDIT')
        
        report_data = {
            "assets": assets,
            "liabilities": liabilities,
            "equity": equity,
            "totals": {
                "assets": total_assets,
                "liabilities": total_liabilities,
                "equity": total_equity,
                "liabilities_equity": total_liabilities + total_equity
            },
            "generated_at": datetime.now().isoformat(),
            "as_of_date": as_of_date.isoformat()
        }
        
        if request_data.get('save_report'):
            report = FinancialReportCreate(
                name=f"Balance Sheet {as_of_date.strftime('%Y-%m-%d')}",
                type="BALANCE_SHEET",
                end_date=as_of_date,
                data=report_data,
                generated_by=user_id
            )
            return await self.create_report(report)
        
        return report_data

    async def generate_income_statement(self, request_data: Dict, user_id: int) -> Dict:
        """Generate income statement report"""
        from app.services.accounting import AccountingService
        
        accounting_service = AccountingService(self.db)
        start_date = request_data['start_date']
        end_date = request_data['end_date']
        
        # Get account balances (await the async call)
        trial_balance = await accounting_service.generate_trial_balance(end_date)
        
        # Categorize accounts with proper type checking
        revenues = [item for item in trial_balance 
                   if AccountTypeEnum(item['account_type']) == AccountTypeEnum.REVENUE]
        expenses = [item for item in trial_balance 
                   if AccountTypeEnum(item['account_type']) == AccountTypeEnum.EXPENSE]
        
        # Calculate totals
        total_revenue = sum(item['balance'] for item in revenues 
                       if item['normal_balance'] == 'CREDIT')
        total_expenses = sum(abs(item['balance']) for item in expenses 
                         if item['normal_balance'] == 'DEBIT')
        net_income = total_revenue - total_expenses
        
        report_data = {
            "revenues": revenues,
            "expenses": expenses,
            "totals": {
                "revenue": total_revenue,
                "expenses": total_expenses,
                "net_income": net_income
            },
            "generated_at": datetime.now().isoformat(),
            "period": {
                "start": start_date.isoformat(),
                "end": end_date.isoformat()
            }
        }
        
        if request_data.get('save_report'):
            report = FinancialReportCreate(
                name=f"Income Statement {start_date.strftime('%Y-%m-%d')} to {end_date.strftime('%Y-%m-%d')}",
                type="INCOME_STATEMENT",
                start_date=start_date,
                end_date=end_date,
                data=report_data,
                generated_by=user_id
            )
            return await self.create_report(report)
        
        return report_data