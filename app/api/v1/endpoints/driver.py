
# === api/v1/endpoints/driver.py ===
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.session import get_db
from app.models.driver import Driver
from app.schemas.driver import DriverCreate, DriverOut

router = APIRouter()

@router.post("/", response_model=DriverOut)
async def create_driver(driver: DriverCreate, db: AsyncSession = Depends(get_db)):
    db_driver = Driver(**driver.dict())
    db.add(db_driver)
    await db.commit()
    await db.refresh(db_driver)
    return db_driver

@router.get("/", response_model=list[DriverOut])
async def get_drivers(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Driver))
    return result.scalars().all()