---
name: research
description: AI research/investigation automation workflow. Receives a topic, determines the research type, executes automatable steps (WebSearch, Gemini CLI, Chrome DevTools YouTube search, NotebookLM MCP) directly, and waits after guiding the user for manual steps (Deep Research via Gemini/Claude/ChatGPT app). Used when the user requests research ("research this", "look into this", etc.). Excludes simple searches ("what is this?") — only applies to investigations requiring synthesis of multiple sources.
---

# /research — AI Research Automation

> Methodology source: `--3-RESOURCES/AI-Creative-Workflows/research-methods.md`
> Core principle: Do not rely on a single AI; chain specialized tools step-by-step.

## Usage
```
/research "Southeast Asia regulated industry market size and certification body comparison"
/research "NotebookLM practical usage latest know-how"
/research "BPJPH Indonesia compliance regulations latest trends"
```

---

## Phase 0: Define Question & Determine Type

Confirm the following with the user (skip if already clear):

1. **Core Question**: What exactly needs to be known?
2. **Scope**: Region? Timeframe? Industry?
3. **Output Format**: Comparison table? Report? Workflow?

Then **automatically determine the research type**:

| Research Type | Criteria | Method to Execute |
|----------|----------|-----------|
| **Quick** | Single fact, simple confirmation | Method 1 |
| **Practical Know-how** | Tool/workflow comparison, "how to use" | Method 2 |
| **Deep** | Market size, policies, strategy, competitive analysis | Method 3 |
| **Academic** | Paper-based, academic evidence required | Method 4 |

Show the determination result to the user and execute after confirmation:
```
"Determined the topic as 'Practical Know-how' type.
Shall we proceed with YouTube + Blog practical content search → NotebookLM cross-analysis?"
```

---

## Method 1: Quick Check (Automatic)

Fully automatic. No manual user work.

```
1. WebSearch: Search with core question (2~3 times)
2. If insufficient → Gemini CLI googleSearch (non-English/in-depth)
3. Once answered → Report immediately including sources
```

---

## Method 2: Practical Know-how Search (Automatic + Partial Manual)

### Step 1: NotebookLM Notebook Creation & Deep Research (Automatic, Highest Priority)
```
1. notebook_create(title="[Topic] Research")
2. research_start(query="[Structured Prompt]", mode="deep", notebook_id="...")
   → NotebookLM automatically searches the web to collect ~40 sources + generates report (~5 mins)
3. Wait for completion with research_status
4. Import core sources with research_import
```
This is the **main engine** for source collection. The remaining steps serve to supplement what NotebookLM missed.
Execute Steps 2~3 in parallel while waiting for Deep Research.

### Step 2: Supplementary Web Search (Automatic, Parallel with Step 1)
```
- WebSearch: "[Topic] practical know-how usage workflow 2026"
- WebSearch: "how I actually use [topic] workflow 2026"
- WebSearch: "reddit [topic] workflow what combination" (Community)
- Gemini CLI googleSearch: Supplementary search (in-depth)
→ Add useful URLs to NotebookLM via source_add
```

### Step 3: YouTube Search (Automatic, Parallel with Step 1)
```
1. Chrome DevTools MCP → Navigate to YouTube search page
   navigate_page(type="url", url="https://www.youtube.com/results?search_query=[Topic+2026]")
2. Batch extract video titles+URLs with evaluate_script
3. Add core video URLs to NotebookLM via source_add (automatic subtitle analysis)
```

### Step 4: Suggest Manual Deep Research (User Action)

> In all types except Quick, **always suggest** manual Deep Research in parallel with automated research.
> Skip if the user says "skip" or "no need". But do not skip without asking first.

Guide the user as follows:

```markdown
## Manual Work Suggestion

While the automated research is running, you can get deeper results
by running the Deep Research below **in parallel**. (Optional — you can skip)

### Gemini App (gemini.google.com) — Recommended
1. Select Deep Research mode
2. Enter the prompt below:
   > [AI-generated structured prompt]
3. ★ Click "Edit plan" → Review/edit the research plan
4. "Start Research" (5~15 mins)
5. Upon completion → **Export to Google Docs**

### Claude App (claude.ai) — Optional
1. Turn on Research button (bottom left, blue)
2. Enter prompt → 5~45 mins, you can close the tab

**Would you like to do this? Or should we proceed only with the automated results?**
When done, please provide the Google Docs link or the result text here.
```

Depending on user response:
- "I'll do it" / "yes" → Provide prompt and wait. Add result to NotebookLM via source_add when received
- "Skip" / "automated only" → Proceed to Step 5

### Step 5: NotebookLM Cross-Analysis & Report (Automatic)
```
1. After all sources are added, notebook_query:
   "Summarize the core workflows, practical tips, and unique know-how from these sources"
2. Follow-up query if needed: "What are the discrepancies or missing perspectives between sources?"
3. Report the results to the user
```

---

## Method 3: Deep Research (Automatic + Manual Mix)

This method mixes **automatic steps** and **manual steps**.

### Step 1: NotebookLM Deep Research (Automatic)
```
1. notebook_create(title="[Topic] Deep Research")
2. research_start(query="[Structured Prompt]", mode="deep", notebook_id="...")
3. Wait for completion with research_status
4. Import core sources with research_import
```
This takes ~5 minutes. Execute Step 2 in parallel while waiting.

### Step 2: Web Supplementary Search (Automatic, Parallel with Step 1)
```
- WebSearch 3~5 items: Search latest data with core keywords
- Gemini CLI googleSearch 2~3 items: Supplementary in-depth search
- WebFetch: Detail extraction of 2~3 core sources
- Add results to NotebookLM via source_add
```

### Step 3: Manual Deep Research (Requires User Action)

> This step must be executed directly by the user in the apps.
> Running 2~3 platforms **simultaneously** saves time.

Guide the user as follows:

```markdown
## Manual Work Guide

Please execute the Deep Research below **in parallel** (2~3 simultaneously):

### Gemini App (gemini.google.com)
1. Select Deep Research mode
2. Enter the prompt below:
   > [AI-generated structured prompt]
3. ★ Click "Edit plan" → Review and modify the research plan if necessary
4. Click "Start Research" (takes 5~15 mins)
5. When complete → Click **Export to Google Docs**

### Claude App (claude.ai) — Optional
1. Turn on Research button (bottom left, blue)
2. Enter the prompt below:
   > [AI-generated structured prompt]
3. Takes 5~45 mins, you can close the tab

### ChatGPT App (chatgpt.com) — Optional
1. Turn on Deep Research toggle
2. Enter the prompt below:
   > [AI-generated structured prompt]
3. Adjust research plan using the Adjust button

**Please let me know here when complete.**
Provide the results using one of the methods below:
- Gemini: Share Google Docs link
- Claude/ChatGPT: Copy + Paste the result text
- Or provide the path after saving as a file
```

The prompt is automatically generated with the template below:
```
Purpose: [Why this research is being done]
Question: [What exactly needs to be known]
Scope: [Region/Timeframe/Industry. Inclusion/Exclusion criteria]
Output: [Table / Executive Summary / Comparative Analysis]
Verification: Include source URLs for each claim. Mark unverified info as 'Unverified'.
Exclusion: [Promotional content / Outdated data]
```

### Step 4: Receive User Results & Integrate into NotebookLM (Automatic)

When the user provides the results:
```
1. Gemini Google Docs → Add Drive source to NotebookLM
   source_add(source_type="drive", document_id="...")
2. Text results → Add text source to NotebookLM
   source_add(source_type="text", text="...", title="Claude Deep Research Results")
3. File → Add file source to NotebookLM
   source_add(source_type="file", file_path="...")
```

### Step 5: NotebookLM Cross-Analysis (Automatic)
```
notebook_query: "Analyze the consensus, discrepancies, and unique claims across all sources.
If there are discrepancies, provide the rationale for which source is more reliable."
```

### Step 6: Discrepancy Resolution & Verification (Automatic)
```
- Discrepancy items → Additional verification via WebSearch/WebFetch
- Core citations → Verify by clicking the original URL
- Unresolvable → Mark as "Unverified"
```

### Step 7: Final Report (Automatic)
```
Report the comprehensive results to the user:
- Core findings
- Agreed facts
- Discrepancies & resolution results
- Unverified items
- List of sources used
```

---

## Method 4: Academic Research (Automatic + Manual Mix)

### Step 1: Paper Discovery (Automatic + Manual)

**Automatic**:
```
- WebSearch: "[Topic] site:scholar.google.com" / "site:semanticscholar.org"
- Gemini CLI googleSearch: Academic keyword search
```

**Guide User to Manual Work**:
```markdown
## Manual Work Guide: Academic Paper Exploration

Please find core papers using the tools below:

### Research Rabbit (researchrabbit.ai) — Free
1. Enter 1~2 seed papers (I will provide the core ones from what I found)
2. Explore citation network → Discover related papers
3. Select 10~15 core papers

### Elicit (elicit.com) — Free/Plus
1. Enter research question: "[Core Question]"
2. Set custom columns in results: Methodology, Sample Size, Key Findings
3. Export table (CSV)

### Consensus (consensus.app) — Free
1. Enter binary research question: "[Does X affect Y?]"
2. Screenshot the Consensus Meter result

**Please let me know here when complete.**
- Research Rabbit: List of core papers (Title+Author)
- Elicit: Path to CSV file
- Consensus: Result screenshot or text
- If you have paper PDFs, please provide the paths as well
```

### Step 2: NotebookLM Synthesis (Automatic)
```
1. notebook_create(title="[Topic] Academic Research")
2. source_add: Paper PDFs, Elicit CSV, related web sources
3. notebook_query: "Compare methodologies, cross-analyze key findings, consensus/discrepancies"
4. Request mind map generation (Studio Panel)
```

### Step 3: Citation Verification (Automatic)
```
- Core papers → Verify existence via WebSearch "site:scholar.google.com [Paper Title]"
- Citation context → Guide user if scite verification is needed
```

---

## Completion Report Format

```markdown
## Research Completion Report

### Core Findings
- [1~5 bullet points]

### Detailed Analysis
[Organized by topic]

### Source Reliability
| Source | Type | Reliability | Notes |
|------|------|--------|------|

### Discrepancies & Unverified
- [Discrepancy items and resolution results]
- [Unverified items]

### NotebookLM Notebook
- ID: [notebook_id]
- URL: [notebook_url]
- Source count: [N] items
- Additional queries available

### Save Suggestion
- [ ] [Save location suggestion (based on PARA)]
- [ ] RAG-Memory save suggestion (for strategic decisions/long-term reference)
```

---

## Tool Dependencies

### Automatic Execution (Claude Code Built-in + MCP)
| Tool | Purpose | Required |
|------|------|------|
| WebSearch | Web search | O |
| WebFetch | Extract URL content | O |
| Gemini CLI (`mcp__gemini-cli__googleSearch`) | Google Search (Non-English/In-depth) | O |
| Chrome DevTools (`mcp__chrome-devtools__*`) | YouTube direct search | O (Method 2) |
| NotebookLM MCP (`mcp__notebooklm-mcp__*`) | Notebook creation/source management/query | O (Methods 2~4) |

### Manual Execution (In User Apps)
| Tool | Purpose | Required |
|------|------|------|
| Gemini App Deep Research | Edit Plan + In-depth research | Method 3 Recommended |
| Claude App Research Mode | In-depth research (Asynchronous) | Method 3 Optional |
| ChatGPT App Deep Research | In-depth research (o4-mini) | Method 3 Optional |
| Research Rabbit / Elicit / Consensus | Academic paper exploration | Method 4 Recommended |

---

## Cautions

- **Do not use Deep Research for Quick Check** — Overkill. WebSearch is sufficient
- **Do not use Deep Research for tool comparisons** — Gathers only marketing posts. Use Method 2 (Practical Know-how)
- **Manual steps must proceed only after user confirmation** — Do not proceed to the next step before receiving the results
- **Upon NotebookLM authentication error**: Execute `/opt/homebrew/bin/uvx --from notebooklm-mcp-cli nlm login`
- **Upon Chrome DevTools browser crash**: `pkill -f "chrome-devtools-mcp/chrome-profile"` and retry
- **Do not skip verification** — ~10% of AI citations are inaccurate. Core facts must be verified against original sources
