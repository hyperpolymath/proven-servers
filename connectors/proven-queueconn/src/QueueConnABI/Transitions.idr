-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- QueueConnABI.Transitions: Valid state transition proofs for queue connections.
--
-- State machine:
--
--   Disconnected --Connect--> Connected --StartConsume--> Consuming
--        ^                      |   |                       |   |
--        |                      |   +--StartProduce-->Producing |
--       Reset                   |   |                  |   |    |
--        |                      |   +--ConnDrop-->     |   |    |
--        |                      |                 |    |   |    |
--        +--- Failed <----------+-ConsumeFail-----+----+   |    |
--        |                      +--ProduceFail----+--------+    |
--        |                                                      |
--        +--- Connected <--- StopConsume -------- Consuming     |
--        +--- Connected <--- StopProduce -------- Producing ----+
--
-- Every arrow has exactly one ValidTransition constructor.

module QueueConnABI.Transitions

import QueueConn.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition
---------------------------------------------------------------------------

public export
data ValidTransition : QueueState -> QueueState -> Type where
  ||| Disconnected -> Connected (connection established).
  Connect      : ValidTransition Disconnected Connected
  ||| Disconnected -> Failed (connection attempt failed).
  ConnectFail  : ValidTransition Disconnected Failed
  ||| Connected -> Consuming (started consuming messages).
  StartConsume : ValidTransition Connected Consuming
  ||| Connected -> Producing (started producing messages).
  StartProduce : ValidTransition Connected Producing
  ||| Connected -> Disconnected (graceful disconnect).
  Disconnect   : ValidTransition Connected Disconnected
  ||| Connected -> Failed (connection dropped).
  ConnDrop     : ValidTransition Connected Failed
  ||| Consuming -> Connected (stopped consuming).
  StopConsume  : ValidTransition Consuming Connected
  ||| Consuming -> Failed (consumer failed).
  ConsumeFail  : ValidTransition Consuming Failed
  ||| Producing -> Connected (stopped producing).
  StopProduce  : ValidTransition Producing Connected
  ||| Producing -> Failed (producer failed).
  ProduceFail  : ValidTransition Producing Failed
  ||| Failed -> Disconnected (reset the failed connection).
  Reset        : ValidTransition Failed Disconnected

public export
Show (ValidTransition from to) where
  show Connect      = "Connect"
  show ConnectFail  = "ConnectFail"
  show StartConsume = "StartConsume"
  show StartProduce = "StartProduce"
  show Disconnect   = "Disconnect"
  show ConnDrop     = "ConnDrop"
  show StopConsume  = "StopConsume"
  show ConsumeFail  = "ConsumeFail"
  show StopProduce  = "StopProduce"
  show ProduceFail  = "ProduceFail"
  show Reset        = "Reset"

---------------------------------------------------------------------------
-- CanConsume: proof that message consumption is active.
---------------------------------------------------------------------------

public export
data CanConsume : QueueState -> Type where
  ||| Consuming messages is active in Consuming state.
  ConsumeActive : CanConsume Consuming

---------------------------------------------------------------------------
-- CanProduce: proof that message production is active.
---------------------------------------------------------------------------

public export
data CanProduce : QueueState -> Type where
  ||| Producing messages is active in Producing state.
  ProduceActive : CanProduce Producing

---------------------------------------------------------------------------
-- CanSubscribe: proof that a subscription can be started.
---------------------------------------------------------------------------

public export
data CanSubscribe : QueueState -> Type where
  ||| Subscriptions can only be started when Connected.
  SubscribeFromConnected : CanSubscribe Connected

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

public export
disconnectedCantConsume : CanConsume Disconnected -> Void
disconnectedCantConsume x impossible

public export
connectedCantConsume : CanConsume Connected -> Void
connectedCantConsume x impossible

public export
producingCantConsume : CanConsume Producing -> Void
producingCantConsume x impossible

public export
failedCantConsume : CanConsume Failed -> Void
failedCantConsume x impossible

public export
disconnectedCantProduce : CanProduce Disconnected -> Void
disconnectedCantProduce x impossible

public export
connectedCantProduce : CanProduce Connected -> Void
connectedCantProduce x impossible

public export
consumingCantProduce : CanProduce Consuming -> Void
consumingCantProduce x impossible

public export
failedCantProduce : CanProduce Failed -> Void
failedCantProduce x impossible

public export
disconnectedCantSubscribe : CanSubscribe Disconnected -> Void
disconnectedCantSubscribe x impossible

public export
consumingCantSubscribe : CanSubscribe Consuming -> Void
consumingCantSubscribe x impossible

public export
producingCantSubscribe : CanSubscribe Producing -> Void
producingCantSubscribe x impossible

public export
failedCantSubscribe : CanSubscribe Failed -> Void
failedCantSubscribe x impossible

---------------------------------------------------------------------------
-- Decidability
---------------------------------------------------------------------------

public export
canConsume : (s : QueueState) -> Dec (CanConsume s)
canConsume Disconnected = No disconnectedCantConsume
canConsume Connected    = No connectedCantConsume
canConsume Consuming    = Yes ConsumeActive
canConsume Producing    = No producingCantConsume
canConsume Failed       = No failedCantConsume

public export
canProduce : (s : QueueState) -> Dec (CanProduce s)
canProduce Disconnected = No disconnectedCantProduce
canProduce Connected    = No connectedCantProduce
canProduce Consuming    = No consumingCantProduce
canProduce Producing    = Yes ProduceActive
canProduce Failed       = No failedCantProduce

public export
canSubscribe : (s : QueueState) -> Dec (CanSubscribe s)
canSubscribe Disconnected = No disconnectedCantSubscribe
canSubscribe Connected    = Yes SubscribeFromConnected
canSubscribe Consuming    = No consumingCantSubscribe
canSubscribe Producing    = No producingCantSubscribe
canSubscribe Failed       = No failedCantSubscribe
