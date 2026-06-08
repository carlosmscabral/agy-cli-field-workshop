# PRD: Migrasi Java 8 → Java 21 & Spring Boot 3

> **Penggunaan Workshop:** Latihan praktik untuk [Modul 2 — Modernisasi Basis Kode Legacy](../../legacy-modernization.md). Mendemonstrasikan pola investigasi basis kode dengan konteks besar, orientasi mandiri AGENTS.md, dan bagaimana agy menangani migrasi namespace mekanis yang rentan terhadap kesalahan bagi manusia.
>

## Masalah

Sebuah enterprise Java REST API (Spring PetClinic REST) berjalan pada Java 8 dan Spring Boot 2.6.x. Java 8 telah mencapai akhir pembaruan publik pada tahun 2022. Aplikasi ini tidak dapat menggunakan Virtual Threads, peningkatan GC modern, atau patch keamanan terbaru. Kepatuhan mensyaratkan migrasi ke versi LTS yang didukung.

## Pendorong Bisnis

| Pendorong | Dampak |
| :-- | :-- |
| **Kepatuhan keamanan** | Java 8 sudah EOL — tidak ada patch keamanan. Temuan audit menghalangi pembaruan SOC 2 berikutnya. |
| **Performa** | Virtual Threads Java 21 mengurangi pertikaian thread pool pada endpoint dengan konkurensi tinggi. Perkiraan pengurangan latensi p99 sebesar 30%. |
| **Biaya** | Jejak memori yang lebih baik berarti instans container yang lebih kecil. Perkiraan penghematan infrastruktur sebesar 20%. |
| **Pengalaman pengembang** | Records, sealed classes, pattern matching, text blocks — mengurangi boilerplate sekitar 15%. |

## Ruang Lingkup

### Dalam Ruang Lingkup

- Peningkatan dari Java 8 ke Java 21 (LTS)
- Peningkatan dari Spring Boot 2.6.x ke Spring Boot 3.3.x
- Migrasi dari namespace javax.*ke jakarta.*
- Mengganti konfigurasi Security yang sudah usang (`WebSecurityConfigurerAdapter`)
- Migrasi OpenAPI/Swagger dari SpringFox ke SpringDoc
- Mengaktifkan Virtual Threads
- Memastikan semua pengujian yang ada berhasil dilewati

### Di Luar Ruang Lingkup

- Dekomposisi layanan mikro (monolit tetap monolit)
- Perubahan skema basis data
- Pengembangan fitur baru

## Pengaturan Workshop: Penyelarasan Versi

Untuk memastikan latihan migrasi tetap konsisten dengan status target yang didefinisikan dalam PRD ini, gunakan varian **Spring PetClinic REST** pada **tag `v2.6.2`**. Tag spesifik ini berfungsi sebagai dasar stabil kita — tag ini menggunakan **Spring Boot 2.6.2 dan Java 8**, dan secara krusial menyertakan konfigurasi Spring Security yang nyata dengan `WebSecurityConfigurerAdapter`, membuat fase migrasi keamanan menjadi autentik.

```bash
git clone --branch v2.6.2 --depth 1 https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
```

> **Mengapa varian ini?** Repositori utama `spring-petclinic` tidak pernah menyertakan Spring Security. Varian REST memiliki `BasicAuthenticationConfig` yang memperluas `WebSecurityConfigurerAdapter` dengan autentikasi berbasis JDBC, akses berbasis peran `@PreAuthorize`, dan konfigurasi CORS — semua pola yang memerlukan migrasi langsung ke Spring Security 6.
>

## Daftar Periksa Migrasi

### Fase 0: Rekayasa Konteks — Orientasi Mandiri Agen

Sebelum menulis satu baris kode migrasi pun, agen harus membangun pemahamannya sendiri tentang basis kode. Fase ini menggunakan pola **orientasi mandiri** (**self-onboarding**): agen membaca seluruh proyek, memetakan pola arsitektur, dan menghasilkan `AGENTS.md` yang menyandikan apa yang dipelajarinya — secara efektif menulis berkas konteksnya sendiri.

- [ ] **Atur mode strict** — tidak ada penulisan selama investigasi:

  ```text
  /permissions strict
  ```

- [ ] **Investigasi basis kode:**

  ```text
  Analisis struktur proyek secara penuh, dependensi, dan pola arsitektur.
  Petakan semua kelas konfigurasi Spring Security, lapisan akses data (JDBC, JPA,
  Spring Data), dan pola pengontrol REST.
  ```

- [ ] **Hasilkan AGENTS.md yang sadar migrasi:**

  ```text
  Berdasarkan analisis Anda, tulis sebuah AGENTS.md untuk proyek ini yang:
  1. Mendokumentasikan arsitektur saat ini (Boot 2.6, Java 8, namespace javax)
  2. Mendefinisikan arsitektur target (Boot 3.3, Java 21, namespace jakarta)
  3. Membuat daftar aturan migrasi (satu modul pada satu waktu, pertahankan kontrak API, dll.)
  4. Menyandikan standar pengujian (setiap endpoint yang dimigrasi harus lulus pengujian)
  5. Mencatat risiko migrasi yang diketahui yang Anda identifikasi
  ```

- [ ] **Tinjau dan setujui AGENTS.md yang dihasilkan** sebelum melanjutkan
- [ ] **Beralih ke request-review** sebelum Fase 1:

  ```text
  /permissions request-review
  ```

> **Mengapa ini penting:** Ini adalah pola "rekayasa konteks untuk migrasi". Alih-alih manusia menulis AGENTS.md dari awal, agen menggunakan kemampuan investigasi basis kodenya untuk mem-bootstrap berkas konteks yang kaya. Agen kemudian menggunakan berkas ini untuk memandu pekerjaan migrasinya sendiri — sebuah loop yang memperkuat diri sendiri di mana konteks yang lebih baik menghasilkan perubahan kode yang lebih baik.

### Fase 1: Sistem Build

- [ ] Perbarui `pom.xml`: atur `java.version` ke 21
- [ ] Perbarui parent Spring Boot ke 3.3.x
- [ ] Ganti API JDK yang dihapus:
  - JAXB → `jakarta.xml.bind:jakarta.xml.bind-api` + runtime Glassfish
  - `javax.annotation` → `jakarta.annotation:jakarta.annotation-api`
  - `mysql-connector-java` → `com.mysql:mysql-connector-j`
- [ ] Jalankan `mvn clean compile` — perbaiki semua kesalahan kompilasi sebelum melanjutkan

### Fase 2: Migrasi Namespace

- [ ] Cari-dan-ganti global: `javax.persistence` → `jakarta.persistence`
- [ ] Cari-dan-ganti global: `javax.validation` → `jakarta.validation`
- [ ] Cari-dan-ganti global: `javax.servlet` → `jakarta.servlet`
- [ ] Cari-dan-ganti global: `javax.annotation` → `jakarta.annotation`
- [ ] Verifikasi: tidak ada impor `javax.*` yang tersisa (kecuali `javax.sql.*` yang tidak berubah)

### Fase 3: Konfigurasi Keamanan

- [ ] Hapus kelas yang memperluas `WebSecurityConfigurerAdapter` (dihapus di Spring Security 6):
  - `BasicAuthenticationConfig`
  - `DisableSecurityConfig`
- [ ] Buat kelas `SecurityConfig` pengganti dengan `@Bean SecurityFilterChain`
- [ ] Migrasi `.authorizeRequests()` → `.authorizeHttpRequests()`
- [ ] Migrasi `@EnableGlobalMethodSecurity` → `@EnableMethodSecurity`
- [ ] Migrasi `configureGlobal(AuthenticationManagerBuilder)` → `@Bean AuthenticationManager`
- [ ] Verifikasi: autentikasi berbasis JDBC, akses berbasis peran, dan CORS masih berfungsi

### Fase 4: Migrasi OpenAPI/Swagger

- [ ] Hapus dependensi SpringFox (`springfox-boot-starter`, `springfox-swagger2`)
- [ ] Tambahkan dependensi SpringDoc (`springdoc-openapi-starter-webmvc-ui`)
- [ ] Migrasi anotasi Swagger: `@Api` → `@Tag`, `@ApiOperation` → `@Operation`
- [ ] Migrasi `@ApiResponse` dari `io.swagger` ke `io.swagger.v3.oas`
- [ ] Perbarui `ApplicationSwaggerConfig` ke konfigurasi SpringDoc
- [ ] Verifikasi: Swagger UI dapat diakses di `/swagger-ui.html`

### Fase 5: Virtual Threads & Validasi

- [ ] Tambahkan ke `application.properties`: `spring.threads.virtual.enabled=true`
- [ ] Tinjau semua metode `@Async` — Virtual Threads membuat kumpulan thread kustom tidak diperlukan untuk pekerjaan yang terikat I/O
- [ ] Jalankan rangkaian pengujian penuh: `mvn clean verify`
- [ ] Verifikasi tidak ada peringatan deprecation Spring Boot di log startup

## Apa yang Harus Dilakukan Agen

PRD ini dirancang untuk menguji kemampuan agen dalam:

1. **Melakukan bootstrap konteksnya sendiri** — menggunakan investigasi basis kode untuk menulis AGENTS.md sebelum memulai pekerjaan migrasi (Fase 0)
2. **Memahami seluruh basis kode** — jendela konteks yang besar memungkinkan agy melihat semua file secara bersamaan
3. **Mengikuti rencana bertahap** — menggunakan `ctrl+g` untuk meninjau rencana sebelum mengeksekusi setiap fase
4. **Melakukan refactoring mekanis** — migrasi namespace bersifat repetitif dan rentan terhadap kesalahan bagi manusia
5. **Memverifikasi pekerjaannya sendiri** — menjalankan `mvn clean verify` setelah setiap fase dan memperbaiki kerusakan apa pun
6. **Menggunakan `/rewind`** jika ada fase yang salah — sangat berguna setelah penulisan ulang konfigurasi keamanan

## Kriteria Penerimaan

- [ ] Sebuah `AGENTS.md` ada di root proyek yang menyandikan konteks migrasi
- [ ] `mvn clean verify` berhasil dengan 0 kegagalan pengujian pada Java 21
- [ ] Nol impor `javax.*` yang tersisa (kecuali `javax.sql.*`)
- [ ] Tidak ada penggunaan `WebSecurityConfigurerAdapter` di mana pun dalam basis kode
- [ ] Dependensi SpringFox sepenuhnya digantikan oleh SpringDoc
- [ ] `application.properties` menyertakan `spring.threads.virtual.enabled=true`
- [ ] Tidak ada peringatan depresiasi Spring Boot di log startup

## Repositori Target

[Spring PetClinic REST](https://github.com/spring-petclinic/spring-petclinic-rest) pada tag [`v2.6.2`](https://github.com/spring-petclinic/spring-petclinic-rest/tree/v2.6.2) — Spring Boot 2.6.2, Java 8, dengan Spring Security dan OpenAPI.
