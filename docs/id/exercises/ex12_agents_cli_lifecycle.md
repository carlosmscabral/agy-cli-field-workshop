# Latihan 12: Siklus Hidup Agen ADK dengan agents-cli

> **Durasi:** 45 menit | **Modul:** 5 — Membangun Agen ADK dengan agents-cli

---

## Tujuan

Gunakan `agents-cli` untuk membuat kerangka (scaffold), membangun, mengevaluasi, dan melakukan iterasi pada agen ADK — mengikuti siklus hidup pengembangan secara penuh. Anda akan membangun agen **Peringkas Catatan Rapat** yang mengambil transkrip rapat mentah dan menghasilkan item tindakan terstruktur.

---

## Prasyarat

- `agents-cli` terinstal (`uvx google-agents-cli setup`)
- `uv` terinstal ([panduan instalasi](https://docs.astral.sh/uv/getting-started/installation/))
- Proyek Google Cloud atau [kunci API AI Studio](https://aistudio.google.com/apikey)
- Antigravity CLI (agy) terinstal dan berfungsi

---

## Bagian 1: Scaffold Agen (10 menit)

### Langkah 1: Buat Proyek

Buka sesi Antigravity CLI dan lakukan scaffold:

```bash
agents-cli scaffold create meeting-notes \
  --agent adk \
  --prototype \
  --agent-guidance-filename GEMINI.md
```

!!! info "Mengapa `--prototype`?"
    Flag prototype melewati CI/CD dan Terraform — Anda fokus untuk membuat agen berfungsi terlebih dahulu, lalu menambahkan penerapan nanti dengan `scaffold enhance`.

### Langkah 2: Jelajahi Struktur yang Di-scaffold

```bash
cd meeting-notes
tree -L 2
```

Anda akan melihat:

```text
meeting-notes/
├── app/
│   ├── __init__.py
│   ├── agent.py
│   └── tools.py
├── tests/
│   └── eval/
│       ├── datasets/
│       │   └── basic-dataset.json
│       └── eval_config.yaml
├── .env
├── agents-cli-manifest.yaml
├── pyproject.toml
├── GEMINI.md
└── Makefile
```

### Langkah 3: Instal Dependensi

Scaffold membuat `pyproject.toml` dengan dependensi ADK yang benar. Instal dependensi tersebut:

```bash
uv sync
```

!!! note "google-adk ≠ google-antigravity"
    Modul 3 menggunakan `google-antigravity` (Antigravity SDK untuk membangun agen di dalam agy). Modul 5 menggunakan `google-adk` (Agent Development Kit untuk membangun agen ADK mandiri yang diterapkan ke Google Cloud). Keduanya adalah paket yang berbeda dengan API yang berbeda. `agents-cli scaffold` selalu melakukan pengaturan `google-adk` secara otomatis.

### Langkah 4: Konfigurasi Lingkungan

```bash
# If using AI Studio:
echo 'GOOGLE_API_KEY=your-key-here' >> .env

# If using Google Cloud:
echo 'GOOGLE_CLOUD_PROJECT=your-project-id' >> .env
echo 'GOOGLE_CLOUD_LOCATION=us-east1' >> .env
```

---

## Bagian 2: Membangun Agen (15 menit)

### Langkah 1: Mendefinisikan Alat

Edit `app/tools.py` untuk menambahkan alat ekstraksi transkrip:

```python
def extract_action_items(transcript: str) -> dict:
    """Parse a meeting transcript and extract structured action items.

    Args:
        transcript: The raw meeting transcript text.

    Returns:
        A dict containing the parsed action items with assignees and deadlines.
    """
    # In a real agent, this might call a document API or parse structured formats.
    # For now, return the transcript for the LLM to process.
    return {
        "transcript_length": len(transcript),
        "raw_text": transcript[:5000],  # Cap at 5K chars for context window
        "status": "ready_for_analysis",
    }


def format_summary(
    title: str,
    attendees: list[str],
    action_items: list[dict],
    key_decisions: list[str],
) -> str:
    """Format the meeting summary into a structured markdown report.

    Args:
        title: Meeting title or topic.
        attendees: List of attendee names.
        action_items: List of dicts with 'task', 'assignee', and 'deadline' keys.
        key_decisions: List of key decisions made during the meeting.

    Returns:
        A formatted markdown string with the complete meeting summary.
    """
    lines = [f"# {title}", ""]
    lines.append(f"**Attendees:** {', '.join(attendees)}")
    lines.append("")
    lines.append("## Action Items")
    for i, item in enumerate(action_items, 1):
        assignee = item.get("assignee", "Unassigned")
        deadline = item.get("deadline", "TBD")
        lines.append(f"{i}. **{item['task']}** — {assignee} (due: {deadline})")
    lines.append("")
    lines.append("## Key Decisions")
    for decision in key_decisions:
        lines.append(f"- {decision}")
    return "\n".join(lines)
```

### Langkah 2: Mengonfigurasi Agen

Edit `app/agent.py`:

```python
from google.adk import Agent
from app.tools import extract_action_items, format_summary

root_agent = Agent(
    name="meeting_notes",
    model="gemini-3.5-flash",
    instruction="""You are a meeting notes summarizer. Your job is to take raw
meeting transcripts and produce structured, actionable summaries.

Workflow:
1. Use `extract_action_items` to process the raw transcript
2. Identify: attendees, action items (with assignees + deadlines), key decisions
3. Use `format_summary` to produce the final structured output

Rules:
- Every action item MUST have an assignee and a deadline
- If a deadline is not mentioned, mark it as "TBD"
- If an assignee is not clear, mark it as "Unassigned"
- Key decisions must be concrete, not vague summaries
- Never fabricate attendees or actions not in the transcript
""",
    tools=[extract_action_items, format_summary],
)
```

### Langkah 3: Smoke Test

```bash
agents-cli run "Summarize this meeting: Alice and Bob discussed the Q3 launch. \
Alice will prepare the marketing deck by Friday. Bob will review the API docs by \
next Monday. They decided to use Cloud Run for deployment and skip the staging \
environment for the MVP."
```

Verifikasi:

- [ ] Agen memanggil `extract_action_items`
- [ ] Agen memanggil `format_summary` dengan data terstruktur
- [ ] Output memiliki item tindakan dengan penerima tugas dan batas waktu
- [ ] Keputusan utama dicantumkan

---

## Bagian 3: Menulis Kasus Evaluasi (10 menit)

### Langkah 1: Buat Dataset Evaluasi

Edit `tests/eval/datasets/basic-dataset.json`:

```json
{
  "eval_cases": [
    {
      "eval_case_id": "simple_meeting",
      "prompt": {
        "role": "user",
        "parts": [
          {
            "text": "Summarize this meeting transcript:\n\nMeeting: Sprint Planning\nDate: 2026-06-01\n\nAlice: Let's review the backlog. The auth migration is top priority.\nBob: I can take the auth migration. Should be done by end of week.\nCarol: I'll handle the API rate limiting. Need two weeks for that.\nAlice: Agreed. Let's also deprecate the v1 endpoints — Carol, can you add that to your scope?\nCarol: Sure, I'll bundle it with the rate limiting work.\nBob: One more thing — we decided to use Redis for session caching instead of Memcached.\nAlice: Confirmed. Meeting adjourned."
          }
        ]
      }
    },
    {
      "eval_case_id": "meeting_no_deadlines",
      "prompt": {
        "role": "user",
        "parts": [
          {
            "text": "Summarize this meeting:\n\nTeam standup. Dave mentioned he's blocked on the database schema review. Eve said she'll look at it when she gets a chance. Frank reported that the CI pipeline is green. No specific deadlines were discussed."
          }
        ]
      }
    },
    {
      "eval_case_id": "meeting_with_decisions",
      "prompt": {
        "role": "user",
        "parts": [
          {
            "text": "Meeting notes: Architecture Review\n\nParticipants: Grace, Heidi, Ivan\n\nGrace proposed moving from monolith to microservices. After discussion, the team decided to start with extracting the payment service first. Heidi will create the service boundary document by next Wednesday. Ivan will set up the new GKE cluster by Friday. They also decided to keep the monolith running in parallel for 3 months during migration. Grace will present the migration timeline to leadership next Monday."
          }
        ]
      }
    }
  ]
}
```

### Langkah 2: Konfigurasi Metrik

Edit `tests/eval/eval_config.yaml`:

```yaml
metrics_to_run:
  - multi_turn_task_success
  - multi_turn_tool_use_quality
  - final_response_quality
  - meeting_summary_quality

custom_metrics:
  - name: meeting_summary_quality
    prompt_template: |
      Evaluate the agent's meeting summary on these criteria (1-5 each):

      1. **Completeness**: Are all action items from the transcript captured?
      2. **Attribution**: Does every action item have an assignee?
      3. **Deadlines**: Are deadlines captured or correctly marked as TBD?
      4. **Decisions**: Are key decisions listed accurately?
      5. **No hallucination**: Does the summary contain ONLY information from the transcript?

      Transcript/Prompt: {prompt}
      Agent response: {response}
      Full trace: {agent_data}

      Return JSON: {"score": <1-5 average>, "explanation": "<detailed reasoning>"}
```

### Langkah 3: Jalankan Evaluasi

```bash
# Generate traces (runs agent on each eval case)
agents-cli eval generate

# Grade the traces
agents-cli eval grade
```

Tinjau output. Jika ada skor metrik di bawah ambang batas, lanjutkan ke Bagian 4.

---

## Bagian 4: Loop Evaluasi-Perbaikan (10 menit)

Di sinilah pekerjaan sebenarnya terjadi. Untuk setiap metrik yang gagal:

### Langkah 1: Baca Hasilnya

```bash
# Open the HTML report (easiest to read)
open artifacts/grade_results/results_*.html

# Or check the JSON programmatically
cat artifacts/grade_results/results_*.json | python -m json.tool | head -50
```

### Langkah 2: Diagnosis dan Perbaiki

Perbaikan umum:

| Gejala | Perbaikan |
| :-- | :-- |
| Agen melewati `extract_action_items` | Perkuat instruksi: "Anda HARUS memanggil extract_action_items terlebih dahulu" |
| Penerima tugas tidak ada | Tambahkan ke instruksi: "Setiap item tindakan HARUS memiliki penerima tugas — gunakan 'Unassigned' jika tidak jelas" |
| Item tindakan berhalusinasi | Tambahkan: "JANGAN PERNAH menambahkan item tindakan yang tidak dinyatakan secara eksplisit dalam transkrip" |
| tool_use_quality rendah | Tingkatkan docstring alat — buat lebih spesifik mengenai parameter |

### Langkah 3: Evaluasi Ulang dan Bandingkan

```bash
# Save the previous results
cp artifacts/grade_results/results_*.json artifacts/grade_results/baseline.json

# Re-run
agents-cli eval generate
agents-cli eval grade

# Compare
agents-cli eval compare \
  artifacts/grade_results/baseline.json \
  artifacts/grade_results/results_*.json
```

Ulangi hingga semua metrik lulus.

---

## Tujuan Tambahan

### Tambahkan Deployment

```bash
# Add Cloud Run deployment
agents-cli scaffold enhance . --deployment-target cloud_run

# Deploy
agents-cli deploy
```

### Tambahkan CI/CD

```bash
agents-cli scaffold enhance . --cicd-runner github_actions
```

### Sintesis Lebih Banyak Kasus Evaluasi

```bash
# Auto-generate multi-turn eval scenarios
agents-cli eval dataset synthesize \
  -n 5 \
  --instruction "User provides meeting transcripts of varying complexity" \
  --max-turns 3
```

### Biarkan agy Mengendalikan Seluruh Alur

Buka sesi agy dan katakan:

```text
> Use agents-cli to improve my meeting-notes agent.
  The eval scores for meeting_summary_quality are low.
  Analyze the failures and fix them.
```

Perhatikan agy memuat skill evaluasi, menjalankan `eval analyze`, mengidentifikasi klaster kegagalan, dan secara iteratif memperbaiki agen tersebut.

---

## Kriteria Penyelesaian

- [ ] Proyek di-scaffold dengan `agents-cli scaffold create`
- [ ] Dua alat didefinisikan: `extract_action_items` dan `format_summary`
- [ ] Instruksi agen mencakup alur kerja dan aturan yang jelas
- [ ] Smoke test lulus dengan `agents-cli run`
- [ ] Tiga kasus evaluasi ditulis dalam `basic-dataset.json`
- [ ] Metrik kustom `meeting_summary_quality` didefinisikan
- [ ] `agents-cli eval generate` + `eval grade` berjalan dengan sukses
- [ ] Setidaknya satu iterasi eval-fix diselesaikan dengan `eval compare` yang menunjukkan peningkatan

---

## Poin Penting

1. **`agents-cli scaffold create`** melakukan bootstrap pada seluruh struktur proyek — jangan mengaturnya secara manual
2. **`agents-cli eval` bukanlah opsional** — ini adalah perbedaan antara demo dan agen produksi
3. **pytest ≠ eval** — pytest menguji kebenaran kode; eval menguji perilaku agen
4. **Loop eval-fix bersifat iteratif** — perkirakan 5–10+ putaran; ini adalah hal yang normal
5. **agents-cli skills** membuat agen pengkodean Anda (agy) menjadi ahli dalam pengembangan ADK secara otomatis
