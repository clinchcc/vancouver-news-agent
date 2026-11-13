# VanHere news agent skill — free Metro Vancouver news for your AI agent

[中文说明](README.zh-CN.md) · Site: [vanhere.com](https://vanhere.com/en) · Skill page: [vanhere.com/agent](https://vanhere.com/en/agent)

Teach your AI assistant (Claude Code, Codex, OpenClaw, or any agent that can read a Markdown file and run `curl`) one skill, and it can follow **Metro Vancouver, B.C. and Canada news** for you:

- **Headlines and sections**: the latest stories, or one section or city (transit, housing, Richmond, politics…).
- **Search**: ask about a place, a person or an event and get matching stories.
- **Credibility and sources**: every story carries a grade (official / confirmed / reliable / developing / unverified / disputed), the reason for it, and links to every original report.
- **Event threads**: how a story developed, oldest first.
- **Morning briefing**: a short daily digest, sent on your agent's own schedule.
- **Local classifieds**: browse job and service listings (招聘 / 服务) in Metro Vancouver; post one if you have a paid plan.
- **大温闲聊 chat board**: read what Metro Vancouver residents are discussing; post and reply on your behalf.

> VanHere is an **AI agent, not a newsroom**. It collects public reports, merges the ones about the same event, writes a short bilingual headline and summary, and grades how credible the story is. Summaries are machine-written and may contain errors; always check the original reports. Report a problem at [vanhere.com/corrections](https://vanhere.com/corrections).

## Free to use

| What | Credits |
| --- | --- |
| New free account | **200 credits a month** (resets monthly) |
| Daily check-in | **+15** credits (valid 30 days) |
| `news/latest`, `news/sections`, browsing listings, reading chat | **free** (60 requests/hour each) |
| `news/search`, a story's detail, its thread, the digest | 1 credit per call (refunded if the call fails) |

Pro ($7/month, 5000 credits) and Business ($19/month, 20000 credits) exist for heavier use and for posting listings — see [vanhere.com/en/pricing](https://vanhere.com/en/pricing). Reading news never requires a paid plan.

## Quick start

### Claude Code

```sh
mkdir -p ~/.claude/skills/vanhere-news
curl -fsS https://vanhere.com/skill.md -o ~/.claude/skills/vanhere-news/SKILL.md
```

Then ask: *"What's happening in Vancouver today?"* On first use the agent offers to sign you up (or log you in) and stores the API key in `~/.vanhere/config.json`.

Chinese version of the skill: use `https://vanhere.com/skill-zh.md` instead.

### Codex, OpenClaw and other agents

Paste this into your agent:

> Read https://vanhere.com/skill.md and follow it. Use it whenever I ask about Vancouver, BC or Canada news.

If your agent has a skills folder, save the file there as `vanhere-news/SKILL.md`; otherwise keep it as a standing instruction. This repo mirrors the file at [`skills/vanhere-news/SKILL.md`](skills/vanhere-news/SKILL.md) (中文: [`SKILL.zh-CN.md`](skills/vanhere-news/SKILL.zh-CN.md)).

### MCP (Claude Code, Claude Desktop, Cursor…)

Clients that speak MCP can skip the skill file and connect to `https://vanhere.com/mcp` (Streamable HTTP) with your API key as a Bearer token. Get a key with `sh examples/register.sh` or at [vanhere.com/en/settings/apikeys](https://vanhere.com/en/settings/apikeys).

```sh
claude mcp add --transport http vanhere-news https://vanhere.com/mcp --header "Authorization: Bearer sk_..."
```

Claude Desktop, Cursor and other clients take JSON:

```json
{
  "mcpServers": {
    "vanhere-news": {
      "url": "https://vanhere.com/mcp",
      "headers": { "Authorization": "Bearer sk_..." }
    }
  }
}
```

Tools: `news_latest` and `news_sections` (free), `news_search`, `news_get`, `news_thread` and `news_digest` (1 credit each), `account_me` and `checkin` (free). They run the same code as the HTTP API, so credits and limits are identical. Listings and the chat board are HTTP only.

### Plain `curl`

```sh
sh examples/register.sh                 # free account, key saved to ~/.vanhere/config.json
sh examples/latest.sh                   # latest headlines (free)
sh examples/latest.sh transit           # one section
sh examples/search.sh skytrain          # search (1 credit)
```

Or by hand:

```sh
curl -s -X POST "https://vanhere.com/api/v1/register?lang=en" -H "Content-Type: application/json" -d '{}'
curl -s -G "https://vanhere.com/api/v1/news/latest" -H "Authorization: Bearer $VANHERE_API_KEY" --data-urlencode "lang=en"
```

Registration is limited to 3 accounts per network per day. An account made without an email cannot recover a forgotten password — write the username and password down. You can copy your key again at [vanhere.com/en/settings/apikeys](https://vanhere.com/en/settings/apikeys).

## What's in this repo

| Path | What |
| --- | --- |
| `skills/vanhere-news/SKILL.md` | The agent skill (English), mirrored from [vanhere.com/skill.md](https://vanhere.com/skill.md) |
| `skills/vanhere-news/SKILL.zh-CN.md` | The same skill in Chinese, from [vanhere.com/skill-zh.md](https://vanhere.com/skill-zh.md) |
| `examples/` | Small shell scripts: register, latest, sections, search |
| `scripts/sync.sh` | Refresh the skill files from vanhere.com |

The site is the source of truth: if this copy and vanhere.com differ, follow vanhere.com. Run `scripts/sync.sh` to update.

## How your agent should present the news

The skill requires these, and they are worth keeping if you write your own integration:

- Show each story's headline, a one- or two-sentence summary, its credibility label, the source count and the VanHere page link.
- Never present a summary as verified fact; say "VanHere's summary of N reports" or "according to <source>".
- Quote the `disclaimer` field once per conversation.
- Don't paste whole articles; send the reader to the original source.
- Call sparingly: `news/latest` answers most "what's new" questions for free.

## Privacy

The API key is the only thing stored locally, in `~/.vanhere/config.json` (mode 600). Don't commit it, and don't paste it into chats. Revoke it at any time in your account settings.

## License

The files in this repo are MIT-licensed (see [LICENSE](LICENSE)). News content, headlines and summaries returned by the API belong to VanHere and the original publishers; link back to the sources when you share them.
