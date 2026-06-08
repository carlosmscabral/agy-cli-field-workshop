# PRD: .NET 5 → .NET 8 클라우드 네이티브 마이그레이션

> **워크숍 용도:** [모듈 2 — 레거시 코드베이스 현대화](../../legacy-modernization.md)를 위한 실습 예제입니다. agy 엄격 모드(strict mode), AGENTS.md를 사용한 에이전트 자체 온보딩, 서브에이전트 계획 수립, 그리고 `ctrl+g` 플랜 편집을 시연합니다. 대상 리포지토리에는 GCP 클라우드 솔루션 아키텍트가 작성한 참조용 `modernization-prompt.md`가 포함되어 있으며, 이는 마이그레이션 작업을 위한 프롬프트 엔지니어링의 완벽한 모범 사례입니다.
>

## 문제

부분적으로 업그레이드된 ASP.NET 애플리케이션(ContosoUniversity)은 Entity Framework 6 및 레거시 Generic Host 패턴(`Startup.cs` + `Program.cs`)과 함께 .NET 5에서 실행됩니다. .NET 5는 2022년 5월에 지원이 종료되었습니다. 이 앱은 SQL Server 기반의 EF6를 사용하지만 PostgreSQL과 함께 Cloud Run을 대상으로 해야 합니다. 컨테이너화, 구조화된 로깅 및 정상적인 종료 처리가 부족합니다.

## 비즈니스 동인

| 동인 | 영향 |
| :-- | :-- |
| **보안 규정 준수** | .NET 5는 EOL(수명 종료) 상태로 보안 패치가 제공되지 않습니다. 규정 준수 인증을 차단합니다. |
| **배포 속도** | 수동 VM 배포에서 Cloud Run에 3분 만에 컨테이너를 푸시하는 방식으로 변경 |
| **확장성** | Cloud Run은 트래픽에 따라 0에서 N개의 인스턴스로 자동 확장됩니다. |
| **비용** | Windows Server 라이선스 제거 — Cloud Run의 Linux 컨테이너는 비용이 약 70% 더 저렴합니다. |
| **데이터 계층** | 관리형 Cloud SQL을 위해 EF6/SQL Server에서 EF Core 8/PostgreSQL로 마이그레이션 |

## 대상 저장소

[ContosoUniversity — Google Cloud .NET 현대화 데모](https://github.com/GoogleCloudPlatform/cloud-solutions/tree/main/projects/dotnet-modernization-demo)

이 저장소는 자체 검증을 위해 레거시 앱(`dotnet-migration-sample/`)과 완료된 목표 상태(`dotnet-migration-sample-modernized/`)를 모두 제공합니다. 학생들은 오직 `dotnet-migration-sample/` 디렉터리에서만 작업합니다.

```bash
git clone --depth 1 https://github.com/GoogleCloudPlatform/cloud-solutions.git
cd cloud-solutions/projects/dotnet-modernization-demo/dotnet-migration-sample
```

> **보너스 리소스:** 저장소에는 GCP 팀에서 작성한 225줄 분량의 프로덕션 수준 마이그레이션 프롬프트인 [`modernization-prompt.md`](https://github.com/GoogleCloudPlatform/cloud-solutions/blob/main/projects/dotnet-modernization-demo/modernization-prompt.md)가 포함되어 있습니다. 마이그레이션 작업을 위한 프롬프트 엔지니어링을 학습하려면 에이전트의 접근 방식과 이 참조 자료를 비교해 보세요.
>

## 범위

### 포함 범위

- 대상 프레임워크를 .NET 5에서 .NET 8로 업그레이드
- 제네릭 호스트 패턴(`Startup.cs`)을 최소 호스팅 API(`WebApplication.CreateBuilder()`)로 교체
- Entity Framework 6을 Entity Framework Core 8로 마이그레이션
- 데이터베이스 공급자를 SQL Server에서 PostgreSQL(Npgsql)로 변경
- Cloud Run 호환 Dockerfile 및 Docker Compose 구성 생성
- 구조화된 로깅, PORT 바인딩 및 SIGTERM 정상 종료 구현

### 제외 범위

- 비즈니스 로직 변경 (충실한 1:1 기능 복제)
- 프런트엔드 재설계 (Razor 뷰는 그대로 유지하며 컴파일 가능 여부만 확인)
- 데이터베이스 스키마 변경 (EF Core는 동일한 스키마에 매핑되어야 함)

## 마이그레이션 체크리스트

### 0단계: 컨텍스트 엔지니어링 — 에이전트 자체 온보딩

마이그레이션 코드를 작성하기 전에, 에이전트는 코드베이스에 대한 자체적인 이해를 구축해야 합니다.

- [ ] **엄격한 모드 설정** — 조사 중 우발적인 파일 쓰기를 방지합니다:

  ```text
  /permissions strict
  ```

- [ ] **코드베이스 조사:**

  ```text
  Analyze the ContosoUniversity application. Map:
  1. Current framework version and all NuGet dependencies
  2. The Startup.cs/Program.cs hosting pattern
  3. All System.Data.Entity (EF6) usage across DAL, controllers, and migrations
  4. Configuration sources (appsettings.json, web.config remnants)
  5. Google Cloud integrations (Diagnostics, logging)
  ```

- [ ] 분석을 기반으로 **마이그레이션을 인식하는 AGENTS.md 생성**
- [ ] 진행하기 전에 생성된 AGENTS.md를 **검토 및 승인**
- [ ] 1단계 전에 **리뷰 요청 모드로 전환**:

  ```text
  /permissions request-review
  ```

### 1단계: TFM 및 패키지 업그레이드

- [ ] `ContosoUniversity.csproj` 업데이트: `<TargetFramework>net5.0</TargetFramework>` → `net8.0`으로 변경
- [ ] 모든 NuGet 패키지를 .NET 8 호환 버전으로 업데이트:
  - `Microsoft.AspNetCore.Mvc.NewtonsoftJson` → 8.0.x
  - `System.ComponentModel.Annotations` → 8.0.x
  - `System.Configuration.ConfigurationManager` → 8.0.x
  - `Google.Cloud.Diagnostics.AspNetCore` → 최신 8.0 호환 버전
- [ ] `Microsoft.DotNet.UpgradeAssistant.Extensions.Default.Analyzers` 패키지 제거 (더 이상 필요하지 않음)
- [ ] `<GenerateAssemblyInfo>false</GenerateAssemblyInfo>` 제거 및 `Properties/AssemblyInfo.cs` 삭제
- [ ] `dotnet restore` 실행 — 패키지 충돌 해결

### 2단계: 호스팅 현대화

- [ ] `Startup.cs` + `Program.cs` (Generic Host 패턴)를 최소 호스팅 API로 교체:

  ```csharp
  var builder = WebApplication.CreateBuilder(args);
  builder.Services.AddControllersWithViews();
  // ... service registration
  var app = builder.Build();
  // ... middleware pipeline
  app.Run();
  ```

- [ ] `ConfigureServices()` 본문을 최상위 `builder.Services` 블록으로 이동
- [ ] `Configure()` 본문을 최상위 `app.Use*()` 파이프라인으로 이동
- [ ] `CreateHostBuilder` 비밀 구성 로딩을 새 패턴으로 마이그레이션
- [ ] Cloud Run을 위한 PORT 바인딩 구성: `app.Run("http://0.0.0.0:" + port)`
- [ ] SIGTERM 정상 종료 핸들러 추가
- [ ] 마이그레이션 완료 후 `Startup.cs` 삭제

### 3단계: Entity Framework 6 → EF Core 8

- [ ] `EntityFramework` 6.4.4 패키지 제거
- [ ] `Microsoft.EntityFrameworkCore` 및 `Npgsql.EntityFrameworkCore.PostgreSQL` 8.0.x 추가
- [ ] `SchoolContext` 리팩터링:
  - `System.Data.Entity` 가져오기 교체 → `Microsoft.EntityFrameworkCore`
  - `OnModelCreating`에서 `DbModelBuilder` 교체 → `ModelBuilder`
  - `PluralizingTableNameConvention` 제거 → 명시적인 `.ToTable()` 호출 추가
  - `MapToStoredProcedures()` 제거 (EF Core에서 지원되지 않음)
  - 생성자 `SchoolContext(string connectString) : base(connectString)` 교체 → `SchoolContext(DbContextOptions<SchoolContext> options) : base(options)`
- [ ] DI에 DbContext 등록: `builder.Services.AddDbContext<SchoolContext>(options => options.UseNpgsql(...))`
- [ ] `context.Database.EnsureCreated()`를 사용하여 `SchoolInitializer.cs` 리팩터링 → `DbInitializer.cs`
- [ ] `SchoolConfiguration.cs` 제거 (`Database.SetInitializer<T>()`는 EF6 전용임)
- [ ] `SchoolInterceptorLogging.cs` 및 `SchoolInterceptorTransientErrors.cs` (EF6 인터셉터) 제거 → `ILoggerFactory`를 통한 EF Core 로깅으로 교체
- [ ] 모든 EF6 마이그레이션 파일 삭제 (`Migrations/2014*.cs`, `Migrations/Configuration.cs`)
- [ ] 모든 컨트롤러를 업데이트하여 `System.Data.Entity` 가져오기를 제거하고 `RetryLimitExceededException` (EF6) 수정 → EF Core 동등 항목으로 교체
- [ ] `dotnet build` 실행 — 모든 컴파일 오류 수정

### 4단계: 컨테이너화 및 Cloud Run

- [ ] 다단계 `Dockerfile` 생성:

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

- [ ] `.dockerignore` 추가 (`bin/`, `obj/`, `.git/` 제외)
- [ ] PostgreSQL + 앱 서비스가 포함된 `compose.yaml` 생성:
  - `pg_isready` 상태 확인이 있는 PostgreSQL 컨테이너
  - 환경 변수를 통한 연결 문자열이 있는 앱 컨테이너
  - `version` 속성 없음 (Compose 사양에서 더 이상 사용되지 않음)
- [ ] Cloud Logging을 위한 구조화된 JSON 로깅 구성: `builder.Logging.AddJsonConsole()`
- [ ] `docker build --check .` 실행 — 모든 Docker 빌드 검사 통과
- [ ] `docker compose up --build --detach` 실행 — 앱이 시작되고 데이터베이스가 초기화되는지 확인

### 5단계: 검증 및 테스트

- [ ] `dotnet build`가 오류나 경고 없이 컴파일됨
- [ ] Docker 이미지가 Linux에서 빌드되고 실행됨 (Windows 컨테이너 아님)
- [ ] 컨테이너가 비루트 사용자(UID 1000)로 실행됨
- [ ] 모든 HTTP 엔드포인트가 올바르게 응답함 (CRUD 작업을 위한 GET, POST)
- [ ] 첫 실행 시 데이터베이스가 시드 데이터로 초기화됨
- [ ] 애플리케이션이 POST/DELETE 작업에 대해 위조 방지 토큰을 올바르게 처리함
- [ ] 구조화된 JSON 로그가 `docker compose logs`에 나타남
- [ ] 소스 코드에 연결 문자열이나 자격 증명이 없음

## 에이전트가 수행해야 할 작업

이 PRD는 에이전트의 다음 능력을 테스트하도록 설계되었습니다:

1. **자체 컨텍스트 부트스트랩** — 시작하기 전에 엄격 모드(strict mode)와 코드베이스 조사를 사용하여 AGENTS.md를 작성합니다 (0단계).
2. **레거시 패턴 이해** — EF6 관용구(`DbModelBuilder`, 인터셉터, `Database.SetInitializer`)를 인식하고 이를 EF Core의 동등한 요소로 매핑합니다.
3. **단계별 계획 준수** — 실행하기 전에 `ctrl+g`를 사용하여 계획을 편집하고 승인합니다.
4. **기계적 리팩토링 수행** — EF6에서 EF Core로의 마이그레이션은 모든 컨트롤러와 모델 파일에 영향을 미칩니다.
5. **자체 작업 검증** — 각 단계 후에 `dotnet build` 및 `docker compose up`을 실행합니다.
6. **단계가 잘못된 경우 `/rewind` 사용** — 이것은 실패가 아니라 체크포인트입니다.

## 인수 조건

- [ ] 마이그레이션 컨텍스트를 담고 있는 `AGENTS.md`가 프로젝트 루트에 존재함
- [ ] .NET 8에서 `dotnet build`가 오류 없이 컴파일됨
- [ ] 코드베이스 어디에도 `System.Data.Entity` import문이 남아있지 않음
- [ ] `Startup.cs`가 없음 — 앱이 `Program.cs`에서 최소 호스팅 API를 사용함
- [ ] `EntityFramework` 6.x 패키지가 `Microsoft.EntityFrameworkCore` 8.x로 완전히 대체됨
- [ ] Docker 이미지가 Linux에서 비루트 사용자로 빌드되고 실행됨
- [ ] `docker compose up`이 앱과 PostgreSQL을 성공적으로 시작하고 데이터베이스를 시드함
- [ ] 소스 코드에 연결 문자열이나 자격 증명이 없음
- [ ] 애플리케이션이 콜드 스타트 후 2초 이내에 상태 확인(health check)에 응답함
