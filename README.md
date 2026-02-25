# opensearch-ops

> Claude Code 플러그인: OpenSearch MCP 서버 + 장애 조사/로그 분석 스킬

**"결제 실패가 2월 25일 5시~7시 쯤 발생한 것 같아. 오픈서치 확인하고 백엔드 코드 원인 파악해줘"** — 이런 자연어 요청으로 장애 원인을 분석합니다.

## 기능

| 스킬 | 설명 |
|------|------|
| `/opensearch-ops:investigate` | 장애 조사 (로그 + 코드 분석) |
| `/opensearch-ops:search-logs` | 조건별 로그 검색 |
| `/opensearch-ops:analyze-patterns` | 두 시간대 로그 패턴 비교 분석 |
| `/opensearch-ops:cluster-health` | 클러스터 상태 확인 |

### MCP 도구 (자동 연결)

[opensearch-mcp-server-py](https://github.com/opensearch-project/opensearch-mcp-server-py)가 자동으로 연결되어 아래 도구들이 사용 가능합니다:

- **SearchIndexTool** — Query DSL 기반 검색
- **LogPatternAnalysisTool** — baseline vs selection 이상 패턴 탐지
- **DataDistributionTool** — 시간대별 데이터 분포 분석
- **ListIndexTool** — 인덱스 목록 조회
- **ClusterHealthTool** — 클러스터 상태 확인
- **GenericOpenSearchApiTool** — 모든 OpenSearch API 호출

## 설치

### 원클릭 설치

```bash
git clone https://github.com/nathankim0/opensearch-ops.git
cd opensearch-ops
chmod +x setup.sh && ./setup.sh
```

### 마켓플레이스에서 설치

```bash
# 마켓플레이스 등록
claude plugin marketplace add nathankim0/opensearch-ops

# 플러그인 설치
claude plugin install opensearch-ops
```

### 로컬 개발 모드

```bash
claude --plugin-dir /path/to/opensearch-ops
```

## 인증 설정

MCP 서버는 **서버-투-서버 통신**이므로, 브라우저 기반 인증(Google OAuth, SAML 등)은 지원되지 않습니다.
아래 세 가지 방식 중 하나를 선택하세요.

### 방법 1: Basic Auth — Internal User (권장)

가장 간단한 방법입니다. OpenSearch Dashboards에서 API 전용 Internal User를 생성합니다.

**생성 방법:** Dashboards → Security → Internal Users → Create internal user

> 관리자 권한이 없다면 인프라 담당자에게 요청하세요:
> "OpenSearch에 API 조회용 Internal User 하나 만들어주세요. `readall` 역할이면 충분합니다."

```bash
# ~/.zshrc 또는 ~/.bashrc 에 추가
export OPENSEARCH_URL="https://your-opensearch-cluster:9200"
export OPENSEARCH_USERNAME="mcp-reader"
export OPENSEARCH_PASSWORD="발급받은비밀번호"
export OPENSEARCH_SSL_VERIFY="true"
```

### 방법 2: AWS IAM 인증 (SigV4)

IAM 유저/역할에 OpenSearch 접근 권한(`es:ESHttp*`)이 있어야 합니다.

```bash
export OPENSEARCH_URL="https://your-domain.ap-northeast-2.es.amazonaws.com"
export AWS_REGION="ap-northeast-2"
# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY 또는 AWS_PROFILE 설정 필요
```

> **주의:** S3 전용 IAM 유저 등 OpenSearch 권한이 없는 유저로는 403 에러가 발생합니다.

### 방법 3: Self-managed OpenSearch

직접 운영하는 클러스터의 경우:

```bash
export OPENSEARCH_URL="https://localhost:9200"
export OPENSEARCH_USERNAME="admin"
export OPENSEARCH_PASSWORD="admin"
export OPENSEARCH_SSL_VERIFY="false"  # self-signed cert인 경우
```

### 지원하지 않는 인증 방식

| 방식 | 지원 여부 | 대안 |
|------|-----------|------|
| Basic Auth (Internal User) | **지원** | — |
| AWS IAM (SigV4) | **지원** | — |
| Google OAuth / SAML / OIDC | **미지원** | Internal User 생성 |
| 브라우저 토큰 가로채기 | **미지원** | Internal User 생성 |

## 사용 예시

### 장애 조사

```
/opensearch-ops:investigate 결제 실패가 2월 25일 5시~7시 쯤 집중 발생. 오픈서치 로그 확인하고 백엔드 코드 원인 파악해줘
```

### 로그 검색

```
/opensearch-ops:search-logs 오늘 오전 10시~11시 사이 ERROR 레벨 로그 중 "timeout" 키워드 검색
```

### 패턴 비교

```
/opensearch-ops:analyze-patterns 배포 전(2월 24일 14시~16시)과 배포 후(2월 24일 16시~18시) 에러 패턴 비교
```

### 클러스터 상태

```
/opensearch-ops:cluster-health
```

## 구조

```
opensearch-ops/
├── .claude-plugin/
│   ├── plugin.json          # 플러그인 매니페스트
│   └── marketplace.json     # 마켓플레이스 메타데이터
├── .mcp.json                # OpenSearch MCP 서버 설정
├── skills/
│   ├── investigate/         # 장애 조사 (메인 스킬)
│   │   └── SKILL.md
│   ├── search-logs/         # 로그 검색
│   │   └── SKILL.md
│   ├── analyze-patterns/    # 패턴 비교 분석
│   │   └── SKILL.md
│   └── cluster-health/      # 클러스터 상태
│       └── SKILL.md
├── setup.sh                 # 원클릭 설치 스크립트
├── LICENSE
└── README.md
```

## 요구 사항

- [Claude Code](https://claude.ai/code) (CLI)
- Python 3.10+ (uv 또는 pip)
- OpenSearch 클러스터 접근 가능

## 라이선스

MIT
