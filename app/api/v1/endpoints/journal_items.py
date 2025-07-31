from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from typing import List
from sqlalchemy.future import select
from app.schemas.journal_items import JournalItems, JournalItemsCreate, JournalItemsUpdate
from app.models.journal_items import JournalItems as JournalItemsModel
from sqlalchemy.orm import selectinload  # Import this for loading related objects

router = APIRouter()

# Get all journal entries
@router.get("/", response_model=List[JournalItems])
async def get_journal_items(skip: int = 0, limit: int = 10, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(JournalItemsModel).offset(skip).limit(limit)
    )
    return result.scalars().all()

# Get a single journal entry by ID
@router.get("/{entry_id}", response_model=JournalItems)
async def get_journal_items(entry_id: int, db: AsyncSession = Depends(get_db)):
    entry = await db.get(JournalItemsModel, entry_id)
    if not entry:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    return entry

# Get a single journal entry by ID
@router.get("/account/{account_id}", response_model=list[JournalItems]) 
async def get_journal_items(account_id: int, db: AsyncSession = Depends(get_db)):   
    result = await db.execute(
        select(JournalItemsModel)
        .options(selectinload(JournalItemsModel.account))
        .filter(JournalItemsModel.account_id == account_id)
    )
    accounts = result.scalars().all()  
    if not accounts:
        raise HTTPException(status_code=404, detail="No journal entries found for the given account_id")
    return accounts

# Create a new journal entry
@router.post("/journal-items/", response_model=JournalItems)
async def create_journal_items(entry_data: JournalItemsCreate, db: AsyncSession = Depends(get_db)):
    new_entry = JournalItemsModel(**entry_data.dict())
    db.add(new_entry)
    await db.commit()
    await db.refresh(new_entry)
    return new_entry

# Update an existing journal entry
@router.put("/journal-items/{entry_id}", response_model=JournalItems)
async def update_journal_items(entry_id: int, entry_data: JournalItemsUpdate, db: AsyncSession = Depends(get_db)):
    entry = await db.get(JournalItemsModel, entry_id)
    if not entry:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    
    for key, value in entry_data.dict(exclude_unset=True).items():
        setattr(entry, key, value)
    
    await db.commit()
    await db.refresh(entry)
    return entry

# Delete a journal entry
@router.delete("/journal-items/{entry_id}")
async def delete_journal_items(entry_id: int, db: AsyncSession = Depends(get_db)):
    entry = await db.get(JournalItemsModel, entry_id)
    if not entry:
        raise HTTPException(status_code=404, detail="Journal entry not found")
    
    await db.delete(entry)
    await db.commit()
    return {"detail": "Journal entry deleted"}
