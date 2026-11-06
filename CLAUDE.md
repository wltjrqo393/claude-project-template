# CLAUDE.md

이 파일은 이 레포에서 Claude가 **항상** 지켜야 하는 규칙이다.
특정 상황에서만 쓰는 절차는 `.claude/skills/`에 스킬로 분리되어 있다.
규칙끼리 충돌하면 **사용자의 최신 지시 > 이 파일 > 일반 관행** 순서로 따른다.

---

## 0. 프로젝트 개요

> TODO: 프로젝트 목적, 주요 구성요소, 실행 방법을 3~5줄로 적는다.

## 1. 커뮤니케이션

- 응답과 문서는 **한국어**로 작성한다. 코드 식별자, 커밋 메시지, 로그 메시지는 영어로 쓴다.
- 보고는 간결하게: 무엇이 바뀌었는지, 어떻게 실행하는지만 쓴다. 작업 과정을 나열하지 않는다.

## 2. 개발 환경 전제 (중요)

- Claude는 클라우드 세션에서 이 레포를 clone해서 작업한다. **실제 실행 환경(사내 환경)과는 분리되어 있고**, 사내 환경으로는 **zip 파일로 코드를 옮긴다.**
  → zip을 만들어 전달할 때는 `zip-deliver` 스킬(`.claude/skills/zip-deliver/`)을 따른다.
- 사내 환경은 외부 인터넷이 제한될 수 있다.
  - 런타임에 외부 API나 외부 다운로드(HuggingFace Hub 자동 다운로드 등)에 의존하지 않는다.
  - 모델/데이터 경로와 엔드포인트는 하드코딩하지 않고 환경변수로 받는다. (`.env.example`에 기록)
- 클라우드 세션에서 동작했다고 사내 환경에서도 동작한다고 가정하지 않는다. GPU/CUDA 버전과 경로 차이를 고려한다.
- 비밀값(API 키, 토큰, 사내 주소)은 코드, 커밋, zip 어디에도 넣지 않는다.

## 3. 기술 스택

- Python 3.10+ / PyTorch, Transformers, PEFT / vLLM, FastAPI / Docker
- 의존성은 `requirements.txt`에 `==`로 버전을 고정한다. 새 의존성은 꼭 필요할 때만 추가하고, 추가할 때 이유를 한 줄로 알린다. (오프라인 설치를 고려)

## 4. 코드 스타일

- `print` 대신 `logging`, 경로는 `pathlib`, 함수에는 type hint를 쓴다.
- 기존 코드가 있으면 기존 스타일을 따른다.

## 5. 코딩 행동 원칙 (Karpathy Guidelines)

> 출처: [forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills) (MIT), Andrej Karpathy가 관찰한 LLM 코딩 실수 패턴에서 도출됨. 원문 그대로 수록.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 5.1 Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 5.2 Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

> 예외: 2장의 환경변수 분리(경로, 엔드포인트, 비밀값)는 사내 환경 이식을 위한 **요구사항**이므로 "요청되지 않은 configurability"로 보지 않는다.

### 5.3 Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 5.4 Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
