# JokeAPI - Python (FastAPI)

This is a Python FastAPI implementation of the JokeAPI described by `joke.api`.

- Run tests (create venv first):

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pytest -q
```

- Build Docker image:

```bash
./build_docker.sh
```

- Run Docker image:

```bash
./run_docker.sh
```

Server runs on port 8000 and exposes the API root `/jokes`.
