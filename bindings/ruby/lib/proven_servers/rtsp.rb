# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# RTSP protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # RTSP protocol types for proven-servers.
  module Rtsp
    # Method matching the Idris2 ABI tags.
    module Method
      DESCRIBE = 0
      SETUP = 1
      PLAY = 2
      PAUSE = 3
      TEARDOWN = 4
      GET_PARAMETER = 5
      SET_PARAMETER = 6
      OPTIONS = 7
      ANNOUNCE = 8
      RECORD = 9
      REDIRECT = 10
    end

    # TransportProtocol matching the Idris2 ABI tags.
    module TransportProtocol
      RTP_AVP_UDP = 0
      RTP_AVP_TCP = 1
      RTP_AVP_UDP_MULTICAST = 2
    end

    # SessionState matching the Idris2 ABI tags.
    module SessionState
      INIT = 0
      READY = 1
      PLAYING = 2
      RECORDING = 3
    end

    # StatusCode matching the Idris2 ABI tags.
    module StatusCode
      STATUS_CODE_OK = 0
      MOVED_PERMANENTLY = 1
      MOVED_TEMPORARILY = 2
      BAD_REQUEST = 3
      UNAUTHORIZED = 4
      NOT_FOUND = 5
      STATUS_CODE_METHOD_NOT_ALLOWED = 6
      NOT_ACCEPTABLE = 7
      SESSION_NOT_FOUND = 8
      INTERNAL_SERVER_ERROR = 9
      NOT_IMPLEMENTED = 10
      SERVICE_UNAVAILABLE = 11
    end

    # RtspError matching the Idris2 ABI tags.
    module RtspError
      RTSP_ERROR_OK = 0
      INVALID_SLOT = 1
      NOT_ACTIVE = 2
      INVALID_TRANSITION = 3
      RTSP_ERROR_METHOD_NOT_ALLOWED = 4
      TRANSPORT_ERROR = 5
      SESSION_EXPIRED = 6
    end

  end
end
