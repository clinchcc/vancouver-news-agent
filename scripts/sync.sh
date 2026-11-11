#!/bin/sh
# Refresh the skill files from vanhere.com (the site is the source of truth).
set -eu
cd "$(dirname "$0")/.."
curl -fsS https://vanhere.com/skill.md -o skills/vanhere-news/SKILL.md
curl -fsS https://vanhere.com/skill-zh.md -o skills/vanhere-news/SKILL.zh-CN.md
echo "updated: $(wc -c < skills/vanhere-news/SKILL.md) / $(wc -c < skills/vanhere-news/SKILL.zh-CN.md) bytes"
