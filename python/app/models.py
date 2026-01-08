from pydantic import BaseModel
from typing import Optional

class JokeBase(BaseModel):
    setup: str
    punchline: str
    category: Optional[str] = ""
    source: Optional[str] = "me"

class JokeCreate(JokeBase):
    pass

class JokeUpdate(BaseModel):
    setup: Optional[str]
    punchline: Optional[str]
    category: Optional[str]
    source: Optional[str]

class JokeOut(JokeBase):
    id: int
    lol_count: int = 0
    groan_count: int = 0

    class Config:
        orm_mode = True
