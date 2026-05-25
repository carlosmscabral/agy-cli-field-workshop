# Panduan Fasilitator

> Panduan internal untuk fasilitator lokakarya. Jangan bagikan kepada peserta.

---
## Gambaran Umum

Ini adalah **lokakarya praktik langsung 4 modul berdurasi ~3,5 jam** untuk agy-cli (Antigravity CLI). Lokakarya ini dirancang untuk audiens pengembang: insinyur, pemimpin teknis, dan arsitek solusi yang sedang mengevaluasi atau mengadopsi agy-cli.

---
## Format Penyampaian

| Format | Modul | Durasi |
|---|---|---|
| ⚡ Kilat | Modul 1 + Sorotan Modul 2 | 1,5 jam |
| 📋 Standar | Modul 1 + 2 + 3 | 2,5 jam |
| 📦 Lengkap | Keempat modul | 3,5 jam |
| 🏗️ Diperpanjang | Semua modul + lab terbuka | 5 jam |

---
## Daftar Periksa Pra-Lokakarya

- [ ] Peserta telah menginstal dan mengautentikasi agy-cli *(lihat [setup.md](setup.md))*
- [ ] Detail autentikasi telah didistribusikan (khusus sesi — konfirmasikan dengan tim agy-cli)
- [ ] Peserta memiliki Git dan basis kode demo yang sesuai
- [ ] Fasilitator telah menjalankan semua latihan dari awal hingga akhir pada versi agy-cli saat ini
- [ ] Berbagi layar / proyeksi telah diuji

!!! warning "Autentikasi adalah titik kegagalan #1"
    Selalu jalankan pemeriksaan autentikasi pra-lokakarya 30 menit sebelum sesi. Jalankan:
    ```bash
    agy --print "Say READY" --print-timeout 30s
    ```
    Jika peserta tidak bisa mendapatkan respons, hentikan dan lakukan debug sebelum memulai.

---
## Catatan Penyampaian per Modul

### Modul 1 — Produktivitas SDLC (50 menit)

**Pesan utama:** agy menggantikan beban mental dalam menavigasi basis kode yang tidak dikenal. Ini bukan pelengkapan otomatis — ini adalah insinyur senior yang bisa Anda tanyakan apa saja.

- **Demo terlebih dahulu, latihan kemudian.** Lakukan demo langsung bagian 1.1 (pemahaman kode) pada basis kode Anda sendiri sebelum meminta peserta untuk mencoba basis kode mereka.
- **Gesekan umum:** peserta mencoba menulis prompt yang sempurna. Dorong penggunaan bahasa alami. "Beri tahu saya cara kerja autentikasi" lebih baik daripada "Tolong jelaskan arsitektur autentikasi dari basis kode ini."
- **Momen AGENTS.md:** bagian 1.5 adalah demo bernilai tinggi. Buat AGENTS.md secara langsung di layar dan tunjukkan bagaimana sesi berikutnya segera menjadi lebih cerdas.

### Modul 2 — Ekosistem Plugin (45 menit)

**Pesan utama:** `agy plugin import gemini` dalam satu perintah membawa semua yang telah Anda bangun di Gemini CLI. Investasi ekstensi Anda terbawa.

- **Demo langsung `agy plugin import gemini`** — biarkan audiens melihat keluaran aslinya. Ini sangat menarik secara visual.
- **Latihan validasi:** bagian validasi plugin bekerja paling baik dengan contoh plugin di `samples/plugins/workshop-helpers/`.
- **Placeholder marketplace:** jika ditanya tentang `plugin install`, katakan itu akan segera hadir dan arahkan ke `plugin import` sebagai jalur saat ini.

### Modul 3 — DevOps & Otomatisasi (40 menit)

**Pesan utama:** `--print` adalah pintu darurat. Setelah Anda dapat menyalurkan keluaran agy, Anda dapat mengotomatiskan apa pun.

- **Demo terbaik:** `git diff --cached | agy -p "Review for bugs."` — setiap pengembang akan langsung melihat nilainya.
- **Bagian CI/CD:** jangan menulis alur kerja lengkap secara langsung. Tunjukkan YAML GitHub Actions dan jelaskan pola `--dangerously-skip-permissions`.
- **Lewati pembahasan mendalam sandbox** kecuali audiens berfokus pada keamanan/kepatuhan.

### Modul 4 — Multi-Agen & Lanjutan (45 menit)

**Pesan utama:** sub-agen + /btw adalah lompatan kualitatif. Di sinilah agy menjadi orkestrator, bukan sekadar chatbot.

- **Demo sub-agen adalah momen yang memukau.** Munculkan dua agen secara langsung, tunjukkan keduanya berjalan secara bersamaan.
- **Demo /btw:** mulai tugas yang agak panjang (memfaktorkan ulang sebuah berkas), lalu gunakan /btw di tengah tugas. Tunjukkan kepada peserta bahwa kursor terus bergerak sementara catatan yang disuntikkan digabungkan.
- **Penjadwalan:** jelaskan polanya secara konseptual, jangan didemokan secara langsung (latensi membuatnya canggung dalam sebuah lokakarya).

---
## Pertanyaan Umum Peserta

| Pertanyaan | Jawaban |
|---|---|
| "Model apa yang digunakan agy?" | Gunakan `/model` untuk melihat dan beralih. Lihat [Dokumentasi model](https://www.antigravity.google/docs/models). |
| "Apa bedanya ini dengan Gemini CLI?" | agy menjembatani plugin dari Gemini CLI dan Claude, memiliki orkestrasi sub-agen bawaan, dan pengarahan di tengah tugas dengan /btw. Produk yang berbeda. |
| "Bisakah saya menggunakan kunci API saya sendiri?" | agy menggunakan Google Sign-In berbasis peramban. Pengguna enterprise menghubungkan proyek GCP. Lihat [Dokumentasi enterprise](https://www.antigravity.google/docs/enterprise). |
| "Apakah kode dikirim ke Google?" | Lihat [FAQ](https://www.antigravity.google/docs/faq) untuk detail penanganan data. |
| "Bagaimana dengan hook?" | agy-cli mendukung hook melalui `hooks.json`. Lihat [Dokumentasi hook](https://www.antigravity.google/docs/hooks). |
| "Di mana log percakapan disimpan?" | `~/.gemini/antigravity-cli/conversations/` |

---
## Pemecahan Masalah Selama Workshop

| Gejala | Perbaikan |
|---|---|
| `agy: command not found` | Periksa PATH. Jalankan `which agy` atau `which agy-cli`. |
| Kesalahan autentikasi / 401 | Kredensial sesi mungkin telah kedaluwarsa. Distribusikan ulang autentikasi. |
| Kesalahan `agy plugin list` | Periksa apakah `~/.gemini/antigravity-cli/` ada |
| Respons lambat | Periksa jaringan. Proses pertama setelah diam mungkin lebih lambat karena pengindeksan ruang kerja. |
| Sub-agen tidak muncul | Konfirmasikan bahwa peserta berada dalam mode interaktif (bukan `--print`) |

---
## Pasca-Lokakarya

1. Kumpulkan umpan balik menggunakan formulir umpan balik lokakarya standar
2. Catat bug agy-cli atau perilaku tak terduga yang diamati — laporkan ke tim agy-cli
3. Setiap latihan yang memerlukan solusi alternatif harus ditandai untuk pembaruan dokumen di `CONTRIBUTING.md`
