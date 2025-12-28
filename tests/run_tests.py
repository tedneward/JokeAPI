#!/usr/bin/env python3
import os
import sys
import json
from urllib import request, error

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

def get_joke(jid):
    code, body = http_request('GET', f'/jokes/{jid}')
    print('Get:', 'HTTP', code)
    print(body)

def update_joke(jid):
    payload = {"setup": "Updated setup", "punchline": "Updated punchline", "category": "Updated"}
    code, body = http_request('PUT', f'/jokes/{jid}', data=payload)
    print('Update:', 'HTTP', code)
    print(body)

def bump(jid, which):
    code, body = http_request('POST', f'/jokes/{jid}/bump/{which}')
    print(f'Bump {which}:', 'HTTP', code)
    print(body)

def get_random():
    code, body = http_request('GET', '/jokes/random')
    print('Random:', 'HTTP', code)
    print(body)

def get_random_category(cat):
    code, body = http_request('GET', f'/jokes/random/category/{cat}')
    print('Random by category:', 'HTTP', code)
    print(body)

def list_by_source(src):
    code, body = http_request('GET', f'/jokes/source/{src}')
    print('By source:', 'HTTP', code)
    print(body)

def delete_joke(jid):
    code, body = http_request('DELETE', f'/jokes/{jid}')
    print('Delete:', 'HTTP', code)

def run_sequence():
    print('Run full sequence of tests against', BASE_URL)
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
    get_random_category('Classic')
    list_by_source('ted')
    delete_joke(jid)
    print('All done')

if __name__ == '__main__':
    run_sequence()
