# Latihan 5: /btw & Penjadwalan

> **Durasi:** 20 menit | **Modul:** 4 — Multi-Agen & Lanjutan

---

## Tujuan

Gunakan `/btw` untuk mengarahkan tugas yang berjalan lama di tengah proses, dan menjadwalkan analisis otomatis berulang.

---

## Bagian 1: /btw Pengarahan di Tengah Tugas (10 menit)

Luncurkan agy dan mulai tugas yang cukup besar:

```bash
agy
```

```text
> I want to refactor the error handling across this entire project to use a consistent pattern. Start by analyzing all error handling in the codebase, then propose and implement a unified approach. This will touch multiple files — start with the analysis phase.
```

Saat agy mulai bekerja (selama fase analisis), masukkan sebuah batasan:

```text
/btw Only touch files in the backend/ directory for now. Leave frontend untouched.
```

Kemudian tambahkan catatan lain:

```text
/btw Use the Result<T, E> pattern if the language supports it. Otherwise use a custom Error class hierarchy.
```

Amati:

- Tugas berlanjut tanpa memulai ulang
- agy memasukkan kedua catatan `/btw` ke dalam pendekatan kerjanya
- Rencana akhir mencerminkan batasan yang Anda masukkan

**Wawasan utama:** `/btw` memungkinkan Anda mengoreksi arah tanpa harus membatalkan dan memulai ulang. Ini setara dengan menepuk bahu seorang pengembang di tengah-tengah sprint.

---

## Bagian 2: Melanjutkan Sesi (5 menit)

Akhiri sesi (Ctrl+C atau tutup terminal).

Lanjutkan sesi terbaru:

```bash
agy -c
```

```text
> Remind me what we decided about the error handling refactor. What was the approach?
```

agy akan memiliki konteks penuh. Sekarang lanjutkan pekerjaan:

```text
> Let's implement step 1 of the plan we discussed.
```

---

## Bagian 3: Menjadwalkan Laporan Berulang (5 menit)

```bash
agy
```

```text
> Schedule a daily dependency check every weekday morning at 8am. It should:
> 1. Check for outdated dependencies with security advisories
> 2. List any new CVEs affecting our current dependency versions
> 3. Save the report to reports/deps-YYYY-MM-DD.md
>
> Create the reports/ directory if it doesn't exist.
```

Konfirmasikan bahwa jadwal telah diterima. Tanyakan:

```text
> What scheduled tasks are currently active?
```

---

## Kriteria Penyelesaian

- [ ] Memulai tugas yang berjalan lama dan menggunakan `/btw` setidaknya dua kali selama eksekusi
- [ ] Mengonfirmasi bahwa pesan `/btw` telah dimasukkan ke dalam output
- [ ] Menggunakan `agy -c` untuk melanjutkan sesi dan mengambil konteks sebelumnya
- [ ] Membuat tugas berulang yang dijadwalkan
