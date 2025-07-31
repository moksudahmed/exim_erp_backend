from sqlalchemy import Column, Integer, String, Float, Date, ForeignKey, Enum as SQLAlchemyEnum
from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, Enum, ForeignKey, Text, Numeric
from sqlalchemy.orm import relationship
from datetime import date
from app.models.enum_types import OrderStatusEnum
from app.db.base import Base

class PurchaseOrder(Base):
    __tablename__ = "purchase_orders"    
    id = Column(Integer, primary_key=True, autoincrement=True)
    client_id = Column(Integer, ForeignKey("client.client_id", ondelete="CASCADE"), nullable=False)
    date = Column(Date, nullable=False, default=date.today)
    total_amount = Column(Float, nullable=False)           
    status = Column(Enum(OrderStatusEnum, name="order_status"), nullable=False)    
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"))
    clients = relationship("Client", back_populates="purchase_order")
    items = relationship("PurchaseOrderItem", back_populates="purchase_order")    
    #accounts_payable = relationship("AccountsPayable", back_populates="purchase_order", uselist=False)    
    payments = relationship("Payment", back_populates="purchase_order")