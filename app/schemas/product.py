from pydantic import BaseModel
from typing import Optional
from app.models.enum_types import ProductTypeEnum, UnitOfMeasurement, ProductSubCategory

class ProductBase(BaseModel):
    title: Optional[str] = None
    price_per_unit: Optional[float] = None
    stock: Optional[int] = None
    category: Optional[str] = None
    sub_category: Optional[ProductSubCategory] = None
    product_type: Optional[ProductTypeEnum] #= None#ProductTypeEnum.tangible
    unit_of_measurement: Optional[UnitOfMeasurement]
    quantity_per_unit: Optional[float] = None
    is_stock_tracked: Optional[bool] = True
    tax_rate: Optional[float] = None
    description: Optional[str] = None
    business_id : Optional[int] = None

class ProductCreate(ProductBase):
    title: str
    price_per_unit: float
    stock: int
    category:str
    sub_category: Optional[ProductSubCategory] = None
    
    
class ProductUpdate(ProductBase):
    pass

class Product(ProductBase):
    id: int

    class Config:
        from_attributes = True