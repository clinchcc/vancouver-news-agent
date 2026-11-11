---
name: vanhere-news
description: VanHere news companion for Metro Vancouver, B.C. and Canada — the latest headlines, a section, a search, one story with its credibility grade and every original source, the event thread, and a daily morning briefing; plus local job & service classifieds (招聘 / 服务) to browse or post. Use when the user mentions Vancouver, 温哥华, 大温, BC, Canada news, 新闻 or VanHere, asks what is happening around Vancouver, or looks for / wants to post a job or a local service there.
---

# VanHere news

Site: `https://vanhere.com/en` (English; the Chinese site is the default, at `https://vanhere.com`)

VanHere is an **AI agent, not a newsroom**: it collects public reports, merges the ones about the same event, writes a
short bilingual headline and summary, and grades how credible the story is. Every story links to the original reports.

## Triggers

Use this skill when the user says **Vancouver, 温哥华, 大温, BC, Canada news, 新闻 or VanHere**, or asks what is going on in
Metro Vancouver (Burnaby, Richmond, Surrey…), British Columbia or Canada — traffic, housing, transit, weather, local
government, crime, events.

## Token and first use

Check `~/.vanhere/config.json` for an `apiKey` (or the `VANHERE_API_KEY` variable). **If there is one, just use it — no menu.**

**No token (first use)**: this is the **only time to show a menu**. Show this and let the user pick:

> 👋 Welcome to VanHere! First you need a token — a new account comes with 200 credits:
>
>   1. I already have an account　→ log in and get the token
>   2. I'm new　→ sign up
>   3. Continue with Gmail　→ one-click login / sign-up

- **1 Existing account**: give the user https://vanhere.com/en/sign-in?callbackUrl=%2Fsettings%2Fapikeys — after logging in it returns to the keys page. Have them press
  **Copy message** and paste it back to you.
- **3 Gmail**: give the user https://vanhere.com/en/sign-in?provider=google&callbackUrl=%2Fsettings%2Fapikeys — it jumps straight to
  Google (a new user is signed up at the same time) and returns to the keys page; they copy the message the same way.
- **2 Sign up**: ask "Do you want to pick a username and password, or should I sign you up automatically?" (automatic
  is the default; do not hold things up over it). If they choose, ask for a username (3–24 of lowercase letters, digits,
  `_`, `-`) and a password (8+ characters); otherwise send no parameters:

```bash
curl -s -X POST "https://vanhere.com/api/v1/register?lang=en" -H "Content-Type: application/json" -d '{}'
# chosen: -d '{"username":"alice","password":"at least 8 chars"}'
```

  You get `token`, `account` (the username), `password` (only when it was generated) and `loginUrl`.
  **After it succeeds you must**:
  1. save the token (below);
  2. **tell the user the whole account and ask them to write it down**: the username (`account.username`), the generated
     password, and the login page `loginUrl`. **No email is needed**: on the web, type the username in the
     "Email / username" box. With no real email **a forgotten password cannot be recovered** — they must keep it safe;
  3. tell them the token can be copied again later at https://vanhere.com/en/settings/apikeys after logging in.

  Email is optional; to attach a real one, also send `"email": "name@example.com"`. One network may create 3 accounts a
  day; more returns 429.

Once you hold an `sk_...`, save it:

```bash
mkdir -p ~/.vanhere && chmod 700 ~/.vanhere
printf '{"apiKey":"%s"}\n' "sk_..." > ~/.vanhere/config.json
chmod 600 ~/.vanhere/config.json
```

(Later preferences such as `dailyDigest` and `lastCheckIn` go into the same JSON object — merge, never overwrite the key.)

Send `Authorization: Bearer sk_...`. **Never echo the token to the user** (the account and password from sign-up are the
exception — those are for them to write down). Responses look like `{ "code": 0, "message": "ok", "data": ... }`;
`code` is `-1` on failure and `message` says why — tell the user. Add `lang=en` or `lang=zh` to match the user's language (without it the API answers in
Chinese).

## How to respond

**Do not show a menu or make the user pick a feature first**: do what they asked, judging by keywords and intent —

| The user says | Do |
| ------------- | -- |
| "what's new in Vancouver", "today's news", "headlines" | `/news/latest` (free) |
| a topic: "SkyTrain", "housing", "Burnaby fire", "BC election" | `/news/search?q=` with 1–3 short words |
| a section or place: "transit news", "Richmond", "politics" | `/news/sections` then `/news/latest?section=` (or `region=` / `category=`) |
| "tell me more", "is that true?", "who reported it?" | `/news/{id}` — summary, credibility reason, all sources |
| "what happened before?", "the whole story", "updates on…" | `/news/{id}/thread` |
| "morning briefing", "daily digest", "what did I miss today" | `/news/digest` (or `?date=YYYY-MM-DD`) |
| "credits", "balance", "check in" | `/me`, `/checkin` |
| "jobs in Richmond", "hiring", "find a plumber / mover" | `/listings?kind=&region=&q=` (free) |
| "post a job", "advertise my service", "my listings" | `POST /listings`, `/my/listings` — see **Listings** |
| "what are people saying", "大温闲聊", "ask the forum", "post a question" | `/chat` (free) — see **Chat** |

Only when the user asks "what can you do", or the intent truly cannot be told, describe those few things in a sentence or
two — no menu. After finishing one thing just answer; do not ask "anything else?".

## How to present the news (required)

- Each story: the **headline**, one or two sentences of summary, the **credibility** label (`credibility.label`) and the
  source count, and the `pageUrl`. For a detail, list the **original sources** (`sources[].name` + `sources[].url`) —
  the primary one first. Mention when `isHearsay` is true or `articleType` is opinion / sponsored / official release.
- **Never present a summary as verified fact.** Say "VanHere's summary of N reports" or "according to <source>"; for
  `developing`, `unverified` or `disputed` stories say so plainly.
- **Quote the `disclaimer` once per conversation** (the first time you share news), word for word:
  > VanHere is an AI agent, not a newsroom. Headlines and summaries are machine-written from the sources listed, may contain errors, and are not the views of VanHere or its operators. Always verify with the original reports. Report a problem → /corrections.
- Do not paste whole articles; the full text is only at the source — send the user there.

## Credits

Free accounts get **200 credits a month** (a new account starts with them; they reset at the end of each
month). **Pro ($7/month)** gets **5000 credits a month**, **Business ($19/month)**
**20000** — https://vanhere.com/en/pricing. A **daily check-in adds
+15** (valid 30 days).

- Free: `/me`, `/checkin`, `/news/latest`, `/news/sections` (rate limited per hour).
- **1 credit per call**: `/news/digest`, `/news/search`, `/news/{id}`, `/news/{id}/thread`. `credits.balance` in the
  response is what is left. A failed call refunds its credit. With too few credits the API answers **HTTP 402** — offer the
  check-in or https://vanhere.com/en/pricing.
- So **call sparingly**: `/news/latest` answers most "what's new" questions for free; fetch a detail only when the user
  wants more about one story.

**Check-in**: when you are already talking to the user about the news and have not checked in today (`lastCheckIn` in the
config is not today, or `/me` says `checkedInToday: false`), call `POST /api/v1/checkin` **once**, then mention it in
one line ("checked in, +15 credits"). Store `"lastCheckIn": "YYYY-MM-DD"`. **Never** check in on a schedule by itself,
never more than once a day, never as the only reason to message the user.

## Endpoints

All under `https://vanhere.com/api/v1`, with `Authorization: Bearer $VANHERE_API_KEY`.

| Endpoint | Cost | Returns |
| -------- | ---- | ------- |
| `POST /register` | — (no key) | `token`, `account`, `password?`, `loginUrl` |
| `GET /me` | free | `credits`, `callCost`, `checkedInToday`, `plan` (`free`/`pro`/`business`) |
| `POST /checkin` | free | `granted` (15 or 0), `balance`, `nextAt` |
| `GET /news/latest?page=&section=&region=&category=` | free (60/h) | `stories[]`, `page`, `totalPages`, `url` |
| `GET /news/sections` | free (60/h) | `sections[]`: `key`, `label`, `count` (last 7 days), `url` |
| `GET /news/digest?date=YYYY-MM-DD` | 1 | `headlines[]`, `sections[]` with `stories[]`, `total` |
| `GET /news/search?q=&page=` | 1 | `stories[]`, `found`, `url` |
| `GET /news/{id}` | 1 | `story` incl. `credibilityReason`, `sources[]`, `thread[]`, `related[]` |
| `GET /news/{id}/thread` | 1 | `thread[]`, oldest first |

A story has `id`, `title`, `summary`, `credibility` (`key` + `label`: confirmed / official / reliable / developing /
unverified / disputed), `category`, `region`, `articleType`, `isHearsay`, `sourceName`, `sourceCount`,
`firstPublishedAt`, `pageUrl` and `detailApi`. Every response carries `disclaimer`.

```bash
curl -s -G "https://vanhere.com/api/v1/news/latest" -H "Authorization: Bearer $VANHERE_API_KEY" --data-urlencode "lang=en"
curl -s -G "https://vanhere.com/api/v1/news/search" -H "Authorization: Bearer $VANHERE_API_KEY" \
  --data-urlencode "q=skytrain" --data-urlencode "lang=en"
```

## Listings (jobs & services)

VanHere also hosts **classifieds posted by users**: `job` (hiring, 招聘) and `service` (local services, 服务), each with a
title, plain-text content, region, up to 3 images and the poster's contact details. They are **not** written or checked by
VanHere.

| Endpoint | Cost | Returns |
| -------- | ---- | ------- |
| `GET /listings?kind=&region=&q=&page=` | free (60/h) | `listings[]` (no contact), `page`, `totalPages`, `url` |
| `GET /listings/{id}` | 1 | `listing` with `content`, `images[]` and `contact` (`phone`/`email`/`wechat`/`whatsapp`; null once expired); with `lang=en`, a Chinese ad that has a stored machine translation comes back in English (`translation`, `original`) |
| `POST /listings` | free | the new `listing` and `manageUrl` |
| `POST /listings/format` | 2 | `listing` `{ title, content, region, phone, email, wechat, whatsapp, notes }` tidied by AI (nothing saved) |
| `GET /my/listings` | free | `listings[]` (yours, with status and views) and `quota` `{ plan, limit, used }` |
| `POST /uploads` | free (30/h) | `url` of a hosted png/jpeg/webp (≤ 3 MB; raw bytes or multipart `file`) |

`region` is a key: vancouver, burnaby, richmond, surrey, coquitlam, north_vancouver, west_vancouver, new_westminster,
delta, langley, maple_ridge, white_rock, metro_vancouver, bc, canada, international.

- **Browsing**: show title, region, "posted …" and the `pageUrl`; fetch `/listings/{id}` (1 credit) only when the user
  wants the contact or the full text of one listing. Always add, in one line, `listingDisclaimer`: posted by users, not
  verified by VanHere; never pay upfront.
- **Posting** needs a paid plan — **Free 0, Pro ($7/mo) 1, Business ($19/mo,
  20000 credits) 5 active listings** (drafts count; a listing is live for 60 days, then
  expires and can be renewed on the site). Over the limit the API answers **403** with the plan — offer https://vanhere.com/en/pricing.
- Body for `POST /listings` (JSON): `kind` (`job`|`service`), `title` (4–120 chars), `content` (10–2000 chars, plain
  text, paragraphs separated by a blank line), `region`, optional `images` (≤ 3 URLs from `/uploads`), and **at least one**
  of `phone`, `email`, `wechat`, `whatsapp`. `"status": "draft"` saves without publishing.
- **Never invent contact details** (or any fact) in a listing. Use only what the user gave you; if they gave none, ask.
  Show the user the final title, text and contact before posting, and post only after they agree. Write in the user's
  language; do not translate their contact info.
- **Style**: plain and concise, in the advertiser's own voice. Lead with the key fact (role or service, pay or price, place),
  one idea per sentence, keep every fact they gave, and cut adjectives and repetition. No stock phrases ("passionate team",
  "one-stop", "全方位", "助力"), slogans, exclamation marks, emoji, closing summary or well-wishes, and no source or
  "posted by AI" line.
- **Rough text from the user?** Paste it to `POST /listings/format` (`{"kind":"job","text":"…","locale":"en"}`, text ≤ 6000
  chars), show the user the result (and `notes`, if any — e.g. a discriminatory requirement was dropped), then `POST /listings`
  with it once they agree. If `region` comes back `""` or no contact is filled, ask the user.
- Editing, renewing and removing happen on the site: https://vanhere.com/en/settings/listings.

```bash
curl -s -G "https://vanhere.com/api/v1/listings" -H "Authorization: Bearer $VANHERE_API_KEY" \
  --data-urlencode "kind=job" --data-urlencode "region=richmond" --data-urlencode "lang=en"
curl -s -X POST "https://vanhere.com/api/v1/listings" -H "Authorization: Bearer $VANHERE_API_KEY" -H "Content-Type: application/json" \
  -d '{"kind":"job","title":"Line cook wanted","content":"Full time, Richmond...","region":"richmond","phone":"604-555-0100"}'
```

## Chat (大温闲聊)

A **text-only discussion board** where Metro Vancouver residents talk about housing, work, school, immigration and daily
life. Posts are **written by users and not reviewed by VanHere** — relay `notice` in one line when you share them, and
never present a post as fact. Older threads were imported from the previous VanHere forum (their `pageUrl` is the old
`/thread-….html` address). Threads with `kind: "digest"` are **AI-written digests of public discussions** (e.g.
r/vancouver), posted by the account "VanHere 社区小编 (AI)" with `source` (`name`, `url`) and `digestNotice`; they
are bilingual (`titles`/`bodies` carry `zh` and `en`). Say they are AI summaries and link the source.

| Endpoint | Cost | Returns |
| -------- | ---- | ------- |
| `GET /chat?page=&sort=active\|new&q=` | free (60/h) | `threads[]` (`kind`, `title`, `author`, `replyCount`, `lastReplyAt`, `pageUrl`), `page`, `totalPages`, `url` |
| `GET /chat/{id}?page=` | free (60/h) | `thread` with `body`, `replies[]` (50 a page), `replyTotal`; with `lang=en`, stored English translations where they exist (`machineTranslated`, `bodies`) |
| `POST /chat` | free | the new `thread` — JSON `title` (≤ 120 chars) and `body` (≤ 4000 chars, plain text) |
| `POST /chat/{id}/replies` | free | the new `reply` — JSON `body` (≤ 2000 chars, plain text) |

- `sort=active` (default) orders by the latest reply, `new` by creation; `q` matches titles.
- **Posting speaks for the user in public.** Write only what the user asked to say, in their language, show them the exact
  title and text first, and post only after they agree. No ads (jobs and services go to **Listings**), no one's personal
  information. Plain text only — HTML is stripped and images are not supported; links are fine.
- Limits: **10 threads and 60 replies a day** per account (HTTP 429 beyond that). Deleting a post happens on the site:
  https://vanhere.com/en/settings/chat.

```bash
curl -s -G "https://vanhere.com/api/v1/chat" -H "Authorization: Bearer $VANHERE_API_KEY" --data-urlencode "sort=active"
curl -s -X POST "https://vanhere.com/api/v1/chat/THREAD_ID/replies" -H "Authorization: Bearer $VANHERE_API_KEY" \
  -H "Content-Type: application/json" -d '{"body":"Thanks, that helped!"}'
```

## Daily briefing

The first time you share news with the user, after answering, **offer once**: roughly "Want a short morning briefing of
Metro Vancouver news every day? I'll send the headlines with their credibility and links (1 credit a day)."

- If they agree: write `"dailyDigest": { "enabled": true, "time": "08:00", "lang": "en" }` into
  `~/.vanhere/config.json` (ask for a different time only if they mention one), then create a **once-a-day** job with
  your own scheduling ability (scheduled task / cron / heartbeat);
- If they decline: write `"dailyDigest": { "enabled": false }` and **never ask again**;
- If `dailyDigest` is already in the config, do not ask again.

The daily job:

1. `GET /api/v1/news/digest?lang=<lang>` (today in Vancouver time);
2. Send the user a compact briefing: up to ~8 `headlines`, each one line with its credibility label and link, grouped by
   section if there are many; flag developing / unverified ones;
3. End with the disclaimer in one line and the site link https://vanhere.com/en;
4. **If `total` is 0, stay silent.** If it answers 402, tell the user once that credits ran out and offer the check-in or
   Pro, then pause the job until they reply.

If you cannot schedule jobs, say so plainly and offer "ask me for the briefing whenever you like" instead.
