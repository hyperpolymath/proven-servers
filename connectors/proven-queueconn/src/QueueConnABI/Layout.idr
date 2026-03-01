-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- QueueConnABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the five core sum types (QueueOp, DeliveryGuarantee,
-- QueueState, MessageState, QueueError) to a fixed Bits8 value for C interop.
--
-- Tag values here MUST match the C header (generated/abi/queueconn.h) and the
-- Zig FFI enums (ffi/zig/src/queueconn.zig) exactly.

module QueueConnABI.Layout

import QueueConn.Types

%default total

---------------------------------------------------------------------------
-- QueueOp (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
queueOpSize : Nat
queueOpSize = 1

public export
queueOpToTag : QueueOp -> Bits8
queueOpToTag Publish     = 0
queueOpToTag Subscribe   = 1
queueOpToTag Acknowledge = 2
queueOpToTag Reject      = 3
queueOpToTag Peek        = 4
queueOpToTag Purge       = 5

public export
tagToQueueOp : Bits8 -> Maybe QueueOp
tagToQueueOp 0 = Just Publish
tagToQueueOp 1 = Just Subscribe
tagToQueueOp 2 = Just Acknowledge
tagToQueueOp 3 = Just Reject
tagToQueueOp 4 = Just Peek
tagToQueueOp 5 = Just Purge
tagToQueueOp _ = Nothing

public export
queueOpRoundtrip : (op : QueueOp) -> tagToQueueOp (queueOpToTag op) = Just op
queueOpRoundtrip Publish     = Refl
queueOpRoundtrip Subscribe   = Refl
queueOpRoundtrip Acknowledge = Refl
queueOpRoundtrip Reject      = Refl
queueOpRoundtrip Peek        = Refl
queueOpRoundtrip Purge       = Refl

---------------------------------------------------------------------------
-- DeliveryGuarantee (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
deliveryGuaranteeSize : Nat
deliveryGuaranteeSize = 1

public export
deliveryGuaranteeToTag : DeliveryGuarantee -> Bits8
deliveryGuaranteeToTag AtMostOnce  = 0
deliveryGuaranteeToTag AtLeastOnce = 1
deliveryGuaranteeToTag ExactlyOnce = 2

public export
tagToDeliveryGuarantee : Bits8 -> Maybe DeliveryGuarantee
tagToDeliveryGuarantee 0 = Just AtMostOnce
tagToDeliveryGuarantee 1 = Just AtLeastOnce
tagToDeliveryGuarantee 2 = Just ExactlyOnce
tagToDeliveryGuarantee _ = Nothing

public export
deliveryGuaranteeRoundtrip : (dg : DeliveryGuarantee) -> tagToDeliveryGuarantee (deliveryGuaranteeToTag dg) = Just dg
deliveryGuaranteeRoundtrip AtMostOnce  = Refl
deliveryGuaranteeRoundtrip AtLeastOnce = Refl
deliveryGuaranteeRoundtrip ExactlyOnce = Refl

---------------------------------------------------------------------------
-- QueueState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
queueStateSize : Nat
queueStateSize = 1

public export
queueStateToTag : QueueState -> Bits8
queueStateToTag Disconnected = 0
queueStateToTag Connected    = 1
queueStateToTag Consuming    = 2
queueStateToTag Producing    = 3
queueStateToTag Failed       = 4

public export
tagToQueueState : Bits8 -> Maybe QueueState
tagToQueueState 0 = Just Disconnected
tagToQueueState 1 = Just Connected
tagToQueueState 2 = Just Consuming
tagToQueueState 3 = Just Producing
tagToQueueState 4 = Just Failed
tagToQueueState _ = Nothing

public export
queueStateRoundtrip : (s : QueueState) -> tagToQueueState (queueStateToTag s) = Just s
queueStateRoundtrip Disconnected = Refl
queueStateRoundtrip Connected    = Refl
queueStateRoundtrip Consuming    = Refl
queueStateRoundtrip Producing    = Refl
queueStateRoundtrip Failed       = Refl

---------------------------------------------------------------------------
-- MessageState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
messageStateSize : Nat
messageStateSize = 1

public export
messageStateToTag : MessageState -> Bits8
messageStateToTag Pending      = 0
messageStateToTag Delivered    = 1
messageStateToTag Acknowledged = 2
messageStateToTag Rejected     = 3
messageStateToTag DeadLettered = 4
messageStateToTag Expired      = 5

public export
tagToMessageState : Bits8 -> Maybe MessageState
tagToMessageState 0 = Just Pending
tagToMessageState 1 = Just Delivered
tagToMessageState 2 = Just Acknowledged
tagToMessageState 3 = Just Rejected
tagToMessageState 4 = Just DeadLettered
tagToMessageState 5 = Just Expired
tagToMessageState _ = Nothing

public export
messageStateRoundtrip : (ms : MessageState) -> tagToMessageState (messageStateToTag ms) = Just ms
messageStateRoundtrip Pending      = Refl
messageStateRoundtrip Delivered    = Refl
messageStateRoundtrip Acknowledged = Refl
messageStateRoundtrip Rejected     = Refl
messageStateRoundtrip DeadLettered = Refl
messageStateRoundtrip Expired      = Refl

---------------------------------------------------------------------------
-- QueueError (7 constructors, tags 1-7; 0 = no error)
---------------------------------------------------------------------------

public export
queueErrorSize : Nat
queueErrorSize = 1

public export
queueErrorToTag : QueueError -> Bits8
queueErrorToTag ConnectionLost     = 1
queueErrorToTag QueueNotFound      = 2
queueErrorToTag MessageTooLarge    = 3
queueErrorToTag QuotaExceeded      = 4
queueErrorToTag AckTimeout         = 5
queueErrorToTag Unauthorized       = 6
queueErrorToTag SerializationError = 7

public export
tagToQueueError : Bits8 -> Maybe QueueError
tagToQueueError 1 = Just ConnectionLost
tagToQueueError 2 = Just QueueNotFound
tagToQueueError 3 = Just MessageTooLarge
tagToQueueError 4 = Just QuotaExceeded
tagToQueueError 5 = Just AckTimeout
tagToQueueError 6 = Just Unauthorized
tagToQueueError 7 = Just SerializationError
tagToQueueError _ = Nothing

public export
queueErrorRoundtrip : (e : QueueError) -> tagToQueueError (queueErrorToTag e) = Just e
queueErrorRoundtrip ConnectionLost     = Refl
queueErrorRoundtrip QueueNotFound      = Refl
queueErrorRoundtrip MessageTooLarge    = Refl
queueErrorRoundtrip QuotaExceeded      = Refl
queueErrorRoundtrip AckTimeout         = Refl
queueErrorRoundtrip Unauthorized       = Refl
queueErrorRoundtrip SerializationError = Refl
