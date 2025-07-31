from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas import journal_entries as journal_entries_schema
from app.models.journal_entries import JournalEntry
from app.models.journal_items import JournalItems
from app.schemas.journal_entries import LedgerWithEntryRequest
from app.schemas.journal_entries import (
    JournalEntryCreate, JournalEntryUpdate, JournalEntry as JournalEntrySchema
)
from app.models.ledger import Ledger
from app.schemas.journal_items import (
    JournalItemsCreate, JournalItemsUpdate, JournalItems as JournalItemsSchema
)
from app.schemas import account as account_schema
from app.models import account as account_model
from typing import List
from sqlalchemy.orm import selectinload  # Import this for loading related objects
from sqlalchemy import text
from decimal import Decimal

router = APIRouter()



async def get_account_balance(db: AsyncSession, account_id: int) -> Decimal:
    result = await db.execute(
        select(Ledger).where(Ledger.account_id == account_id).order_by(Ledger.id.desc())
    )
    last_entry = result.scalars().first()
    return last_entry.balance if last_entry else Decimal("0.0")



@router.post("/ledger-with-entry/", status_code=status.HTTP_201_CREATED)
async def create_ledger_with_entry(
    entry_data: LedgerWithEntryRequest, 
    db: AsyncSession = Depends(get_db)
):
    try:
        # Validate debit/credit balance
        debit_total = sum(item.amount for item in entry_data.journal_items if item.debitcredit == 'DEBIT')
        credit_total = sum(item.amount for item in entry_data.journal_items if item.debitcredit == 'CREDIT')
        
        if abs(debit_total - credit_total) > 0.01:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Debits and credits must balance"
            )
        
        # Create new Journal Entry
        db_entry = JournalEntry(  
            ref_no=entry_data.ref_no,
            account_type=entry_data.account_type.value.lower(),
            company=entry_data.company,
            description=entry_data.description,
            transaction_date=entry_data.transaction_date,
            user_id=entry_data.user_id
        )
        #print(db_entry.account_type)
        db.add(db_entry)
        await db.flush()  # Properly await the flush
        # Process journal items
        journal_items = []
        for journal in entry_data.journal_items:
            # Create Journal Item
            db_item = JournalItems(
                narration=journal.narration,
                debitcredit= journal.debitcredit,
                amount=journal.amount,
                account_id=journal.account_id,
                journal_entry_id=db_entry.id,  # Link to the journal entry
                subsidiary_account_id=db_entry.subsidiary_account_id
            )
            db.add(db_item)
            await db.flush()
            journal_items.append(db_item)

            # Calculate new balance
            current_balance = await get_account_balance(db, journal.account_id)
            amount = Decimal(journal.amount)
            new_balance = current_balance + amount if journal.debitcredit == 'DEBIT' else current_balance - amount

            #new_balance = current_balance + journal.amount if journal.debitcredit == 'DEBIT' else current_balance - journal.amount

            # Create Ledger Entry
            ledger_entry = Ledger(
                account_id=journal.account_id,
                journal_item_id=db_item.id,
                entry_date=entry_data.transaction_date,
                amount=journal.amount,
                balance=new_balance,
                type=journal.debitcredit  # Use the actual type from journal item
            )
            db.add(ledger_entry)

        # Commit all changes
        await db.commit()

        # Refresh objects to get updated data
        await db.refresh(db_entry)
        for item in journal_items:
            await db.refresh(item)

        return {
            "message": "Journal entry created successfully",
            "journal_entry": db_entry,
            "journal_items": journal_items
        }

    except Exception as e:
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )    # Query and return the created ledger with linked journal entries
    """ result = await db.execute(
        select(JournalEntry).options(selectinload(JournalEntry.journal_items)).filter_by(id=new_ledger.id)
    )
    created_ledger = result.scalars().first()

    return {
        "journal_entries": created_ledger,
        "journal_items": created_ledger.journal_items  # Return all linked journal entries
    }"""

@router.post("/general-ledger/", response_model=JournalEntrySchema, status_code=status.HTTP_201_CREATED)
async def create_journal_entries(
    ledger: JournalEntryCreate, db: AsyncSession = Depends(get_db)
):
    new_ledger = JournalEntry(
        account_name=ledger.account_name,
        account_type=ledger.account_type.value.lower(),  # Convert to lowercase before saving
        debit=ledger.debit,
        credit=ledger.credit,
        user_id=ledger.user_id
    )
    db.add(new_ledger)
    await db.commit()
    await db.refresh(new_ledger)
    return new_ledger

@router.post("/general-ledger-journals/", response_model=JournalEntrySchema, status_code=status.HTTP_201_CREATED)
async def create_journal_entries_with_journals(
    ledger: JournalEntryCreate, db: AsyncSession = Depends(get_db)
):
    new_ledger = JournalEntry(
        account_name=ledger.account_name,
        account_type=ledger.account_type.value.lower(),  # Convert to lowercase before saving
        debit=ledger.debit,
        credit=ledger.credit,
        user_id=ledger.user_id
    )

    
    db.add(new_ledger)
    await db.commit()
    await db.refresh(new_ledger)
    return new_ledger


@router.get("/general-ledger/", response_model=List[journal_entries_schema.JournalEntry])
async def get_journal_entries(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(JournalEntry).options(selectinload(JournalEntry.journal_items)))
    ledger = result.scalars().all()
    return ledger



@router.get("/journal-items/", response_model=List[JournalItemsSchema])
async def get_journal_item_list(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(JournalItems).options(selectinload(JournalItems.journal_entries)))
    journals = result.scalars().all()
    return journals


@router.get("/general-ledger/{ledger_id}", response_model=JournalEntrySchema)
async def get_journal_entries(ledger_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(JournalEntry).filter(JournalEntry.id == ledger_id))
    ledger = result.scalars().first()
    if not ledger:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="General Ledger not found")
    return ledger


@router.put("/general-ledger/{ledger_id}", response_model=JournalEntrySchema)
async def update_journal_entries(
    ledger_id: int, ledger_update: JournalEntryUpdate, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(JournalEntry).filter(JournalEntry.id == ledger_id))
    ledger = result.scalars().first()
    if not ledger:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="General Ledger not found")

    ledger.account_name = ledger_update.account_name or ledger.account_name
    ledger.account_type = ledger_update.account_type or ledger.account_type
    ledger.debit = ledger_update.debit or ledger.debit
    ledger.credit = ledger_update.credit or ledger.credit

    db.add(ledger)
    await db.commit()
    await db.refresh(ledger)
    return ledger


@router.delete("/general-ledger/{ledger_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_journal_entries(ledger_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(JournalEntry).filter(JournalEntry.id == ledger_id))
    ledger = result.scalars().first()
    if not ledger:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="General Ledger not found")
    
    await db.delete(ledger)
    await db.commit()
    return {"message": "General Ledger deleted successfully"}


# Journal Entry Endpoints
@router.post("/journal-items/", response_model=JournalItemsSchema, status_code=status.HTTP_201_CREATED)
async def create_journal_items(
    entry: JournalItemsCreate, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(JournalEntry).filter(JournalEntry.id == entry.journal_entries_id))
    journal_entries = result.scalars().first()
    if not journal_entries:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="General Ledger not found")

    new_entry = JournalItems(
        entry_type=entry.entry_type,        
        debit=entry.debit,  # Use debit instead of amount
        credit=entry.credit,  # Add credit to the entry
        description=entry.description,     
        transaction_date= entry.transaction_date,  # Add transaction date
        journal_entries_id= entry.journal_entries_id
    )

    
    
    db.add(new_entry)
    await db.commit()
    await db.refresh(new_entry)
    return new_entry

@router.get("/journal-items/{entry_id}", response_model=JournalItemsSchema)
async def get_journal_items(entry_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(JournalItems).filter(JournalItems.id == entry_id))
    entry = result.scalars().first()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Journal Entry not found")
    return entry


@router.put("/journal-items/{entry_id}", response_model=JournalItemsSchema)
async def update_journal_items(
    entry_id: int, entry_update: JournalItemsUpdate, db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(JournalItems).filter(JournalItems.id == entry_id))
    entry = result.scalars().first()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Journal Entry not found")

    entry.entry_type = entry_update.entry_type or entry.entry_type
    entry.amount = entry_update.amount or entry.amount
    entry.description = entry_update.description or entry.description

    db.add(entry)
    await db.commit()
    await db.refresh(entry)
    return entry


@router.delete("/journal-items/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_journal_items(entry_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(JournalItems).filter(JournalItems.id == entry_id))
    entry = result.scalars().first()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Journal Entry not found")

    await db.delete(entry)
    await db.commit()
    return {"message": "Journal Entry deleted successfully"}

@router.get("/ledger-summary/", status_code=status.HTTP_200_OK)
async def get_summary(db: AsyncSession = Depends(get_db)):
    sql = text('SELECT g.account_type, sum(journal_items.amount) FROM public.journal_entries g, public.journal_items WHERE g.id = journal_items.journal_entries_id GROUP BY g.account_type')
    result = await db.execute(sql)
    rows = result.fetchall()

    # Retrieve column names from the result's metadata
    column_names = result.keys()

    # Convert each row to a dictionary
    ledger_entries = [dict(zip(column_names, row)) for row in rows]

    return {"ledger_entries": ledger_entries}

# Get a single account by ID
@router.get("/account/{account_id}", response_model=account_schema.AccountResponse)
async def read_account(account_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(account_model.Account).filter(account_model.Account.account_id == account_id))
    account = result.scalars().first()   
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    return account