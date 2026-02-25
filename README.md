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
claude plugin marketplace add https://raw.githubusercontent.com/nathankim0/opensearch-ops/main/marketplace.json

# 플러그인 설치
claude plugin install opensearch-ops
```

### 로컬 개발 모드

```bash
claude --plugin-dir /path/to/opensearch-ops
```

## 환경 변수

OpenSearch 클러스터에 연결하려면 아래 환경 변수를 설정하세요:

```bash
# ~/.zshrc 또는 ~/.bashrc 에 추가
export OPENSEARCH_URL="https://your-opensearch-cluster:9200"
export OPENSEARCH_USERNAME="admin"
export OPENSEARCH_PASSWORD="your-password"
export OPENSEARCH_SSL_VERIFY="false"  # self-signed cert인 경우
```

### AWS OpenSearch Service

AWS 환경에서는 IAM 인증을 사용할 수 있습니다:

```bash
export OPENSEARCH_URL="https://your-domain.us-east-1.es.amazonaws.com"
export AWS_REGION="us-east-1"
# IAM 역할 기반 인증은 자동으로 처리됩니다
```

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
│   └── plugin.json          # 플러그인 매니페스트
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
├── marketplace.json         # 마켓플레이스 메타데이터
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
