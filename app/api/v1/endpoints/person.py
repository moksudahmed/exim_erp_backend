from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List

from app.db.session import get_db
from app.schemas import person as person_schema
from app.models import person as person_model

router = APIRouter()


# Create Person
@router.post("/", response_model=person_schema.PersonResponse)
async def create_person(person: person_schema.PersonCreate, db: AsyncSession = Depends(get_db)):
    new_person = person_model.Person(**person.dict())
    db.add(new_person)
    await db.commit()
    await db.refresh(new_person)
    return new_person


# Get all persons
@router.get("/", response_model=List[person_schema.PersonResponse])
async def read_persons(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(person_model.Person).offset(skip).limit(limit)
    result = await db.execute(stmt)
    persons = result.scalars().all()
    return persons


# Get a single person by ID
@router.get("/{person_id}", response_model=person_schema.PersonResponse)
async def read_person(person_id: int, db: AsyncSession = Depends(get_db)):
    stmt = select(person_model.Person).where(person_model.Person.person_id == person_id)
    result = await db.execute(stmt)
    person = result.scalar_one_or_none()
    if not person:
        raise HTTPException(status_code=404, detail="Person not found")
    return person


# Update a person by ID
@router.put("/{person_id}", response_model=person_schema.PersonResponse)
async def update_person(person_id: int, person_update: person_schema.PersonUpdate, db: AsyncSession = Depends(get_db)):
    stmt = select(person_model.Person).where(person_model.Person.person_id == person_id)
    result = await db.execute(stmt)
    db_person = result.scalar_one_or_none()

    if not db_person:
        raise HTTPException(status_code=404, detail="Person not found")

    for key, value in person_update.dict(exclude_unset=True).items():
        setattr(db_person, key, value)

    await db.commit()
    await db.refresh(db_person)
    return db_person


# Delete a person
@router.delete("/{person_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_person(person_id: int, db: AsyncSession = Depends(get_db)):
    stmt = select(person_model.Person).where(person_model.Person.person_id == person_id)
    result = await db.execute(stmt)
    db_person = result.scalar_one_or_none()

    if not db_person:
        raise HTTPException(status_code=404, detail="Person not found")

    await db.delete(db_person)
    await db.commit()
    return None
