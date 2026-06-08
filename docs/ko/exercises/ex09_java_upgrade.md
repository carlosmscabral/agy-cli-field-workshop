# PRD: Java 8 → Java 21 및 Spring Boot 3 마이그레이션

> **워크숍 용도:** [모듈 2 — 레거시 코드베이스 현대화](../../legacy-modernization.md)를 위한 실습 예제입니다. 대규모 컨텍스트 코드베이스 조사 패턴, AGENTS.md 셀프 온보딩, 그리고 사람이 수행할 때 오류가 발생하기 쉬운 기계적인 네임스페이스 마이그레이션을 agy가 어떻게 처리하는지 보여줍니다.
>

## 문제

엔터프라이즈 Java REST API(Spring PetClinic REST)가 Java 8 및 Spring Boot 2.6.x에서 실행됩니다. Java 8은 2022년에 공개 업데이트가 종료되었습니다. 이 애플리케이션은 가상 스레드, 최신 GC 개선 사항 또는 최신 보안 패치를 사용할 수 없습니다. 규정 준수를 위해 지원되는 LTS 버전으로 마이그레이션해야 합니다.

## 비즈니스 동인

| 동인 | 영향 |
| :-- | :-- |
| **보안 규정 준수** | Java 8은 EOL(수명 종료) 상태이며 보안 패치가 제공되지 않습니다. 감사 지적 사항으로 인해 다음 SOC 2 갱신이 차단됩니다. |
| **성능** | Java 21 가상 스레드(Virtual Threads)는 동시성이 높은 엔드포인트에서 스레드 풀 경합을 줄입니다. p99 지연 시간이 약 30% 감소할 것으로 예상됩니다. |
| **비용** | 메모리 사용량이 개선되어 더 작은 컨테이너 인스턴스를 사용할 수 있습니다. 인프라 비용이 약 20% 절감될 것으로 예상됩니다. |
| **개발자 경험** | 레코드(Records), 봉인 클래스(sealed classes), 패턴 매칭(pattern matching), 텍스트 블록(text blocks)을 통해 보일러플레이트 코드를 약 15% 줄입니다. |

## 범위

### 포함 범위

- Java 8에서 Java 21(LTS)로 업그레이드
- Spring Boot 2.6.x에서 Spring Boot 3.3.x로 업그레이드
- javax.*에서 jakarta.* 네임스페이스로 마이그레이션
- 더 이상 사용되지 않는(deprecated) Security 설정 교체 (`WebSecurityConfigurerAdapter`)
- OpenAPI/Swagger를 SpringFox에서 SpringDoc으로 마이그레이션
- 가상 스레드(Virtual Threads) 활성화
- 기존의 모든 테스트 통과 보장

### 제외 범위

- 마이크로서비스 분해 (모놀리식 구조 유지)
- 데이터베이스 스키마 변경
- 새로운 기능 개발

## 워크샵 설정: 버전 맞추기

이 PRD에 정의된 목표 상태와 마이그레이션 실습의 일관성을 유지하려면, **태그 `v2.6.2`**의 **Spring PetClinic REST** 변형을 사용하세요. 이 특정 태그는 안정적인 기준선 역할을 합니다. — 이는 **Spring Boot 2.6.2 및 Java 8**을 사용하며, 결정적으로 `WebSecurityConfigurerAdapter`를 사용한 실제 Spring Security 구성을 포함하고 있어 보안 마이그레이션 단계를 실질적으로 만들어 줍니다.

```bash
git clone --branch v2.6.2 --depth 1 https://github.com/spring-petclinic/spring-petclinic-rest.git
cd spring-petclinic-rest
```

> **왜 이 변형을 사용하나요?** 메인 `spring-petclinic` 저장소에는 Spring Security가 포함된 적이 없습니다. REST 변형에는 JDBC 기반 인증, `@PreAuthorize` 역할 기반 액세스 및 CORS 구성을 갖추고 `WebSecurityConfigurerAdapter`를 확장하는 `BasicAuthenticationConfig`가 있습니다. — 이들은 모두 Spring Security 6으로의 실질적인 마이그레이션이 필요한 패턴입니다.
>

## 마이그레이션 체크리스트

### 0단계: 컨텍스트 엔지니어링 — 에이전트 셀프 온보딩

마이그레이션 코드를 단 한 줄이라도 작성하기 전에, 에이전트는 코드베이스에 대한 자체적인 이해를 구축해야 합니다. 이 단계에서는 **셀프 온보딩(self-onboarding)** 패턴을 사용합니다. 에이전트는 전체 프로젝트를 읽고, 아키텍처 패턴을 매핑하며, 학습한 내용을 인코딩하는 `AGENTS.md`를 생성합니다. 즉, 자체 컨텍스트 파일을 효과적으로 작성하는 것입니다.

- [ ] **엄격 모드 설정** — 조사 중에는 쓰기 금지:

  ```text
  /permissions strict
  ```

- [ ] **코드베이스 조사:**

  ```text
  전체 프로젝트 구조, 종속성 및 아키텍처 패턴을 분석하세요.
  모든 Spring Security 구성 클래스, 데이터 액세스 계층(JDBC, JPA,
  Spring Data) 및 REST 컨트롤러 패턴을 매핑하세요.
  ```

- [ ] **마이그레이션을 인식하는 AGENTS.md 생성:**

  ```text
  분석을 바탕으로 이 프로젝트에 대한 AGENTS.md를 작성하세요. 다음 내용을 포함해야 합니다:
  1. 현재 아키텍처 문서화 (Boot 2.6, Java 8, javax 네임스페이스)
  2. 대상 아키텍처 정의 (Boot 3.3, Java 21, jakarta 네임스페이스)
  3. 마이그레이션 규칙 목록 (한 번에 하나의 모듈, API 계약 유지 등)
  4. 테스트 표준 인코딩 (마이그레이션된 모든 엔드포인트는 테스트를 통과해야 함)
  5. 식별된 알려진 마이그레이션 위험 기록
  ```

- [ ] 진행하기 전에 **생성된 AGENTS.md 검토 및 승인**
- [ ] 1단계 전에 **request-review로 전환**:

  ```text
  /permissions request-review
  ```

> **이것이 중요한 이유:** 이것은 "마이그레이션을 위한 컨텍스트 엔지니어링" 패턴입니다. 사람이 처음부터 AGENTS.md를 작성하는 대신, 에이전트가 코드베이스 조사 기능을 사용하여 풍부한 컨텍스트 파일을 부트스트랩합니다. 그런 다음 에이전트는 이 파일을 사용하여 자체 마이그레이션 작업을 안내합니다. 이는 더 나은 컨텍스트가 더 나은 코드 변경을 생성하는 자기 강화 루프입니다.

### 1단계: 빌드 시스템

- [ ] `pom.xml` 업데이트: `java.version`을 21로 설정
- [ ] Spring Boot parent를 3.3.x로 업데이트
- [ ] 제거된 JDK API 교체:
  - JAXB → `jakarta.xml.bind:jakarta.xml.bind-api` + Glassfish 런타임
  - `javax.annotation` → `jakarta.annotation:jakarta.annotation-api`
  - `mysql-connector-java` → `com.mysql:mysql-connector-j`
- [ ] `mvn clean compile` 실행 — 진행하기 전에 모든 컴파일 오류 수정

### 2단계: 네임스페이스 마이그레이션

- [ ] 전역 찾기 및 바꾸기: `javax.persistence` → `jakarta.persistence`
- [ ] 전역 찾기 및 바꾸기: `javax.validation` → `jakarta.validation`
- [ ] 전역 찾기 및 바꾸기: `javax.servlet` → `jakarta.servlet`
- [ ] 전역 찾기 및 바꾸기: `javax.annotation` → `jakarta.annotation`
- [ ] 확인: 남아있는 `javax.*` import가 없는지 확인 (변경되지 않는 `javax.sql.*` 제외)

### 3단계: 보안 구성

- [ ] `WebSecurityConfigurerAdapter`를 확장하는 클래스 제거 (Spring Security 6에서 삭제됨):
  - `BasicAuthenticationConfig`
  - `DisableSecurityConfig`
- [ ] `@Bean SecurityFilterChain`을 사용하여 대체 `SecurityConfig` 클래스 생성
- [ ] `.authorizeRequests()` → `.authorizeHttpRequests()` 마이그레이션
- [ ] `@EnableGlobalMethodSecurity` → `@EnableMethodSecurity` 마이그레이션
- [ ] `configureGlobal(AuthenticationManagerBuilder)` → `@Bean AuthenticationManager` 마이그레이션
- [ ] 확인: JDBC 기반 인증, 역할 기반 액세스 및 CORS가 여전히 작동하는지 확인

### 4단계: OpenAPI/Swagger 마이그레이션

- [ ] SpringFox 종속성 제거 (`springfox-boot-starter`, `springfox-swagger2`)
- [ ] SpringDoc 종속성 추가 (`springdoc-openapi-starter-webmvc-ui`)
- [ ] Swagger 어노테이션 마이그레이션: `@Api` → `@Tag`, `@ApiOperation` → `@Operation`
- [ ] `io.swagger`에서 `io.swagger.v3.oas`로 `@ApiResponse` 마이그레이션
- [ ] `ApplicationSwaggerConfig`를 SpringDoc 구성으로 업데이트
- [ ] 확인: `/swagger-ui.html`에서 Swagger UI에 액세스할 수 있는지 확인

### 5단계: 가상 스레드(Virtual Threads) 및 유효성 검사

- [ ] `application.properties`에 추가: `spring.threads.virtual.enabled=true`
- [ ] `@Async` 메서드 검토 — 가상 스레드를 사용하면 I/O 바운드 작업에 사용자 지정 스레드 풀이 필요하지 않습니다.
- [ ] 전체 테스트 제품군 실행: `mvn clean verify`
- [ ] 시작 로그에 Spring Boot 지원 중단(deprecation) 경고가 없는지 확인

## 에이전트가 수행해야 할 작업

이 PRD는 에이전트의 다음 능력을 테스트하도록 설계되었습니다:

1. **자체 컨텍스트 부트스트랩** — 마이그레이션 작업을 시작하기 전에 코드베이스 조사를 사용하여 AGENTS.md를 작성합니다 (0단계).
2. **전체 코드베이스 이해** — 큰 컨텍스트 윈도우를 통해 agy가 모든 파일을 동시에 볼 수 있습니다.
3. **단계별 계획 따르기** — 각 단계를 실행하기 전에 `ctrl+g`를 사용하여 계획을 검토합니다.
4. **기계적인 리팩토링 수행** — 네임스페이스 마이그레이션은 반복적이며 사람이 수행할 경우 오류가 발생하기 쉽습니다.
5. **자체 작업 검증** — 각 단계 후에 `mvn clean verify`를 실행하고 손상된 부분을 수정합니다.
6. **단계가 잘못된 경우 `/rewind` 사용** — 보안 구성 재작성 후에 특히 유용합니다.

## 인수 조건

- [ ] 프로젝트 루트에 마이그레이션 컨텍스트를 인코딩하는 `AGENTS.md`가 존재합니다.
- [ ] Java 21에서 테스트 실패 0건으로 `mvn clean verify`가 통과합니다.
- [ ] `javax.*` 임포트가 남아있지 않습니다 (`javax.sql.*` 제외).
- [ ] 코드베이스 어디에도 `WebSecurityConfigurerAdapter`가 사용되지 않습니다.
- [ ] SpringFox 종속성이 SpringDoc으로 완전히 대체되었습니다.
- [ ] `application.properties`에 `spring.threads.virtual.enabled=true`가 포함되어 있습니다.
- [ ] 시작 로그에 Spring Boot 사용 중단 경고가 없습니다.

## 대상 저장소

[Spring PetClinic REST](https://github.com/spring-petclinic/spring-petclinic-rest)의 [`v2.6.2`](https://github.com/spring-petclinic/spring-petclinic-rest/tree/v2.6.2) 태그 기준 — Spring Boot 2.6.2, Java 8, Spring Security 및 OpenAPI 포함.
