# Agent Tools — Marketing & ASO Reference

> Companion reference for AI agents working in ARCDistribution.
> ARCDistribution handles the **technical pipeline** (API, automation, CI/CD).
> These external skills provide the **strategic layer** — ASO strategy, copy, analytics, monetization.

---

## When to use each layer

```
arc-aso-keywords        → technical: validates keywords via App Store API
keyword-research        → strategic: research and prioritization methodology

asc-localize-metadata   → technical: submits localized metadata to ASC
metadata-optimization   → strategic: copy quality, conversion optimization

asc-shots-pipeline      → technical: automates screenshot generation
screenshot-optimization → strategic: what to show, messaging, visual hierarchy
```

---

## Available Community Skills

Installed at `~/.agents/skills/` (symlinked from iCloud — available on all studio machines).

### ASO & App Store Strategy

| Skill | What it adds (beyond arc-* / asc-*) |
|---|---|
| `metadata-optimization` | App name, subtitle, description copy — conversion-focused writing |
| `keyword-research` | Keyword prioritization methodology, long-tail strategy, intent analysis |
| `screenshot-optimization` | Screenshot messaging strategy, visual hierarchy, A/B testing approach |
| `aso-audit` | Full ASO health check — gaps, opportunities, competitor positioning |
| `app-store-featured` | Editorial featuring strategy — how to get featured by Apple |
| `competitor-analysis` | Market positioning, differentiation, gap analysis |
| `ab-test-store-listing` | A/B testing methodology for App Store listing elements |

### Growth & Monetization

| Skill | What it adds |
|---|---|
| `monetization-strategy` | Pricing model, subscription design, paywall placement |
| `review-management` | Review response strategy, sentiment analysis, flagging |
| `app-analytics` | Metrics framework, funnel definition, KPI setup |
| `retention-optimization` | Churn reduction, re-engagement, lifecycle messaging |
| `ua-campaign` | Paid user acquisition strategy, creative briefs, channel mix |
| `app-launch` | Pre-launch checklist, launch day execution, post-launch review |
| `localization` | Localization strategy — which markets, cultural adaptation |

### Content & Copy

| Skill | What it adds |
|---|---|
| `copywriting` | Marketing copy for promo text, What's New, notifications |
| `social-content` | Social media content tied to app releases |
| `launch-strategy` | Launch campaign coordination across channels |

---

## MCPs

Configured in `~/.claude/mcp_settings.json`.

| MCP | Relevance for ARCDistribution |
|---|---|
| **XcodeBuildMCP** | Build verification, simulator testing before submission |
| **ARC Linear GitHub MCP** | Tracks release issues in Linear alongside distribution PRs |
| **Firebase MCP** | Analytics and crash data post-release |

---

## Claude Code Plugins

| Plugin | Relevance |
|---|---|
| **swift-lsp** | Swift diagnostics during package development |
| **axiom** | Observability integration |

---

## Skill Load Order

```
ARCDistribution .claude/skills/   → arc-* and asc-* (highest priority)
    ↓
~/.agents/skills/                  → community skills above (strategic layer)
    ↓
~/.claude/skills/                  → (not currently used)
```

Arc-* and asc-* skills always win for technical distribution work.
Community skills complement with strategy and copywriting.

---

## Related Docs

- [`respectaso.md`](respectaso.md) — Local keyword research tool (free, self-hosted)
- [`ARCKnowledge/Tools/agent-tools.md`](../ARCDevTools/ARCKnowledge/Tools/agent-tools.md) — iOS development tools reference

---

*Last updated: 2026-03-28 — ARC Labs Studio*
