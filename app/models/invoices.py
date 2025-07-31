from sqlalchemy import Column, Integer, Numeric,Text, DateTime, ForeignKey, String, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from app.db.base import Base
from app.models.enum_types import InvoiceStatus


class Invoice(Base):
    __tablename__ = "invoices"
    
    id = Column(Integer, primary_key=True)
    business_id = Column(Integer, ForeignKey("businesses.id"))
    customer_id = Column(Integer, ForeignKey("customers.id"))
    sale_id = Column(Integer, ForeignKey("sales.id"))
    invoice_number = Column(String(50), unique=True)
    issue_date = Column(DateTime)
    due_date = Column(DateTime)
    status = Column(Enum(InvoiceStatus, name="invoice_status"), nullable=False)
    total_amount = Column(Numeric(12, 2))
    amount_paid = Column(Numeric(12, 2), default=0)
    balance_due = Column(Numeric(12, 2))
     
    # Relationships
    business = relationship("Business")
    customer = relationship("Customer", back_populates="invoices")
    sale = relationship("Sale", back_populates="invoice")

