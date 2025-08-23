from decimal import Decimal
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.sql import func
from fastapi import HTTPException, status
from pydantic import ValidationError

from app.models import (
    PurchaseOrder, PurchaseOrderItem, Payment,
    SubsidiaryAccount, JournalEntry, JournalItems, Ledger
)
from app.models.enum_types import OrderStatusEnum
from app.schemas.purchase_order import PurchaseOrderCreate
from app.schemas.journal_entries import LedgerWithEntryRequest
from app.schemas.journal_items import JournalItems as JournalItemSchema
from app.schemas.payment import PaymentCreate, PaymentSchema

class PurchaseService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def create_purchase_order(self, order_data: PurchaseOrderCreate, payment:PaymentCreate) -> PurchaseOrder:
        """Handles credit purchase orders: records purchase, payment, journals and ledger"""
        try:
            sub_account_id = await self.get_subsidiary_account(order_data.client_id)
            
            # Create purchase order
            new_order = PurchaseOrder(
                client_id=order_data.client_id,
                date=order_data.date,
                total_amount=Decimal(order_data.total_amount),
                status=order_data.status,
                user_id=order_data.user_id,
                branch_id=order_data.branch_id                
            )
            self.db.add(new_order)
            await self.db.flush()

            # Insert items
            for item in order_data.items:
                self.db.add(PurchaseOrderItem(
                    product_id=item.product_id,
                    quantity=item.quantity,
                    cost_per_unit=item.cost_per_unit,
                    purchase_order_id=new_order.id,
                    quality_type=item.quality_type,
                    measurement_type=item.measurement_type,
                    measurement_value=item.measurement_value
                ))
                
            # Record payment (credit)
            payment_data = Payment(
                business_id=1,
                amount=Decimal(order_data.total_amount),
                payment_method=payment.payment_method,
                reference_number=f"PO-{new_order.id}",
                notes='Purchase recorded as payable',
                purchase_id=new_order.id
            )
            self.db.add(payment_data)

            # Prepare journal entries
            journal_items = self._build_journal_items(
                payment_method=payment.payment_method,
                total=order_data.total_amount,
                amount_paid=order_data.total_amount,
                sub_account_id=sub_account_id
            )

            journal_entry = LedgerWithEntryRequest(
                ref_no=f"PURCHASE-{datetime.utcnow():%Y%m%d%H%M%S}",
                account_type='liability',
                company="Stone Ltd.",
                description=f"Goods purchased on {payment.payment_method}",
                user_id=order_data.user_id,
                journal_items=journal_items
            )

            await self.create_ledger_with_entry(journal_entry)

            await self.db.commit()
            await self.db.refresh(new_order)
            return new_order

        except Exception as e:
            await self.db.rollback()
            raise HTTPException(status_code=500, detail=f"Purchase creation failed: {e}")

    async def create_cash_purchase_order(self, order_data: PurchaseOrderCreate) -> PurchaseOrder:
        """Handles cash purchase orders with immediate payment and balanced ledger"""
        try:
            sub_account_id = await self.get_subsidiary_account(order_data.client_id)

            new_order = PurchaseOrder(
                client_id=order_data.client_id,
                date=order_data.date,
                total_amount=Decimal(order_data.total_amount),
                status=OrderStatusEnum.PAID,
                user_id=order_data.user_id,
                measurement=order_data.measurement
            )
            self.db.add(new_order)
            await self.db.flush()

            for item in order_data.items:
                self.db.add(PurchaseOrderItem(
                    product_id=item.product_id,
                    quantity=item.quantity,
                    cost_per_unit=item.cost_per_unit,
                    purchase_order_id=new_order.id
                ))

            payment = Payment(
                business_id=1,
                amount=Decimal(order_data.total_amount),
                payment_method='cash',
                reference_number=f"CPO-{new_order.id}",
                notes='Cash purchase',
                purchase_id=new_order.id
            )
            self.db.add(payment)

            # Journal entry for cash transaction
            journal_items = [
                JournalItemSchema(
                    narration="Goods purchased (cash)",
                    debitcredit="DEBIT",
                    amount=Decimal(order_data.total_amount),
                    account_id=6,  # Expense
                    subsidiary_account_id=sub_account_id
                ),
                JournalItemSchema(
                    narration="Cash Paid",
                    debitcredit="CREDIT",
                    amount=Decimal(order_data.total_amount),
                    account_id=1,  # Cash
                    subsidiary_account_id=sub_account_id
                )
            ]

            journal_entry = LedgerWithEntryRequest(
                ref_no=f"CASH-PURCHASE-{datetime.utcnow():%Y%m%d%H%M%S}",
                account_type="expense",
                company="Stone Ltd.",
                description="Cash purchase of goods",
                user_id=order_data.user_id,
                journal_items=journal_items
            )

            await self.create_ledger_with_entry(journal_entry)

            await self.db.commit()
            await self.db.refresh(new_order)
            return new_order

        except Exception as e:
            await self.db.rollback()
            raise HTTPException(status_code=500, detail=f"Cash purchase failed: {e}")

    async def create_ledger_with_entry(self, entry_data: LedgerWithEntryRequest):
        """Validates and inserts journal entry and linked ledger records"""
        debit_total = sum(Decimal(i.amount) for i in entry_data.journal_items if i.debitcredit == 'DEBIT')
        credit_total = sum(Decimal(i.amount) for i in entry_data.journal_items if i.debitcredit == 'CREDIT')

        if abs(debit_total - credit_total) > Decimal("0.01"):
            raise HTTPException(status_code=400, detail="Debits and credits must be balanced")

        journal_entry = JournalEntry(
            ref_no=entry_data.ref_no,
            account_type=entry_data.account_type.lower(),
            company=entry_data.company,
            description=entry_data.description,
            user_id=entry_data.user_id
        )
        self.db.add(journal_entry)
        await self.db.flush()

        for item in entry_data.journal_items:
            amount = Decimal(item.amount)
            journal_item = JournalItems(
                narration=item.narration,
                debitcredit=item.debitcredit,
                amount=amount,
                account_id=item.account_id,
                journal_entry_id=journal_entry.id,
                subsidiary_account_id=item.subsidiary_account_id
            )
            self.db.add(journal_item)
            await self.db.flush()

            current_balance = await self.get_account_balance(item.account_id)
            new_balance = current_balance + amount if item.debitcredit == 'DEBIT' else current_balance - amount

            self.db.add(Ledger(
                account_id=item.account_id,
                journal_item_id=journal_item.id,
                entry_date=func.now(),
                amount=amount,
                balance=new_balance,
                type=item.debitcredit
            ))

        await self.db.flush()

    async def get_subsidiary_account(self, client_id: int) -> int:
        result = await self.db.execute(
            select(SubsidiaryAccount).where(SubsidiaryAccount.client_id == client_id)
        )
        account = result.scalars().first()
        if not account:
            raise HTTPException(status_code=404, detail=f"No subsidiary account for client {client_id}")
        return account.subsidiary_account_id

    async def get_account_balance(self, account_id: int) -> Decimal:
        result = await self.db.execute(
            select(func.coalesce(func.sum(Ledger.amount), 0)).where(Ledger.account_id == account_id)
        )
        return Decimal(result.scalar_one())

    def _build_journal_items(self, payment_method: str, total: float, amount_paid: float, sub_account_id: int) -> list[dict]:
        total = Decimal(total)

        if payment_method == 'cash':
            return [
                {"narration": "Goods purchased (cash)", "debitcredit": "DEBIT", "amount": total, "account_id": 6, "subsidiary_account_id": sub_account_id},
                {"narration": "Cash Paid", "debitcredit": "CREDIT", "amount": total, "account_id": 1, "subsidiary_account_id": sub_account_id}
            ]
        elif payment_method == 'credit':
            return [
                {"narration": "Goods purchased", "debitcredit": "DEBIT", "amount": total, "account_id": 6, "subsidiary_account_id": sub_account_id},
                {"narration": "Accounts Payable", "debitcredit": "CREDIT", "amount": total, "account_id": 5, "subsidiary_account_id": sub_account_id}
            ]
        elif payment_method == 'bank_transfer':
            return [
                {"narration": "Goods purchased (bank transfer)", "debitcredit": "DEBIT", "amount": total, "account_id": 6, "subsidiary_account_id": sub_account_id},
                {"narration": "Bank Payment", "debitcredit": "CREDIT", "amount": total, "account_id": 4, "subsidiary_account_id": sub_account_id}
            ]
        else:
            # Default fallback, e.g., for invoicing or receivable
            return [
                {"narration": "Accounts Receivable", "debitcredit": "DEBIT", "amount": total, "account_id": 2, "subsidiary_account_id": sub_account_id},
                {"narration": "Sales Income", "debitcredit": "CREDIT", "amount": total, "account_id": 3, "subsidiary_account_id": sub_account_id}
            ]
