# Pengaturan Lingkungan

> Selesaikan ini sebelum memulai modul apa pun. Membutuhkan waktu sekitar 15 menit.

---

## Persyaratan Sistem

| Komponen | Minimum | Catatan |
| :-- | :-- | :-- |
| **agy** | Terbaru | Instruksi instalasi di bawah |
| **Git** | v2.30+ | Untuk repo latihan |
| **Terminal** | Apa saja | iTerm2, macOS Terminal, atau terintegrasi VS Code |
| **jq** | Opsional | Berguna untuk mengurai keluaran JSON `--print` |

---

## Langkah 1: Instal agy

> 📖 Instruksi lengkap: [Dokumentasi Memulai](https://www.antigravity.google/docs/cli-getting-started)

### macOS / Linux

```bash
curl -fsSL https://antigravity.google/cli/install.sh | bash
```bash

### Windows

```powershell
# PowerShell
irm https://antigravity.google/cli/install.ps1 | iex

# Or via WSL (recommended)
curl -fsSL https://antigravity.google/cli/install.sh | bash
```bash

Setelah instalasi, verifikasi bahwa berkas biner tersedia:

```bash
# Verify the binary is in your PATH
which agy

# Confirm the version
agy changelog
```yaml

---
## Langkah 2: Autentikasi

agy menggunakan **Google Sign-In berbasis browser**. Pada saat dijalankan pertama kali, ini akan:

- **Mesin lokal:** Secara otomatis membuka browser bawaan Anda untuk masuk.
- **SSH / sesi jarak jauh:** Mencetak URL untuk ditempelkan ke browser apa pun, lalu menempelkan kembali kode autentikasi ke dalam terminal.

```bash
# Start agy — auth will trigger automatically on first run
agy
```bash

Untuk keluar:

```bash
/logout
```bash

> 📖 Untuk autentikasi enterprise melalui proyek GCP, lihat [Dokumentasi Enterprise](https://www.antigravity.google/docs/enterprise).

Setelah autentikasi dikonfigurasi, jalankan *smoke test* singkat:

```bash
agy --print "Say 'Workshop ready!' in exactly two words." --print-timeout 30s
```yaml

Keluaran yang diharapkan: `Workshop ready!`

---
## Langkah 3: Inisialisasi Ruang Kerja Proyek Anda

agy menemukan konfigurasi proyek secara otomatis dengan menelusuri ke atas dari direktori Anda saat ini, mencari folder `.agents/`. Buat satu untuk lokakarya ini:

```bash
# Clone the workshop exercises repo
git clone https://github.com/pauldatta/agy-cli-field-workshop.git
cd agy-cli-field-workshop

# agy will create .agents/ on first run
agy --print "List the files in the current directory."
```bash

Anda akan melihat folder `.agents/` dibuat dengan file-file konfigurasi proyek (settings.json, mcp.json, dll.).

!!! info "Kompatibilitas .gemini/"
    agy juga membaca direktori `.gemini/` — berguna jika Anda sudah memiliki pengaturan proyek Gemini CLI. Kedua lokasi konfigurasi tersebut diakui.

---
## Langkah 4: Verifikasi Semuanya

```bash
# Check agy is accessible
agy --help

# List installed plugins (output is JSON)
agy plugin list

# Pretty-print the plugin list
agy plugin list | python3 -m json.tool

# Quick print-mode smoke test
agy --print "What is 2 + 2?" --print-timeout 30s
```yaml

Daftar periksa sebelum lokakarya dimulai:

- [ ] `agy --help` menampilkan flag dan subperintah
- [ ] `agy plugin list` mengembalikan JSON tanpa kesalahan
- [ ] `agy --print "..."` mengembalikan respons

---
## Pemecahan Masalah

| Masalah | Solusi |
| :-- | :-- |
| `agy: command not found` | Periksa apakah berkas biner ada di dalam PATH Anda. Jalankan `echo $PATH` dan pastikan direktori instalasi disertakan. Jalankan ulang skrip instalasi jika diperlukan |
| Kesalahan autentikasi / peramban tidak terbuka | Untuk sesi SSH, salin URL yang dicetak secara manual. Untuk lokal, periksa pengaturan peramban bawaan. Jalankan `/logout` dan coba lagi |
| `agy plugin list` mengembalikan `{}` kosong | Hal ini wajar pada instalasi baru. Anda akan mengisi plugin di Modul 2 |
| Respons pertama lambat | Proses pertama mungkin lebih lambat karena agy mengindeks ruang kerja Anda |
| Konfigurasi tidak dimuat | Periksa `~/.gemini/antigravity-cli/settings.json` (pengaturan pengguna) dan `.agents/` (pengaturan proyek) |

---
## Langkah Selanjutnya

→ Mulai dengan **[Modul 1: Produktivitas SDLC](sdlc-productivity.md)**
