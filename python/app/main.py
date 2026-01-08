from fastapi import FastAPI, HTTPException, Depends
from .models import JokeCreate, JokeOut, JokeUpdate
from .db import SessionLocal, init_db
from .repository import Repository
from sqlalchemy.orm import Session
from typing import Optional, List

app = FastAPI()

# initialize DB and tables
init_db()


# dependency
def get_repo():
    db = SessionLocal()
    try:
        repo = Repository(db)
        yield repo
    finally:
        db.close()

@app.get('/jokes', response_model=List[JokeOut])
def list_jokes(repo: Repository = Depends(get_repo)):
    return repo.list_jokes()

@app.post('/jokes', response_model=JokeOut, status_code=201)
def create_joke(j: JokeCreate, repo: Repository = Depends(get_repo)):
    joke = repo.create_joke(j.setup, j.punchline, j.category or "", j.source or "me")
    return joke

@app.post('/jokes/{joke_id}/lol')
def bump_lol(joke_id: int, repo: Repository = Depends(get_repo)):
    res = repo.increment_lol(joke_id)
    if res is None:
        raise HTTPException(status_code=404, detail='Not found')
    return {'lol_count': res}


@app.post('/jokes/{joke_id}/groan')
def bump_groan(joke_id: int, repo: Repository = Depends(get_repo)):
    res = repo.increment_groan(joke_id)
    if res is None:
        raise HTTPException(status_code=404, detail='Not found')
    return {'groan_count': res}


@app.get('/jokes/random', response_model=JokeOut)
def random_joke(category: Optional[str] = None, repo: Repository = Depends(get_repo)):
    joke = repo.random_joke(category)
    if not joke:
        raise HTTPException(status_code=404, detail='No jokes')
    return joke


@app.get('/jokes/source/{source}', response_model=List[JokeOut])
def jokes_by_source(source: str, repo: Repository = Depends(get_repo)):
    return repo.list_by_source(source)


# Standard CRUD routes (placed after static routes to avoid path collisions)
@app.get('/jokes/{joke_id}', response_model=JokeOut)
def get_joke(joke_id: int, repo: Repository = Depends(get_repo)):
    joke = repo.get_joke(joke_id)
    if not joke:
        raise HTTPException(status_code=404, detail='Not found')
    return joke


@app.put('/jokes/{joke_id}', response_model=JokeOut)
def update_joke(joke_id: int, j: JokeUpdate, repo: Repository = Depends(get_repo)):
    updated = repo.update_joke(joke_id, setup=j.setup, punchline=j.punchline, category=j.category, source=j.source)
    if not updated:
        raise HTTPException(status_code=404, detail='Not found')
    return updated


@app.delete('/jokes/{joke_id}', status_code=204)
def delete_joke(joke_id: int, repo: Repository = Depends(get_repo)):
    ok = repo.delete_joke(joke_id)
    if not ok:
        raise HTTPException(status_code=404, detail='Not found')
    return None


# Backwards-compatible bump endpoints expected by tests/run_tests.py
@app.post('/jokes/{joke_id}/bump-lol')
def bump_lol_alias(joke_id: int, repo: Repository = Depends(get_repo)):
    res = repo.increment_lol(joke_id)
    if res is None:
        raise HTTPException(status_code=404, detail='Not found')
    return {'lol_count': res}


@app.post('/jokes/{joke_id}/bump-groan')
def bump_groan_alias(joke_id: int, repo: Repository = Depends(get_repo)):
    res = repo.increment_groan(joke_id)
    if res is None:
        raise HTTPException(status_code=404, detail='Not found')
    return {'groan_count': res}

@app.get('/')
def root():
    return {'status': 'ok'}
