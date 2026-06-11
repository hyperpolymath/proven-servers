# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Media do
  @moduledoc """
  Media Server types for the proven-servers ABI.
  
  Formally verified media streaming types.
  Mirrors the Idris2 module `MediaABI.Types`.
  
  - `MediaContentType` -- Media content types.
  - `Codec` -- Media codecs.
  - `StreamProtocol` -- Media streaming protocols.
  - `TranscodeProfile` -- Transcoding quality profiles.
  - `PlayerEvent` -- Media player events.
  - `PlayerState` -- Media player states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # MediaContentType (tags 0-4)
  # ===========================================================================

  @typedoc """
  MediaContentType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type media_content_type :: :audio | :video | :live_stream | :playlist | :subtitle

  @media_content_type_tags %{
    audio: 0,
    video: 1,
    live_stream: 2,
    playlist: 3,
    subtitle: 4,
  }

  @tag_to_media_content_type Map.new(@media_content_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MediaContentType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Media.media_content_type_from_tag(0)
      {:ok, :audio}
  """
  @spec media_content_type_from_tag(non_neg_integer()) :: {:ok, media_content_type()} | :error
  def media_content_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_media_content_type, tag)}
  end

  def media_content_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MediaContentType` to the C-ABI tag value.
  """
  @spec media_content_type_to_tag(media_content_type()) :: non_neg_integer()
  def media_content_type_to_tag(val) when is_map_key(@media_content_type_tags, val) do
    Map.fetch!(@media_content_type_tags, val)
  end

  @doc """
  All `MediaContentType` variants in tag order.
  """
  @spec all_media_content_types() :: [media_content_type()]
  def all_media_content_types, do: [:audio, :video, :live_stream, :playlist, :subtitle]

  # ===========================================================================
  # Codec (tags 0-7)
  # ===========================================================================

  @typedoc """
  Codec types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type codec :: :h264 | :h265 | :av1 | :vp9 | :aac | :opus | :flac | :mp3

  @codec_tags %{
    h264: 0,
    h265: 1,
    av1: 2,
    vp9: 3,
    aac: 4,
    opus: 5,
    flac: 6,
    mp3: 7,
  }

  @tag_to_codec Map.new(@codec_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Codec` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Media.codec_from_tag(0)
      {:ok, :h264}
  """
  @spec codec_from_tag(non_neg_integer()) :: {:ok, codec()} | :error
  def codec_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_codec, tag)}
  end

  def codec_from_tag(_tag), do: :error

  @doc """
  Encode a `Codec` to the C-ABI tag value.
  """
  @spec codec_to_tag(codec()) :: non_neg_integer()
  def codec_to_tag(val) when is_map_key(@codec_tags, val) do
    Map.fetch!(@codec_tags, val)
  end

  @doc """
  All `Codec` variants in tag order.
  """
  @spec all_codecs() :: [codec()]
  def all_codecs, do: [:h264, :h265, :av1, :vp9, :aac, :opus, :flac, :mp3]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a video codec.
  """
  @spec is_video?(codec()) :: boolean()
  def is_video?(val) when val in [:h264, :h265, :av1, :vp9], do: true
  def is_video?(_val), do: false

  @doc """
  Whether this is an audio codec.
  """
  @spec is_audio?(codec()) :: boolean()
  def is_audio?(val) when val in [:aac, :opus, :flac, :mp3], do: true
  def is_audio?(_val), do: false

  # ===========================================================================
  # StreamProtocol (tags 0-5)
  # ===========================================================================

  @typedoc """
  StreamProtocol types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type stream_protocol :: :hls | :dash | :rtmp | :rtsp | :web_rtc | :srt

  @stream_protocol_tags %{
    hls: 0,
    dash: 1,
    rtmp: 2,
    rtsp: 3,
    web_rtc: 4,
    srt: 5,
  }

  @tag_to_stream_protocol Map.new(@stream_protocol_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StreamProtocol` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Media.stream_protocol_from_tag(0)
      {:ok, :hls}
  """
  @spec stream_protocol_from_tag(non_neg_integer()) :: {:ok, stream_protocol()} | :error
  def stream_protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_stream_protocol, tag)}
  end

  def stream_protocol_from_tag(_tag), do: :error

  @doc """
  Encode a `StreamProtocol` to the C-ABI tag value.
  """
  @spec stream_protocol_to_tag(stream_protocol()) :: non_neg_integer()
  def stream_protocol_to_tag(val) when is_map_key(@stream_protocol_tags, val) do
    Map.fetch!(@stream_protocol_tags, val)
  end

  @doc """
  All `StreamProtocol` variants in tag order.
  """
  @spec all_stream_protocols() :: [stream_protocol()]
  def all_stream_protocols, do: [:hls, :dash, :rtmp, :rtsp, :web_rtc, :srt]

  # ===========================================================================
  # TranscodeProfile (tags 0-4)
  # ===========================================================================

  @typedoc """
  TranscodeProfile types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transcode_profile :: :passthrough | :low | :medium | :high | :ultra

  @transcode_profile_tags %{
    passthrough: 0,
    low: 1,
    medium: 2,
    high: 3,
    ultra: 4,
  }

  @tag_to_transcode_profile Map.new(@transcode_profile_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TranscodeProfile` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Media.transcode_profile_from_tag(0)
      {:ok, :passthrough}
  """
  @spec transcode_profile_from_tag(non_neg_integer()) :: {:ok, transcode_profile()} | :error
  def transcode_profile_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_transcode_profile, tag)}
  end

  def transcode_profile_from_tag(_tag), do: :error

  @doc """
  Encode a `TranscodeProfile` to the C-ABI tag value.
  """
  @spec transcode_profile_to_tag(transcode_profile()) :: non_neg_integer()
  def transcode_profile_to_tag(val) when is_map_key(@transcode_profile_tags, val) do
    Map.fetch!(@transcode_profile_tags, val)
  end

  @doc """
  All `TranscodeProfile` variants in tag order.
  """
  @spec all_transcode_profiles() :: [transcode_profile()]
  def all_transcode_profiles, do: [:passthrough, :low, :medium, :high, :ultra]

  # ===========================================================================
  # PlayerEvent (tags 0-7)
  # ===========================================================================

  @typedoc """
  PlayerEvent types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type player_event ::
          :play
          | :pause
          | :seek
          | :stop
          | :buffer_start
          | :buffer_end
          | :error
          | :quality_change

  @player_event_tags %{
    play: 0,
    pause: 1,
    seek: 2,
    stop: 3,
    buffer_start: 4,
    buffer_end: 5,
    error: 6,
    quality_change: 7,
  }

  @tag_to_player_event Map.new(@player_event_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PlayerEvent` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Media.player_event_from_tag(0)
      {:ok, :play}
  """
  @spec player_event_from_tag(non_neg_integer()) :: {:ok, player_event()} | :error
  def player_event_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_player_event, tag)}
  end

  def player_event_from_tag(_tag), do: :error

  @doc """
  Encode a `PlayerEvent` to the C-ABI tag value.
  """
  @spec player_event_to_tag(player_event()) :: non_neg_integer()
  def player_event_to_tag(val) when is_map_key(@player_event_tags, val) do
    Map.fetch!(@player_event_tags, val)
  end

  @doc """
  All `PlayerEvent` variants in tag order.
  """
  @spec all_player_events() :: [player_event()]
  def all_player_events do
    [
      :play, :pause, :seek, :stop, :buffer_start, :buffer_end, :error,
      :quality_change
    ]
  end

  # ===========================================================================
  # PlayerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  PlayerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type player_state :: :idle | :ready | :playing | :paused | :stopping

  @player_state_tags %{
    idle: 0,
    ready: 1,
    playing: 2,
    paused: 3,
    stopping: 4,
  }

  @tag_to_player_state Map.new(@player_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PlayerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Media.player_state_from_tag(0)
      {:ok, :idle}
  """
  @spec player_state_from_tag(non_neg_integer()) :: {:ok, player_state()} | :error
  def player_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_player_state, tag)}
  end

  def player_state_from_tag(_tag), do: :error

  @doc """
  Encode a `PlayerState` to the C-ABI tag value.
  """
  @spec player_state_to_tag(player_state()) :: non_neg_integer()
  def player_state_to_tag(val) when is_map_key(@player_state_tags, val) do
    Map.fetch!(@player_state_tags, val)
  end

  @doc """
  All `PlayerState` variants in tag order.
  """
  @spec all_player_states() :: [player_state()]
  def all_player_states, do: [:idle, :ready, :playing, :paused, :stopping]

end
