# Modul 1: Produktivitas SDLC <span class="duration-badge">50 menit</span>

> **Sesi agy-cli nyata pertama Anda.** Modul ini mencakup alur kerja harian utama: memahami kode, refactoring, membuat pengujian, dan meninjau perubahan — semuanya dari terminal.

---

## 1.0 — Sesi Interaktif Pertama <span class="duration-badge">5 menit</span>

Jalankan agy-cli di direktori proyek workshop Anda:

```bash
cd agy-cli-field-workshop
agy
```

Anda akan masuk ke prompt interaktif. Coba:

```
> What files are in this project and what does each one do?
```

Perhatikan bagaimana agy membaca ruang kerja Anda — ia mengindeks repo git, membaca isi file, dan merespons dengan konteks. Ini **otomatis**: tanpa konfigurasi, tanpa prompt yang harus ditulis terlebih dahulu.

!!! tip "Folder .agents/"
    Setelah sesi pertama Anda, periksa `.agents/` — agy membuat file konfigurasi proyek yang melacak ruang kerja Anda. Beginilah cara ia mengetahui apa yang harus diindeks pada eksekusi selanjutnya.

---

## 1.1 — Pemahaman Kode <span class="duration-badge">10 min</span>

> **Pola: Jelaskan Sebelum Menyentuh** — pahami kode sebelum mengubahnya.

### Latihan: Memetakan Basis Kode yang Tidak Dikenal

```bash
# Start with --prompt-interactive: give agy an initial task, then continue conversationally
agy -i "Give me a high-level architecture overview of this project. What are the main components and how do they connect?"
```

Kemudian tindak lanjuti secara interaktif:

```
> Which file handles the entry point?
> What external dependencies does this project have?
> Are there any obvious code smells or tech debt?
```

!!! tip "Gunakan -i untuk sesi yang diinisialisasi"
    `agy -i "<task>"` (singkatan dari `--prompt-interactive`) dimulai dengan sebuah prompt tetapi tetap interaktif. Sangat bagus untuk eksplorasi yang terarah — Anda menentukan arahnya, lalu mengarahkannya dengan tindak lanjut.

---

## 1.2 — Refactoring <span class="duration-badge">10 menit</span>

> **Pola: Usulkan, Tinjau, Terapkan** — jangan pernah menerapkan perubahan yang belum Anda baca.

### Latihan: Refactor Bertarget

```bash
agy
```

```
> I want to refactor the error handling in this project. First, show me all the places where errors are currently caught or returned — don't change anything yet.
```

Tinjau temuannya. Kemudian:

```
> Now propose a refactored version of [specific function] using a consistent error handling pattern. Show me the diff before applying.
```

Terapkan hanya setelah Anda membaca perubahan yang diusulkan.

### Model Izin

agy memiliki **model izin 3 tingkat** yang mengontrol bagaimana ia menangani persetujuan alat:

| Tingkat | Perilaku |
|---|---|
| `request-review` | **Bawaan.** agy meminta persetujuan sebelum menulis file atau menjalankan perintah |
| `always-proceed` | Setujui otomatis semua panggilan alat — berguna untuk skrip tepercaya dan CI |
| `strict` | Tolak semua penggunaan alat kecuali diizinkan secara eksplisit — kontrol maksimum |

Gunakan perintah garis miring `/permissions` untuk melihat atau mengubah tingkat saat ini. Anda juga dapat menetapkan aturan terperinci:

```json
{
  "permissions": {
    "allow": ["command(git)", "read_file"],
    "deny": ["command(rm -rf)"]
  }
}
```

> 📖 Detail lengkap: [Dokumentasi Izin](https://www.antigravity.google/docs/permissions) · [Dokumentasi Mode Ketat](https://www.antigravity.google/docs/strict-mode)

---

## 1.3 — Pembuatan Pengujian <span class="duration-badge">10 min</span>

> **Pola: Uji Apa yang Ada** — buat pengujian untuk kode nyata, bukan hipotesis.

### Latihan: Buat Pengujian Unit

```bash
agy
```

```
> Look at [specific function or file]. Generate a comprehensive unit test suite for it. Include happy path, edge cases, and error conditions. Use the testing framework already in this project.
```

Kemudian:

```
> Run the tests and fix any that fail.
```

!!! tip "Biarkan agy menjalankan pengujian"
    agy dapat mengeksekusi perintah shell. Ini akan menjalankan rangkaian pengujian Anda dan melakukan iterasi pada kegagalan tanpa Anda harus menyalin-tempel pesan kesalahan. Perhatikan ia mengoreksi dirinya sendiri.

---

## 1.4 — Tinjauan Kode <span class="duration-badge">10 min</span>

> **Pola: Tinjauan Pre-Commit** — gunakan agy sebagai peninjau senior sebelum setiap push.

### Latihan: Tinjau Perubahan Anda

```bash
# Stage some changes (or use an existing branch)
git add -p

# Start agy and review what's staged
agy
```

```
> Review my staged changes for: (1) correctness, (2) security issues, (3) missing test coverage, (4) anything that would block a PR. Be direct — don't soften findings.
```

### Varian Headless (untuk pembuatan skrip)

```bash
# Review changes non-interactively — useful in pre-commit hooks or CI
git diff --cached | agy --print "Review these changes. Flag any bugs, security issues, or missing tests. Output as markdown."
```

---

## 1.5 — Konteks Proyek dengan AGENTS.md <span class="duration-badge">5 menit</span>

> **Pola: Konteks Persisten** — beri tahu agy sekali, ia akan mengingatnya di setiap sesi.

agy membaca berkas konteks pada saat sesi dimulai. Buat satu di root proyek:

```bash
cat > AGENTS.md << 'EOF'
# Project Context

This is a [your project description]. Key conventions:

- Language: [your language/framework]
- Testing: [your test framework]
- Style: [your coding conventions]
- DO NOT: [things agy should never do]

## Architecture
[Brief architecture summary]
EOF
```

Sekarang mulai sesi baru:

```bash
agy --print "What do you know about this project?"
```

agy akan memasukkan AGENTS.md Anda ke dalam setiap sesi berikutnya secara otomatis.

!!! info "Hierarki konteks"
    agy membaca AGENTS.md dari: direktori saat ini → direktori induk → direktori beranda. Konteks yang lebih spesifik menimpa konteks yang lebih luas.

### Sumber Konteks Tambahan

Selain AGENTS.md, agy juga memuat:

- **`.agents/rules.md`** (atau `.agents/rules/*.md`) — aturan tingkat proyek yang disuntikkan sebagai arahan prompt sistem. Gunakan ini untuk persyaratan mutlak seperti "jangan pernah menghapus berkas migrasi" atau "selalu gunakan mode ketat TypeScript."
- **`.gemini/`** — untuk kompatibilitas Gemini CLI, agy membaca direktori `.gemini/` bersama dengan `.agents/`.
- **`~/.gemini/config/rules.md`** — aturan global yang diterapkan ke semua sesi.

> 📖 Detail lengkap: [Dokumentasi Aturan & Alur Kerja](https://www.antigravity.google/docs/rules-workflows)

---

## 1.6 — Navigasi Interaktif <span class="duration-badge">5 menit</span>

> **Pola: Kelancaran Terminal** — ketahui pintasan yang membuat sesi agy menjadi cepat.

> 📖 Referensi lengkap: [Menggunakan Antigravity CLI](https://www.antigravity.google/docs/cli-using)

### Perintah Slash Utama

| Perintah | Fungsinya |
|---|---|
| `/rewind` (atau `/undo`) | Mengembalikan riwayat percakapan ke checkpoint sebelumnya |
| `/resume` (atau `/switch`) | Membuka pemilih percakapan untuk melanjutkan atau beralih sesi |
| `/rename <name>` | Mengganti nama utas percakapan aktif |
| `/config` (atau `/settings`) | Membuka overlay pengaturan layar penuh |
| `/permissions` | Mengatur tingkat otonomi agen (`request-review`, `always-proceed`, `strict`) |
| `/model` | Memilih model penalaran (bertahan di seluruh sesi) |
| `/tasks` | Memantau, melihat log untuk, atau menghentikan tugas latar belakang |
| `/agents` | Melihat, mengelola, dan menyetujui tindakan sub-agen |
| `/open <path>` | Membuka file di editor eksternal pilihan Anda |
| `/usage` | Membuka manual bantuan interaktif sebaris |
| `/skills` | Menelusuri skill agen lokal dan global |
| `/mcp` | Mengonfigurasi dan mengelola server MCP |

> 📖 Referensi lengkap perintah slash: [Fitur CLI](https://antigravity.google/docs/cli-features)

### Tips Cepat

| Pintasan | Fungsinya |
|---|---|
| `@` | Pelengkapan otomatis jalur file — ketik `@` untuk memicu saran jalur |
| `!` | Menjalankan perintah terminal secara langsung tanpa meninggalkan agy |
| `esc esc` | Menghapus input prompt saat ini (saat tidak ada streaming yang aktif) |
| `?` | Mendapatkan bantuan dan mencantumkan semua perintah slash |
| `alt+enter` / `ctrl+j` / `shift+enter` | Menyisipkan baris baru di prompt Anda (input multi-baris) |
| `ctrl+g` | Mengedit prompt di dalam editor shell default Anda |
| `ctrl+l` | Membersihkan layar TUI |
| `ctrl+d` | Keluar dari CLI |

> 📖 Referensi lengkap keybinding: [Menggunakan Antigravity CLI](https://antigravity.google/docs/cli-using)

---

## Latihan Modul 1

<div class="exercise-card" markdown>

#### :material-file-document: Latihan 1: Sesi Pertama

**Berkas:** `exercises/ex01_first_session.md`
**Durasi:** 15 menit
**Tujuan:** Menjalankan agy, menjelajahi basis kode, menghasilkan AGENTS.md.

</div>

---

## Modul Selanjutnya

→ **[Modul 2: Ekosistem Plugin](../plugin-ecosystem.md)** — mengimpor plugin Gemini CLI dan Claude ke dalam agy dalam satu perintah.
