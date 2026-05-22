# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Media protocol types for proven-servers.

# frozen_string_literal: true

module ProvenServers
  # Media protocol types for proven-servers.
  module Media
    # MediaContentType matching the Idris2 ABI tags.
    module MediaContentType
      AUDIO = 0
      VIDEO = 1
      LIVE_STREAM = 2
      PLAYLIST = 3
      SUBTITLE = 4
    end

    # Codec matching the Idris2 ABI tags.
    module Codec
      H264 = 0
      H265 = 1
      AV1 = 2
      VP9 = 3
      AAC = 4
      OPUS = 5
      FLAC = 6
      MP3 = 7
    end

    # StreamProtocol matching the Idris2 ABI tags.
    module StreamProtocol
      HLS = 0
      DASH = 1
      RTMP = 2
      RTSP = 3
      WEB_RTC = 4
      SRT = 5
    end

    # TranscodeProfile matching the Idris2 ABI tags.
    module TranscodeProfile
      PASSTHROUGH = 0
      LOW = 1
      MEDIUM = 2
      HIGH = 3
      ULTRA = 4
    end

    # PlayerEvent matching the Idris2 ABI tags.
    module PlayerEvent
      PLAY = 0
      PAUSE = 1
      SEEK = 2
      STOP = 3
      BUFFER_START = 4
      BUFFER_END = 5
      ERROR = 6
      QUALITY_CHANGE = 7
    end

    # PlayerState matching the Idris2 ABI tags.
    module PlayerState
      IDLE = 0
      READY = 1
      PLAYING = 2
      PAUSED = 3
      STOPPING = 4
    end

  end
end
