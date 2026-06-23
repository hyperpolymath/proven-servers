-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
||| Top-level module for proven-timestamp.
||| Re-exports the core API and provides service constants.
module Timestamp

import public Timestamp.Types
import public Timestamp.Receipt
import public Timestamp.Chain
import public Timestamp.Provider

%default total

||| Default HTTP port for the (future) web/API layer.
public export
defaultPort : Nat
defaultPort = 8080

||| Maximum content size accepted for hashing, in bytes (16 MiB).
||| Inputs are hashed and discarded; contents are never stored.
public export
maxContentBytes : Nat
maxContentBytes = 16777216

||| The service-wide default hash algorithm (SHA3-256, FIPS 202).
public export
defaultHashAlgo : HashAlgo
defaultHashAlgo = SHA3_256
