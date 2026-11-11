---
name: vanhere-news
description: VanHere 大温新闻助手——大温哥华、BC 省和加拿大的最新新闻、分栏目、搜索、单条新闻的可信度评级和全部原始来源、事件时间线，以及每天早上的新闻简报；还有用户发布的本地招聘和服务分类信息，可浏览也可发布。用户提到「温哥华」「大温」「Vancouver」「BC」「加拿大新闻」「新闻」「VanHere」，问温哥华附近发生了什么，或想在大温找工作、找服务、发招聘 / 服务信息时使用。
---

# VanHere 大温新闻

站点：`https://vanhere.com`（英文版在 `https://vanhere.com/en`）

VanHere 是一个 **AI agent，不是新闻编辑部**：它收集公开报道，把同一事件的报道合并，写出简短的中英文标题和摘要，
并给出可信度评级。每条新闻都附原始报道链接。

## 触发词

用户的话里出现 **温哥华、大温、Vancouver、BC、加拿大新闻、新闻、VanHere**，或者问大温（本拿比、列治文、素里……）、
BC 省、加拿大发生了什么——交通、房产、公交、天气、市政、治安、活动——就用这个 skill。

## 令牌与第一次使用

先看 `~/.vanhere/config.json` 里有没有 `apiKey`（或环境变量 `VANHERE_API_KEY`）。**有就直接用，不用出任何菜单。**

**没有令牌（第一次用）**：这是**唯一需要出菜单**的时候，先出这个，让用户选：

> 👋 欢迎使用 VanHere！先要一个令牌（token），新账号送 200 积分：
>
>   1. 我已有账号　→ 登录后拿令牌
>   2. 我是新用户　→ 注册
>   3. 用 Gmail 账号一键登录 / 注册

- **1 已有账号**：把这个链接给用户 https://vanhere.com/sign-in?callbackUrl=%2Fsettings%2Fapikeys ——登录后会自动回到密钥页。让他点页面上的"复制消息"，把带 token 的那段话贴回来。
- **3 Gmail**：把这个链接给用户 https://vanhere.com/sign-in?provider=google&callbackUrl=%2Fsettings%2Fapikeys ——点开直接跳转 Google
  登录（新用户同时完成注册），登录后回到密钥页，同样复制消息贴回来。
- **2 注册**：问用户"用户名和密码你自己定，还是我帮你自动注册？"（默认自动，别为此多问）。
  用户自己定，就让他给用户名（3 到 24 位小写字母、数字、`_`、`-`）和密码（至少 8 位）；自动就不带参数：

```bash
curl -s -X POST "https://vanhere.com/api/v1/register" -H "Content-Type: application/json" -d '{}'
# 自己定： -d '{"username":"alice","password":"至少8位"}'
```

  返回 `token`、`account`（账号）、自动生成时才有的 `password`、`loginUrl`。**成功后必须这样做**：
  1. 保存 token（见下面）；
  2. **把账号信息完整告诉用户，并叮嘱他记下来**：账号（`account.username`）、密码（自动生成的）、网页登录地址 `loginUrl`。
     **不需要邮箱**：网页登录时「邮箱 / 账号」那一栏直接填账号就行。因为没有真实邮箱，**密码忘了没法找回**，要他自己保管；
  3. 告诉他令牌以后也能在 https://vanhere.com/settings/apikeys 登录后重新复制。

  邮箱不是必填；想绑定真实邮箱的话，可以多传 `"email": "name@example.com"`。同一个网络每天最多注册 3 个账号，超了返回 429。

收到或拿到 `sk_...` 后保存：

```bash
mkdir -p ~/.vanhere && chmod 700 ~/.vanhere
printf '{"apiKey":"%s"}\n' "sk_..." > ~/.vanhere/config.json
chmod 600 ~/.vanhere/config.json
```

（之后的偏好，比如 `dailyDigest`、`lastCheckIn`，都写进同一个 JSON 对象——合并写入，别把 apiKey 覆盖掉。）

请求头带 `Authorization: Bearer sk_...`。**不要把 token 回显给用户**（注册时的账号和密码除外，那是要他记下的）。返回的 JSON 形如
`{ "code": 0, "message": "ok", "data": ... }`，失败时 `code` 为 `-1`，`message` 说明原因，如实告诉用户。
请求带 `lang=zh`（不带时默认就是中文；用户说英文就用 `lang=en`）。

## 怎么响应

**不要弹菜单，也不要让用户先选功能**：用户说了什么就直接做什么，按关键词和意图判断——

| 用户的话 | 做什么 |
| -------- | ------ |
| "温哥华最近有什么新闻"、"今天的新闻"、"头条" | `/news/latest`（免费） |
| 某个话题："天车"、"房价"、"本拿比火灾"、"BC 选举" | `/news/search?q=`，用 1 到 3 个短词 |
| 某个栏目或地方："交通新闻"、"列治文"、"政治" | `/news/sections`，再 `/news/latest?section=`（或 `region=` / `category=`） |
| "详细说说"、"这是真的吗"、"谁报道的" | `/news/{id}`——摘要、可信度理由、全部来源 |
| "之前怎么回事"、"来龙去脉"、"后续" | `/news/{id}/thread` |
| "早报"、"今日简报"、"今天错过了什么" | `/news/digest`（或 `?date=YYYY-MM-DD`） |
| "积分"、"余额"、"签到" | `/me`、`/checkin` |
| "列治文招聘"、"找工作"、"找装修师傅 / 搬家" | `/listings?kind=&region=&q=`（免费） |
| "帮我发招聘"、"发个服务广告"、"我的信息" | `POST /listings`、`/my/listings`——见下面**分类信息** |
| "大家怎么说"、"大温闲聊"、"去论坛问问"、"帮我发个帖" | `/chat`（免费）——见下面**大温闲聊** |

只有用户问"你能做什么"，或者意图实在判断不出来时，才用几句话列出上面这几件事，不要画菜单。
做完一件事就直接回答，不要追问"还要做别的吗"。

## 怎么呈现新闻（必须遵守）

- 每条新闻：**标题**、一两句摘要、**可信度**（`credibility.label`）和来源数、`pageUrl`。看详情时列出**原始来源**
  （`sources[].name` + `sources[].url`），主来源排第一。`isHearsay` 为真、或 `articleType` 是评论 / 赞助 / 官方通稿时要说明。
- **不要把摘要当成已核实的事实。** 说"VanHere 汇总了 N 篇报道"或"据 <来源> 报道"；`developing`（发展中）、
  `unverified`（未证实）、`disputed`（有争议）的新闻要直接点明。
- **每次对话引用一次 `disclaimer`**（第一次给用户看新闻时），原文照录：
  > VanHere 是一个 AI agent，不是新闻编辑部。标题和摘要由 AI 根据所列来源自动改写，可能有误，不代表 VanHere 或运营者的观点。请以原始报道为准。发现问题 → /corrections。
- 不要整篇转贴原文；全文只在来源网站，请用户去原文看。

## 积分

免费用户**每月 200 积分**（新账号注册即得，每月月底清零重发）。**Pro（每月 $7）每月 5000 积分**，**Business（每月 $19）每月 20000 积分**——
https://vanhere.com/pricing。**每天签到 +15**（30 天内有效）。

- 免费：`/me`、`/checkin`、`/news/latest`、`/news/sections`（每小时有次数上限）。
- **每次调用扣 1 积分**：`/news/digest`、`/news/search`、`/news/{id}`、`/news/{id}/thread`。响应里的 `credits.balance`
  是剩余积分。失败的请求会退回积分。余额不足返回 **HTTP 402**——提醒用户签到，或给出 https://vanhere.com/pricing。
- 所以**少调用**："最近有什么新闻"用免费的 `/news/latest` 就能回答；用户想深入了解某一条时才取详情。

**签到**：你本来就在和用户聊新闻、而且今天还没签到（配置里的 `lastCheckIn` 不是今天，或 `/me` 返回
`checkedInToday: false`）时，调用一次 `POST /api/v1/checkin`，然后用一句话告诉用户（"已签到，+15 积分"），并写入
`"lastCheckIn": "YYYY-MM-DD"`。**不要**自己定时签到，一天不超过一次，也不要只为签到去打扰用户。

## 接口

都在 `https://vanhere.com/api/v1` 下，请求头带 `Authorization: Bearer $VANHERE_API_KEY`。

| 接口 | 积分 | 返回 |
| ---- | ---- | ---- |
| `POST /register` | —（不用令牌） | `token`、`account`、`password?`、`loginUrl` |
| `GET /me` | 免费 | `credits`、`callCost`、`checkedInToday`、`plan`（`free`/`pro`/`business`） |
| `POST /checkin` | 免费 | `granted`（15 或 0）、`balance`、`nextAt` |
| `GET /news/latest?page=&section=&region=&category=` | 免费（60 次/小时） | `stories[]`、`page`、`totalPages`、`url` |
| `GET /news/sections` | 免费（60 次/小时） | `sections[]`：`key`、`label`、`count`（近 7 天）、`url` |
| `GET /news/digest?date=YYYY-MM-DD` | 1 | `headlines[]`、按栏目分组的 `sections[].stories[]`、`total` |
| `GET /news/search?q=&page=` | 1 | `stories[]`、`found`、`url` |
| `GET /news/{id}` | 1 | `story`，含 `credibilityReason`、`sources[]`、`thread[]`、`related[]` |
| `GET /news/{id}/thread` | 1 | `thread[]`，从早到晚 |

每条新闻有 `id`、`title`、`summary`、`credibility`（`key` + `label`：confirmed 已证实 / official 官方 / reliable 可靠 /
developing 发展中 / unverified 未证实 / disputed 有争议）、`category`、`region`、`articleType`、`isHearsay`、`sourceName`、
`sourceCount`、`firstPublishedAt`、`pageUrl` 和 `detailApi`。每个响应都带 `disclaimer`。

```bash
curl -s -G "https://vanhere.com/api/v1/news/latest" -H "Authorization: Bearer $VANHERE_API_KEY" --data-urlencode "lang=zh"
curl -s -G "https://vanhere.com/api/v1/news/search" -H "Authorization: Bearer $VANHERE_API_KEY" \
  --data-urlencode "q=天车" --data-urlencode "lang=zh"
```

## 分类信息（招聘与服务）

VanHere 还有**用户自己发布的分类信息**：`job`（招聘）和 `service`（服务），每条有标题、纯文本正文、地区、最多 3 张图片和
发布者的联系方式。这些内容**不是** VanHere 写的，也没有经过核实。

| 接口 | 积分 | 返回 |
| ---- | ---- | ---- |
| `GET /listings?kind=&region=&q=&page=` | 免费（60 次/小时） | `listings[]`（不含联系方式）、`page`、`totalPages`、`url` |
| `GET /listings/{id}` | 1 | `listing`，含 `content`、`images[]` 和 `contact`（`phone`/`email`/`wechat`/`whatsapp`；过期后为 null）；`lang=en` 时，已有机器翻译的中文信息返回英文（`translation`、`original`） |
| `POST /listings` | 免费 | 新建的 `listing` 和 `manageUrl` |
| `POST /listings/format` | 2 | AI 整理后的 `listing` `{ title, content, region, phone, email, wechat, whatsapp, notes }`（不保存） |
| `GET /my/listings` | 免费 | 自己的 `listings[]`（状态、浏览量）和 `quota` `{ plan, limit, used }` |
| `POST /uploads` | 免费（30 次/小时） | 托管后的图片 `url`（png/jpeg/webp，≤ 3 MB；直接发图片字节或 multipart `file`） |

`region` 用英文键：vancouver 温哥华、burnaby 本拿比、richmond 列治文、surrey 素里、coquitlam 高贵林、north_vancouver 北温、
west_vancouver 西温、new_westminster 新西敏、delta 三角洲、langley 兰里、maple_ridge 枫树岭、white_rock 白石、
metro_vancouver 大温其他、bc、canada、international。

- **浏览**：给出标题、地区、发布时间和 `pageUrl`；用户想要某一条的联系方式或全文时，才调用 `/listings/{id}`（1 积分）。
  每次都用一句话附上 `listingDisclaimer`：信息由用户发布，VanHere 不做核实，切勿预先付款。
- **发布**需要付费套餐——**免费 0 条，Pro（每月 $7）1 条，Business（每月 $19，
  20000 积分）5 条**同时有效的信息（草稿也算；发布后有效 60 天，过期后可在网站上续期）。
  超出上限返回 **403** 并说明当前套餐——给出 https://vanhere.com/pricing。
- `POST /listings` 的 JSON：`kind`（`job`|`service`）、`title`（4 到 120 字）、`content`（10 到 2000 字，纯文本，段落之间空一行）、
  `region`、可选 `images`（最多 3 个 `/uploads` 返回的 URL），以及 `phone`、`email`、`wechat`、`whatsapp` **至少一项**。
  传 `"status": "draft"` 只存草稿不发布。
- **绝不能编造联系方式**（或任何事实）。只用用户提供的信息；没给联系方式就问用户。发布前把最终的标题、正文和联系方式给用户看，
  用户同意后再发。用用户的语言写，联系方式原样保留不要翻译。写中文时，地名、人名、公司/机构/品牌名保持英文原文，不翻译不音译
  （写 "Port Hardy"，不写"哈迪港"；只有温哥华、本拿比、列治文这类本站地区名可以写中文）。
- **文风**：简洁平实，用发布者自己的口吻。先说关键事实（职位或服务、薪酬或价格、地点），一句一个意思，用户给的事实全部保留，
  删形容词和重复。不用套话（"值得注意的是""一站式""全方位""助力"）、口号、感叹号、emoji、结尾总结或祝福，不写出处尾巴，不提 AI。
- **用户给的是草稿/乱糟糟的文字？** 把原文发到 `POST /listings/format`（`{"kind":"job","text":"…","locale":"zh"}`，text 最多 6000 字），
  把整理结果（以及 `notes`，例如删掉了歧视性要求）给用户看，用户同意后再 `POST /listings`。`region` 为 `""` 或没有联系方式时，问用户。
- 修改、续期、删除在网站上操作：https://vanhere.com/settings/listings。

```bash
curl -s -G "https://vanhere.com/api/v1/listings" -H "Authorization: Bearer $VANHERE_API_KEY" \
  --data-urlencode "kind=job" --data-urlencode "region=richmond" --data-urlencode "lang=zh"
```

## 大温闲聊（Chat）

大温闲聊是一个**纯文字讨论区**，大温居民在这里聊租房买房、工作、读书、移民和日常生活。帖子**由用户发布，VanHere 未经审核**——
转述时用一句话带上 `notice`，不要把帖子内容当成事实。较早的帖子是从旧版 VanHere 论坛导入的（它们的 `pageUrl` 是原来的
`/thread-….html` 地址）。`kind: "digest"` 的帖子是 **AI 整理的公开讨论摘要**（例如 r/vancouver），由账号
“VanHere 社区小编 (AI)”发布，带 `source`（`name`、`url`）和 `digestNotice`，中英双语（`titles`/`bodies` 含 `zh` 和
`en`）。转述时说明是 AI 摘要并附上来源链接。

| 接口 | 积分 | 返回 |
| ---- | ---- | ---- |
| `GET /chat?page=&sort=active\|new&q=` | 免费（60 次/小时） | `threads[]`（`kind`、`title`、`author`、`replyCount`、`lastReplyAt`、`pageUrl`）、`page`、`totalPages`、`url` |
| `GET /chat/{id}?page=` | 免费（60 次/小时） | `thread`（含 `body`）、`replies[]`（每页 50 条）、`replyTotal`；`lang=en` 时返回已存的英文翻译（`machineTranslated`、`bodies`） |
| `POST /chat` | 免费 | 新帖子 `thread`——JSON：`title`（不超过 120 字）、`body`（不超过 4000 字，纯文本） |
| `POST /chat/{id}/replies` | 免费 | 新回复 `reply`——JSON：`body`（不超过 2000 字，纯文本） |

- `sort=active`（默认）按最新回复排序，`new` 按发帖时间；`q` 搜索标题。
- **发帖是以用户的名义公开发言。** 只写用户要说的内容、用他的语言，先把标题和正文原样给他确认，同意后再发。不发广告（招聘和服务请发
  **分类信息**），不涉及任何人的隐私。只支持纯文本——HTML 会被去掉，不支持图片，可以贴链接。
- 限制：每个账号**每天最多 10 个帖子、60 条回复**（超出返回 HTTP 429）。删除帖子请到网站上操作：https://vanhere.com/settings/chat。

```bash
curl -s -G "https://vanhere.com/api/v1/chat" -H "Authorization: Bearer $VANHERE_API_KEY" --data-urlencode "sort=active" --data-urlencode "lang=zh"
curl -s -X POST "https://vanhere.com/api/v1/chat/THREAD_ID/replies" -H "Authorization: Bearer $VANHERE_API_KEY" \
  -H "Content-Type: application/json" -d '{"body":"谢谢，很有帮助！"}'
```

## 每日早报

第一次给用户看完新闻、回答完之后，**只问一次**，话术大意是："要不要每天早上给你发一份大温新闻简报？我会把当天的标题、
可信度和链接整理好发给你（每天 1 积分）。"

- 用户同意：把 `"dailyDigest": { "enabled": true, "time": "08:00", "lang": "zh" }` 写进 `~/.vanhere/config.json`
  （用户提到别的时间才改），然后用你自己的定时能力（定时任务 / cron / 心跳）建一个**每天一次**的任务；
- 用户拒绝：写 `"dailyDigest": { "enabled": false }`，以后**不要再问**；
- 配置里已经有 `dailyDigest`，就不要重复问。

每天的任务这样做：

1. `GET /api/v1/news/digest?lang=<lang>`（温哥华时间的今天）；
2. 给用户发一份简短的早报：最多 8 条左右 `headlines`，每条一行，带可信度和链接，条数多时按栏目分组；发展中 / 未证实的要标出来；
3. 最后用一行附上免责声明和站点链接 https://vanhere.com；
4. **`total` 为 0 就不打扰用户**。返回 402 时告诉用户一次积分用完了，提醒签到或升级 Pro，然后暂停任务等他回复。

如果你这边没法做定时任务，就如实告诉用户，改成"想看的时候跟我说一声"。
