from sqlalchemy import (
    Column, Integer, String, Float, Boolean, Text, ForeignKey, DateTime, Enum, Numeric
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.db.base import Base
from app.models.enum_types import ProductTypeEnum, UnitOfMeasurement, ProductSubCategory
# Product Model

class Product(Base):
    __tablename__ = 'products'
    
    id = Column(Integer, primary_key=True, index=True)
    business_id = Column(Integer, ForeignKey("businesses.id"), nullable=False)
    title = Column(String(255), nullable=False, index=True)
    price_per_unit = Column(Numeric(10, 2), nullable=False)
    stock = Column(Integer, nullable=False)
    category = Column(String(255), index=True)    
    sub_category = Column(Enum(ProductSubCategory, name="product_subcategory_enum"), nullable=False, default=ProductSubCategory.MEDIUM)
    user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
       
    product_type = Column(Enum(ProductTypeEnum, name="product_type_enum"), nullable=False, default=ProductTypeEnum.tangible)
    unit_of_measurement = Column(Enum(UnitOfMeasurement, name="unit_of_measurement_enum"), nullable=False, default=UnitOfMeasurement.kg)
    quantity_per_unit = Column(Numeric(10, 3), nullable=True)
    is_stock_tracked = Column(Boolean, default=True)
    tax_rate = Column(Numeric(5, 2), nullable=True)
    description = Column(Text, nullable=True)

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relationships
    business = relationship("Business", back_populates="products")
    sale_products = relationship("SaleProduct", back_populates="product")
    inventory_log = relationship("InventoryLog", back_populates="product")
    lc_goods = relationship("LCGoods", back_populates="product")
    #user = relationship("User", back_populates="products")  # if User model has products relationship