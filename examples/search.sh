#!/bin/sh
# Search the news (1 credit per call). Usage: ./search.sh skytrain
set -eu
[ $# -ge 1 ] || { echo "usage: $0 <1-3 short words>" >&2; exit 64; }
key="${VANHERE_API_KEY:-$(python3 -c 'import json,os; print(json.load(open(os.path.expanduser("~/.vanhere/config.json")))["apiKey"])')}"
curl -fsS -G "https://vanhere.com/api/v1/news/search" -H "Authorization: Bearer $key" \
  --data-urlencode "q=$*" --data-urlencode "lang=en"
