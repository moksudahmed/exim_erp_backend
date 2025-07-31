from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import select, func, update
from app.db.session import get_db
from app.models.payment import Payment
from app.schemas.payment import PaymentCreate, PaymentSchema
from app.schemas import payment as payment_schema
from app.models.enum_types import PaymentMethod
from typing import List
from app.models import payment as payment_model
from sqlalchemy import select, func
from app.models.sale import Sale
from app.models.enum_types import PaymentStatus
from decimal import Decimal  # ⬅️ import this at the top if not already

router = APIRouter()

@router.post("/", response_model=PaymentSchema)
async def create_payment(payment: PaymentCreate, db: AsyncSession = Depends(get_db)):
    db_payment = Payment(**payment.dict())
    db.add(db_payment)
    await db.commit()
    await db.refresh(db_payment)
    return db_payment

@router.post("/customer-payment", response_model=PaymentSchema) 
async def create_payment(payment: PaymentCreate, db: AsyncSession = Depends(get_db)):
    # Insert the payment
    db_payment = Payment(**payment.dict())
    db.add(db_payment)
    await db.flush()  # flush to get access to payment.sale_id if needed

    # Fetch the total paid so far for this sale
    result = await db.execute(
        select(func.coalesce(func.sum(Payment.amount), 0)).where(Payment.sale_id == payment.sale_id)
    )
    total_paid = result.scalar() or Decimal("0.0")  # ensure it's Decimal

    # Convert incoming float to Decimal before adding
    payment_amount_decimal = Decimal(str(payment.amount))
    total_paid += payment_amount_decimal

    # Fetch the sale to get total amount due
    sale_result = await db.execute(select(Sale).where(Sale.id == payment.sale_id))
    sale = sale_result.scalar_one_or_none()

    if not sale:
        raise HTTPException(status_code=404, detail="Sale not found")

    # Determine new payment status
    new_status = PaymentStatus.PAID if total_paid >= sale.total else PaymentStatus.DUE
    print(new_status)
    print(total_paid)
    # Update the sale's payment status
    await db.execute(
        update(Sale)
        .where(Sale.id == sale.id)
        .values(payment_status=new_status)
    )

    await db.commit()
    await db.refresh(db_payment)

    return db_payment

# READ all transactions with pagination
@router.get("/", response_model=List[payment_schema.PaymentResponse])
async def read_payments(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(payment_model.Payment).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    account = result.scalars().all()

    return account
@router.get("/{payment_id}", response_model=PaymentSchema)
async def get_payment(payment_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Payment).where(Payment.id == payment_id))
    payment = result.scalars().first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    return payment


@router.get("/payment-summary/")
async def get_payment_summary(db: AsyncSession = Depends(get_db)):
    stmt = (
        select(Payment.payment_method, func.sum(Payment.amount))
        .group_by(Payment.payment_method)
    )
    result = await db.execute(stmt)
    rows = result.all()

    summary = [
        {method, float(total)}
        for method, total in rows
    ]

    return summary
