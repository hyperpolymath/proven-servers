# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Metrics protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Metrics protocol types for proven-servers.
  module Metrics
    # MetricType matching the Idris2 ABI tags.
    module MetricType
      COUNTER = 0
      GAUGE = 1
      HISTOGRAM = 2
      SUMMARY = 3
      INFO = 4
      STATE_SET = 5
    end

    # ScrapeResult matching the Idris2 ABI tags.
    module ScrapeResult
      SUCCESS = 0
      SCRAPE_TIMEOUT = 1
      CONNECTION_REFUSED = 2
      INVALID_RESPONSE = 3
    end

    # AlertState matching the Idris2 ABI tags.
    module AlertState
      INACTIVE = 0
      PENDING = 1
      FIRING = 2
      RESOLVED = 3
    end

    # AggregationOp matching the Idris2 ABI tags.
    module AggregationOp
      SUM = 0
      AVG = 1
      MIN = 2
      MAX = 3
      COUNT = 4
      RATE = 5
      INCREASE = 6
      P50 = 7
      P90 = 8
      P95 = 9
      P99 = 10
    end

    # QueryError matching the Idris2 ABI tags.
    module QueryError
      PARSE_ERROR = 0
      EXECUTION_ERROR = 1
      QUERY_TIMEOUT = 2
      TOO_MANY_SERIES = 3
    end

    # CollectorState matching the Idris2 ABI tags.
    module CollectorState
      IDLE = 0
      CONFIGURED = 1
      SCRAPING = 2
      ALERTING = 3
      STOPPING = 4
    end

  end
end
