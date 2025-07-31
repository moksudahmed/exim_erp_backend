from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas import customer as customer_schema
from typing import List
from app.models import customer as customer_model
from app.db.session import get_db
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import Depends
from app.models import Customer, Sale, Payment  # adjust as needed
from fastapi import APIRouter, Depends, Query
from decimal import Decimal

router = APIRouter()

@router.post("/", response_model=customer_schema.Customer)
async def create_customer(customer: customer_schema.CustomerCreate, db: AsyncSession = Depends(get_db)):
    new_customer = customer_model.Customer(**customer.dict())      
    db.add(new_customer)
    await db.commit()
    await db.refresh(new_customer)
    return new_customer

# READ all transactions with pagination
@router.get("/", response_model=List[customer_schema.CustomerResponse])
async def read_customers(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(customer_model.Customer).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    customer = result.scalars().all()

    return customer

# READ all transactions with pagination
@router.get("/{id}", response_model=customer_schema.CustomerResponse)
async def read_customer_reocrd(id: int, db: AsyncSession = Depends(get_db)):    
    result = await db.execute(select(customer_model.Customer).filter(customer_model.Customer.id == id))
    customer = result.scalars().first()    
    return customer

@router.get("/customer-payments")
async def fetch_customer_payment_info(db: AsyncSession = Depends(get_db)):
    stmt = (
        select(
            Customer.id,
            Customer.name,
            Customer.contact_info,
            Sale.total,
            Sale.discount,
            Sale.payment_status,
            Payment.payment_date,
            Payment.payment_method,
            Payment.amount
        )
        .join(Sale, Customer.id == Sale.customer_id)
        .join(Payment, Sale.id == Payment.sale_id)
    )

    result = await db.execute(stmt)
    records = result.fetchall()

    # Optional: convert to list of dicts
    return [dict(row._mapping) for row in records]

@router.get("/customer-payments/{id}")
async def fetch_customer_payment_info(id: int, db: AsyncSession = Depends(get_db)):
    print("HELLO")
    print(id)
    stmt = (
        select(
            Customer.id,
            Customer.name,
            Customer.contact_info,
            Sale.total,
            Sale.discount,
            Sale.payment_status,
            Payment.payment_date,
            Payment.payment_method,
            Payment.amount
        )
        .join(Sale, Customer.id == Sale.customer_id)
        .join(Payment, Sale.id == Payment.sale_id)
        .where(Customer.id == id)
    )

    result = await db.execute(stmt)
    records = result.fetchall()

    return [dict(row._mapping) for row in records]

@router.get("/customer-due/{customer_id}")
async def get_customer_due(customer_id: int, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(
            Sale.total,
            Sale.discount,
            Payment.amount
        )
        .join(Customer, Customer.id == Sale.customer_id)
        .join(Payment, Payment.sale_id == Sale.id)
        .where(Customer.id == customer_id)
    )

    result = await db.execute(stmt)
    rows = result.fetchall()

    # Use Decimal for all monetary calculations
    total_sales = Decimal('0.0')
    total_discount = Decimal('0.0')
    total_paid = Decimal('0.0')

    for row in rows:
        total_sales += Decimal(str(row.total or 0))
        total_discount += Decimal(str(row.discount or 0))
        total_paid += Decimal(str(row.amount or 0))

    due = total_sales - total_discount + total_paid

    return {
        "customer_id": customer_id,
        "total_sales": float(total_sales),
        "total_discount": float(total_discount),
        "total_paid": float(total_paid),
        "balance_due": float(due),
    }

@router.get("/customer-summary")
async def get_customer_count(db: AsyncSession = Depends(get_db)):
    stmt = select(func.count(Customer.id))
    result = await db.execute(stmt)
    count = result.scalar_one()
    return {count}