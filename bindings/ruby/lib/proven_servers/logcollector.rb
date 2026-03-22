# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Log Collector protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Log Collector protocol types for proven-servers.
  module Logcollector
    # LogLevel matching the Idris2 ABI tags.
    module LogLevel
      TRACE = 0
      DEBUG = 1
      INFO = 2
      WARN = 3
      ERR = 4
      FATAL = 5
    end

    # InputFormat matching the Idris2 ABI tags.
    module InputFormat
      JSON = 0
      LOGFMT = 1
      SYSLOG = 2
      CEF = 3
      GELF = 4
      RAW = 5
    end

    # OutputTarget matching the Idris2 ABI tags.
    module OutputTarget
      FILE = 0
      ELASTICSEARCH = 1
      S3 = 2
      KAFKA = 3
      STDOUT = 4
    end

    # FilterOp matching the Idris2 ABI tags.
    module FilterOp
      INCLUDE = 0
      EXCLUDE = 1
      TRANSFORM = 2
      REDACT = 3
      SAMPLE = 4
    end

    # PipelineStage matching the Idris2 ABI tags.
    module PipelineStage
      INPUT = 0
      PARSE = 1
      FILTER = 2
      PIPELINE_TRANSFORM = 3
      OUTPUT = 4
    end

  end
end
