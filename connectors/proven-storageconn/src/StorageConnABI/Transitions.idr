-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- StorageConnABI.Transitions: Valid state transition proofs for storage connections.
--
-- State machine:
--
--   Disconnected --Connect--> Connected --StartUpload--> Uploading
--        ^                      |   |                       |   |
--        |                      |   +--StartDownload-->Downloading|
--       Reset                   |   |                  |   |    |
--        |                      |   +--ConnDrop-->     |   |    |
--        |                      |                 |    |   |    |
--        +--- Failed <----------+-UploadFail------+----+   |    |
--        |                      +--DownloadFail---+--------+    |
--        |                                                      |
--        +--- Connected <--- UploadComplete ---- Uploading      |
--        +--- Connected <--- DownloadComplete -- Downloading ---+

module StorageConnABI.Transitions

import StorageConn.Types

%default total

---------------------------------------------------------------------------
-- ValidTransition
---------------------------------------------------------------------------

public export
data ValidTransition : StorageState -> StorageState -> Type where
  ||| Disconnected -> Connected (connection established).
  Connect          : ValidTransition Disconnected Connected
  ||| Disconnected -> Failed (connection attempt failed).
  ConnectFail      : ValidTransition Disconnected Failed
  ||| Connected -> Uploading (started multipart/streaming upload).
  StartUpload      : ValidTransition Connected Uploading
  ||| Connected -> Downloading (started streaming download).
  StartDownload    : ValidTransition Connected Downloading
  ||| Connected -> Disconnected (graceful disconnect).
  Disconnect       : ValidTransition Connected Disconnected
  ||| Connected -> Failed (connection dropped).
  ConnDrop         : ValidTransition Connected Failed
  ||| Uploading -> Connected (upload completed).
  UploadComplete   : ValidTransition Uploading Connected
  ||| Uploading -> Failed (upload failed).
  UploadFail       : ValidTransition Uploading Failed
  ||| Downloading -> Connected (download completed).
  DownloadComplete : ValidTransition Downloading Connected
  ||| Downloading -> Failed (download failed).
  DownloadFail     : ValidTransition Downloading Failed
  ||| Failed -> Disconnected (reset the failed connection).
  Reset            : ValidTransition Failed Disconnected

public export
Show (ValidTransition from to) where
  show Connect          = "Connect"
  show ConnectFail      = "ConnectFail"
  show StartUpload      = "StartUpload"
  show StartDownload    = "StartDownload"
  show Disconnect       = "Disconnect"
  show ConnDrop         = "ConnDrop"
  show UploadComplete   = "UploadComplete"
  show UploadFail       = "UploadFail"
  show DownloadComplete = "DownloadComplete"
  show DownloadFail     = "DownloadFail"
  show Reset            = "Reset"

---------------------------------------------------------------------------
-- CanOperate: proof that storage operations are permitted.
---------------------------------------------------------------------------

||| Proof that storage operations can be initiated.
||| Only Connected permits new operations — Uploading and Downloading
||| are already doing I/O and cannot start a new operation.
public export
data CanOperate : StorageState -> Type where
  ||| Operations can be initiated when Connected.
  OperateConnected : CanOperate Connected

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

public export
disconnectedCantOperate : CanOperate Disconnected -> Void
disconnectedCantOperate x impossible

public export
uploadingCantOperate : CanOperate Uploading -> Void
uploadingCantOperate x impossible

public export
downloadingCantOperate : CanOperate Downloading -> Void
downloadingCantOperate x impossible

public export
failedCantOperate : CanOperate Failed -> Void
failedCantOperate x impossible

---------------------------------------------------------------------------
-- Decidability
---------------------------------------------------------------------------

public export
canOperate : (s : StorageState) -> Dec (CanOperate s)
canOperate Disconnected = No disconnectedCantOperate
canOperate Connected    = Yes OperateConnected
canOperate Uploading    = No uploadingCantOperate
canOperate Downloading  = No downloadingCantOperate
canOperate Failed       = No failedCantOperate
