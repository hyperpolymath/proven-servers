# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# MCP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # MCP protocol types for proven-servers.
  module Mcp
    # McpMessageType matching the Idris2 ABI tags.
    module McpMessageType
      INITIALIZE = 0
      INITIALIZED = 1
      PING = 2
      CALL_TOOL = 3
      TOOL_RESULT = 4
      LIST_TOOLS = 5
      LIST_RESOURCES = 6
      READ_RESOURCE = 7
      LIST_PROMPTS = 8
      GET_PROMPT = 9
      SUBSCRIBE = 10
      UNSUBSCRIBE = 11
      NOTIFICATION = 12
      CANCEL = 13
    end

    # Transport matching the Idris2 ABI tags.
    module Transport
      STDIO = 0
      SSE = 1
      WEB_SOCKET = 2
      STREAMABLE_HTTP = 3
    end

    # McpContentType matching the Idris2 ABI tags.
    module McpContentType
      TEXT = 0
      IMAGE = 1
      RESOURCE = 2
      EMBEDDING = 3
    end

    # McpErrorCode matching the Idris2 ABI tags.
    module McpErrorCode
      PARSE_ERROR = 0
      INVALID_REQUEST = 1
      METHOD_NOT_FOUND = 2
      INVALID_PARAMS = 3
      INTERNAL_ERROR = 4
      TIMEOUT = 5
    end

    # McpCapability matching the Idris2 ABI tags.
    module McpCapability
      TOOLS = 0
      RESOURCES = 1
      PROMPTS = 2
      LOGGING = 3
      SAMPLING = 4
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      IDLE = 0
      CONNECTING = 1
      READY = 2
      PROCESSING = 3
      DISCONNECTING = 4
    end

  end
end
