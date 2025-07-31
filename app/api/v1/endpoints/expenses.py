# backend/routes/expenses.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import insert
from app.models import SubsidiaryAccount
from app.models.journal_entries import JournalEntry
from app.models.journal_items import JournalItems
from app.models.ledger import Ledger
from sqlalchemy.future import select
from app.models import account as account_model
from app.schemas.expense import ExpenseCreate
from app.db.session import get_db
from datetime import datetime
from decimal import Decimal
import uuid
from app.models.ViewJournalEntryDetails import ViewJournalEntryDetails  # ✅ Correct import

router = APIRouter()

@router.post("/", status_code=201)
async def create_expense(entry: ExpenseCreate, db: AsyncSession = Depends(get_db)):
    try:
        ref_no = entry.ref_no or str(uuid.uuid4())

        # Create Journal Entry
        new_entry = JournalEntry(
            ref_no=ref_no,
            account_type='EXPENSE',
            company="Main Office",
            transaction_date=entry.transaction_date,
            description=entry.description,
            user_id=1  # should be taken from auth context
        )
        db.add(new_entry)
        await db.flush()

        # Debit expense account
        expense_item = JournalItems(
            journal_entry_id=new_entry.id,
            narration=entry.narration,
            debitcredit='DEBIT',
            amount=Decimal(entry.amount),
            account_id=entry.account_id,
            subsidiary_account_id=entry.subsidiary_account_id,
        )
        db.add(expense_item)
        await db.flush()

        # Credit cash/bank account (hardcoded account_id = 2 for example)
        credit_item = JournalItems(
            journal_entry_id=new_entry.id,
            narration="Cash/Bank Payment",
            debitcredit='CREDIT',
            amount=Decimal(entry.amount),
            account_id=2
        )
        db.add(credit_item)
        await db.flush()

        # Ledger entries
        db.add(Ledger(
            account_id=expense_item.account_id,
            journal_item_id=expense_item.id,
            entry_date=entry.transaction_date,
            amount=expense_item.amount,
            balance=0,
            type='DEBIT'
        ))
        db.add(Ledger(
            account_id=credit_item.account_id,
            journal_item_id=credit_item.id,
            entry_date=entry.transaction_date,
            amount=credit_item.amount,
            balance=0,
            type='CREDIT'
        ))

        await db.commit()
        return {"message": "Expense recorded successfully", "ref_no": ref_no}

    except Exception as e:
        await db.rollback()
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=str(e))


@router.get("/statements2/{subsidiary_account_id}")
async def get_subsidiary_account_statement(subsidiary_account_id: int, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(ViewJournalEntryDetails)
        .where(ViewJournalEntryDetails.subsidiary_account_id == subsidiary_account_id)
        .order_by(ViewJournalEntryDetails.transaction_date.asc())
    )
    result = await db.execute(stmt)
    rows = result.fetchall()

    if not rows:
        raise HTTPException(status_code=404, detail="No entries found for the selected subsidiary account.")

    balance = 0
    statement = []

    for row in rows:
        debit = float(row.amount) if row.debitcredit == 'DEBIT' else 0
        credit = float(row.amount) if row.debitcredit == 'CREDIT' else 0
        balance += debit - credit

        statement.append({
            "date": row.transaction_date,
            "ref_no": row.ref_no,
            "description": row.journal_description,
            "narration": row.narration,
            "debit": debit,
            "credit": credit,
            "balance": round(balance, 2),
            "main_account": {
                "code": row.main_account_code,
                "name": row.main_account_name
            },
            "subsidiary_account": {
                "name": row.subsidiary_account_name,
                "number": row.subsidiary_account_no,
                "holder": row.subsidiary_holder,
                "branch": row.subsidiary_branch,
                "type": row.subsidiary_type
            }
        })

    return {
        "subsidiary_account_id": subsidiary_account_id,
        "subsidiary_account_name": rows[0].subsidiary_account_name,
        "subsidiary_account_number": rows[0].subsidiary_account_no,
        "statement": statement
    }


@router.get("/statements/{subsidiary_account_id}")
async def get_subsidiary_account_statement(subsidiary_account_id: int, db: AsyncSession = Depends(get_db)):
    try:
        stmt = select(ViewJournalEntryDetails).where(
            ViewJournalEntryDetails.subsidiary_account_id == subsidiary_account_id
        ).order_by(ViewJournalEntryDetails.transaction_date)
        result = await db.execute(stmt)
        entries = result.scalars().all()

        if not entries:
            raise HTTPException(status_code=404, detail="No entries found for this subsidiary account.")

        return entries

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))