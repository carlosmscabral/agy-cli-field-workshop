# Latihan 1: Sesi Pertama

> **Durasi:** 15 mnt | **Modul:** 1 — Produktivitas SDLC

---

## Tujuan

Luncurkan agy-cli, jelajahi basis kode, dan buat AGENTS.md yang membuat setiap sesi di masa mendatang menjadi lebih pintar.

---

## Pengaturan

Anda memerlukan repositori Git untuk bekerja. Gunakan aplikasi sampel di repositori ini atau gunakan milik Anda sendiri:

```bash
# Option A: Use the workshop sample (minimal Node.js app)
cd samples/demo-app

# Option B: Use any of your own Git repos
cd /path/to/your/project
```

---

## Bagian 1: Sesi Interaktif Pertama (5 menit)

```bash
agy
```

Pada prompt, tanyakan:

```text
> What does this project do? Give me a one-paragraph summary.
```

Kemudian tindak lanjuti:

```text
> What are the top 3 files I should read to understand the core logic?
```

```text
> Are there any obvious code quality issues or tech debt?
```

**Perhatikan:** agy membaca file Anda tanpa perlu Anda tentukan. Ia mengindeks repo git secara otomatis.

---

## Bagian 2: Pembahasan Mendalam (5 menit)

Pilih satu file dari saran agy dan pelajari lebih dalam:

```text
> Explain [filename] in detail. Walk me through what each function does and how they connect.
```

```text
> If I wanted to add [a simple feature], where would I start?
```

---

## Bagian 3: Membuat AGENTS.md (5 menit)

Sekarang kodifikasikan apa yang telah Anda pelajari sehingga setiap sesi di masa mendatang dimulai dengan konteks:

```text
> Based on our conversation, generate an AGENTS.md file for this project. Include: project purpose, tech stack, key conventions, and anything I should tell an AI assistant before asking it to modify this code.
```

Tinjau apa yang dihasilkan oleh agy. Edit jika ada yang salah. Kemudian tuliskan:

```text
> Write that AGENTS.md to the project root.
```

Mulai sesi baru dan verifikasi bahwa ini berfungsi:

```bash
agy --print "What do you know about this project?" --print-timeout 30s
```

---

## Kriteria Penyelesaian

- [ ] agy diluncurkan dan merespons dalam mode interaktif
- [ ] Menjelajahi setidaknya 3 pertanyaan lanjutan
- [ ] AGENTS.md ada di root proyek
- [ ] `agy --print "What do you know about this project?"` mengembalikan info yang akurat
