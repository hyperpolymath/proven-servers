#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# proven-servers — Static Source-Check Smoke Suite
#
# This script uses source-pattern checks over a small, explicitly listed
# sample. It does not execute protocol functions and is not property-based
# testing, proof evidence, or a substitute for Zig/Idris builds and tests.
#
# Heuristics checked
# ──────────────────
#   P1  Selected transition-table source lines are present/absent
#
#   P2  A selected initial-edge source line is present
#
#   P3  Selected Zig enum declarations have an expected number of tags
#
#   P4  Selected create functions contain a textual -1 exhaustion branch
#
#   P5  Selected ABI version functions do not visibly return zero
#
#   P6  Selected transition functions contain only literal 0/1 return branches
#
#   P7  Selected transition functions contain a literal rejecting fallback
#
#   P8  Selected source files contain a slot-validator helper pattern
#
# Usage
# ─────
#   bash tests/source_smoke_test.sh
#   just source-smoke

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

PASS=0
FAIL=0
SKIP=0

green()  { printf '\033[32m%s\033[0m\n' "$*"; }
red()    { printf '\033[31m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
bold()   { printf '\033[1m%s\033[0m\n' "$*"; }

pass()      { green  "  PASS: $1"; PASS=$((PASS + 1)); }
fail_test() { red    "  FAIL: $1"; FAIL=$((FAIL + 1)); }
skip_test() { yellow "  SKIP: $1 ($2)"; SKIP=$((SKIP + 1)); }

# Extract one single-line-signature exported Zig function. The targeted
# functions have their closing brace at column zero in this repository.
exported_function_body() {
    local function_name="$1" source_file="$2"
    awk -v fn="$function_name" '
        !capture && index($0, "pub export fn " fn "(") > 0 { capture=1 }
        capture { print }
        capture && /^}/ { exit }
    ' "$source_file"
}

echo "═══════════════════════════════════════════════════════════════"
echo "  proven-servers — Source-Pattern Smoke Checks (not runtime tests)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P1 — Selected source lines inside the named transition function.
# These grep-based checks are neither exhaustive nor executable verification.
# ─────────────────────────────────────────────────────────────────────────────
bold "P1 — Selected transition source lines (not runtime validation)"

# Format: "proto_slug  invalid_from  invalid_to  valid_from  valid_to"
declare -a P1_CASES=(
    "amqp    0  3   0  1"   # Idle->Open invalid; Idle->Connected valid
    "amqp    5  2   5  0"   # Disconnecting->ChannelOpen invalid; ->Idle valid
    "mqtt    0  2   0  1"   # Idle->Subscribed invalid; Idle->Connected valid
    "mqtt    0  3   1  3"   # Idle->Publishing invalid; Connected->Publishing valid
    "mqtt    4  3   4  0"   # Disconnecting->Publishing invalid; ->Idle valid
    "dns     2  0   2  3"   # Lookup->Idle invalid; Lookup->ResponseBuilding valid
    "dns     3  0   3  4"   # ResponseBuilding->Idle invalid; ->Sent valid
    "dns     1  3   1  2"   # QueryReceived->ResponseBuilding (skip) invalid; ->Lookup valid
)

for entry in "${P1_CASES[@]}"; do
    read -r proto inv_from inv_to val_from val_to <<<"$entry"
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"

    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P1 proven-${proto} (${inv_from}→${inv_to} rejected)" "no src file"
        continue
    fi

    transition_body="$(exported_function_body "${proto}_can_transition" "$SRC_FILE")"
    if [ -z "$transition_body" ]; then
        skip_test "P1 proven-${proto} transition table" "exported function not found"
        continue
    fi

    # These are source-text checks scoped to the broker/protocol transition function.
    VALID_PATTERN="from == ${val_from} and to == ${val_to}"
    if grep -q "$VALID_PATTERN" <<<"$transition_body"; then
        pass "P1 proven-${proto}: selected valid edge ${val_from}→${val_to} appears in source"
    else
        fail_test "P1 proven-${proto}: selected valid edge ${val_from}→${val_to} not found"
    fi

    INVALID_PATTERN="from == ${inv_from} and to == ${inv_to}"
    if grep "$INVALID_PATTERN" <<<"$transition_body" | grep -q "return 1"; then
        fail_test "P1 proven-${proto}: selected invalid edge ${inv_from}→${inv_to} appears accepted"
    else
        pass "P1 proven-${proto}: selected invalid edge ${inv_from}→${inv_to} not accepted by source pattern"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P2 — Selected initial-transition source line.
# ─────────────────────────────────────────────────────────────────────────────
bold "P2 — Selected initial-transition source line"

declare -a P2_PROTOCOLS=(
    "amqp" "dns" "mqtt" "smtp" "ftp" "cache" "ca" "agentic"
    "bfd" "caldav" "coap" "ctlog" "dds" "doh"
)

for proto in "${P2_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P2 proven-${proto}: initial transition" "no src file"
        continue
    fi

    transition_body="$(exported_function_body "${proto}_can_transition" "$SRC_FILE")"
    if [ -z "$transition_body" ]; then
        skip_test "P2 proven-${proto} initial transition" "exported function not found"
    elif grep -qE "from == 0 and to == [1-9]" <<<"$transition_body"; then
        pass "P2 proven-${proto}: initial edge appears in transition-function source"
    elif grep -q 'canTransitionCheck(' <<<"$transition_body"; then
        helper_body="$(awk '/^fn canTransitionCheck[(]/ {capture=1} capture {print} capture && /^}/ {exit}' "$SRC_FILE")"
        if grep -qE 'from == 0 and to == [1-9]' <<<"$helper_body"; then
            pass "P2 proven-${proto}: initial edge appears in delegated transition-check source"
        else
            fail_test "P2 proven-${proto}: no initial edge found in delegated source"
        fi
    else
        skip_test "P2 proven-${proto} initial transition" "implementation is not a recognized literal transition table"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P3 — Count literal enum assignments in selected Zig source declarations.
# Expected counts are local test data, not generated from Idris proofs.
# ─────────────────────────────────────────────────────────────────────────────
bold "P3 — Selected Zig enum assignment counts (source heuristic)"

# Format: "proto_slug  enum_name  expected_tag_count"
declare -a P3_CASES=(
    "amqp  FrameType       4"
    "amqp  MethodClass     7"
    "amqp  ExchangeType    4"
    "amqp  DeliveryMode    2"
    "amqp  ConnectionState 5"
    "amqp  BrokerState     6"
    "dns   RecordType      15"
    "dns   QueryClass      4"
    "dns   Opcode          5"
    "dns   ResponseCode    11"
    "dns   DnsState        5"
    "mqtt  BrokerState     5"
    "mqtt  QoSDeliveryState 7"
)

for entry in "${P3_CASES[@]}"; do
    read -r proto enum_name expected_count <<<"$entry"
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"

    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P3 ${proto}::${enum_name}" "no src file"
        continue
    fi

    # Count assignment lines (field = N,) inside the enum block.
    actual_count=$(awk "
        /pub const ${enum_name}[[:space:]]*=/ { in_enum=1; depth=0 }
        in_enum && /\\{/ { depth++ }
        in_enum && /\\}/ { depth--; if (depth == 0) { in_enum=0 } }
        in_enum && depth > 0 && /=[[:space:]]*[0-9]/ { count++ }
        END { print count+0 }
    " "$SRC_FILE")

    if [[ "$actual_count" -eq "$expected_count" ]]; then
        pass "P3 ${proto}::${enum_name}: ${actual_count} tags (expected ${expected_count})"
    elif [[ "$actual_count" -eq 0 ]]; then
        skip_test "P3 ${proto}::${enum_name}" "awk returned 0 — struct layout may differ"
    else
        fail_test "P3 ${proto}::${enum_name}: got ${actual_count} tags, expected ${expected_count}"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P4 — Search the selected create function for a literal -1 return branch.
# ─────────────────────────────────────────────────────────────────────────────
bold "P4 — Slot exhaustion: create() returns -1 on pool full"

declare -a P4_PROTOCOLS=(
    "amqp" "dns" "mqtt" "cache" "ca" "smtp" "ftp" "bfd"
    "caldav" "coap" "ctlog" "agentic"
)

for proto in "${P4_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P4 proven-${proto} slot exhaustion" "no src file"
        continue
    fi

    create_body="$(exported_function_body "${proto}_create" "$SRC_FILE")"
    if [ -z "$create_body" ]; then
        skip_test "P4 proven-${proto} create() exhaustion" "exported function not found"
    elif grep -qE 'return (-1|@as\(c_int, -1\));' <<<"$create_body"; then
        pass "P4 proven-${proto}: create() contains a textual -1 return branch"
    else
        fail_test "P4 proven-${proto}: create() has no textual -1 return branch"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P5 — Look for a visible zero or positive return in ABI-version functions.
# ─────────────────────────────────────────────────────────────────────────────
bold "P5 — ABI-version return-expression source heuristic"

ABI_VERSION_ZERO_COUNT=0
ABI_VERSION_POSITIVE_COUNT=0

for src in protocols/proven-*/ffi/zig/src/*.zig; do
    [ -f "$src" ] || continue
    function_name="$(basename "$src" .zig)_abi_version"
    version_body="$(exported_function_body "$function_name" "$src")"
    [ -z "$version_body" ] && continue

    proto_name="$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$src")")")")")"
    if grep -Eq 'return[[:space:]]+0;' <<<"$version_body"; then
        fail_test "P5 ${proto_name}: abi_version visibly returns zero"
        ABI_VERSION_ZERO_COUNT=$((ABI_VERSION_ZERO_COUNT + 1))
    elif grep -Eq 'return[[:space:]]+([1-9][0-9]*|ABI_VERSION);' <<<"$version_body"; then
        ABI_VERSION_POSITIVE_COUNT=$((ABI_VERSION_POSITIVE_COUNT + 1))
    else
        skip_test "P5 ${proto_name} ABI version" "return expression is not recognized by this source heuristic"
    fi
done

if [ "$ABI_VERSION_POSITIVE_COUNT" -gt 0 ] && [ "$ABI_VERSION_ZERO_COUNT" -eq 0 ]; then
    pass "P5 ${ABI_VERSION_POSITIVE_COUNT} ABI-version functions have a recognized nonzero return expression"
elif [ "$ABI_VERSION_POSITIVE_COUNT" -eq 0 ]; then
    skip_test "P5 ABI version check" "no parseable abi_version functions found"
fi
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P6 — Check literal return lines inside selected transition functions.
# ─────────────────────────────────────────────────────────────────────────────
bold "P6 — Literal return lines in selected transition functions"

declare -a P6_PROTOCOLS=("amqp" "dns" "mqtt" "ca" "bfd" "smtp")

for proto in "${P6_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P6 proven-${proto} boolean predicate" "no src file"
        continue
    fi

    transition_body="$(exported_function_body "${proto}_can_transition" "$SRC_FILE")"
    if [ -z "$transition_body" ]; then
        skip_test "P6 proven-${proto} transition predicate" "exported function not found"
        continue
    fi
    bad_returns="$(grep -E 'return[[:space:]]' <<<"$transition_body" | grep -vE 'return[[:space:]]+(0|1);|return if .* 1 else 0;' || true)"

    if [ -z "$bad_returns" ]; then
        pass "P6 proven-${proto}: transition function has only literal 0/1 return lines"
    else
        fail_test "P6 proven-${proto}: transition function has unrecognized returns: $(echo "$bad_returns" | head -2)"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P7 — Presence of a rejecting fallback in selected transition functions.
# This textual check does not establish liveness, reachability, or quiescence.
# ─────────────────────────────────────────────────────────────────────────────
bold "P7 — Transition functions contain a rejecting fallback (source heuristic)"

declare -a P7_PROTOCOLS=("amqp" "dns" "mqtt" "smtp" "ca" "cache" "bfd")

for proto in "${P7_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P7 proven-${proto} rejecting fallback" "no src file"
        continue
    fi

    transition_body="$(exported_function_body "${proto}_can_transition" "$SRC_FILE")"
    if [ -z "$transition_body" ]; then
        skip_test "P7 proven-${proto} rejecting fallback" "exported function not found"
    elif grep -qE '^[[:space:]]*return 0;' <<<"$transition_body"; then
        pass "P7 proven-${proto}: transition function contains a rejecting fallback"
    elif grep -q 'canTransitionCheck(' <<<"$transition_body"; then
        helper_body="$(awk '/^fn canTransitionCheck[(]/ {capture=1} capture {print} capture && /^}/ {exit}' "$SRC_FILE")"
        if grep -qE '^[[:space:]]*return false;' <<<"$helper_body"; then
            pass "P7 proven-${proto}: delegated transition helper contains a false fallback"
        else
            fail_test "P7 proven-${proto}: delegated transition helper has no false fallback"
        fi
    else
        skip_test "P7 proven-${proto} rejecting fallback" "implementation is not a recognized literal transition table"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# P8 — A slot-validation helper pattern is present in selected source files.
# This does not prove every exported operation calls the helper correctly.
# ─────────────────────────────────────────────────────────────────────────────
bold "P8 — Slot-validation helper pattern is present (source heuristic)"

declare -a P8_PROTOCOLS=("amqp" "dns" "mqtt")

for proto in "${P8_PROTOCOLS[@]}"; do
    SRC_FILE="protocols/proven-${proto}/ffi/zig/src/${proto}.zig"
    if [ ! -f "$SRC_FILE" ]; then
        skip_test "P8 proven-${proto} slot guard" "no src file"
        continue
    fi

    if grep -qE 'fn validSlot|slot[[:space:]]*<[[:space:]]*0' "$SRC_FILE"; then
        pass "P8 proven-${proto}: slot-validator source pattern is present"
    else
        fail_test "P8 proven-${proto}: no slot-validator source pattern found"
    fi
done
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo "═══════════════════════════════════════════════════════════════"
printf "  Results: "
green "PASS=$PASS" | tr -d '\n'
echo -n "  "
if [ "$FAIL" -gt 0 ]; then red "FAIL=$FAIL" | tr -d '\n'; else echo -n "FAIL=0"; fi
echo -n "  "
if [ "$SKIP" -gt 0 ]; then yellow "SKIP=$SKIP"; else echo "SKIP=0"; fi
echo ""
echo "═══════════════════════════════════════════════════════════════"

exit "$FAIL"
