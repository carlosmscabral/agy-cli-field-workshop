# Latihan 2: Jembatan Plugin

> **Durasi:** 20 menit | **Modul:** 2 — Ekosistem Plugin

---

## Tujuan

Impor pustaka plugin Anda yang sudah ada ke dalam Antigravity CLI, aktifkan/nonaktifkan plugin secara selektif, dan validasi contoh plugin kustom.

---

## Bagian 1: Mengimpor Plugin (7 menit)

```bash
# Check what's currently in agy
agy plugin list

# Import everything from Gemini CLI
agy plugin import gemini
```

Baca output dengan saksama:

- Plugin apa saja yang diimpor?
- Komponen apa saja yang disumbangkan oleh setiap plugin (skill, perintah, mcpServers, agen)?
- Apakah ada yang dilewati? Mengapa?

```bash
# See the updated list
agy plugin list | python3 -m json.tool
```

**Pertanyaan:** Plugin apa yang sekarang tersedia yang sebelumnya tidak ada?

---

## Bagian 2: Menguji Plugin yang Diimpor (5 menit)

Luncurkan agy dan coba perintah dari salah satu plugin yang diimpor:

```bash
agy
```

Jika `code-review` diimpor:

```text
> /code-review Review the main entry point of this project.
```

Jika `gemini-deep-research` diimpor:

```text
> Use the deep research capability to find best practices for error handling in Node.js APIs.
```

---

## Bagian 3: Menonaktifkan dan Mengaktifkan Kembali (3 menit)

```bash
# Disable a plugin you just imported
agy plugin disable <plugin-name>

# Confirm it's disabled
agy plugin list | python3 -m json.tool

# Re-enable it
agy plugin enable <plugin-name>
```

---

## Bagian 4: Validasi Plugin Sampel (5 menit)

Repo lokakarya menyertakan plugin sampel:

```bash
ls samples/plugins/workshop-helpers/

# Validate its structure
agy plugin validate samples/plugins/workshop-helpers/
```

Kemudian rusak secara sengaja dan lihat apa yang ditangkap oleh validasi:

```bash
# Edit the manifest to remove a required field (use any text editor)
# Then re-validate
agy plugin validate samples/plugins/workshop-helpers/
```

Pulihkan manifes jika sudah selesai.

---

## Kriteria Penyelesaian

- [ ] `agy plugin import` berhasil dijalankan dan mengimpor setidaknya satu plugin
- [ ] Menguji setidaknya satu perintah dari plugin yang diimpor
- [ ] Berhasil menonaktifkan dan mengaktifkan kembali sebuah plugin
- [ ] `agy plugin validate` mengembalikan hasil yang valid pada plugin sampel
