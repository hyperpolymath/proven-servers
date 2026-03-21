# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Telnet do
  @moduledoc """
  Telnet protocol types for the proven-servers ABI.
  
  **INSECURE PROTOCOL** — for legacy interoperability only.
  
  Mirrors the Idris2 module `TelnetABI.Types` and its type definitions:
  - `Command`          — Telnet commands (16 constructors, tags 0-15)
  - `TelnetOption`     — Telnet options (10 constructors, tags 0-9)
  - `NegotiationState` — Option negotiation states (4 constructors, tags 0-3)
  - `SessionState`     — Session lifecycle states (5 constructors, tags 0-4)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Telnet port (RFC 854)."
  @spec telnet_port() :: non_neg_integer()
  def telnet_port, do: 23

  # ===========================================================================
  # Command (tags 0-15)
  # ===========================================================================

  @typedoc """
  Command types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command ::
          :se
          | :nop
          | :data_mark
          | :break
          | :interrupt_process
          | :abort_output
          | :are_you_there
          | :erase_char
          | :erase_line
          | :go_ahead
          | :sb
          | :will
          | :wont
          | :do
          | :dont
          | :iac

  @command_tags %{
    se: 0,
    nop: 1,
    data_mark: 2,
    break: 3,
    interrupt_process: 4,
    abort_output: 5,
    are_you_there: 6,
    erase_char: 7,
    erase_line: 8,
    go_ahead: 9,
    sb: 10,
    will: 11,
    wont: 12,
    do: 13,
    dont: 14,
    iac: 15,
  }

  @tag_to_command Map.new(@command_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Command` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..15, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Telnet.command_from_tag(0)
      {:ok, :se}
  """
  @spec command_from_tag(non_neg_integer()) :: {:ok, command()} | :error
  def command_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 15 do
    {:ok, Map.fetch!(@tag_to_command, tag)}
  end

  def command_from_tag(_tag), do: :error

  @doc """
  Encode a `Command` to the C-ABI tag value.
  """
  @spec command_to_tag(command()) :: non_neg_integer()
  def command_to_tag(val) when is_map_key(@command_tags, val) do
    Map.fetch!(@command_tags, val)
  end

  @doc """
  All `Command` variants in tag order.
  """
  @spec all_commands() :: [command()]
  def all_commands do
    [
      :se, :nop, :data_mark, :break, :interrupt_process, :abort_output,
      :are_you_there, :erase_char, :erase_line, :go_ahead, :sb, :will,
      :wont, :do, :dont, :iac
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this command is a negotiation command (WILL/WONT/DO/DONT).
  """
  @spec is_negotiation?(command()) :: boolean()
  def is_negotiation?(val) when val in [:will, :wont, :do, :dont], do: true
  def is_negotiation?(_val), do: false

  # ===========================================================================
  # TelnetOption (tags 0-9)
  # ===========================================================================

  @typedoc """
  TelnetOption types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type telnet_option ::
          :echo
          | :suppress_go_ahead
          | :status
          | :timing_mark
          | :terminal_type
          | :window_size
          | :terminal_speed
          | :remote_flow_control
          | :linemode
          | :environment

  @telnet_option_tags %{
    echo: 0,
    suppress_go_ahead: 1,
    status: 2,
    timing_mark: 3,
    terminal_type: 4,
    window_size: 5,
    terminal_speed: 6,
    remote_flow_control: 7,
    linemode: 8,
    environment: 9,
  }

  @tag_to_telnet_option Map.new(@telnet_option_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TelnetOption` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Telnet.telnet_option_from_tag(0)
      {:ok, :echo}
  """
  @spec telnet_option_from_tag(non_neg_integer()) :: {:ok, telnet_option()} | :error
  def telnet_option_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_telnet_option, tag)}
  end

  def telnet_option_from_tag(_tag), do: :error

  @doc """
  Encode a `TelnetOption` to the C-ABI tag value.
  """
  @spec telnet_option_to_tag(telnet_option()) :: non_neg_integer()
  def telnet_option_to_tag(val) when is_map_key(@telnet_option_tags, val) do
    Map.fetch!(@telnet_option_tags, val)
  end

  @doc """
  All `TelnetOption` variants in tag order.
  """
  @spec all_telnet_options() :: [telnet_option()]
  def all_telnet_options do
    [
      :echo, :suppress_go_ahead, :status, :timing_mark, :terminal_type,
      :window_size, :terminal_speed, :remote_flow_control, :linemode,
      :environment
    ]
  end

  # ===========================================================================
  # NegotiationState (tags 0-3)
  # ===========================================================================

  @typedoc """
  NegotiationState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type negotiation_state :: :inactive | :will_sent | :do_sent | :active

  @negotiation_state_tags %{
    inactive: 0,
    will_sent: 1,
    do_sent: 2,
    active: 3,
  }

  @tag_to_negotiation_state Map.new(@negotiation_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `NegotiationState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Telnet.negotiation_state_from_tag(0)
      {:ok, :inactive}
  """
  @spec negotiation_state_from_tag(non_neg_integer()) :: {:ok, negotiation_state()} | :error
  def negotiation_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_negotiation_state, tag)}
  end

  def negotiation_state_from_tag(_tag), do: :error

  @doc """
  Encode a `NegotiationState` to the C-ABI tag value.
  """
  @spec negotiation_state_to_tag(negotiation_state()) :: non_neg_integer()
  def negotiation_state_to_tag(val) when is_map_key(@negotiation_state_tags, val) do
    Map.fetch!(@negotiation_state_tags, val)
  end

  @doc """
  All `NegotiationState` variants in tag order.
  """
  @spec all_negotiation_states() :: [negotiation_state()]
  def all_negotiation_states, do: [:inactive, :will_sent, :do_sent, :active]

  # ===========================================================================
  # SessionState (tags 0-4)
  # ===========================================================================

  @typedoc """
  SessionState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type session_state :: :idle | :negotiating | :active | :subneg | :closing

  @session_state_tags %{
    idle: 0,
    negotiating: 1,
    active: 2,
    subneg: 3,
    closing: 4,
  }

  @tag_to_session_state Map.new(@session_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SessionState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Telnet.session_state_from_tag(0)
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
  def all_session_states, do: [:idle, :negotiating, :active, :subneg, :closing]

end
