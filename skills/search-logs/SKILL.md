---
name: search-logs
description: "OpenSearch에서 특정 조건의 로그를 검색합니다. 시간대, 로그 레벨, 키워드, 서비스명 등으로 필터링할 수 있습니다."
argument-hint: "[검색 조건 - 시간대, 키워드, 로그레벨 등]"
---

# 로그 검색 스킬

OpenSearch에서 로그를 검색하고 결과를 정리합니다.

## 입력

$ARGUMENTS

## 실행 절차

### 1단계: 검색 조건 파싱

사용자 입력에서 추출:
- **시간 범위**: 날짜/시간 → ISO 8601 변환 (기본 타임존: KST → UTC 변환)
- **로그 레벨**: ERROR, WARN, INFO, DEBUG
- **키워드**: 에러 메시지, API 경로, 사용자 ID 등
- **서비스/호스트**: 특정 서비스 필터링
- **인덱스 패턴**: 미지정 시 ListIndexTool로 확인

### 2단계: 검색 쿼리 구성

**SearchIndexTool**을 사용하여 Query DSL 구성:

```json
{
  "query": {
    "bool": {
      "filter": [
        { "range": { "@timestamp": { "gte": "<start>", "lte": "<end>" } } }
      ],
      "must": [
        { "match_phrase": { "message": "<키워드>" } }
      ]
    }
  },
  "sort": [{ "@timestamp": "desc" }],
  "size": 30
}
```

### 3단계: 결과 정리

검색 결과를 아래 형식으로 정리:

```
## 검색 결과 (총 N건)

### 조건
- 기간: YYYY-MM-DD HH:MM ~ HH:MM
- 필터: [적용된 필터]
- 인덱스: [검색한 인덱스]

### 주요 로그
| 시각 | 레벨 | 서비스 | 메시지 (요약) |
|------|------|--------|---------------|
| ... | ERROR | ... | ... |

### 패턴 요약
- ERROR 발생 N건 (주요 원인: ...)
- WARN 발생 N건
```

### 추가 옵션

사용자가 요청 시:
- **집계 모드**: 에러 코드별/서비스별/시간대별 카운트
- **상세 모드**: 스택트레이스 포함 전체 로그
- **추적 모드**: 특정 trace ID / request ID 기반 추적
