from sqlalchemy import (
    Column, Integer, String, Float, Boolean, Text, ForeignKey, DateTime, Enum, Numeric
)
from sqlalchemy.orm import relationship
from app.models.enum_types import ProductSubCategory, ProductTypeEnum
from app.db.base import Base


class PurchaseOrderItem(Base):
    __tablename__ = "purchase_order_items"

    id = Column(Integer, primary_key=True)
    purchase_order_id = Column(Integer, ForeignKey("purchase_orders.id", ondelete="CASCADE"), nullable=False)
    product_id = Column(Integer, ForeignKey("products.id", ondelete="CASCADE"), nullable=False)
    quantity = Column(Integer, nullable=False)
    cost_per_unit = Column(Float, nullable=False)
    quality_type = Column(String(10))
    measurement_type= Column(String(10), nullable=False, index=True)
    measurement_value= Column(Float, nullable=False)
    
    # ✅ Use SQLAlchemyEnum, not Python Enum
   # quality_type = Column(SQLAlchemyEnum(ProductSubCategory, name="product_subcategory_enum"), nullable=False)
    
    # Relationships
    purchase_order = relationship("PurchaseOrder", back_populates="items")
    product = relationship("Product")
