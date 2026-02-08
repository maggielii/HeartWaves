# Hackathon Plan: Health Screening & Self‑Advocacy App

## Purpose
Build a **non‑diagnostic, ethical health screening and self‑advocacy tool** that helps users:
- Import their Apple Health data
- View clean, understandable summaries
- Answer adaptive screening questions
- Receive a **doctor‑ready PDF** to support clinical conversations

This tool **does not diagnose**. It highlights patterns that *may warrant professional evaluation*.

The system is designed to be **modular**, with a **POTS‑specific module** that can be activated when relevant.

---

## MVP Goals (Hackathon Scope)
1. Import Apple Health–derived data (or demo dataset)
2. Clean + transform data into tidy, daily features
3. Use Google Gemini to:
   - Screen for normal vs. follow‑up‑worthy patterns
   - Generate adaptive screening questions
4. Score responses using app‑side logic (not the LLM)
5. Generate a **doctor‑facing PDF report**
6. Unlock a **POTS module** if indicated

---

## High‑Level Architecture

### Frontend
- React web app (prototype)
- Designed to be portable to SwiftUI later

### Backend
- Lightweight API (Node/Python)
- Data cleaning + feature engineering
- Gemini prompt orchestration
- PDF generation

### Data Handling (Hackathon Mode)
- No accounts required
- Session‑based processing
- No long‑term storage
- Manual delete option

---

## Team Breakdown (3 People)

---

## Person 1 — Frontend Lead (React UI & Flow)

### Responsibilities
- User experience & screens
- Charts and questionnaire UI
- PDF preview & download

### Step‑by‑Step

1. **Landing Page**
   - What the app does
   - Clear medical disclaimer

2. **Consent & Privacy Screen**
   - Non‑diagnostic notice
   - Data processing explanation

3. **Data Import Screen**
   - Upload Apple Health export or demo dataset
   - Progress + validation state

4. **Results Dashboard**
   - Cards: Resting HR, HRV, Sleep, Steps
   - Simple line charts (daily trends)

5. **Questionnaire Screen**
   - Render Gemini‑generated questions
   - Radio / slider / checkbox inputs

6. **Outcome Screen**
   - Ethical summary (no diagnosis)
   - Explanation of what “signals” mean

7. **Doctor PDF Screen**
   - Preview
   - Download button

8. **POTS Module Screen (MVP)**
   - Placeholder + basic logic demo
   - “Future early‑warning system” explanation

### Notes
- Maintain a single app state machine
- Keep UI structure SwiftUI‑portable

---

## Person 2 — Data & Backend Lead

### Responsibilities
- Health data parsing
- Tidy data transformation
- Feature engineering
- PDF generation

### Step‑by‑Step

#### 1. Data Ingestion
Choose one:
- Apple Health export (ZIP/XML)
- CSV derived from HealthKit
- Demo dataset fallback

#### 2. Tidy Data Model
Transform raw data into:

```
(user_session_id, timestamp, metric_type, value, unit, source)
```

Then aggregate into daily features:

```
(date, resting_hr_mean, hr_max, hrv_mean, steps, sleep_duration, sleep_efficiency, standing_minutes)
```

#### 3. Feature Engineering (Dysautonomia‑Relevant)
- Resting HR baseline (rolling median)
- HR spikes during low activity
- HRV suppression trends
- Morning vs evening differences
- Sleep vs next‑day HR patterns
- Frequency of elevated HR events

> Note: These are **proxies**, not diagnostic tests.

#### 4. Gemini‑Safe Summary Object
Send only aggregates, never raw streams:

```
{
  baseline_metrics,
  trend_slopes,
  outlier_counts,
  missingness_report
}
```

#### 5. PDF Report Generation
Include:
- User symptoms (from questionnaire)
- Computed summaries
- 2–4 charts
- “What to discuss with your doctor” section
- “Possible tests to ask about” (neutral phrasing)

---

## Person 3 — LLM, Safety & Prompt Lead

### Responsibilities
- Gemini prompt design
- Safety & ethics guardrails
- Questionnaire logic

### Step‑by‑Step

#### 1. Strict Gemini Output Schema
Gemini must return JSON only:

```
{
  status: "normal" | "needs_followup",
  signals: [],
  questionnaire: [],
  doctor_summary_bullets: [],
  safety_notes: []
}
```

#### 2. Two‑Stage Prompting

**Stage A — Signal Screening**
- Input: feature summary JSON
- Output: normal vs. follow‑up patterns

**Stage B — Questionnaire Generation**
- If normal → short wellness check
- If follow‑up → dysautonomia‑focused questions

#### 3. Scoring Logic (App‑Side)
- Data signal score (0–5)
- Questionnaire score (0–10)

Output categories:
- No strong signals
- Some signals — discuss with clinician
- Stronger signals — evaluation may be warranted

> LLM never assigns diagnoses.

#### 4. Safety Rails
- Always include “not a diagnosis” language
- Escalation message for severe red‑flag symptoms
- Use “consistent with” / “may warrant evaluation” phrasing only

---

## POTS Module Integration

### Activation Conditions
- Screening suggests POTS‑like patterns
- User self‑reports a POTS diagnosis
- Questionnaire score crosses threshold

### Hackathon‑Level POTS Logic
- Simple HR‑baseline comparisons
- Example: HR +30 bpm above baseline during low activity
- Educational, not predictive

### Future Roadmap
- Public dataset pretraining
- Personalized HealthKit fine‑tuning
- Early‑warning lead times (30–60s → minutes)

---

## Build Order (Recommended)
1. Demo dataset + upload UI
2. Tidy data pipeline
3. Dashboard charts
4. Gemini integration
5. Questionnaire flow
6. PDF generation
7. POTS module placeholder
8. Polish + disclaimers

---

## Hackathon Deliverables
- Live demo flow
- Downloadable doctor PDF
- Clear ethics & privacy framing
- Modular architecture
- Roadmap: React → SwiftUI + HealthKit

---

## Positioning for Judges
This is a **patient self‑advocacy and structured data summarization tool**, not a diagnostic system. It helps users communicate patterns to clinicians more effectively and responsibly.

---

*End of plan.*

