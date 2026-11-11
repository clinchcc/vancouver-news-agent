#!/bin/sh
# List the news sections (free endpoint).
set -eu
key="${VANHERE_API_KEY:-$(python3 -c 'import json,os; print(json.load(open(os.path.expanduser("~/.vanhere/config.json")))["apiKey"])')}"
curl -fsS -G "https://vanhere.com/api/v1/news/sections" -H "Authorization: Bearer $key" --data-urlencode "lang=en"
