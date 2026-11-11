#!/bin/sh
# Latest Metro Vancouver headlines (free endpoint, 60 requests/hour).
# Usage: VANHERE_API_KEY=sk_... ./latest.sh [section]    (see sections.sh for keys)
set -eu
key="${VANHERE_API_KEY:-$(python3 -c 'import json,os; print(json.load(open(os.path.expanduser("~/.vanhere/config.json")))["apiKey"])')}"
curl -fsS -G "https://vanhere.com/api/v1/news/latest" \
  -H "Authorization: Bearer $key" \
  --data-urlencode "lang=en" ${1:+--data-urlencode "section=$1"} |
python3 -c '
import sys, json
for s in json.load(sys.stdin)["data"]["stories"]:
    print("- " + s["title"] + "  [" + s["credibility"]["label"] + ", " + str(s["sourceCount"]) + " sources]")
    print("  " + s["pageUrl"])'
