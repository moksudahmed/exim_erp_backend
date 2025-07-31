from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from typing import Optional
from sqlalchemy import text
from app.db.session import get_db
from app.models.subsidiary_account import SubsidiaryAccount
from app.schemas.subsidiary_account import (
    SubsidiaryAccountCreate,
    SubsidiaryAccountUpdate,
    SubsidiaryAccountResponse,
    SubsidiaryAccountBankResponse
)
from sqlalchemy.future import select

router = APIRouter()

@router.get("/", response_model=List[SubsidiaryAccountResponse])
async def read_account(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(SubsidiaryAccount).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    account = result.scalars().all()

    return account

@router.get("/{account_id}", response_model=SubsidiaryAccountResponse)
def get_subsidiary_account(account_id: int, db: AsyncSession = Depends(get_db)):
    account = db.query(SubsidiaryAccount).filter(
        SubsidiaryAccount.subsidiary_account_id == account_id).first()
    if not account:
        raise HTTPException(status_code=404, detail="Subsidiary account not found.")
    return account


@router.post("/", response_model=SubsidiaryAccountResponse)
def create_subsidiary_account(
    request: SubsidiaryAccountCreate, db: AsyncSession = Depends(get_db)
):
    new_account = SubsidiaryAccount(**request.dict())
    db.add(new_account)
    db.commit()
    db.refresh(new_account)
    return new_account


@router.put("/{account_id}", response_model=SubsidiaryAccountResponse)
def update_subsidiary_account(
    account_id: int,
    request: SubsidiaryAccountUpdate,
    db: AsyncSession = Depends(get_db)
):
    account = db.query(SubsidiaryAccount).filter(
        SubsidiaryAccount.subsidiary_account_id == account_id).first()
    if not account:
        raise HTTPException(status_code=404, detail="Subsidiary account not found.")

    for key, value in request.dict(exclude_unset=True).items():
        setattr(account, key, value)

    db.commit()
    db.refresh(account)
    return account


@router.delete("/{account_id}")
def delete_subsidiary_account(account_id: int, db: AsyncSession = Depends(get_db)):
    account = db.query(SubsidiaryAccount).filter(
        SubsidiaryAccount.subsidiary_account_id == account_id).first()
    if not account:
        raise HTTPException(status_code=404, detail="Subsidiary account not found.")
    db.delete(account)
    db.commit()
    return {"message": "Subsidiary account deleted successfully."}

@router.get("/bank-accounts/", response_model=List[SubsidiaryAccountBankResponse])
async def get_bank_accounts(db: AsyncSession = Depends(get_db)):
    query = text("""
        SELECT 
          s.subsidiary_account_id, 
          s.account_id, 
          s.account_name, 
          s.account_no, 
          s.address, 
          s.branch, 
          s.account_holder, 
          s.type
        FROM 
          public.subsidiary_account s, 
          public.account a
        WHERE 
          a.account_id = s.account_id AND
          a.account_name = 'Bank A/C';
    """)
    result = await db.execute(query)
    rows = result.mappings().all()  # Returns a list of dictionaries compatible with Pydantic
    return rows