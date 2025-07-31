
# FastAPI Endpoint (api/v1/endpoints/delivery.py)

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_db
from app.models.delivery import Delivery
from app.schemas.delivery import DeliveryCreate, DeliveryRead
from sqlalchemy.future import select

router = APIRouter()

@router.post("/", response_model=DeliveryRead)
async def create_delivery(delivery: DeliveryCreate, db: AsyncSession = Depends(get_db)):
    new_delivery = Delivery(**delivery.dict())
    db.add(new_delivery)
    await db.commit()
    await db.refresh(new_delivery)
    return new_delivery

@router.get("/{sale_id}", response_model=list[DeliveryRead])
async def get_deliveries_by_sale(sale_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Delivery).where(Delivery.sale_id == sale_id))
    deliveries = result.scalars().all()
    return deliveries
