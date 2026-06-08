# Latihan 6: Sandbox & Tata Kelola

> **Durasi:** 15 menit | **Modul:** 4 — Multi-Agen & Lanjutan

---

## Tujuan

Jalankan agy dalam mode `--sandbox` untuk audit kode yang aman, pahami flag `--dangerously-skip-permissions`, dan modelkan alur kerja yang sesuai dengan tata kelola untuk lingkungan enterprise.

---

## Bagian 1: Mode Sandbox — Audit Aman (7 menit)

Jalankan audit keamanan dengan pembatasan terminal diaktifkan:

```bash
agy --sandbox \
    --print "Scan this entire codebase for: (1) hardcoded secrets or API keys, (2) SQL injection risks, (3) insecure direct object references, (4) any .env files or credentials committed to the repo. Output findings as markdown with severity levels." \
    --print-timeout 5m > audit-sandbox.md

cat audit-sandbox.md
```

Properti utama dari proses ini:

- `--sandbox` membatasi eksekusi perintah terminal — agy membaca file tetapi tidak dapat menjalankan perintah shell sembarangan
- `--print` berarti tidak ada sesi interaktif — sepenuhnya otomatis
- Output ditangkap ke dalam file untuk jejak audit

**Kapan menggunakan pola ini:**

- Mengaudit kode yang tidak sepenuhnya Anda percayai
- Pemindaian kepatuhan di lingkungan yang diatur
- Menjalankan pada basis kode produksi di mana efek samping tidak dapat diterima

---

## Bagian 2: Mode Persetujuan Otomatis — Pahami Risikonya (5 menit)

`--dangerously-skip-permissions` mengabaikan semua prompt persetujuan alat. agy mengeksekusi penulisan file dan perintah shell tanpa bertanya.

**Demonstrasi aman:** jalankan dengan `--sandbox` untuk menunjukkan persetujuan otomatis tanpa eksekusi perintah yang sebenarnya:

```bash
agy --sandbox --dangerously-skip-permissions \
    --print "List all TODO comments in this codebase and generate a prioritized backlog." \
    --print-timeout 3m
```

Tanpa `--sandbox`, flag ini akan memungkinkan agy untuk menulis file, menjalankan pengujian, dan mengeksekusi perintah tanpa prompt. **Hanya gunakan ini:**

- Di CI/CD di mana tidak ada manusia yang hadir
- Dipasangkan dengan `--sandbox` untuk audit hanya-baca
- Di lingkungan sekali pakai di mana penulisan dapat diterima

!!! warning "Jangan pernah di produksi"
    `--dangerously-skip-permissions` tanpa `--sandbox` dalam sesi interaktif pada basis kode aktif adalah senjata makan tuan. Tidak ada pembatalan untuk file yang tertimpa.

---

## Bagian 3: Alur Kerja Tata Kelola (3 menit)

Modelkan alur kerja tata kelola dua fase:

### Fase 1: Analisis aman (tanpa efek samping)

```bash
agy --sandbox \
    --print "Analyze all database operations in this codebase. Flag any that lack transaction safety or input validation." \
    --print-timeout 3m > phase1-analysis.md
```

### Fase 2: Tinjauan manusia, lalu menyetujui sesi interaktif

```bash
cat phase1-analysis.md  # human reviews findings

# If approved, continue with interactive session for remediation
agy -i "Based on the findings in phase1-analysis.md, fix the top 3 database safety issues."
```

Pola ini adalah model tingkat enterprise: **baca tanpa rasa percaya, tulis hanya setelah ditinjau**.

---

## Kriteria Penyelesaian

- [ ] `agy --sandbox --print "..."` berjalan dan menghasilkan file audit
- [ ] Memahami kapan `--dangerously-skip-permissions` tepat digunakan vs berbahaya
- [ ] Mengimplementasikan alur kerja tata kelola dua fase (audit sandbox → tinjauan manusia → perbaikan interaktif)
