# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Ptp do
  @moduledoc """
  PTP types for the proven-servers ABI.
  
  Formally verified PTP (Precision Time Protocol, IEEE 1588) types.
  Mirrors the Idris2 module `PtpABI.Types`.
  
  - `PtpMessageType` -- PTP message types.
  - `ClockClass` -- PTP clock classes.
  - `PtpPortState` -- PTP port states (IEEE 1588).
  - `DelayMechanism` -- PTP delay measurement mechanisms.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "PTP event port."
  @spec ptp_event_port() :: non_neg_integer()
  def ptp_event_port, do: 319

  @doc "PTP general port."
  @spec ptp_general_port() :: non_neg_integer()
  def ptp_general_port, do: 320

  # ===========================================================================
  # PtpMessageType (tags 0-9)
  # ===========================================================================

  @typedoc """
  PtpMessageType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ptp_message_type ::
          :sync
          | :delay_req
          | :pdelay_req
          | :pdelay_resp
          | :follow_up
          | :delay_resp
          | :pdelay_resp_follow_up
          | :announce
          | :signaling
          | :management

  @ptp_message_type_tags %{
    sync: 0,
    delay_req: 1,
    pdelay_req: 2,
    pdelay_resp: 3,
    follow_up: 4,
    delay_resp: 5,
    pdelay_resp_follow_up: 6,
    announce: 7,
    signaling: 8,
    management: 9,
  }

  @tag_to_ptp_message_type Map.new(@ptp_message_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PtpMessageType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ptp.ptp_message_type_from_tag(0)
      {:ok, :sync}
  """
  @spec ptp_message_type_from_tag(non_neg_integer()) :: {:ok, ptp_message_type()} | :error
  def ptp_message_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_ptp_message_type, tag)}
  end

  def ptp_message_type_from_tag(_tag), do: :error

  @doc """
  Encode a `PtpMessageType` to the C-ABI tag value.
  """
  @spec ptp_message_type_to_tag(ptp_message_type()) :: non_neg_integer()
  def ptp_message_type_to_tag(val) when is_map_key(@ptp_message_type_tags, val) do
    Map.fetch!(@ptp_message_type_tags, val)
  end

  @doc """
  All `PtpMessageType` variants in tag order.
  """
  @spec all_ptp_message_types() :: [ptp_message_type()]
  def all_ptp_message_types do
    [
      :sync, :delay_req, :pdelay_req, :pdelay_resp, :follow_up, :delay_resp,
      :pdelay_resp_follow_up, :announce, :signaling, :management
    ]
  end

  # ===========================================================================
  # ClockClass (tags 0-3)
  # ===========================================================================

  @typedoc """
  ClockClass types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type clock_class :: :primary_clock | :application_specific | :slave_only | :default_class

  @clock_class_tags %{
    primary_clock: 0,
    application_specific: 1,
    slave_only: 2,
    default_class: 3,
  }

  @tag_to_clock_class Map.new(@clock_class_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ClockClass` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ptp.clock_class_from_tag(0)
      {:ok, :primary_clock}
  """
  @spec clock_class_from_tag(non_neg_integer()) :: {:ok, clock_class()} | :error
  def clock_class_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_clock_class, tag)}
  end

  def clock_class_from_tag(_tag), do: :error

  @doc """
  Encode a `ClockClass` to the C-ABI tag value.
  """
  @spec clock_class_to_tag(clock_class()) :: non_neg_integer()
  def clock_class_to_tag(val) when is_map_key(@clock_class_tags, val) do
    Map.fetch!(@clock_class_tags, val)
  end

  @doc """
  All `ClockClass` variants in tag order.
  """
  @spec all_clock_classs() :: [clock_class()]
  def all_clock_classs, do: [:primary_clock, :application_specific, :slave_only, :default_class]

  # ===========================================================================
  # PtpPortState (tags 0-8)
  # ===========================================================================

  @typedoc """
  PtpPortState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type ptp_port_state ::
          :initializing
          | :faulty
          | :disabled
          | :listening
          | :pre_master
          | :master
          | :passive
          | :uncalibrated
          | :slave

  @ptp_port_state_tags %{
    initializing: 0,
    faulty: 1,
    disabled: 2,
    listening: 3,
    pre_master: 4,
    master: 5,
    passive: 6,
    uncalibrated: 7,
    slave: 8,
  }

  @tag_to_ptp_port_state Map.new(@ptp_port_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PtpPortState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ptp.ptp_port_state_from_tag(0)
      {:ok, :initializing}
  """
  @spec ptp_port_state_from_tag(non_neg_integer()) :: {:ok, ptp_port_state()} | :error
  def ptp_port_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_ptp_port_state, tag)}
  end

  def ptp_port_state_from_tag(_tag), do: :error

  @doc """
  Encode a `PtpPortState` to the C-ABI tag value.
  """
  @spec ptp_port_state_to_tag(ptp_port_state()) :: non_neg_integer()
  def ptp_port_state_to_tag(val) when is_map_key(@ptp_port_state_tags, val) do
    Map.fetch!(@ptp_port_state_tags, val)
  end

  @doc """
  All `PtpPortState` variants in tag order.
  """
  @spec all_ptp_port_states() :: [ptp_port_state()]
  def all_ptp_port_states do
    [
      :initializing, :faulty, :disabled, :listening, :pre_master, :master,
      :passive, :uncalibrated, :slave
    ]
  end

  # ===========================================================================
  # DelayMechanism (tags 0-2)
  # ===========================================================================

  @typedoc """
  DelayMechanism types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type delay_mechanism :: :e2_e | :p2_p | :dm_disabled

  @delay_mechanism_tags %{
    e2_e: 0,
    p2_p: 1,
    dm_disabled: 2,
  }

  @tag_to_delay_mechanism Map.new(@delay_mechanism_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DelayMechanism` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Ptp.delay_mechanism_from_tag(0)
      {:ok, :e2_e}
  """
  @spec delay_mechanism_from_tag(non_neg_integer()) :: {:ok, delay_mechanism()} | :error
  def delay_mechanism_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_delay_mechanism, tag)}
  end

  def delay_mechanism_from_tag(_tag), do: :error

  @doc """
  Encode a `DelayMechanism` to the C-ABI tag value.
  """
  @spec delay_mechanism_to_tag(delay_mechanism()) :: non_neg_integer()
  def delay_mechanism_to_tag(val) when is_map_key(@delay_mechanism_tags, val) do
    Map.fetch!(@delay_mechanism_tags, val)
  end

  @doc """
  All `DelayMechanism` variants in tag order.
  """
  @spec all_delay_mechanisms() :: [delay_mechanism()]
  def all_delay_mechanisms, do: [:e2_e, :p2_p, :dm_disabled]

end
