# Roadmap

Deferred improvements for the workshop. Not blocking — parked for a future pass.

---

## Single-repo onboarding — attendees clone only `agy-sample-app`

**Status:** planned (agreed 2026-07-07) · **Effort:** small

Today attendees clone **two** repos (`agy-cli-field-workshop` + `agy-sample-app`), but the workshop repo is only used locally in a few spots. The curriculum is read on the live GitHub Pages site, and `agy` should run in the **sample app** — not the curriculum repo, which it would otherwise index. Goal: onboarding becomes *install `agy` → auth Vertex → clone only `agy-sample-app` → go.*

**Local uses of the workshop repo to remove or relocate:**

- `scripts/verify-workstation.sh` / `.ps1` (workstation verifier) and `scripts/bootstrap-enterprise.sh` — deliver via `curl -fsSL <raw-url> | bash` (keep the scripts in the repo, just don't require a clone), or fold their steps (gcloud ADC + Vertex env + clone + venv) inline into the setup guide.
- `scripts/check-env.sh` via `make check-env` (README quick start) — same treatment or drop from the attendee path.
- **`docs/exercises/ex03_skills_rules.md` Part 4** — currently `cd ../agy-cli-field-workshop` + `agy plugin validate samples/plugins/workshop-helpers/`. Rework to package the skill + rule built earlier in the beat into a small plugin **inside the sample app** and validate that (no cross-repo hop, more coherent) — or drop Part 4.

**Docs to update when implementing:** `setup.md` (drop "Why Two Repositories" / clone-both), `setup-corporate.md` (Step 2 clone + bootstrap note), `README.md` (quick start), `facilitator-guide.md` (checklist "cloned both repos"). Facilitators/maintainers may still clone the workshop repo; attendees shouldn't need to.

**Recommended approach:** (a) verifier as a `curl | bash` one-liner; (b) rework ex03 Part 4 rather than dropping it.
