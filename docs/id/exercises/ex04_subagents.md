# Latihan 4: Sub-agen

> **Durasi:** 20 menit | **Modul:** 4 — Multi-Agen & Lanjutan

---

## Tujuan

Buat sub-agen paralel pada basis kode Anda, praktikkan pola peninjau adversarial, dan amati eksekusi yang terisolasi.

---

## Bagian 1: Audit Paralel (10 menit)

Luncurkan agy secara interaktif:

```bash
agy
```

Tugaskan tim audit paralel:

```text
> Spawn two subagents in parallel using branch workspace mode:
> 1. A security auditor — scan for: hardcoded credentials, injection vulnerabilities, exposed sensitive data, and insecure dependencies
> 2. A test coverage auditor — identify: untested public functions, missing edge cases, and integration test gaps
>
> Report back when both complete with a combined findings summary.
```

Selagi mereka berjalan, tanyakan:

```text
> What's the status of the subagents?
```

Ketika mereka selesai:

```text
> Show me the combined findings from both audits. What are the top 3 things to fix?
```

---

## Bagian 2: Peninjau Adversarial (7 menit)

Pilih PR, cabang, atau serangkaian perubahan terbaru apa pun:

```bash
git checkout -b feature/my-test-branch
# (make a few changes)
git add -A
```

Kembali ke agy:

```text
> I have changes on the current branch. Spawn an adversarial reviewer subagent.
> Its only job: find reasons why these changes should NOT be merged.
> It should challenge assumptions, look for edge cases, and be skeptical of everything.
> Be harsh — this is an adversarial review, not a supportive one.
```

Baca temuan adversarial tersebut. Tujuannya adalah untuk mengidentifikasi apa yang akan ditemukan oleh tinjauan kode yang menyeluruh.

---

## Bagian 3: Melanjutkan Pekerjaan Sub-agen (3 menit)

```text
> One of the subagent findings mentioned [specific issue]. Let's fix it. Create a subagent in inherit mode to implement the fix.
```

Perhatikan perbedaannya dari mode cabang: `inherit` berarti sub-agen bekerja di direktori yang sama dengan sesi utama Anda — cocok untuk perbaikan yang ditargetkan dan tidak menimbulkan konflik.

---

## Kriteria Penyelesaian

- [ ] Berhasil menjalankan setidaknya 2 sub-agen paralel
- [ ] Kedua sub-agen berjalan dan mengembalikan temuan
- [ ] Peninjau adversarial mengembalikan temuan kritis
- [ ] Menggunakan setidaknya dua mode ruang kerja yang berbeda (branch vs inherit)
