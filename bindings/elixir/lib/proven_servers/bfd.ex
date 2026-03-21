# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Bfd do
  @moduledoc """
  BFD types for the proven-servers ABI.
  
  Formally verified BFD (Bidirectional Forwarding Detection, RFC 5880) types.
  Mirrors the Idris2 module `BfdABI.Types`.
  
  - `BfdState` -- BFD session states (RFC 5880 Section 4.1).
  - `Diagnostic` -- BFD diagnostic codes (RFC 5880 Section 4.1).
  - `SessionMode` -- BFD session modes.
  - `SessionState` -- BFD session lifecycle states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard BFD port."
  @spec bfd_port() :: non_neg_integer()
  def bfd_port, do: 3784

  # ===========================================================================
  # BfdState (tags 0-3)
  # ===========================================================================

  @typedoc """
  BfdState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type bfd_state :: :admin_down | :down | :init | :up

  @bfd_state_tags %{
    admin_down: 0,
    down: 1,
    init: 2,
    up: 3,
  }

  @tag_to_bfd_state Map.new(@bfd_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BfdState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bfd.bfd_state_from_tag(0)
      {:ok, :admin_down}
  """
  @spec bfd_state_from_tag(non_neg_integer()) :: {:ok, bfd_state()} | :error
  def bfd_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_bfd_state, tag)}
  end

  def bfd_state_from_tag(_tag), do: :error

  @doc """
  Encode a `BfdState` to the C-ABI tag value.
  """
  @spec bfd_state_to_tag(bfd_state()) :: non_neg_integer()
  def bfd_state_to_tag(val) when is_map_key(@bfd_state_tags, val) do
    Map.fetch!(@bfd_state_tags, val)
  end

  @doc """
  All `BfdState` variants in tag order.
  """
  @spec all_bfd_states() :: [bfd_state()]
  def all_bfd_states, do: [:admin_down, :down, :init, :up]

  # ===========================================================================
  # Diagnostic (tags 0-8)
  # ===========================================================================

  @typedoc """
  Diagnostic types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type diagnostic ::
          :no_diagnostic
          | :control_detection_time_expired
          | :echo_function_failed
          | :neighbor_signaled_session_down
          | :forwarding_plane_reset
          | :path_down
          | :concatenated_path_down
          | :administratively_down
          | :reverse_concatenated_path_down

  @diagnostic_tags %{
    no_diagnostic: 0,
    control_detection_time_expired: 1,
    echo_function_failed: 2,
    neighbor_signaled_session_down: 3,
    forwarding_plane_reset: 4,
    path_down: 5,
    concatenated_path_down: 6,
    administratively_down: 7,
    reverse_concatenated_path_down: 8,
  }

  @tag_to_diagnostic Map.new(@diagnostic_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Diagnostic` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bfd.diagnostic_from_tag(0)
      {:ok, :no_diagnostic}
  """
  @spec diagnostic_from_tag(non_neg_integer()) :: {:ok, diagnostic()} | :error
  def diagnostic_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_diagnostic, tag)}
  end

  def diagnostic_from_tag(_tag), do: :error

  @doc """
  Encode a `Diagnostic` to the C-ABI tag value.
  """
  @spec diagnostic_to_tag(diagnostic()) :: non_neg_integer()
  def diagnostic_to_tag(val) when is_map_key(@diagnostic_tags, val) do
    Map.fetch!(@diagnostic_tags, val)
  end

  @doc """
  All `Diagnostic` variants in tag order.
  """
  @spec all_diagnostics() :: [diagnostic()]
  def all_diagnostics do
    [
      :no_diagnostic, :control_detection_time_expired, :echo_function_failed,
      :neighbor_signaled_session_down, :forwarding_plane_reset, :path_down,
      :concatenated_path_down, :administratively_down, :reverse_concatenated_path_down,
    ]
  end

  # ===========================================================================
  # SessionMode (tags 0-1)
  # ===========================================================================

  @typedoc """
  SessionMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_mode :: :async_mode | :demand_mode

  @session_mode_tags %{
    async_mode: 0,
    demand_mode: 1,
  }

  @tag_to_session_mode Map.new(@session_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bfd.session_mode_from_tag(0)
      {:ok, :async_mode}
  """
  @spec session_mode_from_tag(non_neg_integer()) :: {:ok, session_mode()} | :error
  def session_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_session_mode, tag)}
  end

  def session_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `SessionMode` to the C-ABI tag value.
  """
  @spec session_mode_to_tag(session_mode()) :: non_neg_integer()
  def session_mode_to_tag(val) when is_map_key(@session_mode_tags, val) do
    Map.fetch!(@session_mode_tags, val)
  end

  @doc """
  All `SessionMode` variants in tag order.
  """
  @spec all_session_modes() :: [session_mode()]
  def all_session_modes, do: [:async_mode, :demand_mode]

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :ss_down | :negotiating | :established | :teardown

  @session_state_tags %{
    idle: 0,
    ss_down: 1,
    negotiating: 2,
    established: 3,
    teardown: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Bfd.session_state_from_tag(0)
      {:ok, :idle}
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
  def all_session_states, do: [:idle, :ss_down, :negotiating, :established, :teardown]

end
