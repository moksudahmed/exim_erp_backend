
# --- schemas/person.py ---
from pydantic import BaseModel
from typing import Optional
from datetime import date

class PersonBase(BaseModel):
    title: Optional[str]
    first_name: str
    last_name: str
    contact_no: Optional[str]    
  #  gender: Optional[str]
   

class PersonCreate(PersonBase):
    pass

class PersonResponse(PersonBase):
    person_id: int
    class Config:
        orm_mode = True
