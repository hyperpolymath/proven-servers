-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| C-ABI numeric encodings for the proven-epistemic enums, each with a total
||| encoder, partial decoder, and encode-then-decode round-trip proof.
||| Tag values MUST match the Zig engine (ffi/zig/src/epistemic.zig) exactly.
module EpistemicABI.Types

import Epistemic.Types

%default total

---------------------------------------------------------------------------
-- Tier (tags 0-2, ordered Band < Relational < Full)
---------------------------------------------------------------------------

public export
tierToTag : Tier -> Bits8
tierToTag Band       = 0
tierToTag Relational = 1
tierToTag Full       = 2

public export
tagToTier : Bits8 -> Maybe Tier
tagToTier 0 = Just Band
tagToTier 1 = Just Relational
tagToTier 2 = Just Full
tagToTier _ = Nothing

public export
tierRoundtrip : (t : Tier) -> tagToTier (tierToTag t) = Just t
tierRoundtrip Band       = Refl
tierRoundtrip Relational = Refl
tierRoundtrip Full       = Refl

---------------------------------------------------------------------------
-- Revealingness (tags 0-2)
---------------------------------------------------------------------------

public export
revealingnessToTag : Revealingness -> Bits8
revealingnessToTag Innocuous  = 0
revealingnessToTag Contextual = 1
revealingnessToTag Sensitive  = 2

public export
tagToRevealingness : Bits8 -> Maybe Revealingness
tagToRevealingness 0 = Just Innocuous
tagToRevealingness 1 = Just Contextual
tagToRevealingness 2 = Just Sensitive
tagToRevealingness _ = Nothing

public export
revealingnessRoundtrip : (r : Revealingness) -> tagToRevealingness (revealingnessToTag r) = Just r
revealingnessRoundtrip Innocuous  = Refl
revealingnessRoundtrip Contextual = Refl
revealingnessRoundtrip Sensitive  = Refl

---------------------------------------------------------------------------
-- Purpose (tags 0-4)
---------------------------------------------------------------------------

public export
purposeToTag : Purpose -> Bits8
purposeToTag Identification = 0
purposeToTag Eligibility    = 1
purposeToTag Compatibility  = 2
purposeToTag Contractual    = 3
purposeToTag Audit          = 4

public export
tagToPurpose : Bits8 -> Maybe Purpose
tagToPurpose 0 = Just Identification
tagToPurpose 1 = Just Eligibility
tagToPurpose 2 = Just Compatibility
tagToPurpose 3 = Just Contractual
tagToPurpose 4 = Just Audit
tagToPurpose _ = Nothing

public export
purposeRoundtrip : (p : Purpose) -> tagToPurpose (purposeToTag p) = Just p
purposeRoundtrip Identification = Refl
purposeRoundtrip Eligibility    = Refl
purposeRoundtrip Compatibility  = Refl
purposeRoundtrip Contractual    = Refl
purposeRoundtrip Audit          = Refl

---------------------------------------------------------------------------
-- SessionPhase (tags 0-3)
---------------------------------------------------------------------------

public export
phaseToTag : SessionPhase -> Bits8
phaseToTag Initiated   = 0
phaseToTag TiersAgreed = 1
phaseToTag Disclosing  = 2
phaseToTag Closed      = 3

public export
tagToPhase : Bits8 -> Maybe SessionPhase
tagToPhase 0 = Just Initiated
tagToPhase 1 = Just TiersAgreed
tagToPhase 2 = Just Disclosing
tagToPhase 3 = Just Closed
tagToPhase _ = Nothing

public export
phaseRoundtrip : (s : SessionPhase) -> tagToPhase (phaseToTag s) = Just s
phaseRoundtrip Initiated   = Refl
phaseRoundtrip TiersAgreed = Refl
phaseRoundtrip Disclosing  = Refl
phaseRoundtrip Closed      = Refl

---------------------------------------------------------------------------
-- DisclosureError (tags 0-4)
---------------------------------------------------------------------------

public export
errorToTag : DisclosureError -> Bits8
errorToTag TierExceeded         = 0
errorToTag UnknownField         = 1
errorToTag NoActiveSession      = 2
errorToTag SessionAlreadyClosed = 3
errorToTag IllGoverned          = 4

public export
tagToError : Bits8 -> Maybe DisclosureError
tagToError 0 = Just TierExceeded
tagToError 1 = Just UnknownField
tagToError 2 = Just NoActiveSession
tagToError 3 = Just SessionAlreadyClosed
tagToError 4 = Just IllGoverned
tagToError _ = Nothing

public export
errorRoundtrip : (e : DisclosureError) -> tagToError (errorToTag e) = Just e
errorRoundtrip TierExceeded         = Refl
errorRoundtrip UnknownField         = Refl
errorRoundtrip NoActiveSession      = Refl
errorRoundtrip SessionAlreadyClosed = Refl
errorRoundtrip IllGoverned          = Refl
