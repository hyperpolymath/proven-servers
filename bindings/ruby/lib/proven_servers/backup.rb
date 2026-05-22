# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Backup protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Backup protocol types for proven-servers.
  module Backup
    # BackupType matching the Idris2 ABI tags.
    module BackupType
      FULL = 0
      INCREMENTAL = 1
      DIFFERENTIAL = 2
      SNAPSHOT = 3
      MIRROR = 4
    end

    # ScheduleFreq matching the Idris2 ABI tags.
    module ScheduleFreq
      HOURLY = 0
      DAILY = 1
      WEEKLY = 2
      MONTHLY = 3
      ON_DEMAND = 4
    end

    # CompressionAlg matching the Idris2 ABI tags.
    module CompressionAlg
      NONE = 0
      GZIP = 1
      ZSTD = 2
      LZ4 = 3
      XZ = 4
    end

    # EncryptionAlg matching the Idris2 ABI tags.
    module EncryptionAlg
      NO_ENCRYPTION = 0
      AES256_GCM = 1
      CHA_CHA20_POLY1305 = 2
    end

    # BackupState matching the Idris2 ABI tags.
    module BackupState
      IDLE = 0
      RUNNING = 1
      VERIFYING = 2
      COMPLETE = 3
      FAILED = 4
      CANCELLED = 5
    end

    # RetentionPolicy matching the Idris2 ABI tags.
    module RetentionPolicy
      KEEP_ALL = 0
      KEEP_LAST = 1
      KEEP_DAILY = 2
      KEEP_WEEKLY = 3
      KEEP_MONTHLY = 4
    end

  end
end
