-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| The append-only hash chain — the proven core of proven-timestamp.
|||
||| `ValidChain` is an inductive proof that a list of receipts is correctly
||| hash-linked.  It is *impossible* to construct a `ValidChain` for a list
||| whose links do not match, so a value of this type is a machine-checked
||| certificate of chain integrity.  Mutating any receipt changes its
||| `receiptHash`, which breaks the equality the next receipt depends on —
||| that is the tamper-evidence guarantee, witnessed by `brokenLinkRejected`.
module Timestamp.Chain

import Timestamp.Types
import Timestamp.Receipt
import Data.List
import Decidable.Equality

%default total

---------------------------------------------------------------------------
-- Linkage relation
---------------------------------------------------------------------------

||| `LinksTo prev cur` holds when `cur` chains directly onto `prev`:
||| cur's previous-pointer equals prev's receipt hash.
public export
LinksTo : (prev : Receipt) -> (cur : Receipt) -> Type
LinksTo prev cur = cur.previousReceiptHash = prev.receiptHash

||| `LinksGenesis r` holds when `r` is a valid first (oldest) receipt:
||| its previous-pointer is the genesis value.  (Defined as an alias so the
||| global `genesisHash` is not implicitly re-bound inside type signatures.)
public export
LinksGenesis : (r : Receipt) -> Type
LinksGenesis r = r.previousReceiptHash = genesisHash

---------------------------------------------------------------------------
-- The chain
---------------------------------------------------------------------------

||| A well-formed, append-only hash chain.  The list head is the most
||| recent receipt (reverse-chronological order).  By construction:
|||
|||   * the oldest receipt links to `genesisHash`; and
|||   * every newer receipt links to its immediate predecessor.
public export
data ValidChain : List Receipt -> Type where
  ||| A single genesis receipt that points at `genesisHash`.
  GenesisChain : (r : Receipt) ->
                 (genesis : LinksGenesis r) ->
                 ValidChain [r]
  ||| Prepend a newer receipt `r` that links to the current head `h`.
  ExtendChain  : (r : Receipt) ->
                 (rest : ValidChain (h :: t)) ->
                 (link : LinksTo h r) ->
                 ValidChain (r :: h :: t)

---------------------------------------------------------------------------
-- Smart constructors / eliminators
---------------------------------------------------------------------------

||| Extend a valid chain with a new most-recent receipt, given a proof that
||| it links to the current head.  The older portion is reused unchanged —
||| this is the append-only property made concrete: history is never
||| rewritten, only grown.
public export
extendChain : (r : Receipt) -> ValidChain (h :: t) -> LinksTo h r ->
              ValidChain (r :: h :: t)
extendChain = ExtendChain

||| Drop the newest receipt, recovering the (still valid) prior chain.
||| The tail is returned untouched, so older receipts are immutable.
public export
priorChain : ValidChain (r :: h :: t) -> ValidChain (h :: t)
priorChain (ExtendChain _ rest _) = rest

||| Recover the link proof between the two newest receipts.
public export
linkProof : ValidChain (r :: h :: t) -> LinksTo h r
linkProof (ExtendChain _ _ link) = link

---------------------------------------------------------------------------
-- Validator: build the certificate from raw data, or reject it
---------------------------------------------------------------------------

||| Decide whether a raw receipt list is a valid hash chain, returning the
||| machine-checked proof on success.  This is what a verifier runs over a
||| downloaded append-only log.
public export
validateChain : (rs : List Receipt) -> Maybe (ValidChain rs)
validateChain [] = Nothing
validateChain [r] with (decEq r.previousReceiptHash genesisHash)
  validateChain [r] | Yes prf = Just (GenesisChain r prf)
  validateChain [r] | No  _   = Nothing
validateChain (r :: h :: t) with (validateChain (h :: t))
  validateChain (r :: h :: t) | Nothing     = Nothing
  validateChain (r :: h :: t) | Just rest with (decEq r.previousReceiptHash h.receiptHash)
    validateChain (r :: h :: t) | Just rest | Yes prf = Just (ExtendChain r rest prf)
    validateChain (r :: h :: t) | Just rest | No  _   = Nothing

---------------------------------------------------------------------------
-- Tamper-evidence (impossibility proofs)
---------------------------------------------------------------------------

||| A lone receipt whose previous-pointer is not the genesis value cannot
||| form a valid chain.
public export
nonGenesisRejected : Not (LinksGenesis r) -> Not (ValidChain [r])
nonGenesisRejected contra (GenesisChain _ prf) = contra prf

||| If a receipt's previous-pointer does not equal its predecessor's
||| receipt hash, the two cannot sit adjacently in a valid chain.  Because
||| `receiptHash` is the digest of the receipt's own fields, editing any
||| stored receipt makes this equality fail — the chain refuses to validate.
public export
brokenLinkRejected : Not (LinksTo h r) -> Not (ValidChain (r :: h :: t))
brokenLinkRejected contra (ExtendChain _ _ link) = contra link
