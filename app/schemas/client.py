# --- schemas/client.py ---
from pydantic import BaseModel
from typing import Optional
from datetime import date
from app.models.enum_types import ClientType

class ClientBase(BaseModel):
    client_type: Optional[ClientType]
    registration_date: date
    businesses_id: int
    #person_id: Optional[int]

class ClientCreate(ClientBase):
    pass

class ClientResponse(ClientBase):
    client_id: int
    class Config:
        orm_mode = True
        
class ClientList(BaseModel):
    # Person fields
    person_id: int
    title: Optional[str]
    first_name: str
    last_name: str
    contact_no: Optional[str]  # ✅ Use `date` instead of `str`
    gender: Optional[str]

    # Client fields
    client_id: int
    client_type: Optional[ClientType]
    registration_date: Optional[date]  # ✅ Use `date` instead of `str`

    # SubsidiaryAccount fields
    subsidiary_account_id: int
    account_id: int
    account_name: Optional[str]
    account_no: Optional[str]
    address: Optional[str]
    branch: Optional[str]
    account_holder: Optional[str]
    type: Optional[str]

    class Config:
        orm_mode = True