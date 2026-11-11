# VanHere 大温新闻 Agent 技能：让你的 AI 助手免费看懂大温哥华新闻

[English](README.md) · 网站：[vanhere.com](https://vanhere.com) · 技能页：[vanhere.com/agent](https://vanhere.com/agent)

给你的 AI 助手（Claude Code、Codex、OpenClaw，或任何能读 Markdown、能执行 `curl` 的 agent）装上这一个技能，它就能替你关注**大温哥华、BC 省和加拿大的新闻**：

- **头条和栏目**：最新新闻，或某个栏目、某个城市（交通、房产、列治文、政治……）。
- **搜索**：问一个地点、一个人、一件事，得到相关报道。
- **可信度和来源**：每条新闻都有评级（官方 / 多方证实 / 可靠来源 / 进行中 / 未证实 / 有争议）、评级理由，以及全部原始报道的链接。
- **事件时间线**：一件事怎么发展的，从早到晚。
- **每日早报**：按你的 agent 自己的日程发一份简短摘要。
- **本地分类信息**：浏览大温的招聘和服务（付费套餐可发布）。
- **大温闲聊**：看本地居民在聊什么，也可以替你发帖、回帖。

> VanHere 是**AI agent，不是新闻编辑部**。它收集公开报道，把讲同一件事的合并起来，写成简短的中英双语标题和摘要，并评估可信度。摘要由机器撰写，可能有错，请以原始报道为准。发现问题请到 [vanhere.com/corrections](https://vanhere.com/corrections) 反馈。

## 免费使用

| 项目 | 额度 |
| --- | --- |
| 新注册的免费账户 | **每月 200 点**（每月重置） |
| 每日签到 | **+15 点**（30 天有效） |
| `news/latest`、`news/sections`、浏览分类信息、看闲聊 | **免费**（每项每小时 60 次） |
| `news/search`、单条新闻详情、事件时间线、每日摘要 | 每次 1 点（调用失败退回） |

Pro（$7/月，5000 点）和 Business（$19/月，20000 点）适合用得更多或要发布分类信息，见 [vanhere.com/pricing](https://vanhere.com/pricing)。看新闻不需要付费。

## 快速开始

### Claude Code

```sh
mkdir -p ~/.claude/skills/vanhere-news
curl -fsS https://vanhere.com/skill-zh.md -o ~/.claude/skills/vanhere-news/SKILL.md
```

然后问：「今天温哥华有什么新闻？」第一次使用时，助手会带你注册或登录，并把 API key 存到 `~/.vanhere/config.json`。

英文版技能用 `https://vanhere.com/skill.md`。

### Codex、OpenClaw 等其他 agent

把下面这句话发给你的 agent：

> 读 https://vanhere.com/skill-zh.md 并照做。我问温哥华、BC 省或加拿大新闻时就用它。

如果你的 agent 有 skills 目录，就把文件存成 `vanhere-news/SKILL.md`，否则当作常驻指令。本仓库里也有一份镜像：[`skills/vanhere-news/SKILL.zh-CN.md`](skills/vanhere-news/SKILL.zh-CN.md)（英文：[`SKILL.md`](skills/vanhere-news/SKILL.md)）。

### 直接用 `curl`

```sh
sh examples/register.sh                 # 免费注册，key 存到 ~/.vanhere/config.json
sh examples/latest.sh                   # 最新头条（免费）
sh examples/latest.sh transit           # 某个栏目
sh examples/search.sh skytrain          # 搜索（1 点）
```

手动调用：

```sh
curl -s -X POST "https://vanhere.com/api/v1/register" -H "Content-Type: application/json" -d '{}'
curl -s -G "https://vanhere.com/api/v1/news/latest" -H "Authorization: Bearer $VANHERE_API_KEY"
```

同一网络每天最多注册 3 个账户。不填邮箱注册的账户忘记密码无法找回，请把用户名和密码记下来。key 可以随时在 [vanhere.com/settings/apikeys](https://vanhere.com/settings/apikeys) 登录后再复制。

## 仓库内容

| 路径 | 说明 |
| --- | --- |
| `skills/vanhere-news/SKILL.md` | 英文版技能，镜像自 [vanhere.com/skill.md](https://vanhere.com/skill.md) |
| `skills/vanhere-news/SKILL.zh-CN.md` | 中文版技能，来自 [vanhere.com/skill-zh.md](https://vanhere.com/skill-zh.md) |
| `examples/` | 几个 shell 小脚本：注册、最新、栏目、搜索 |
| `scripts/sync.sh` | 从 vanhere.com 更新技能文件 |

以网站为准：这里的副本和 vanhere.com 不一致时，按 vanhere.com 的来，运行 `scripts/sync.sh` 更新。

## 怎样向用户展示新闻

技能里要求这样做，自己写集成时也值得保留：

- 每条新闻给出标题、一两句摘要、可信度标签、来源数量和 VanHere 页面链接。
- 不把摘要说成已核实的事实，写「VanHere 对 N 篇报道的摘要」或「据 <来源>」。
- 每次对话第一次分享新闻时，引用一次 `disclaimer`。
- 不整篇粘贴原文，让读者去原始来源看。
- 省着调用：`news/latest` 免费，能回答大多数「有什么新闻」。

## 隐私

本地只保存 API key，在 `~/.vanhere/config.json`（权限 600）。不要提交到仓库，也不要贴到聊天里；可以随时在账户设置里作废。

## 许可

本仓库的文件使用 MIT 许可（见 [LICENSE](LICENSE)）。API 返回的新闻标题、摘要等内容归 VanHere 和原始发布方所有，分享时请带上来源链接。
