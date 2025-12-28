#!/usr/bin/env python3
import os
import sys
import json
from urllib import request, error, parse

BASE_URL = os.environ.get('BASE_URL', 'http://localhost:8000')
CONTENT_TYPE = os.environ.get('CONTENT_TYPE', 'application/json')

def http_request(method, path, data=None, headers=None):
    url = BASE_URL.rstrip('/') + path
    hdrs = {'Content-Type': CONTENT_TYPE}
    if headers:
        hdrs.update(headers)
    body = None
    if data is not None:
        body = json.dumps(data).encode('utf-8')
    req = request.Request(url, data=body, headers=hdrs)
    req.get_method = lambda: method
    try:
        with request.urlopen(req, timeout=10) as resp:
            resp_body = resp.read().decode('utf-8')
            return resp.getcode(), resp_body
    except error.HTTPError as e:
        try:
            body = e.read().decode('utf-8')
        except Exception:
            body = ''
        return e.code, body
    except Exception as e:
        print('Request error:', e)
        raise

def create_joke():
    payload = {
        "setup": "Why did the chicken cross the road?",
        "punchline": "To get to the other side!",
        "category": "Classic",
        "source": "ted"
    }
    code, body = http_request('POST', '/jokes', data=payload)
    print('Create:', 'HTTP', code)
    print(body)
    if code in (200,201):
        obj = json.loads(body)
        return obj.get('id')
    return None

def seed_jokes():
    jokes = [
        {"setup": "I told my computer I needed a break, and it said 'No problem — I'll go to sleep.'", "punchline": "Turns out it just went into airplane mode.", "category": "Generated", "source": "Copilot"},
        {"setup": "Why don't programmers like nature?", "punchline": "It has too many bugs.", "category": "Generated", "source": "Copilot"},
        {"setup": "How many developers does it take to change a light bulb?", "punchline": "None — that's a hardware problem.", "category": "Generated", "source": "Copilot"},
        {"setup": "Why do Java developers wear glasses?", "punchline": "Because they don't C#.", "category": "Generated", "source": "Copilot"},
        {"setup": "I asked the librarian if the library had books on paranoia.", "punchline": "She whispered, 'They're right behind you.'", "category": "Generated", "source": "Copilot"},
        {"setup": "Why did the scarecrow win an award?", "punchline": "Because he was outstanding in his field.", "category": "Generated", "source": "Copilot"}
    ]
    created_ids = []
    print('Seeding database with 6 jokes (source=Copilot, category=Generated)')
    for j in jokes:
        code, body = http_request('POST', '/jokes', data=j)
        print('Seed create:', 'HTTP', code)
        if code in (200,201):
            try:
                obj = json.loads(body)
                created_ids.append(obj.get('id'))
            except Exception:
                pass
    print('Seeded ids:', created_ids)
    return created_ids

def get_joke(jid):
    code, body = http_request('GET', f'/jokes/{jid}')
    print('Get:', 'HTTP', code)
    print(body)

def update_joke(jid):
    payload = {"category": "Generated"}
    code, body = http_request('PUT', f'/jokes/{jid}', data=payload)
    print('Update:', 'HTTP', code)
    print(body)

def bump(jid, which):
    # use hyphenated endpoint to match joke.api: /jokes/{id}/bump-lol and /jokes/{id}/bump-groan
    path = f'/jokes/{jid}/bump-lol' if which == 'lol' else f'/jokes/{jid}/bump-groan'
    code, body = http_request('POST', path)
    print(f'Bump {which}:', 'HTTP', code)
    print(body)

def get_random():
    code, body = http_request('GET', '/jokes/random')
    print('Random:', 'HTTP', code)
    print(body)

def get_random_category(cat):
    # Use query parameter to request random by category per spec: /jokes/random?category=...
    q = parse.quote_plus(cat)
    code, body = http_request('GET', f'/jokes/random?category={q}')
    print('Random by category:', 'HTTP', code)
    print(body)

def list_by_source(src):
    # Use query parameter to filter by source per spec: /jokes?source=...
    q = parse.quote_plus(src)
    code, body = http_request('GET', f'/jokes?source={q}')
    print('By source:', 'HTTP', code)
    print(body)

def delete_joke(jid):
    code, body = http_request('DELETE', f'/jokes/{jid}')
    print('Delete:', 'HTTP', code)

def run_sequence():
    print('Run full sequence of tests against', BASE_URL)
    # seed the DB with a small collection of generated jokes
    seed_jokes()

    jid = create_joke()
    if not jid:
        print('Failed to create joke')
        sys.exit(2)
    print('Created id:', jid)
    get_joke(jid)
    update_joke(jid)
    bump(jid, 'lol')
    bump(jid, 'groan')
    get_random()
    get_random_category('Generated')
    list_by_source('ted')
    delete_joke(jid)
    print('All done')

if __name__ == '__main__':
    run_sequence()
