from fastapi import APIRouter, Depends, HTTPException, status
from flask import Flask, request, jsonify
from sqlalchemy.orm import Session
from typing import List
from app.models.ledger import Ledger
from app.db.session import get_db
from app.schemas.ledger import (
    Ledger, LedgerCreate, LedgerSchema
    
)
from app.models.ledger import Ledger  # ✅ SQLAlchemy model
from app.schemas.ledger import LedgerSchema  # ✅ Pydantic schema
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.models.financial_report import FinancialReport
from app.schemas.financial_report import FinancialReportOut, FinancialReportBase

router = APIRouter()

@router.get("/ledger/", response_model=List[LedgerSchema])
async def read_ledger_entries(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Ledger).offset(skip).limit(limit))
    entries = result.scalars().all()
    return entries

@router.get("/financial-reports", response_model=List[FinancialReportOut])
async def get_reports(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(FinancialReport))
    reports = result.scalars().all()
    return reports

@router.get("/financial-reports/{id}", response_model=FinancialReportOut)
async def get_report(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(FinancialReport).where(FinancialReport.id == id))
    report = result.scalars().first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    return report

@router.post("/financial-reports", status_code=status.HTTP_201_CREATED)
async def create_report(report_data: FinancialReportBase, db: AsyncSession = Depends(get_db)):
    report = FinancialReport(**report_data.dict())
    db.add(report)
    await db.commit()
    await db.refresh(report)
    return {"message": "Report created", "id": report.id}

@router.put("/financial-reports/{id}")
async def update_report(w, report_data: FinancialReportBase, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(FinancialReport).where(FinancialReport.id == id))
    report = result.scalars().first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    for key, value in report_data.dict().items():
        setattr(report, key, value)

    await db.commit()
    return {"message": "Report updated"}

@router.delete("/financial-reports/{id}")
async def delete_report(id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(FinancialReport).where(FinancialReport.id == id))
    report = result.scalars().first()
    if not report:
        raise HTTPException(status_code=404, detail="Report not found")
    
    await db.delete(report)
    await db.commit()
    return {"message": "Report deleted"}


"""
@router.post("/financial-periods/", response_model=FinancialPeriod)
def create_financial_period_endpoint(
    period: FinancialPeriodCreate, 
    db: Session = Depends(get_db)
):
    return create_financial_period(db=db, period=period)

@router.post("/financial-periods/{period_id}/close/", response_model=FinancialPeriod)
def close_financial_period_endpoint(
    period_id: int, 
    user_id: int,
    db: Session = Depends(get_db)
):
    return close_financial_period(db=db, period_id=period_id, user_id=user_id)

@router.post("/financial-reports/", response_model=FinancialReport)
def create_financial_report_endpoint(
    report: FinancialReportCreate, 
    db: Session = Depends(get_db)
):
    return generate_financial_report(db=db, report=report)

@router.get("/settings/{key}", response_model=AccountingSetting)
def get_setting_endpoint(key: str, db: Session = Depends(get_db)):
    return get_accounting_setting(db=db, key=key)

@router.put("/settings/", response_model=AccountingSetting)
def update_setting_endpoint(
    setting: AccountingSettingCreate, 
    db: Session = Depends(get_db)
):
    return update_accounting_setting(db=db, setting=setting)

    """