#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
#
# Disabled: the experimental Fly.io deployment script is not a validated or
# authorized production release path. It previously orchestrated multiple
# external apps/services and could incur charges or modify live resources.
# This guard intentionally runs before checking for or invoking flyctl.

set -euo pipefail
printf '%s\n' \
  'ERROR: Fly.io deployment is disabled for proven-nesy-solver-api.' \
  'The Zig image and upstream integrations are not verified or release-ready.' \
  'No cloud commands were run. See this connector README and root READINESS.adoc.' >&2
exit 2
