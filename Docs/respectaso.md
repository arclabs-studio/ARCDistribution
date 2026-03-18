# RespectASO — Local Keyword Research Tool

RespectASO is a self-hosted, free alternative to paid ASO tools. It provides keyword volume estimates, difficulty scores, and trending data using the App Store's own search suggestions.

## Why Use It

- **Free** — no subscription
- **Self-hosted** — data stays local
- **Integrates** with `arc-aso-keywords` workflow for keyword validation

## Prerequisites

- Docker and Docker Compose installed
- Docker Desktop running

```bash
# Verify prerequisites
docker --version
docker compose version
```

## Setup

1. Clone the repository:
```bash
git clone https://github.com/EronRodan/respectaso.git ~/Developer/Tools/respectaso
cd ~/Developer/Tools/respectaso
```

2. Start the service:
```bash
docker compose up -d
```

3. Verify it's running:
```bash
open http://localhost:3000
```

## Stopping and Restarting

```bash
# Stop (preserves data)
docker compose stop

# Start again
docker compose start

# Full reset (clears cached data)
docker compose down -v && docker compose up -d
```

## Using RespectASO for ARC Labs Keyword Research

### Integration with arc-aso-keywords skill

When running `/arc-aso-keywords`, the skill will prompt you to optionally validate top keyword candidates with RespectASO.

### Manual workflow

1. Start RespectASO: `docker compose start` (in `~/Developer/Tools/respectaso`)
2. Open http://localhost:3000
3. Enter your app's category and seed keywords
4. Export the keyword list as CSV
5. Use CSV data to inform `keywords.txt` content

### What to look for

| Metric | Good | Bad |
|--------|------|-----|
| Difficulty | < 40 | > 70 |
| Popularity | > 50 | < 20 |
| Trending | ↑ | ↓ |

**Sweet spot**: Keywords with popularity > 40 AND difficulty < 50.

### Keyword tiers from RespectASO data

1. **Exact match targets** (popularity > 60, difficulty < 40): Put in `keywords.txt`
2. **Broad targets** (popularity 40–60): Use in description naturally
3. **Long-tail** (popularity < 40, difficulty < 20): Use in release notes

## Updating RespectASO

```bash
cd ~/Developer/Tools/respectaso
git pull
docker compose pull
docker compose up -d
```

## Troubleshooting

**Port 3000 already in use:**
```bash
docker compose down
docker compose up -d -p 3001:3000
```

**Data not loading:**
```bash
docker compose logs
docker compose restart
```

## Alternative: iTunes Search API (no Docker needed)

If RespectASO is not running, the `arc-aso-keywords` skill falls back to the iTunes Search API for competitive density analysis:

```bash
# Check keyword density (number of results = competition proxy)
curl "https://itunes.apple.com/search?term=<keyword>&entity=software&country=us&limit=10" \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'{d[\"resultCount\"]} apps found')"
```

High result count (> 200) = high competition.
Low result count (< 50) = low competition, good opportunity.
