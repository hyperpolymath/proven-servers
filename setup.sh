#!/usr/bin/env sh
# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Non-mutating workspace status helper. This is deliberately not an installer:
# it never downloads or executes remote scripts, installs packages, changes
# firewall/SELinux state, writes reports, or deploys anything.

set -eu

if ! command -v just >/dev/null 2>&1; then
    printf '%s\n' \
      'ERROR: Just is required to display repository task information.' \
      'Install Just using your platform-approved package source, then run `just info`.' >&2
    exit 127
fi

if [ ! -f Justfile ]; then
    printf '%s\n' 'ERROR: run this helper from the proven-servers repository root.' >&2
    exit 2
fi

just info
printf '\n%s\n' \
  'This helper does not install Idris2 or Zig.' \
  'See QUICKSTART-DEV.adoc for package-scoped build and test instructions.'
