# Latihan 3: Pipeline Mode --print

> **Durasi:** 20 menit | **Modul:** 3 — DevOps & Otomatisasi

---

## Tujuan

Bangun pipeline shell multi-langkah menggunakan `agy --print`. Tinjau perubahan yang di-stage, buat dokumentasi, dan buat draf alur kerja GitHub Actions.

---

## Bagian 1: Tinjau Perubahan yang Di-stage (5 menit)

Buat perubahan kode kecil pada sebuah file di proyek Anda:

```bash
# Make any small edit
echo "// TODO: refactor this" >> src/index.js   # or equivalent

# Stage it
git add src/index.js
```

Sekarang jalankan peninjauan headless:

```bash
git diff --cached | agy -p "Review these staged changes. Flag any issues. Output as markdown." \
  --print-timeout 60s
```

**Perhatikan:** tidak diperlukan sesi interaktif. agy mengonsumsi stdin dan mencetaknya ke stdout.

---

## Bagian 2: Membuat Dokumentasi API (5 menit)

Pilih file sumber dengan fungsi atau rute:

```bash
# Generate docs for a specific file
cat src/routes/api.js | \
  agy -p "Generate OpenAPI-style documentation for all routes in this file. Output as YAML." \
  --print-timeout 90s > docs/api-generated.yaml

# Verify the output
cat docs/api-generated.yaml
```

---

## Bagian 3: Analisis Multi-Direktori (5 menit)

Jika Anda memiliki repo atau direktori lain yang tersedia:

```bash
# Analyze two directories simultaneously
agy --add-dir ../another-project \
    -p "Compare the error handling approaches in both projects. Which is more consistent?" \
    --print-timeout 90s
```

Jika Anda hanya memiliki satu repo, gunakan dua subdirektori:

```bash
agy --add-dir ./backend --add-dir ./frontend \
    -p "Are there any API contracts defined in the backend that aren't implemented in the frontend?" \
    --print-timeout 2m
```

---

## Bagian 4: Membuat Draf Alur Kerja CI/CD (5 menit)

```bash
agy -p "Write a GitHub Actions workflow that: (1) checks out the repo, (2) runs agy in print mode to review changed files, (3) posts the review as a PR comment. Use --dangerously-skip-permissions for CI. Output as a complete .yml file." \
  --print-timeout 2m > .github/workflows/agy-review.yml

cat .github/workflows/agy-review.yml
```

---

## Kriteria Penyelesaian

- [ ] `git diff --cached | agy -p "..."` dijalankan dan menghasilkan output ulasan
- [ ] Dokumentasi API yang dihasilkan ditulis ke dalam sebuah file
- [ ] `--add-dir` digunakan dengan setidaknya satu direktori tambahan
- [ ] YAML alur kerja GitHub Actions dihasilkan dan disimpan
