# PRD: Migrasi Cloud-Native .NET 5 → .NET 8

> **Penggunaan Workshop:** Latihan praktik untuk [Modul 2 — Modernisasi Basis Kode Legacy](../../legacy-modernization.md). Mendemonstrasikan mode ketat agy, orientasi mandiri agen dengan AGENTS.md, perencanaan sub-agen, dan pengeditan rencana `ctrl+g`. Repositori target mencakup referensi `modernization-prompt.md` yang ditulis oleh GCP Cloud Solutions Architects — contoh standar emas dari rekayasa prompt untuk tugas-tugas migrasi.
>

## Masalah

Aplikasi ASP.NET yang ditingkatkan sebagian (ContosoUniversity) berjalan di .NET 5 dengan Entity Framework 6 dan pola Generic Host legacy (`Startup.cs` + `Program.cs`). .NET 5 telah mencapai akhir masa dukungan pada Mei 2022. Aplikasi ini menggunakan EF6 dengan varian SQL Server tetapi harus menargetkan Cloud Run dengan PostgreSQL. Aplikasi ini tidak memiliki kontainerisasi, logging terstruktur, dan penanganan graceful shutdown.

## Pendorong Bisnis

| Pendorong | Dampak |
| :-- | :-- |
| **Kepatuhan keamanan** | .NET 5 sudah EOL — tidak ada patch keamanan. Menghambat sertifikasi kepatuhan. |
| **Kecepatan deployment** | Dari deployment VM manual menjadi push container 3 menit di Cloud Run |
| **Skalabilitas** | Cloud Run melakukan penskalaan otomatis dari 0 hingga N instance berdasarkan lalu lintas |
| **Biaya** | Menghilangkan lisensi Windows Server — container Linux di Cloud Run memakan biaya ~70% lebih murah |
| **Lapisan data** | Migrasi dari EF6/SQL Server ke EF Core 8/PostgreSQL untuk Cloud SQL terkelola |

## Repositori Target

[ContosoUniversity — Demo Modernisasi .NET Google Cloud](https://github.com/GoogleCloudPlatform/cloud-solutions/tree/main/projects/dotnet-modernization-demo)

Repositori ini menyediakan aplikasi legacy (`dotnet-migration-sample/`) dan status target yang telah selesai (`dotnet-migration-sample-modernized/`) untuk verifikasi mandiri. Siswa bekerja secara eksklusif di direktori `dotnet-migration-sample/`.

```bash
git clone --depth 1 https://github.com/GoogleCloudPlatform/cloud-solutions.git
cd cloud-solutions/projects/dotnet-modernization-demo/dotnet-migration-sample
```

> **Sumber daya bonus:** Repositori ini menyertakan [`modernization-prompt.md`](https://github.com/GoogleCloudPlatform/cloud-solutions/blob/main/projects/dotnet-modernization-demo/modernization-prompt.md) — sebuah prompt migrasi tingkat produksi sepanjang 225 baris dari tim GCP. Bandingkan pendekatan agen Anda dengan referensi ini untuk mempelajari rekayasa prompt untuk tugas-tugas migrasi.
>

## Ruang Lingkup

### Dalam Ruang Lingkup

- Memperbarui framework target dari .NET 5 ke .NET 8
- Mengganti pola Generic Host (`Startup.cs`) dengan minimal hosting API (`WebApplication.CreateBuilder()`)
- Memigrasikan Entity Framework 6 ke Entity Framework Core 8
- Mengganti penyedia database dari SQL Server ke PostgreSQL (Npgsql)
- Membuat Dockerfile dan konfigurasi Docker Compose yang kompatibel dengan Cloud Run
- Mengimplementasikan logging terstruktur, binding PORT, dan graceful shutdown SIGTERM

### Di Luar Ruang Lingkup

- Perubahan logika bisnis (replikasi fitur 1:1 yang persis)
- Desain ulang frontend (tampilan Razor tetap seperti aslinya, pastikan saja dapat dikompilasi)
- Perubahan skema database (EF Core harus memetakan ke skema yang setara)

## Daftar Periksa Migrasi

### Fase 0: Rekayasa Konteks — Orientasi Mandiri Agen

Sebelum menulis kode migrasi, agen harus membangun pemahamannya sendiri tentang basis kode.

- [ ] **Tetapkan mode ketat** — cegah penulisan file yang tidak disengaja selama investigasi:

  ```text
  /permissions strict
  ```

- [ ] **Investigasi basis kode:**

  ```text
  Analisis aplikasi ContosoUniversity. Petakan:
  1. Versi framework saat ini dan semua dependensi NuGet
  2. Pola hosting Startup.cs/Program.cs
  3. Semua penggunaan System.Data.Entity (EF6) di seluruh DAL, pengontrol, dan migrasi
  4. Sumber konfigurasi (appsettings.json, sisa-sisa web.config)
  5. Integrasi Google Cloud (Diagnostik, logging)
  ```

- [ ] **Hasilkan AGENTS.md yang sadar migrasi** berdasarkan analisis
- [ ] **Tinjau dan setujui** AGENTS.md yang dihasilkan sebelum melanjutkan
- [ ] **Beralih ke mode request-review** sebelum Fase 1:

  ```text
  /permissions request-review
  ```

### Fase 1: Peningkatan TFM dan Paket

- [ ] Perbarui `ContosoUniversity.csproj`: ubah `<TargetFramework>net5.0</TargetFramework>` → `net8.0`
- [ ] Perbarui semua paket NuGet ke versi yang kompatibel dengan .NET 8:
  - `Microsoft.AspNetCore.Mvc.NewtonsoftJson` → 8.0.x
  - `System.ComponentModel.Annotations` → 8.0.x
  - `System.Configuration.ConfigurationManager` → 8.0.x
  - `Google.Cloud.Diagnostics.AspNetCore` → terbaru yang kompatibel dengan 8.0
- [ ] Hapus paket `Microsoft.DotNet.UpgradeAssistant.Extensions.Default.Analyzers` (tidak lagi diperlukan)
- [ ] Hapus `<GenerateAssemblyInfo>false</GenerateAssemblyInfo>` dan hapus `Properties/AssemblyInfo.cs`
- [ ] Jalankan `dotnet restore` — selesaikan konflik paket apa pun

### Fase 2: Modernisasi Hosting

- [ ] Ganti `Startup.cs` + `Program.cs` (pola Generic Host) dengan API hosting minimal:

  ```csharp
  var builder = WebApplication.CreateBuilder(args);
  builder.Services.AddControllersWithViews();
  // ... pendaftaran layanan
  var app = builder.Build();
  // ... pipeline middleware
  app.Run();
  ```

- [ ] Pindahkan isi `ConfigureServices()` ke dalam blok `builder.Services` tingkat atas
- [ ] Pindahkan isi `Configure()` ke dalam pipeline `app.Use*()` tingkat atas
- [ ] Migrasikan pemuatan konfigurasi rahasia `CreateHostBuilder` ke pola baru
- [ ] Konfigurasikan pengikatan PORT untuk Cloud Run: `app.Run("http://0.0.0.0:" + port)`
- [ ] Tambahkan penangan graceful shutdown SIGTERM
- [ ] Hapus `Startup.cs` setelah migrasi selesai

### Fase 3: Entity Framework 6 → EF Core 8

- [ ] Hapus paket `EntityFramework` 6.4.4
- [ ] Tambahkan `Microsoft.EntityFrameworkCore` dan `Npgsql.EntityFrameworkCore.PostgreSQL` 8.0.x
- [ ] Refaktor `SchoolContext`:
  - Ganti impor `System.Data.Entity` → `Microsoft.EntityFrameworkCore`
  - Ganti `DbModelBuilder` → `ModelBuilder` di `OnModelCreating`
  - Hapus `PluralizingTableNameConvention` → tambahkan panggilan `.ToTable()` eksplisit
  - Hapus `MapToStoredProcedures()` (tidak didukung di EF Core)
  - Ganti konstruktor `SchoolContext(string connectString) : base(connectString)` → `SchoolContext(DbContextOptions<SchoolContext> options) : base(options)`
- [ ] Daftarkan DbContext di DI: `builder.Services.AddDbContext<SchoolContext>(options => options.UseNpgsql(...))`
- [ ] Refaktor `SchoolInitializer.cs` → `DbInitializer.cs` menggunakan `context.Database.EnsureCreated()`
- [ ] Hapus `SchoolConfiguration.cs` (`Database.SetInitializer<T>()` hanya untuk EF6)
- [ ] Hapus `SchoolInterceptorLogging.cs` dan `SchoolInterceptorTransientErrors.cs` (interseptor EF6) → ganti dengan logging EF Core melalui `ILoggerFactory`
- [ ] Hapus semua file migrasi EF6 (`Migrations/2014*.cs`, `Migrations/Configuration.cs`)
- [ ] Perbarui semua pengontrol untuk menghapus impor `System.Data.Entity` dan perbaiki `RetryLimitExceededException` (EF6) → padanan EF Core
- [ ] Jalankan `dotnet build` — perbaiki semua kesalahan kompilasi

### Fase 4: Kontainerisasi & Cloud Run

- [ ] Buat `Dockerfile` multi-tahap:

  ```dockerfile
  FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
  WORKDIR /src
  COPY . .
  RUN dotnet publish -c Release -o /app

  FROM mcr.microsoft.com/dotnet/aspnet:8.0
  WORKDIR /app
  COPY --from=build /app .
  USER 1000
  EXPOSE 8080
  ENTRYPOINT ["dotnet", "ContosoUniversity.dll"]
  ```

- [ ] Tambahkan `.dockerignore` (kecualikan `bin/`, `obj/`, `.git/`)
- [ ] Buat `compose.yaml` dengan layanan PostgreSQL + aplikasi:
  - Kontainer PostgreSQL dengan healthcheck `pg_isready`
  - Kontainer aplikasi dengan string koneksi melalui variabel lingkungan
  - Tanpa atribut `version` (usang di Compose Spec)
- [ ] Konfigurasikan logging JSON terstruktur untuk Cloud Logging: `builder.Logging.AddJsonConsole()`
- [ ] Jalankan `docker build --check .` — lewati semua pemeriksaan build Docker
- [ ] Jalankan `docker compose up --build --detach` — verifikasi aplikasi dimulai dan database diinisialisasi

### Fase 5: Validasi & Pengujian

- [ ] `dotnet build` mengkompilasi tanpa kesalahan atau peringatan
- [ ] Image Docker dibangun dan berjalan di Linux (bukan kontainer Windows)
- [ ] Kontainer berjalan sebagai pengguna non-root (UID 1000)
- [ ] Semua endpoint HTTP merespons dengan benar (GET, POST untuk operasi CRUD)
- [ ] Database diinisialisasi dengan data seed pada proses pertama
- [ ] Aplikasi menangani token anti-pemalsuan dengan benar untuk operasi POST/DELETE
- [ ] Log JSON terstruktur muncul di `docker compose logs`
- [ ] Tidak ada string koneksi atau kredensial dalam kode sumber

## Apa yang Harus Dilakukan Agen

PRD ini dirancang untuk menguji kemampuan agen untuk:

1. **Mem-bootstrap konteksnya sendiri** — menggunakan mode ketat + investigasi basis kode untuk menulis AGENTS.md sebelum memulai (Fase 0)
2. **Memahami pola legacy** — mengenali idiom EF6 (`DbModelBuilder`, interceptor, `Database.SetInitializer`) dan memetakannya ke ekuivalen EF Core
3. **Mengikuti rencana bertahap** — menggunakan `ctrl+g` untuk mengedit dan menyetujui rencana sebelum mengeksekusi
4. **Melakukan refactoring mekanis** — migrasi EF6 → EF Core menyentuh setiap file pengontrol dan model
5. **Memverifikasi pekerjaannya sendiri** — menjalankan `dotnet build` dan `docker compose up` setelah setiap fase
6. **Menggunakan `/rewind`** jika ada fase yang salah — ini adalah checkpoint Anda, bukan sebuah kegagalan

## Kriteria Penerimaan

- [ ] Sebuah `AGENTS.md` ada di root proyek yang menyandikan konteks migrasi
- [ ] `dotnet build` mengompilasi tanpa kesalahan di .NET 8
- [ ] Tidak ada impor `System.Data.Entity` yang tersisa di mana pun dalam basis kode
- [ ] Tidak ada `Startup.cs` — aplikasi menggunakan API hosting minimal di `Program.cs`
- [ ] Paket `EntityFramework` 6.x sepenuhnya diganti oleh `Microsoft.EntityFrameworkCore` 8.x
- [ ] Image Docker dibangun dan berjalan di Linux dengan pengguna non-root
- [ ] `docker compose up` berhasil memulai aplikasi + PostgreSQL dan melakukan seed pada basis data
- [ ] Tidak ada string koneksi atau kredensial dalam kode sumber
- [ ] Aplikasi merespons pemeriksaan kesehatan dalam waktu 2 detik dari cold start
