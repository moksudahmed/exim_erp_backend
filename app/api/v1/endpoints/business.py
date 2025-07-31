from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.schemas import branches as branch_schema
from app.schemas import business as business_schema
from app.schemas import warehouse as warehouse_schema
from typing import List
from app.models import business as business_model
from app.models import branches as branch_model
from app.models import warehouse as warehouse_model
from app.db.session import get_db
from sqlalchemy.future import select

router = APIRouter()

@router.post("/", response_model=business_schema.Business)
async def create_business(business: business_schema.BusinessCreate, db: AsyncSession = Depends(get_db)):
    new_customer = business_model.Business(**business.dict())      
    db.add(new_customer)
    await db.commit()
    await db.refresh(new_customer)
    return new_customer

# READ all transactions with pagination
@router.get("/", response_model=List[business_schema.BusinessResponse])
async def read_customers(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(business_model.Business).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    customer = result.scalars().all()

    return customer


@router.post("/branch/", response_model=branch_schema.BranchResponse)
async def create_branch(branch: branch_schema.BranchCreate, db: AsyncSession = Depends(get_db)):
    new_branch = branch_model.Branch(**branch.dict())      
    db.add(new_branch)
    await db.commit()
    await db.refresh(new_branch)
    return new_branch

@router.get("/branch/", response_model=List[branch_schema.BranchResponse])
async def read_branches(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(branch_model.Branch).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    branches = result.scalars().all()

    return branches

# Warehouse
@router.post("/warehouses/", response_model=warehouse_schema.WarehouseRead)
def create_warehouse(warehouse: warehouse_schema.WarehouseCreate, db: AsyncSession = Depends(get_db)):
    db_wh = warehouse_model.Warehouse(**warehouse.dict())
    db.add(db_wh)
    db.commit()
    db.refresh(db_wh)
    return db_wh

@router.get("/warehouses/", response_model=List[warehouse_schema.WarehouseRead])
async def read_branches(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(warehouse_model.Warehouse).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    branches = result.scalars().all()

    return branches