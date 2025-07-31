# api/endpoints/report.py
from fastapi import APIRouter, Depends, HTTPException
from typing import List
from app.db.session import get_db
from app.schemas.financial_report import FinancialReport, FinancialReportRequest, FinancialReportCreate, BalanceSheetResponse,FinancialReportResponse
from app.services.financial_report import FinancialReportService
#from ..dependencies import get_db, get_current_user
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.services.financial_report import FinancialReportService
from datetime import datetime, date  # Add missing datetime import
from app.models.financial_report import FinancialReport
router = APIRouter()

@router.post("/balance-sheet")
async def generate_balance_sheet(
    request: FinancialReportRequest,
    db: AsyncSession = Depends(get_db)
    #user_id: int = Depends(get_current_user)
):
    service = FinancialReportService(db)
    request_data = {
        "end_date": request.end_date,
        "save_report": request.save_report
    }
    user_id =1
    
    return await service.generate_balance_sheet(request_data, user_id)

@router.get("/type/{report_type}", response_model=FinancialReportResponse)
async def get_report_by_type_and_date(
    report_type: str,
    as_of: date,
    db: AsyncSession = Depends(get_db)
):
    valid_types = ["BALANCE_SHEET", "INCOME_STATEMENT", "CASH_FLOW", "TRIAL_BALANCE", "GENERAL_LEDGER"]
    if report_type not in valid_types:
        raise HTTPException(status_code=400, detail="Invalid report type")
    
    # Query for the most recent report matching the criteria
    result = await db.execute(
        select(FinancialReport)
        .where(FinancialReport.type == report_type)
        .where(FinancialReport.end_date == as_of)
        .order_by(FinancialReport.generated_at.desc())
        .limit(1)
    )
    
    report = result.scalars().first()
    
    if not report:
        # Create current timestamp
        current_time = datetime.utcnow()
        
        # Return an empty report structure if none found
        return FinancialReportResponse(
            id=0,
            name=f"{report_type} {as_of}",
            type=report_type,
            start_date=None,
            end_date=as_of,
            generated_at=current_time,
            generated_by=0,
            data={
                "assets": [],
                "liabilities": [],
                "equity": [],
                "totals": {
                    "assets": 0,
                    "liabilities": 0,
                    "equity": 0,
                    "liabilities_equity": 0
                },
                "as_of_date": as_of.isoformat(),
                "generated_at": current_time.isoformat()
            }
        )
    
    return report

@router.get("/type2/{report_type}", response_model=List[FinancialReportResponse])
async def get_reports_by_type(
    report_type: str,
    as_of: date,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    skip: int = 0   
    #result = await db.execute(select(FinancialReport))
    valid_types = ["BALANCE_SHEET", "INCOME_STATEMENT", "CASH_FLOW", "TRIAL_BALANCE", "GENERAL_LEDGER"]
    if report_type not in valid_types:
       raise HTTPException(status_code=400, detail="Invalid report type")    
    
    result = await db.execute(
            select(FinancialReport)
            .where(FinancialReport.type == report_type)
            .order_by(FinancialReport.generated_at.desc())
            .limit(limit)
        )
    reports = result.scalars().all()
    return reports

"""
@router.get("/type2/{report_type}", response_model=List[FinancialReport])
def get_reports_by_type(
    report_type: str,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    
    valid_types = ["BALANCE_SHEET", "INCOME_STATEMENT", "CASH_FLOW", "TRIAL_BALANCE", "GENERAL_LEDGER"]
    if report_type not in valid_types:
        raise HTTPException(status_code=400, detail="Invalid report type")
       
    service = FinancialReportService(db)
    return service.get_reports_by_type(report_type, limit)
"""
"""@router.post("/balance-sheet", response_model=FinancialReport)
def generate_balance_sheet(
    request: FinancialReportRequest,
    db: Session = Depends(get_db)
    #id: int
):
    id = 1
    service = FinancialReportService(db)
    return service.generate_balance_sheet(request.dict(), id)

@router.post("/income-statement", response_model=FinancialReport)
def generate_income_statement(
    request: FinancialReportRequest,
    db: Session = Depends(get_db),
    user_id: int = 1 #Depends(get_current_user)
):
    service = FinancialReportService(db)
    return service.generate_income_statement(request.dict(), user_id)

@router.get("/{report_id}", response_model=FinancialReport)
def get_report(
    report_id: int,
    db: Session = Depends(get_db)
):
    service = FinancialReportService(db)
    report = service.get_report(report_id)
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report

@router.get("/type/{report_type}", response_model=List[FinancialReport])
def get_reports_by_type(
    report_type: str,
    limit: int = 100,
    db: Session = Depends(get_db)
):
    valid_types = ["BALANCE_SHEET", "INCOME_STATEMENT", "CASH_FLOW", "TRIAL_BALANCE", "GENERAL_LEDGER"]
    if report_type not in valid_types:
        raise HTTPException(status_code=400, detail="Invalid report type")
    
    service = FinancialReportService(db)
    return service.get_reports_by_type(report_type, limit)
"""
@router.get("/")
def read_root():
    return {"message": "Welcome to the POS Reports"}
