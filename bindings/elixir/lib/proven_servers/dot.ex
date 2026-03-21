# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Dot do
  @moduledoc """
  DNS-over-TLS types for the proven-servers ABI.
  
  Formally verified DoT types (RFC 7858).
  Mirrors the Idris2 module `DotABI.Types`.
  
  - `SessionState` -- DoT session lifecycle states.
  - `PaddingStrategy` -- DoT padding strategies (RFC 7830).
  - `ErrorReason` -- DoT error reasons.
  - `ServerState` -- DoT server lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard DoT port."
  @spec dot_port() :: non_neg_integer()
  def dot_port, do: 853

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :connecting | :handshaking | :established | :closing | :closed

  @session_state_tags %{
    connecting: 0,
    handshaking: 1,
    established: 2,
    closing: 3,
    closed: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dot.session_state_from_tag(0)
      {:ok, :connecting}
  """
  @spec session_state_from_tag(non_neg_integer()) :: {:ok, session_state()} | :error
  def session_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_session_state, tag)}
  end

  def session_state_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionState` to the C-ABI tag value.
  """
  @spec session_state_to_tag(session_state()) :: non_neg_integer()
  def session_state_to_tag(val) when is_map_key(@session_state_tags, val) do
    Map.fetch!(@session_state_tags, val)
  end

  @doc """
  All `SessionState` variants in tag order.
  """
  @spec all_session_states() :: [session_state()]
  def all_session_states, do: [:connecting, :handshaking, :established, :closing, :closed]

  # ===========================================================================
  # PaddingStrategy (tags 0-2)
  # ===========================================================================

  @typedoc """
  PaddingStrategy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type padding_strategy :: :no_padding | :block_padding | :random_padding

  @padding_strategy_tags %{
    no_padding: 0,
    block_padding: 1,
    random_padding: 2,
  }

  @tag_to_padding_strategy Map.new(@padding_strategy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PaddingStrategy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dot.padding_strategy_from_tag(0)
      {:ok, :no_padding}
  """
  @spec padding_strategy_from_tag(non_neg_integer()) :: {:ok, padding_strategy()} | :error
  def padding_strategy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_padding_strategy, tag)}
  end

  def padding_strategy_from_tag(_tag), do: :error

  @doc """
  Encode a `PaddingStrategy` to the C-ABI tag value.
  """
  @spec padding_strategy_to_tag(padding_strategy()) :: non_neg_integer()
  def padding_strategy_to_tag(val) when is_map_key(@padding_strategy_tags, val) do
    Map.fetch!(@padding_strategy_tags, val)
  end

  @doc """
  All `PaddingStrategy` variants in tag order.
  """
  @spec all_padding_strategys() :: [padding_strategy()]
  def all_padding_strategys, do: [:no_padding, :block_padding, :random_padding]

  # ===========================================================================
  # ErrorReason (tags 0-3)
  # ===========================================================================

  @typedoc """
  ErrorReason types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type error_reason :: :handshake_failed | :certificate_invalid | :timeout | :upstream_error

  @error_reason_tags %{
    handshake_failed: 0,
    certificate_invalid: 1,
    timeout: 2,
    upstream_error: 3,
  }

  @tag_to_error_reason Map.new(@error_reason_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ErrorReason` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dot.error_reason_from_tag(0)
      {:ok, :handshake_failed}
  """
  @spec error_reason_from_tag(non_neg_integer()) :: {:ok, error_reason()} | :error
  def error_reason_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_error_reason, tag)}
  end

  def error_reason_from_tag(_tag), do: :error

  @doc """
  Encode a `ErrorReason` to the C-ABI tag value.
  """
  @spec error_reason_to_tag(error_reason()) :: non_neg_integer()
  def error_reason_to_tag(val) when is_map_key(@error_reason_tags, val) do
    Map.fetch!(@error_reason_tags, val)
  end

  @doc """
  All `ErrorReason` variants in tag order.
  """
  @spec all_error_reasons() :: [error_reason()]
  def all_error_reasons, do: [:handshake_failed, :certificate_invalid, :timeout, :upstream_error]

  # ===========================================================================
  # ServerState (tags 0-4)
  # ===========================================================================

  @typedoc """
  ServerState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type server_state :: :idle | :bound | :listening | :processing | :shutdown

  @server_state_tags %{
    idle: 0,
    bound: 1,
    listening: 2,
    processing: 3,
    shutdown: 4,
  }

  @tag_to_server_state Map.new(@server_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ServerState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Dot.server_state_from_tag(0)
      {:ok, :idle}
  """
  @spec server_state_from_tag(non_neg_integer()) :: {:ok, server_state()} | :error
  def server_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_server_state, tag)}
  end

  def server_state_from_tag(_tag), do: :error

  @doc """
  Encode a `ServerState` to the C-ABI tag value.
  """
  @spec server_state_to_tag(server_state()) :: non_neg_integer()
  def server_state_to_tag(val) when is_map_key(@server_state_tags, val) do
    Map.fetch!(@server_state_tags, val)
  end

  @doc """
  All `ServerState` variants in tag order.
  """
  @spec all_server_states() :: [server_state()]
  def all_server_states, do: [:idle, :bound, :listening, :processing, :shutdown]

end
