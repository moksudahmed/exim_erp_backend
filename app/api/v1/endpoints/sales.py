from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.schemas import sale as sale_schema
from app.models import sale as sale_model
from app.models.sale import Sale  # Make sure to import the Sale model
from app.models import product as product_model
from app.db.session import get_db
from typing import List
from sqlalchemy import select, delete
from sqlalchemy.future import select
from app.models.product import Product
from app.models.sale import Sale
from app.models.sale_product import SaleProduct
from app.models.user import User
from sqlalchemy.orm import selectinload  # Import this for loading related objects
from app.schemas.sale import SaleCreate, SaleUpdate, Sale as SaleSchema
from app.models import inventory_log as inventory_model
from app.models import transaction as transaction_model
from app.schemas import transaction as transaction_schema
from sqlalchemy.sql import func
from app.models.enum_types import PaymentStatus
from app.models.journal_entries import JournalEntry
from app.services.sale import SaleService
from app.schemas.payment import PaymentCreate, PaymentSchema

# Define account IDs (should come from configuration)
CASH_ACCOUNT_ID = 1
ACCOUNTS_RECEIVABLE_ID = 2
SALES_REVENUE_ID = 3
INVENTORY_ACCOUNT_ID = 4
COGS_ACCOUNT_ID = 5

router = APIRouter()
"""
@router.post("/sale-with-transaction", response_model=sale_schema.SaleWithTransactionResponse)
async def create_sale_with_transaction(
    payload: sale_schema.SaleWithTransactionCreate,
    db: AsyncSession = Depends(get_db)
):
    print("Test Test")
    sale_data = payload.sale
    transaction_data = payload.transaction

    # Step 1: Create Sale
    db_sale = Sale(
        user_id=sale_data.user_id,
        customer_id=sale_data.customer_id,
        total=sale_data.total,
        discount=sale_data.discount,
        business_id=sale_data.business_id
    )

    for sale_product in sale_data.sale_products:
        product = await db.get(Product, sale_product.product_id)

        if not product:
            raise HTTPException(status_code=404, detail=f"Product with id {sale_product.product_id} not found")

        if product.stock < sale_product.quantity:
            raise HTTPException(status_code=400, detail=f"Not enough stock for product with id {sale_product.product_id}")

        db_sale_product = SaleProduct(
            product_id=sale_product.product_id,
            quantity=sale_product.quantity,
            price_per_unit=sale_product.price_per_unit,
            total_price=sale_product.total_price,
            sale=db_sale
        )

        product.stock -= sale_product.quantity
        db.add(db_sale_product)

        new_log = inventory_model.InventoryLog(
            product_id=sale_product.product_id,
            action_type='DEDUCT',
            quantity=sale_product.quantity,
            user_id=sale_data.user_id
        )
        db.add(new_log)

    db.add(db_sale)
    await db.commit()
    await db.refresh(db_sale)

    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=db_sale.id)
    )
    db_sale = result.scalars().first()

    # Step 2: Create Transaction
    db_transaction = transaction_model.Transaction(**transaction_data.dict())
    db.add(db_transaction)
    await db.commit()
    await db.refresh(db_transaction)

    # Step 3: Return combined response
    return {
        "sale": db_sale,
        "transaction": db_transaction
}"""

@router.post("/", response_model=SaleSchema)
async def create_sale(sale: SaleCreate, payment:PaymentCreate, db: AsyncSession = Depends(get_db)):
    service = SaleService(db)
    db_sale = await service.create_sale(sale, payment)

    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=db_sale.id)
    )
    sale_with_products = result.scalars().first()

    return sale_with_products

@router.post("/abc", response_model=SaleSchema)
async def create_sale(sale: SaleCreate, db: AsyncSession = Depends(get_db)):
    # Step 1: Create Sale object
    db_sale = Sale(
        user_id=sale.user_id,
        client_id=sale.client_id,
        total=sale.total,
        discount=sale.discount,
        business_id=sale.business_id,
        payment_status=sale.payment_status.value        
    )
    db.add(db_sale)

    # Step 2: Process each SaleProduct
    for item in sale.sale_products:
        product = await db.get(Product, item.product_id)
        if not product:
            raise HTTPException(status_code=404, detail=f"Product with id {item.product_id} not found")

        if product.stock < item.quantity:
            raise HTTPException(status_code=400, detail=f"Not enough stock for product with id {item.product_id}")

        sale_product = SaleProduct(
            product_id=item.product_id,
            quantity=item.quantity,
            price_per_unit=item.price_per_unit,
            total_price=item.total_price,
            sale=db_sale
        )
        db.add(sale_product)

        product.stock -= item.quantity  # Deduct stock

        inventory_log = inventory_model.InventoryLog(
            product_id=item.product_id,
            action_type='DEDUCT',
            quantity=item.quantity,
            user_id=sale.user_id  # replace 1 with actual user_id
        )
        db.add(inventory_log)

    # Step 3: Create Transaction
    transaction = transaction_model.Transaction(
        account_id=3,  # replace as needed
        amount=db_sale.total,
        transaction_date=func.now(),
        description='Sale of products-items',
        user_id=db_sale.user_id,
        business_id=db_sale.business_id or 1,
        reference_type='sale',
        type="DEBIT",
        reference_id=db_sale.id
    )
    db.add(transaction)

    # Step 4: Commit and refresh
    await db.commit()
    await db.refresh(db_sale)
    await db.refresh(transaction)

    # Reload sale with its products for response
    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=db_sale.id)
    )
    sale_with_products = result.scalars().first()

    return db_sale



"""
@router.post("/", response_model=SaleSchema)
async def create_sale2(sale: SaleCreate, db: AsyncSession = Depends(get_db)):
    # Initialize a new Sale object
    #db_sale = Sale(user_id=sale.user_id,customer_id=sale.customer_id, total=sale.total, discount=sale.discount, business_id=sale.business_id)
    db_sale = Sale(
        user_id=sale.user_id,
        customer_id=sale.customer_id,
        total=sale.total,
        discount=sale.discount,
        business_id=sale.business_id
    )

    db.add(db_sale)
    for sale_product in sale.sale_products:
        product = await db.get(Product, sale_product.product_id)
        
        if not product:
            raise HTTPException(status_code=404, detail=f"Product with id {sale_product.product_id} not found")
        
        if product.stock < sale_product.quantity:           
            raise HTTPException(status_code=400, detail=f"Not enough stock for product with id {sale_product.product_id}")
        
        # Create the SaleProduct record
        db_sale_product = SaleProduct(
            product_id=sale_product.product_id,
            quantity=sale_product.quantity,
            price_per_unit = sale_product.price_per_unit, 
            total_price=sale_product.total_price,
            #itemwise_discount=sale_product.itemwise_discount,
            sale=db_sale  # Link this SaleProduct to the Sale
        )
        
        # Update the stock of the product
        product.stock -= sale_product.quantity
        db.add(db_sale_product)
        
        new_log = inventory_model.InventoryLog(
            product_id=sale_product.product_id,
            action_type='DEDUCT',
            quantity=sale_product.quantity,
            user_id = 1
        )
        db.add(new_log)
    
    # Step 2: Create Transaction
    transaction = transaction_model.Transaction(            
            account_id= 1,
            amount= db_sale.total,
            transaction_date = func.now(),
            description= f"Sale of products-items",
            user_id= db_sale.user_id, 
            business_id= 1,
            reference_type= 'sale',
            type= "DEBIT",
            reference_id= db_sale.id
        )
    
    db.add(transaction)  
   # await db.commit()
  #  await db.refresh(db_sale)
     # Single commit for sale + transaction + logs
    await db.commit()
    await db.refresh(db_sale)
    await db.refresh(transaction)

    # Ensure sale_products are loaded with selectinload
    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=db_sale.id)
    )
    db_sale = result.scalars().first()


    result = await db.execute(select(transaction_model.Transaction).filter(transaction_model.Transaction.transaction_id == transaction.transaction_id))
    db_transaction = result.scalars().first()
    setattr(db_transaction, 'reference_id', db_sale.id)

    await db.commit()
    await db.refresh(db_transaction)

    return db_sale"""

  

@router.put("/{sale_id}", response_model=SaleSchema)
async def update_sale(sale_id: int, sale: SaleUpdate, db: AsyncSession = Depends(get_db)):
    # Fetch the existing sale
    print("Update sale: ")
    print(sale)
    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=sale_id)
    )
    db_sale = result.scalars().first()
    
    if not db_sale:
        raise HTTPException(status_code=404, detail=f"Sale with id {sale_id} not found")
    
    # Update sale's total and user_id if provided
    if sale.total is not None:
        db_sale.total = sale.total
    if sale.user_id is not None:
        db_sale.user_id = sale.user_id
    if sale.discount is not None:
        db_sale.discount = sale.discount
    # Process sale products
    for sale_product_data in sale.sale_products:
        # Check if the product exists
        product = await db.get(Product, sale_product_data.product_id)
        
        if not product:
            raise HTTPException(status_code=404, detail=f"Product with id {sale_product_data.product_id} not found")
        
        # Find the existing SaleProduct or create a new one
        db_sale_product = next((sp for sp in db_sale.sale_products if sp.product_id == sale_product_data.product_id), None)
        
        if db_sale_product:
            # Update the existing SaleProduct
            product.stock += db_sale_product.quantity  # Revert stock change
            if product.stock < sale_product_data.quantity:
                raise HTTPException(status_code=400, detail=f"Not enough stock for product with id {sale_product_data.product_id}")
            
            product.stock -= sale_product_data.quantity
            db_sale_product.quantity = sale_product_data.quantity
            db_sale_product.total_price = sale_product_data.total_price
            #db_sale_product.itemwise_discount = sale_product_data.itemwise_discount
        else:
            # Create a new SaleProduct record
            if product.stock < sale_product_data.quantity:
                raise HTTPException(status_code=400, detail=f"Not enough stock for product with id {sale_product_data.product_id}")
            
            product.stock -= sale_product_data.quantity
            
            new_sale_product = SaleProduct(
                product_id=sale_product_data.product_id,
                quantity=sale_product_data.quantity,
                total_price=sale_product_data.total_price,
                #itemwise_discount = sale_product_data.itemwise_discount,
                sale=db_sale  # Link this SaleProduct to the Sale
            )
            db.add(new_sale_product)
    
    await db.commit()
    await db.refresh(db_sale)
    
    # Ensure sale_products are loaded with selectinload
    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=db_sale.id)
    )
    db_sale = result.scalars().first()
    
    return db_sale

@router.get("/", response_model=List[sale_schema.Sale])
async def get_sales(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Sale).options(selectinload(Sale.sale_products)))
    sales = result.scalars().all()
    return sales

@router.delete("/{sale_id}", response_model=sale_schema.Sale)
async def delete_sale(sale_id: int, db: AsyncSession = Depends(get_db)):
    # Fetch the sale
    result = await db.execute(
        select(Sale).options(selectinload(Sale.sale_products)).filter_by(id=sale_id)
    )
    db_sale = result.scalars().first()

    if not db_sale:
        raise HTTPException(status_code=404, detail=f"Sale with id {sale_id} not found")

    # Revert the stock of each product and delete SaleProduct records
    for sale_product in db_sale.sale_products:
        product = await db.get(Product, sale_product.product_id)
        if product:
            product.stock += sale_product.quantity
        await db.execute(delete(SaleProduct).where(SaleProduct.id == sale_product.id))

    # Delete the sale
    await db.delete(db_sale)
    await db.commit()

    return db_sale

