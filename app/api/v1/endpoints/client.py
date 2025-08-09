from fastapi import APIRouter, Depends, HTTPException
from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import Session
from typing import List
from pydantic import BaseModel
from datetime import date
from app.db.session import get_db
from app.models.client import Client
from app.schemas.client import ClientResponse, ClientCreate
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from app.models import person as person_model, client as client_model, subsidiary_account as sa_model
from app.schemas import person as person_schema, client as client_schema, subsidiary_account as sa_schema
from app.schemas.client import ClientList
from sqlalchemy import text
from app.models import Person, Client, Sale, Payment  # Adjust model paths as needed
from app.models.purchase_order import PurchaseOrder
from app.models.ViewJournalEntryDetails import ViewJournalEntryDetails
from app.models.journal_entries import JournalEntry
from app.models.journal_items import JournalItems
from app.models.subsidiary_account import SubsidiaryAccount
from app.schemas import account as account_schema

from app.models import account as account_model
from sqlalchemy import func
from collections import defaultdict
router = APIRouter()


@router.post("/", status_code=201)
async def create_client_entry(
    person: person_schema.PersonCreate,
    client: client_schema.ClientCreate,
    account: sa_schema.SubsidiaryAccountCreate,
    db: AsyncSession = Depends(get_db)
):
    # Create Person
    new_person = person_model.Person(**person.dict())
    db.add(new_person)
    await db.flush()  # get person_id

    # Create Client
    client_data = client.dict()
    client_data["person_id"] = new_person.person_id
    
    new_client = client_model.Client(**client_data)
    db.add(new_client)
    await db.flush()  # get client_id

    # Create Subsidiary Account
    
    account_data = account.dict()
    account_data["client_id"] = new_client.client_id
    if client.client_type == 'CUSTOMER':
        result = await db.execute(select(account_model.Account).where(account_model.Account.account_name == 'Accounts Receivable'))
    elif client.client_type == 'SUPPLIER':
        result = await db.execute(select(account_model.Account).where(account_model.Account.account_name == 'Accounts Payable'))
    else:
        result = await db.execute(select(account_model.Account).where(account_model.Account.account_name == 'Accounts Receivable'))
    acc = result.scalar_one_or_none()
    account_data["account_id"] = acc.account_id
    
    new_account = sa_model.SubsidiaryAccount(**account_data)
    db.add(new_account)

    await db.commit()
    return {
        "message": "Client with personal and account information created successfully.",
        "person_id": new_person.person_id,
        "client_id": new_client.client_id,
        "subsidiary_account_id": new_account.subsidiary_account_id
    }


@router.get("/list", response_model=List[ClientList])
async def get_client_list(db: AsyncSession = Depends(get_db)):
    query = text("""
        SELECT 
          p.person_id, 
          p.title, 
          p.first_name, 
          p.last_name, 
          p.contact_no, 
          p.gender, 
          c.client_id, 
          c.client_type, 
          c.registration_date, 
          s.subsidiary_account_id, 
          s.account_id, 
          s.account_name, 
          s.account_no, 
          s.address, 
          s.branch, 
          s.account_holder, 
          s.type
        FROM 
          public.person p, 
          public.client c, 
          public.subsidiary_account s
        WHERE 
          p.person_id = c.person_id AND
          c.client_id = s.client_id
    """)

    result = await db.execute(query)
    rows = result.mappings().all()  # This returns list of dicts compatible with Pydantic
    return rows

@router.get("/list/{client_type}", response_model=List[ClientList])
async def get_client_list(client_type: str, db: AsyncSession = Depends(get_db)):
    query = text("""
        SELECT 
          p.person_id, 
          p.title, 
          p.first_name, 
          p.last_name, 
          p.contact_no, 
          p.gender, 
          c.client_id, 
          c.client_type, 
          c.registration_date, 
          s.subsidiary_account_id, 
          s.account_id, 
          s.account_name, 
          s.account_no, 
          s.address, 
          s.branch, 
          s.account_holder, 
          s.type
        FROM 
          public.person p
        JOIN 
          public.client c ON p.person_id = c.person_id
        JOIN 
          public.subsidiary_account s ON c.client_id = s.client_id
        WHERE 
          c.client_type = :client_type
    """)

    result = await db.execute(query, {"client_type": client_type})
    rows = result.mappings().all()  # returns list of dicts
    return rows

@router.get("/client-statement2/{client_id}")
async def get_client_statement2(client_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(ViewJournalEntryDetails)
        .where(ViewJournalEntryDetails.client_id == client_id)
    )
    rows = result.scalars().all()

    # Compute totals
    total_due = sum(r.amount for r in rows if r.debitcredit == "Debit")
    total_paid = sum(r.amount for r in rows if r.debitcredit == "Credit")
    outstanding_due = total_due - total_paid

    return {
        "statement": [
            {
                "date": r.transaction_date,
                "ref_no": r.ref_no,
                "account": r.main_account_name,
                "narration": r.narration,
                "debit": r.amount if r.debitcredit == "Debit" else 0,
                "credit": r.amount if r.debitcredit == "Credit" else 0,
            } for r in rows
        ],
        "summary": {
            "total_due": total_due,
            "total_paid": total_paid,
            "outstanding_due": outstanding_due
        }
    }

@router.get("/client-statement")
async def get_client_statement(db: AsyncSession = Depends(get_db)):
    query = text("""
        SELECT
            subsidiary_account_name AS client,
            main_account_name AS account,
            debitcredit AS dc,
            SUM(amount) AS amt
        FROM public.view_journal_entry_details
        GROUP BY
            subsidiary_account_name,
            main_account_name,
            debitcredit
    """)

    result = await db.execute(query)
    rows = result.fetchall()
    print("DEBUG — Rows returned from view:", rows)

    client_totals = defaultdict(lambda: {'total_due': 0, 'total_paid': 0})

    for row in rows:
        client = row.client
        account = row.account
        dc = row.dc.upper()
        amount = float(row.amt or 0)

        # Skip entries with no client name
        if not client:
            continue

        account_lower = account.lower()

        # Total due logic
        if account_lower == "accounts receivable" and dc == "DEBIT":
            client_totals[client]["total_due"] += amount
        # Total paid logic (cash/bank)
        elif account_lower in ["cash", "bank"] and dc == "DEBIT":
            client_totals[client]["total_paid"] += amount

    statement = []
    for client, totals in client_totals.items():
        due = totals["total_due"]
        paid = totals["total_paid"]
        outstanding = due - paid
        statement.append({
            "client_name": client,
            "total_due": due,
            "total_paid": paid,
            "outstanding_due": outstanding
        })

    print("DEBUG — Computed Statement:", statement)
    return statement

@router.get("/single-client-statement/{client_id}")
async def get_client_statement_by_id(client_id: int, db: AsyncSession = Depends(get_db)):
     
    result = await db.execute(
            select(SubsidiaryAccount).where(SubsidiaryAccount.client_id == client_id)
        )
    account = result.scalars().first()
    if account is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Subsidiary account not found for client_id {client_id}"
            )
    
    
    query = text("""
        SELECT
            subsidiary_account_id,
            subsidiary_account_name AS client,
            main_account_name AS account,
            debitcredit AS dc,
            amount,
            transaction_date
        FROM public.view_journal_entry_details
        WHERE subsidiary_account_id = :subsidiary_account_id
        ORDER BY transaction_date
    """)

    result = await db.execute(query, {"subsidiary_account_id": account.subsidiary_account_id})
    rows = result.fetchall()

    if not rows:
        raise HTTPException(status_code=404, detail="No records found for this client")

    statement = {
        "client_name": "",
        "client_id": client_id,
        "entries": [],
        "total_due": 0.0,
        "total_paid": 0.0,
        "outstanding_due": 0.0
    }

    for row in rows:
        client = row.client
        account = row.account or ""
        dc = row.dc.upper()
        amount = float(row.amount or 0)
        date = row.transaction_date

        if not client:
            continue

        statement["client_name"] = client

        # Calculate totals
        if account.lower() == "accounts receivable" and dc == "DEBIT":
            statement["total_due"] += amount
        elif account.lower() in ["cash", "bank"] and dc == "DEBIT":
            statement["total_paid"] += amount

        # Add individual transaction
        statement["entries"].append({
            "date": str(date),
            "account": account,
            "debit_credit": dc,
            "amount": amount
        })

    # Compute outstanding
    statement["outstanding_due"] = statement["total_due"] - statement["total_paid"]

    return statement

@router.get("/single-supplier-statement/{supplier_id}")
async def get_supplier_statement_by_id(supplier_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(SubsidiaryAccount).where(SubsidiaryAccount.client_id == supplier_id)
    )
    account = result.scalars().first()

    if account is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Subsidiary account not found for supplier_id {supplier_id}"
        )

    query = text("""
        SELECT
            subsidiary_account_id,
            subsidiary_account_name AS supplier,
            main_account_name AS account,
            debitcredit AS dc,
            amount,
            transaction_date
        FROM public.view_journal_entry_details
        WHERE subsidiary_account_id = :subsidiary_account_id
        ORDER BY transaction_date
    """)

    result = await db.execute(query, {"subsidiary_account_id": account.subsidiary_account_id})
    rows = result.fetchall()

    if not rows:
        raise HTTPException(status_code=404, detail="No records found for this supplier")

    statement = {
        "supplier_name": "",
        "supplier_id": supplier_id,
        "entries": [],
        "total_payable": 0.0,
        "total_paid": 0.0,
        "outstanding_payable": 0.0
    }

    for row in rows:
        supplier = row.supplier
        account = row.account or ""
        dc = row.dc.upper()
        amount = float(row.amount or 0)
        date = row.transaction_date

        if not supplier:
            continue

        statement["supplier_name"] = supplier

        # Totals logic for suppliers
        if account.lower() == "accounts payable" and dc == "CREDIT":
            statement["total_payable"] += amount
        elif account.lower() in ["cash", "bank"] and dc == "CREDIT":
            statement["total_paid"] += amount

        # Add to entries
        statement["entries"].append({
            "date": str(date),
            "account": account,
            "debit_credit": dc,
            "amount": amount
        })

    # Outstanding payable = total payable - total paid
    statement["outstanding_payable"] = statement["total_payable"] - statement["total_paid"]

    return statement

@router.get("/customer-payments/{client_id}")
async def fetch_customer_payment_info(client_id: int, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(
            Person.person_id,
            Person.title,
            Person.first_name,
            Person.last_name,
            Client.client_type,
            Sale.total,
            Sale.discount,
            Sale.payment_status,
            Payment.payment_date,
            Payment.amount,
            Payment.payment_method
        )
        .select_from(Sale)
        .join(Client, Client.client_id == Sale.client_id)
        .join(Person, Person.person_id == Client.person_id)
        .join(Payment, Payment.sale_id == Sale.id)
        .where(Client.client_id == client_id)
    )

    result = await db.execute(stmt)
    records = result.fetchall()
    return [dict(row._mapping) for row in records]
@router.get("/supplier-payments/{client_id}")
async def fetch_supplier_payment_info(client_id: int, db: AsyncSession = Depends(get_db)):
    stmt = (
        select(
            Person.person_id,
            Person.title,
            Person.first_name,
            Person.last_name,
            Client.client_type,
            PurchaseOrder.total_amount,
            PurchaseOrder.status,
            Payment.payment_date,
            Payment.amount,
            Payment.payment_method
        )
        .select_from(PurchaseOrder)
        .join(Client, Client.client_id == PurchaseOrder.client_id)
        .join(Person, Person.person_id == Client.person_id)
        .join(Payment, Payment.purchase_id == PurchaseOrder.id)
        .where(Client.client_id == client_id)
    )

    result = await db.execute(stmt)
    records = result.fetchall()
    return [dict(row._mapping) for row in records]

@router.post("/123", response_model=ClientResponse)
def create_client(client: ClientCreate, db: Session = Depends(get_db)):
    db_client = Client(**client.dict())
    db.add(db_client)
    db.commit()
    db.refresh(db_client)
    return db_client


@router.get("/", response_model=List[ClientResponse])
async def read_transactions(skip: int = 0, limit: int = 100, db: AsyncSession = Depends(get_db)):
    stmt = select(Client).offset(skip).limit(limit)    
    # Execute query asynchronously
    result = await db.execute(stmt)
    account = result.scalars().all()
    return account

@router.get("/test/{client_id}", response_model=ClientResponse)
async def get_client2(client_id: int, db: AsyncSession = Depends(get_db)):
    """
    Retrieve a client by ID, including related Person and SubsidiaryAccount data.
    """
    result = await db.execute(
        select(client_model.Client)
        .options(
            selectinload(client_model.Client.person),                # Eager load Person
            selectinload(client_model.Client.subsidiary_accounts)    # Eager load Subsidiary Accounts
        )
        .where(client_model.Client.client_id == client_id)
    )

    client = result.scalars().first()

    if not client:
        raise HTTPException(status_code=404, detail="Client not found")

    return client
@router.get("/{client_id}", response_model=ClientList)
async def get_client(client_id: int, db: AsyncSession = Depends(get_db)):
    query = text("""
        SELECT 
          p.person_id, 
          p.title, 
          p.first_name, 
          p.last_name, 
          p.contact_no, 
          p.gender, 
          c.client_id, 
          c.client_type, 
          c.registration_date, 
          s.subsidiary_account_id, 
          s.account_id, 
          s.account_name, 
          s.account_no, 
          s.address, 
          s.branch, 
          s.account_holder, 
          s.type
        FROM 
          public.person p
        JOIN 
          public.client c ON p.person_id = c.person_id
        JOIN 
          public.subsidiary_account s ON c.client_id = s.client_id
        WHERE 
          c.client_id = :client_id
    """)

    result = await db.execute(query, {"client_id": client_id})
    client = result.mappings().first()  # ✅ Returns dict-like object

    if not client:
        raise HTTPException(status_code=404, detail="Client not found")

    return dict(client)  # ✅ Convert to normal dict so Pydantic can parse


"""
@router.put("/{client_id}", response_model=ClientResponse)
def update_client(client_id: int, client_data: ClientUpdate, db: Session = Depends(get_db)):
    client = db.query(Client).filter(Client.client_id == client_id).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client not found")
    
    for key, value in client_data.dict(exclude_unset=True).items():
        setattr(client, key, value)

    db.commit()
    db.refresh(client)
    return client"""

@router.delete("/{client_id}", response_model=ClientResponse)
def delete_client(client_id: int, db: Session = Depends(get_db)):
    client = db.query(Client).filter(Client.client_id == client_id).first()
    if not client:
        raise HTTPException(status_code=404, detail="Client not found")
    
    db.delete(client)
    db.commit()
    return client
