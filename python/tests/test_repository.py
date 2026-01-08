import sys, os
import pytest
sys.path.append(os.path.dirname(os.path.dirname(__file__)))
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.db import Base
from app.repository import Repository, Joke

@pytest.fixture
def session():
    engine = create_engine('sqlite:///:memory:', connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.close()


def test_create_and_get(session):
    repo = Repository(session)
    j = repo.create_joke('Why?', 'Because.', 'funny', 'me')
    assert j.id is not None
    got = repo.get_joke(j.id)
    assert got.setup == 'Why?'

def test_increment_counts(session):
    repo = Repository(session)
    j = repo.create_joke('A','B')
    assert j.lol_count == 0
    repo.increment_lol(j.id)
    assert repo.get_joke(j.id).lol_count == 1
    repo.increment_groan(j.id)
    assert repo.get_joke(j.id).groan_count == 1

def test_random_and_source(session):
    repo = Repository(session)
    repo.create_joke('S1','P1', category='c1', source='alice')
    repo.create_joke('S2','P2', category='c2', source='bob')
    r = repo.random_joke()
    assert r is not None
    r2 = repo.random_joke(category='c1')
    assert r2.category == 'c1'
    by_source = repo.list_by_source('alice')
    assert len(by_source) == 1
