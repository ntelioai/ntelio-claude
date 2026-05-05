---
name: market-analysis
description: Conducts comprehensive market analysis for a product or business idea. Use when the user asks to analyze a market, research competitors, size a market, evaluate a business opportunity, or conduct competitive intelligence. Covers market sizing, competitive landscape, pricing, customer analysis, trends, GTM channels, funding landscape, and barriers to entry.
allowed-tools: Read, Write, Edit, Glob, Grep, WebSearch, WebFetch, AskUserQuestion
user-invocable: true
argument: Product or market description to analyze
---

# Market Analysis

This skill conducts deep, web-research-driven market analysis across 8 dimensions, then synthesizes findings into actionable strategic recommendations.

## When to Use This Skill

- User asks to "analyze the market for X"
- User wants competitive intelligence or landscape mapping
- User needs market sizing (TAM/SAM/SOM)
- User asks to evaluate a business opportunity
- User wants pricing research or benchmarking
- User requests a go-to-market analysis

## Workflow

### Step 0: Understand the Product

If the user provided a product description or argument, use it. Otherwise, check the current working directory for product documentation (CLAUDE.md, README, PRDs, pitch decks) to understand what product/market to analyze.

If still unclear, use AskUserQuestion to ask:
- What product or service are we analyzing?
- What is the target market or customer segment?
- Any specific competitors or comparisons to focus on?

Establish a clear **product description** and **market category** before proceeding.

### Step 1: Market Sizing (TAM/SAM/SOM)

Use WebSearch extensively (3-5 searches) to find:
- Market size reports and forecasts
- Industry growth rates (CAGR)
- Relevant spending data and analyst reports

Search queries to try:
- `"{market category}" market size 2025 2026`
- `"{market category}" TAM forecast CAGR`
- `"{market category}" industry report spending`

**Deliverable**: Estimate TAM, SAM, and SOM with explicit assumptions and math shown. Flag which numbers are verified data vs. estimates.

### Step 2: Competitive Landscape

Use WebSearch (5-8 searches) to map competitors:
- `"best {category} tools 2025"` / `"best {category} software"`
- `"{category}" site:g2.com` / `"{category}" site:capterra.com`
- `"{competitor name}" pricing features`
- `"alternatives to {known competitor}"`
- `"{category}" comparison review`

For each competitor, extract:
- Name, website, founding year
- Pricing model and price points
- Target customer segment
- Key features and differentiators
- Strengths and weaknesses
- Funding raised (if available)

**Organize into tiers:**
- **Tier 1 — Direct competitors**: Same problem, same customer
- **Tier 2 — Adjacent competitors**: Overlapping features or market
- **Tier 3 — Substitutes**: Manual processes, spreadsheets, or workarounds

**Deliverable**: Competitor comparison matrix table.

### Step 3: Pricing & Monetization

Use WebSearch and WebFetch (3-5 searches) to research pricing:
- Fetch competitor pricing pages directly
- `"{competitor}" pricing plans`
- `"{category} software" pricing comparison`
- `"{category}" average deal size contract value`

Extract:
- Pricing models (per-seat, usage-based, flat-rate, freemium)
- Price ranges per tier (starter, pro, enterprise)
- Free trial and freemium strategies
- Common upsells and expansion revenue tactics

**Deliverable**: Pricing landscape summary with gaps and opportunities identified.

### Step 4: Customer & Buyer Analysis

Use WebSearch (3-5 searches) to understand buyers:
- `"{category}" buyer persona ICP`
- `"{competitor}" reviews site:g2.com` (fetch review summaries)
- `"{category}" pain points challenges`
- `"{competitor}" churn reasons switching`
- `"why I switched from {competitor}"`

Extract:
- Ideal Customer Profile (ICP) descriptions
- Key decision-makers and buying committee
- Top 5 pain points driving purchases
- Purchase triggers and buying criteria
- Common objections and churn reasons

**Deliverable**: ICP profiles and pain point analysis.

### Step 5: Industry Trends & Tailwinds

Use WebSearch (3-5 searches) for macro trends:
- `"{category}" trends 2025 2026`
- `"{category}" AI impact transformation`
- `"{category}" regulatory changes compliance`
- `"{industry}" technology shifts`

Identify:
- Macro trends creating opportunity (tailwinds)
- Trends creating risk (headwinds)
- Technology shifts (AI, automation, etc.)
- Regulatory or compliance changes

**Deliverable**: Trend analysis with impact assessment.

### Step 6: Go-to-Market Channels

Use WebSearch (3-5 searches) for GTM intelligence:
- `"{competitor}" growth story how they grew`
- `"{category}" customer acquisition strategy`
- `"{competitor}" marketing strategy`
- `"{category}" PLG product-led growth`

Identify:
- Primary acquisition channels (SEO, PLG, outbound sales, partnerships, community)
- Sales motions (self-serve, inside sales, enterprise sales)
- Content and thought leadership strategies
- Partnership and integration ecosystem plays

**Deliverable**: Channel analysis with recommended GTM approach.

### Step 7: Funding & Investment Landscape

Use WebSearch (2-4 searches) for investment activity:
- `"{category}" funding rounds 2024 2025`
- `"{category}" startup acquisition M&A`
- `"{category}" venture capital investment`

Extract:
- Recent funding rounds in the space (amounts, investors, stages)
- M&A activity and exits
- Investor thesis and what they're betting on
- Market maturity signals

**Deliverable**: Funding landscape summary.

### Step 8: Barriers to Entry & Moats

Use WebSearch (2-3 searches) for defensibility analysis:
- `"{category}" switching costs lock-in`
- `"{category}" network effects moat`
- `"{category}" build vs buy`

Assess:
- Switching costs (data migration, workflow disruption, contracts)
- Network effects (direct, indirect, data)
- Regulatory or compliance barriers
- Technical complexity and build-vs-buy dynamics
- Brand and trust as barriers

**Deliverable**: Barrier assessment with defensibility rating.

---

## Synthesis

After completing all 8 dimensions, produce these final deliverables:

### SWOT Analysis

| | Helpful | Harmful |
|---|---------|---------|
| **Internal** | **Strengths** | **Weaknesses** |
| **External** | **Opportunities** | **Threats** |

Fill in based on all research findings.

### Opportunity Scorecard

Rate each dimension 1-10 with brief justification:

| Dimension | Score (1-10) | Justification |
|-----------|-------------|---------------|
| Market size & growth | | |
| Competitive intensity | | |
| Differentiation potential | | |
| Timing & tailwinds | | |
| Barriers to entry | | |
| **Overall opportunity score** | | |

### Strategic Recommendations

1. **Positioning strategy** — Where to play in the market
2. **Differentiation strategy** — How to win against incumbents
3. **Pricing recommendation** — Model, range, and rationale
4. **Go-to-market approach** — Primary channels and sales motion
5. **Top 3 risks and mitigations** — What could go wrong and how to hedge

### Open Questions

List 5-10 questions that warrant further investigation (customer interviews, deeper research, validation experiments).

---

## Output Format

Save the completed analysis as:
- **Location**: Same directory as the product documentation, or `Research/` directory
- **Filename**: `YYYY-MM-DD_{product-name}_market-analysis.md`
- **Format**: Markdown with tables, clear headers per dimension

### Quality Standards

- **Cite sources** for key data points (include URLs where available)
- **Flag confidence levels** — distinguish verified data from estimates
- **Show your math** for market sizing calculations
- **Be honest** about gaps in research
- **Use tables** for competitor comparisons and scorecards
- **Total web searches**: Aim for 20-30+ across all dimensions

---

## Related Skills

- `/prd-writer` — Create product requirements after market validation
- `/create-fcbo` — Build the product once requirements are defined
