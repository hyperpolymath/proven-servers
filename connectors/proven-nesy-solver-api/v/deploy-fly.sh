#!/usr/bin/env bash
# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# deploy-fly.sh: Deploy the nesy-solver playground stack to fly.io.
#
# Deploys in dependency order:
#   1. ClickHouse (clickhouse-nesy) — needs volume, schema migration
#   2. verisim-api (verisim-api) — HTTP API, depends on ClickHouse
#   3. echidna (echidna-nesy) — prover dispatcher, standalone
#   4. nesy-solver-api (nesy-solver-api) — public edge, depends on echidna + verisim-api
#
# Prereqs:
#   - flyctl auth login      (interactive browser OAuth)
#   - podman installed       (for any local container test-builds)
#
# Run:
#   ./deploy-fly.sh [phase]
#     phase = all (default) | clickhouse | verisim | echidna | nesy-api | schema
#
# Idempotent: app-create and volume-create steps are skipped if they exist.

set -euo pipefail

REGION="${FLY_REGION:-lhr}"
ORG="${FLY_ORG:-personal}"
CH_APP="clickhouse-nesy"
VERISIM_APP="verisim-api"
ECHIDNA_APP="echidna-nesy"
NESY_APP="nesy-solver-api"

# Repo paths (absolute, so the script works from any cwd).
REPOS_ROOT="$(cd "$(dirname "$0")/../../../../.." && pwd)"
VERISIMDB="$REPOS_ROOT/verisimdb"
ECHIDNA="$REPOS_ROOT/echidna"
NESY_API="$REPOS_ROOT/proven-servers/connectors/proven-nesy-solver-api/v"

PHASE="${1:-all}"

say() { printf "\n\033[1;34m▶ %s\033[0m\n" "$*"; }
ok()  { printf "  \033[1;32m✓\033[0m %s\n" "$*"; }
warn(){ printf "  \033[1;33m!\033[0m %s\n" "$*"; }

ensure_app() {
  local app="$1"
  if flyctl apps list -j 2>/dev/null | grep -q "\"Name\": *\"$app\""; then
    ok "app $app exists"
  else
    say "creating app $app"
    flyctl apps create "$app" --org "$ORG"
  fi
}

ensure_volume() {
  local app="$1" name="$2" size="$3"
  if flyctl volumes list -a "$app" -j 2>/dev/null | grep -q "\"name\": *\"$name\""; then
    ok "volume $name exists on $app"
  else
    say "creating volume $name ($size GB) on $app"
    flyctl volumes create "$name" --size "$size" --region "$REGION" -a "$app" --yes
  fi
}

deploy_clickhouse() {
  say "=== Phase 1: ClickHouse ==="
  ensure_app "$CH_APP"
  ensure_volume "$CH_APP" clickhouse_data 1

  # Set a random ClickHouse password if not already set.
  if ! flyctl secrets list -a "$CH_APP" -j 2>/dev/null | grep -q CLICKHOUSE_PASSWORD; then
    local pw
    pw="$(openssl rand -hex 24)"
    flyctl secrets set CLICKHOUSE_PASSWORD="$pw" -a "$CH_APP" --stage
    warn "set CLICKHOUSE_PASSWORD (save it locally: flyctl secrets list -a $CH_APP)"
    # Propagate to verisim-api as part of the connection URL.
    flyctl secrets set VERISIM_CLICKHOUSE_URL="http://verisim:${pw}@${CH_APP}.internal:8123/verisimdb" \
                        -a "$VERISIM_APP" --stage 2>/dev/null \
      || warn "verisim-api app not yet created — set VERISIM_CLICKHOUSE_URL manually later"
  fi

  cd "$VERISIMDB"
  flyctl deploy -a "$CH_APP" -c clickhouse.fly.toml --remote-only
  ok "clickhouse deployed"
}

apply_schema() {
  say "=== Phase 1b: Apply ClickHouse schema ==="
  cd "$VERISIMDB"
  # Use flyctl proxy to reach clickhouse-nesy.internal:8123 over a local port.
  warn "opening flyctl proxy to $CH_APP:8123 → localhost:18123 (keep this terminal)"
  flyctl proxy 18123:8123 -a "$CH_APP" &
  local proxy_pid=$!
  sleep 5
  curl -sSf "http://localhost:18123/" --data-binary @deploy/nesy-playground-schema.sql
  kill $proxy_pid 2>/dev/null || true
  ok "schema applied (proof_attempts + mv_prover_success_by_class)"
}

deploy_verisim() {
  say "=== Phase 2: verisim-api ==="
  ensure_app "$VERISIM_APP"
  cd "$VERISIMDB"
  flyctl deploy -a "$VERISIM_APP" -c fly.toml -f Containerfile.api --remote-only
  ok "verisim-api deployed"
}

deploy_echidna() {
  say "=== Phase 3: echidna ==="
  ensure_app "$ECHIDNA_APP"
  cd "$ECHIDNA"
  flyctl deploy -a "$ECHIDNA_APP" -c fly.toml -f .containerization/Containerfile.full --remote-only
  ok "echidna deployed"
}

deploy_nesy_api() {
  say "=== Phase 4: nesy-solver-api ==="
  ensure_app "$NESY_APP"
  cd "$NESY_API"
  flyctl deploy -a "$NESY_APP" -c fly.toml -f Containerfile --remote-only
  ok "nesy-solver-api deployed"
  local url
  url="$(flyctl status -a "$NESY_APP" -j 2>/dev/null | grep -oE 'https?://[^"]*fly\.dev' | head -1 || echo "")"
  if [ -n "$url" ]; then
    ok "public URL: $url"
  fi
}

main() {
  if ! command -v flyctl >/dev/null 2>&1; then
    echo "flyctl not in PATH — add: export PATH=\"\$HOME/.fly/bin:\$PATH\""
    exit 1
  fi
  if ! flyctl auth whoami >/dev/null 2>&1; then
    echo "not authenticated — run: flyctl auth login"
    exit 1
  fi

  case "$PHASE" in
    clickhouse) deploy_clickhouse ;;
    schema)     apply_schema ;;
    verisim)    deploy_verisim ;;
    echidna)    deploy_echidna ;;
    nesy-api)   deploy_nesy_api ;;
    all)
      deploy_clickhouse
      apply_schema
      deploy_verisim
      deploy_echidna
      deploy_nesy_api
      say "=== Deploy complete ==="
      ;;
    *)
      echo "usage: $0 [all|clickhouse|schema|verisim|echidna|nesy-api]"
      exit 1
      ;;
  esac
}

main "$@"
