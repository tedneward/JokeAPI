from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import Session
from sqlalchemy.exc import NoResultFound
from .db import Base
from typing import Optional, List
import random

class Joke(Base):
    __tablename__ = 'jokes'

    id = Column(Integer, primary_key=True, index=True)
    setup = Column(String, nullable=False)
    punchline = Column(String, nullable=False)
    category = Column(String, nullable=False, default="")
    source = Column(String, nullable=False, default="me")
    lol_count = Column(Integer, nullable=False, default=0)
    groan_count = Column(Integer, nullable=False, default=0)

class Repository:
    def __init__(self, session: Session):
        self.session = session

    def list_jokes(self) -> List[Joke]:
        return self.session.query(Joke).all()

    def get_joke(self, joke_id: int) -> Optional[Joke]:
        return self.session.query(Joke).filter(Joke.id == joke_id).first()

    def create_joke(self, setup: str, punchline: str, category: str = "", source: str = "me") -> Joke:
        joke = Joke(setup=setup, punchline=punchline, category=category or "", source=source or "me")
        self.session.add(joke)
        self.session.commit()
        self.session.refresh(joke)
        return joke

    def update_joke(self, joke_id: int, **kwargs) -> Optional[Joke]:
        joke = self.get_joke(joke_id)
        if not joke:
            return None
        for k, v in kwargs.items():
            if hasattr(joke, k) and v is not None:
                setattr(joke, k, v)
        self.session.commit()
        self.session.refresh(joke)
        return joke

    def delete_joke(self, joke_id: int) -> bool:
        joke = self.get_joke(joke_id)
        if not joke:
            return False
        self.session.delete(joke)
        self.session.commit()
        return True

    def increment_lol(self, joke_id: int) -> Optional[int]:
        joke = self.get_joke(joke_id)
        if not joke:
            return None
        joke.lol_count += 1
        self.session.commit()
        return joke.lol_count

    def increment_groan(self, joke_id: int) -> Optional[int]:
        joke = self.get_joke(joke_id)
        if not joke:
            return None
        joke.groan_count += 1
        self.session.commit()
        return joke.groan_count

    def random_joke(self, category: Optional[str] = None) -> Optional[Joke]:
        query = self.session.query(Joke)
        if category:
            query = query.filter(Joke.category == category)
        rows = query.all()
        if not rows:
            return None
        return random.choice(rows)

    def list_by_source(self, source: str) -> List[Joke]:
        return self.session.query(Joke).filter(Joke.source == source).all()
