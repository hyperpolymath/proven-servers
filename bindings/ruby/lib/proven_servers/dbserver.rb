# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Database protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Database protocol types for proven-servers.
  module Dbserver
    # QueryType matching the Idris2 ABI tags.
    module QueryType
      SELECT = 0
      INSERT = 1
      UPDATE = 2
      DELETE = 3
      CREATE_TABLE = 4
      DROP_TABLE = 5
      ALTER_TABLE = 6
      CREATE_INDEX = 7
      DROP_INDEX = 8
      BEGIN = 9
      COMMIT = 10
      ROLLBACK = 11
    end

    # DataType matching the Idris2 ABI tags.
    module DataType
      INTEGER = 0
      FLOAT = 1
      TEXT = 2
      BLOB = 3
      BOOLEAN = 4
      TIMESTAMP = 5
      UUID = 6
      JSON = 7
      NULL = 8
    end

    # IsolationLevel matching the Idris2 ABI tags.
    module IsolationLevel
      READ_UNCOMMITTED = 0
      READ_COMMITTED = 1
      REPEATABLE_READ = 2
      SERIALIZABLE = 3
    end

    # ErrorCode matching the Idris2 ABI tags.
    module ErrorCode
      SYNTAX_ERROR = 0
      TABLE_NOT_FOUND = 1
      COLUMN_NOT_FOUND = 2
      DUPLICATE_KEY = 3
      CONSTRAINT_VIOLATION = 4
      TYPE_MISMATCH = 5
      DEADLOCK_DETECTED = 6
      TRANSACTION_ABORTED = 7
      DISK_FULL = 8
      CONNECTION_LOST = 9
    end

    # JoinType matching the Idris2 ABI tags.
    module JoinType
      INNER = 0
      LEFT_OUTER = 1
      RIGHT_OUTER = 2
      FULL_OUTER = 3
      CROSS = 4
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      CONNECTED = 1
      TRANSACTION = 2
      EXECUTING = 3
      FINALISING = 4
      DISCONNECTING = 5
    end

  end
end
