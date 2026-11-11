#!/bin/sh
# Create a free VanHere account + API key (200 credits). Prints the account and
# password ONCE (write them down) and saves the key to ~/.vanhere/config.json.
set -eu
resp=$(curl -fsS -X POST "https://vanhere.com/api/v1/register?lang=en" \
  -H "Content-Type: application/json" -d '{}')
token=$(printf '%s' "$resp" | python3 -c 'import sys,json; print(json.load(sys.stdin)["data"]["token"])')
mkdir -p ~/.vanhere && chmod 700 ~/.vanhere
printf '{"apiKey":"%s"}\n' "$token" > ~/.vanhere/config.json
chmod 600 ~/.vanhere/config.json
printf '%s' "$resp" | python3 -c '
import sys, json
d = json.load(sys.stdin)["data"]
print("account :", d.get("account", {}).get("username"))
print("password:", d.get("password", "(you chose one)"))
print("login   :", d.get("loginUrl"))
print("Key saved to ~/.vanhere/config.json. Write the account and password down: without an email a lost password cannot be recovered.")'
