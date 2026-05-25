---
title: ""
hide:
  - navigation
  - toc
---

<div class="hero-banner" markdown>
  <img src="assets/banner.png" alt="Antigravity CLI 필드 워크숍">
</div>

---

## 워크숍 모듈

<div class="grid cards" markdown>

- :material-rocket-launch:{ .lg .middle } **모듈 1 — SDLC 생산성 향상**

    ---

    첫 번째 Antigravity CLI 세션입니다. 코드 설명, 리팩토링, 테스트, 리뷰를 수행하고 단일 명령으로 플러그인을 사용하여 툴체인을 확장해 봅니다.

    **75분** · 섹션 1.0–1.7

    [:octicons-arrow-right-24: 모듈 1 시작하기](sdlc-productivity.md)

- :material-wrench:{ .lg .middle } **모듈 2 — 레거시 현대화 ⭐**

    ---

    가장 핵심적인 모듈입니다. 엄격한 모드(strict mode), 에이전트 자체 온보딩(self-onboarding), 서브에이전트 계획 수립을 사용하여 실제 레거시 코드베이스(.NET 또는 Java)를 마이그레이션합니다.

    **90분** · 실습: ex08, ex09

    [:octicons-arrow-right-24: 모듈 2 시작하기](legacy-modernization.md)

- :material-code-braces:{ .lg .middle } **모듈 3 — AGY 에이전트 구축**

    ---

    ADK SDK를 사용하여 프로덕션 에이전트를 구축합니다. 도구, 세션 상태, SequentialAgent 파이프라인을 다루고 Cloud Run에 배포합니다.

    **90분** · 실습: ex10, ex11

    [:octicons-arrow-right-24: 모듈 3 시작하기](agy-sdk.md)

- :material-sitemap:{ .lg .middle } **모듈 4 — 멀티 에이전트 및 고급 기능**

    ---

    격리된 서브에이전트를 생성하고, `/btw`를 사용하여 실행 중인 작업을 조정하며, 반복 작업을 예약하고, ID를 통해 장기 실행 세션을 재개합니다.

    **60분** · 실습: ex04–ex07

    [:octicons-arrow-right-24: 모듈 4 시작하기](multi-agent-advanced.md)

</div>

---

## 워크숍 일정

| 시간 | 내용 | 소요 시간 |
| :-- | :-- | :-- |
| `0:00` | 설정 + 첫 실행 | 20분 |
| `0:20` | **모듈 1:** SDLC 생산성 향상 + 플러그인 | 75분 |
| `1:35` | :coffee: 휴식 | 10분 |
| `1:45` | **모듈 2:** 레거시 코드베이스 현대화 | 90분 |
| `3:15` | :coffee: 휴식 | 10분 |
| `3:25` | **모듈 3:** SDK를 사용한 AGY 에이전트 구축 | 90분 |
| `4:55` | **모듈 4:** 멀티 에이전트 및 고급 | 60분 |
| `5:55` | 마무리 및 Q&A | 15분 |

> **반일(Half-day) 형식:** 모듈 1 + 2만 진행 (2.5시간). **라이트닝(Lightning) 형식:** 모듈 1 + 모듈 2 주요 내용 (1.5시간).

---

## 시작하기 전에

!!! warning "사전 작업 필수"
    워크숍 전에 [환경 설정](setup.md)을 완료하세요. Antigravity CLI가 설치되고 인증되어 있어야 합니다.

!!! info "공식 문서"
    전체 참조 문서는 [antigravity.google/docs](https://www.antigravity.google/docs/cli-overview)에서 확인할 수 있습니다.

!!! info "사전 요구 사항"
    터미널, git 및 기본 코딩 워크플로에 익숙해야 합니다. 이전 AI 코딩 어시스턴트 경험은 필요하지 않습니다.
