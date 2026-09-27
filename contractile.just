# SPDX-License-Identifier: MPL-2.0
# Repository-specific, non-destructive contractile task wrappers.
# The generated template helpers formerly checked nonexistent files and exposed
# a `git checkout HEAD -- .` rollback. They have been replaced with bounded
# checks that do not discard working-tree changes.

must-check: validate
    bash tools/check-binding-policy.sh
    test -f SECURITY.adoc
    test -f .well-known/security.txt

# Source-pattern security checks only; not cryptographic/integrity verification.
trust-smoke:
    bash tests/aspect/security_test.sh
    bash tools/check-binding-policy.sh

# Show current worktree state; no automatic rollback is provided.
dust-status:
    @git status --short

# Display the declared near-term work assembly for human review.
intend-list:
    @cat .machine_readable/contractiles/Intentfile.a2ml
