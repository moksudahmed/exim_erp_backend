from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List, Optional
from sqlalchemy.exc import SQLAlchemyError
from app.schemas import account as account_schema
from app.schemas import letter_of_credit as letter_of_credit_schema
from app.models import letter_of_credit as letter_of_credit_model
from app.schemas import lc_goods_receipt as lc_goods_receipt_schema
from app.schemas import lc_final_payment as lc_final_payment_schema
from app.schemas import lc_goods_shipment as lc_goods_shipment_schema
from app.schemas import lc_realization as lc_realization_schema
from app.schemas import lc_issuance as lc_issuance_schema
from app.models import lc_final_payment as lc_final_payment_model
from app.models import lc_goods_receipt as lc_goods_receipt_model
from app.models import lc_realization as lc_realization_model
from app.db.session import get_db
from app.services.CashFlowService import CashFlowService
from app.models.enum_types import AccountTypeEnum
from app.schemas import lc_margin_payment as lc_margin_payment_schema
from app.models import lc_margin_payment as lc_margin_payment_model
from app.models import lc_goods_shipment as lc_goods_shipment_model
from app.models import lc_issuance as lc_issuance_model
from decimal import Decimal
from sqlalchemy.sql import func

router = APIRouter()

# Simulate DB
LC_DATA = [
    {
        "id": 1,
        "lc_number": "LC-202507001",
        "supplier_name": "Global Steel Ltd.",
        "issue_date": "2025-07-01",
        "amount": 500000,
        "margin": 100000,
        "status": "PAID",
    },
    {
        "id": 2,
        "lc_number": "LC-202507002",
        "supplier_name": "Nippon Electronics",
        "issue_date": "2025-07-03",
        "amount": 750000,
        "margin": 150000,
        "status": "GOODS_RECEIVED",
    },
    {
        "id": 3,
        "lc_number": "LC-202507003",
        "supplier_name": "Eastern Cables",
        "issue_date": "2025-07-10",
        "amount": 300000,
        "margin": 50000,
        "status": "ISSUED",
    },
]
@router.post("/", response_model=letter_of_credit_schema.LetterOfCreditResponse)
async def create_lc_record(lc: letter_of_credit_schema.LetterOfCreditCreate, 
                               margin_payment: lc_margin_payment_schema.LCMarginPaymentCreate, db: AsyncSession = Depends(get_db)):
    new_lc = letter_of_credit_model.LetterOfCredit(**lc.dict())
    db.add(new_lc)
    await db.flush()  # So we can get new_lc.id before committing
    new_margin = lc_margin_payment_model.LCMarginPayment(
            lc_id=new_lc.id,
            amount= margin_payment.amount,
            payment_date= margin_payment.payment_date,
            account_id=margin_payment.account_id   
        )
    db.add(new_margin)
    await db.commit()
    await db.refresh(new_lc)
    await db.refresh(new_margin)  
    return {
        "letter_of_credit": new_lc,
        "margin_payment": new_margin
    }

@router.post("/old", response_model=letter_of_credit_schema.LetterOfCreditResponse)
async def create_lc_record_old(lc: letter_of_credit_schema.LetterOfCreditCreate, db: AsyncSession = Depends(get_db)):
    new_lc = letter_of_credit_model.LetterOfCredit(**lc.dict())
    db.add(new_lc)
    await db.flush()  # So we can get new_lc.id before committing
    new_margin = lc_margin_payment_model.LCMarginPayment(
            lc_id=new_lc.id,
            amount= new_lc.margin_amount,
            payment_date= new_lc.issue_date,
            account_id=new_lc.bank_id,            
        )
    db.add(new_margin)
    await db.commit()
    await db.refresh(new_lc)
    await db.refresh(new_margin)
    return {
        "letter_of_credit": new_lc,
        "margin_payment": new_margin
    }

# READ all transactions with pagination
@router.get("/", response_model=List[letter_of_credit_schema.LetterOfCreditResponse])
async def read_transactions(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(letter_of_credit_model.LetterOfCredit).offset(skip).limit(limit)
    
    # Execute query asynchronously
    result = await db.execute(stmt)
    lc = result.scalars().all()

    return lc

@router.get("/margin-payment/{lc_no}", response_model=List[lc_margin_payment_schema.LCMarginPaymentResponse])
async def read_margin_payment(lc_no: int, db: AsyncSession = Depends(get_db)):
    stmt = select(lc_margin_payment_model.LCMarginPayment).where(
        lc_margin_payment_model.LCMarginPayment.lc_id == lc_no
    )
    result = await db.execute(stmt)
    lc = result.scalars().all()
    return lc

# Get a single account by ID
@router.get("/{ref_no}", response_model=letter_of_credit_schema.LetterOfCreditResponse)
async def get_payment(ref_no: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(letter_of_credit_model.LetterOfCredit).where(letter_of_credit_model.LetterOfCredit.reference_no == ref_no))
    lc = result.scalars().first()
    if not lc:
        raise HTTPException(status_code=404, detail="LC not found")
    return lc



@router.get("/234", response_model=List[letter_of_credit_schema.LetterOfCreditResponse])
def get_lc_records(
    supplier: Optional[str] = None,
    status: Optional[str] = None,
    month: Optional[int] = None,
    year: Optional[int] = None,
):
    records = LC_DATA
    if supplier:
        records = [r for r in records if r["supplier_name"] == supplier]
    if status:
        records = [r for r in records if r["status"] == status]
    if month:
        records = [r for r in records if int(r["issue_date"].split("-")[1]) == month]
    if year:
        records = [r for r in records if int(r["issue_date"].split("-")[0]) == year]
    return records


# LC Goods Receipt

@router.post("/lc-goods-receipts/", response_model=lc_goods_receipt_schema.LCGoodsReceiptRead)
async def create_payment(receipt: lc_goods_receipt_schema.LCGoodsReceiptCreate, db: AsyncSession = Depends(get_db)):
    db_receipt = lc_goods_receipt_model.LCGoodsReceipt(**receipt.dict())
    db.add(db_receipt)
    await db.commit()
    await db.refresh(db_receipt)
    return db_receipt

# LC Realization
@router.post("/lc-realizations/", response_model=lc_realization_schema.LCRealizationRead)
async def create_lc_realization(realization: lc_realization_schema.LCRealizationCreate, db: AsyncSession = Depends(get_db)):
    db_obj = lc_realization_model.LCRealization(**realization.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

# LC Final Payment
@router.post("/lc-final-payments/", response_model=lc_final_payment_schema.LCFinalPaymentRead)
async def create_lc_final_payment(payment: lc_final_payment_schema.LCFinalPaymentCreate, db: AsyncSession = Depends(get_db)):
    db_obj = lc_final_payment_model.LCFinalPayment(**payment.dict())
    db.add(db_obj)
    db.commit()
    db.refresh(db_obj)
    return db_obj

@router.post("/goods-shipment", response_model= lc_goods_shipment_schema.LCGoodsShipmentResponse)
async def create_goods_shipment(
    payload: lc_goods_shipment_schema.LCGoodsShipmentCreate, db: AsyncSession = Depends(get_db)
):
    new_shipment = lc_goods_shipment_model.LCGoodsShipment(**payload.dict())
    db.add(new_shipment)
    await db.commit()
    await db.refresh(new_shipment)
    return new_shipment

@router.get("/goods-shipment/{lc_no}", response_model=List[lc_goods_shipment_schema.LCGoodsShipmentResponse])
async def read_margin_payment(lc_no: int, db: AsyncSession = Depends(get_db)):
    stmt = select(lc_goods_shipment_model.LCGoodsShipment).where(
        lc_goods_shipment_model.LCGoodsShipment.lc_id == lc_no
    )
    result = await db.execute(stmt)
    lc = result.scalars().all()
    return lc

@router.post("/issuance", response_model= lc_issuance_schema.LCIssuanceResponse)
async def create_issuance(
    payload: lc_issuance_schema.LCIssuanceCreate, db: AsyncSession = Depends(get_db)
):
    new_shipment = lc_issuance_model.LCIssuance(**payload.dict())
    db.add(new_shipment)
    await db.commit()
    await db.refresh(new_shipment)
    return new_shipment
