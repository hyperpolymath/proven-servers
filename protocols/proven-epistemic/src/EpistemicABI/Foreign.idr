-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- EpistemicABI.Foreign: opaque handle and the FFI contract that the Zig
-- engine (ffi/zig/src/epistemic.zig) provides.
--
-- The engine governs tiered disclosure between two parties: a pool of
-- sessions, each running the SessionPhase state machine, with the effective
-- tier computed as the lattice meet of the parties' grants and every
-- disclosure gated by `minTier <= effective tier`.  Enum values cross the C
-- ABI as Bits8 tags matching EpistemicABI.Types.

module EpistemicABI.Foreign

import EpistemicABI.Types

%default total

||| Opaque handle to a disclosure session.
export
data EpistemicContext : Type where [external]

||| ABI version -- must match epistemic_abi_version() in the Zig engine.
public export
abiVersion : Bits32
abiVersion = 1

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature / behaviour                   |
-- +-------------------------------+-----------------------------------------+
-- | epistemic_abi_version         | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | epistemic_meet                | (a:u8, b:u8) -> u8                       |
-- |                               | Lattice meet of two tier grants (the    |
-- |                               | effective tier); mirrors Lattice.meet.  |
-- | epistemic_well_governed       | (revealingness:u8, min_tier:u8) -> u8   |
-- |                               | 1 iff Sensitive implies Full (mirrors   |
-- |                               | Transitions.WellGoverned).              |
-- +-------------------------------+-----------------------------------------+
-- | epistemic_create              | () -> c_int (slot)  [Initiated]         |
-- | epistemic_destroy             | (slot:c_int) -> void                    |
-- | epistemic_phase               | (slot:c_int) -> u8 (SessionPhase tag)   |
-- | epistemic_effective_tier      | (slot:c_int) -> u8 (Tier tag)           |
-- +-------------------------------+-----------------------------------------+
-- | epistemic_agree_tiers         | (slot, granted:u8, theirs:u8) -> u8     |
-- |                               | Initiated -> TiersAgreed; stores the    |
-- |                               | effective tier = meet(granted,theirs).  |
-- |                               | 0 = ok, 1 = rejected.                   |
-- | epistemic_begin_disclosure    | (slot) -> u8  TiersAgreed -> Disclosing |
-- | epistemic_close               | (slot) -> u8  -> Closed                 |
-- | epistemic_can_transition      | (from:u8, to:u8) -> u8 (1/0)            |
-- +-------------------------------+-----------------------------------------+
-- | epistemic_disclose            | (slot, min_tier:u8, revealingness:u8)   |
-- |                               |  -> u8                                  |
-- |                               | Gated disclosure. 0 = disclosed; else   |
-- |                               | DisclosureError tag + 1 (1=TierExceeded,|
-- |                               | 3=NoActiveSession, 4=SessionClosed,     |
-- |                               | 5=IllGoverned). UnknownField (2) is a   |
-- |                               | lookup-layer concern, not raised here.  |
-- +-------------------------------+-----------------------------------------+

-- TODO(lookup): a field-governance registry (name -> FieldGovernance) would
-- sit above this engine and is where UnknownField (tag 1) is raised.
-- TODO(audit): append-only disclosure-event log (Purpose=Audit) for
-- accountability, analogous to proven-timestamp's hash chain.
