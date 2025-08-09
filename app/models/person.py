# --- models/person.py ---
from sqlalchemy import Column, Integer, String, Date
from app.db.base import Base
from sqlalchemy.orm import relationship

class Person(Base):
    __tablename__ = "person"

    person_id = Column(Integer, primary_key=True, index=True)
    title = Column(String(20))
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    contact_no = Column(String(13), nullable=False)
    gender = Column(String(8))   

    clients = relationship("Client", back_populates="person")

