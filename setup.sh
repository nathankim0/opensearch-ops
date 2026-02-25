#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# opensearch-ops: 원클릭 설치 스크립트
# MCP 서버(opensearch-mcp-server-py) + 스킬 설치
# ──────────────────────────────────────────────

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo -e "${BOLD}  opensearch-ops 설치${NC}"
echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo ""

# ── 1. 사전 요구사항 확인 ──

echo -e "${BOLD}[1/4] 사전 요구사항 확인${NC}"

# Python / uv 확인
if command -v uv &>/dev/null; then
  info "uv 감지: $(uv --version)"
elif command -v uvx &>/dev/null; then
  info "uvx 감지"
elif command -v pip &>/dev/null; then
  warn "uv 미설치. pip으로 대체합니다."
else
  error "Python 패키지 매니저(uv 또는 pip)가 필요합니다.\n  설치: curl -LsSf https://astral.sh/uv/install.sh | sh"
fi

# Claude Code 확인
if command -v claude &>/dev/null; then
  info "Claude Code 감지: $(claude --version 2>/dev/null || echo 'installed')"
else
  error "Claude Code가 필요합니다.\n  설치: npm install -g @anthropic-ai/claude-code"
fi

echo ""

# ── 2. OpenSearch MCP 서버 설치 ──

echo -e "${BOLD}[2/4] OpenSearch MCP 서버 설치${NC}"

if command -v uv &>/dev/null; then
  uv pip install opensearch-mcp-server-py 2>/dev/null && info "opensearch-mcp-server-py 설치 완료 (uv)" || {
    uv tool install opensearch-mcp-server-py 2>/dev/null && info "opensearch-mcp-server-py 설치 완료 (uv tool)" || {
      warn "uv 설치 실패. uvx로 런타임 실행 방식을 사용합니다."
    }
  }
else
  pip install opensearch-mcp-server-py && info "opensearch-mcp-server-py 설치 완료 (pip)"
fi

echo ""

# ── 3. 환경 변수 설정 가이드 ──

echo -e "${BOLD}[3/4] 환경 변수 설정${NC}"

if [ -z "${OPENSEARCH_URL:-}" ]; then
  warn "OPENSEARCH_URL 미설정"
  echo ""
  echo "  다음 환경 변수를 설정하세요 (~/.zshrc 또는 ~/.bashrc):"
  echo ""
  echo "    export OPENSEARCH_URL=\"https://your-opensearch:9200\""
  echo "    export OPENSEARCH_USERNAME=\"admin\""
  echo "    export OPENSEARCH_PASSWORD=\"your-password\""
  echo "    export OPENSEARCH_SSL_VERIFY=\"false\""
  echo ""
else
  info "OPENSEARCH_URL: ${OPENSEARCH_URL}"
fi

echo ""

# ── 4. Claude Code 플러그인 설치 ──

echo -e "${BOLD}[4/4] Claude Code 플러그인 설치${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 마켓플레이스 방식 또는 로컬 설치
if [ -f "$SCRIPT_DIR/.claude-plugin/plugin.json" ]; then
  info "플러그인 디렉토리 확인: $SCRIPT_DIR"
  echo ""
  echo "  사용 방법:"
  echo ""
  echo "  ${BOLD}방법 1: 로컬 개발 모드${NC}"
  echo "    claude --plugin-dir $SCRIPT_DIR"
  echo ""
  echo "  ${BOLD}방법 2: 마켓플레이스에서 설치${NC}"
  echo "    claude plugin marketplace add https://raw.githubusercontent.com/nathankim0/opensearch-ops/main/marketplace.json"
  echo "    claude plugin install opensearch-ops"
  echo ""
else
  error "플러그인 디렉토리 구조가 올바르지 않습니다."
fi

echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo -e "${GREEN}설치 완료!${NC}"
echo ""
echo "사용 가능한 스킬:"
echo "  /opensearch-ops:investigate      - 장애 조사 (로그 + 코드 분석)"
echo "  /opensearch-ops:search-logs      - 로그 검색"
echo "  /opensearch-ops:analyze-patterns - 로그 패턴 비교 분석"
echo "  /opensearch-ops:cluster-health   - 클러스터 상태 확인"
echo ""
echo -e "${BOLD}═══════════════════════════════════════${NC}"
