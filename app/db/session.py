from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.core.config import settings

DATABASE_URL = settings.SQLALCHEMY_DATABASE_URL

engine = create_async_engine(DATABASE_URL, echo=True)

async_session = async_sessionmaker(bind=engine, class_=AsyncSession, expire_on_commit=False)

async def get_db():
    async with async_session() as session:
        yield session
