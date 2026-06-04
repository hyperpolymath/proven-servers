# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Diode do
  @moduledoc """
  Data Diode types for the proven-servers ABI.
  
  Formally verified data diode (unidirectional network) types.
  Mirrors the Idris2 module `DiodeABI.Types`.
  
  - `Direction` -- Diode data flow direction.
  - `DiodeProtocol` -- Diode transfer protocols.
  - `TransferState` -- Diode transfer states.
  - `ValidationResult` -- Data validation results.
  - `IntegrityCheck` -- Integrity verification methods.
  - `GatewayState` -- Diode gateway states.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # Direction (tags 0-1)
  # ===========================================================================

  @typedoc """
  Direction types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type direction :: :high_to_low | :low_to_high

  @direction_tags %{
    high_to_low: 0,
    low_to_high: 1,
  }

  @tag_to_direction Map.new(@direction_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Direction` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Diode.direction_from_tag(0)
      {:ok, :high_to_low}
  """
  @spec direction_from_tag(non_neg_integer()) :: {:ok, direction()} | :error
  def direction_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_direction, tag)}
  end

  def direction_from_tag(_tag), do: :error

  @doc """
  Encode a `Direction` to the C-ABI tag value.
  """
  @spec direction_to_tag(direction()) :: non_neg_integer()
  def direction_to_tag(val) when is_map_key(@direction_tags, val) do
    Map.fetch!(@direction_tags, val)
  end

  @doc """
  All `Direction` variants in tag order.
  """
  @spec all_directions() :: [direction()]
  def all_directions, do: [:high_to_low, :low_to_high]

  # ===========================================================================
  # DiodeProtocol (tags 0-4)
  # ===========================================================================

  @typedoc """
  DiodeProtocol types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type diode_protocol :: :udp | :tcp | :file_transfer | :syslog | :snmp

  @diode_protocol_tags %{
    udp: 0,
    tcp: 1,
    file_transfer: 2,
    syslog: 3,
    snmp: 4,
  }

  @tag_to_diode_protocol Map.new(@diode_protocol_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DiodeProtocol` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Diode.diode_protocol_from_tag(0)
      {:ok, :udp}
  """
  @spec diode_protocol_from_tag(non_neg_integer()) :: {:ok, diode_protocol()} | :error
  def diode_protocol_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_diode_protocol, tag)}
  end

  def diode_protocol_from_tag(_tag), do: :error

  @doc """
  Encode a `DiodeProtocol` to the C-ABI tag value.
  """
  @spec diode_protocol_to_tag(diode_protocol()) :: non_neg_integer()
  def diode_protocol_to_tag(val) when is_map_key(@diode_protocol_tags, val) do
    Map.fetch!(@diode_protocol_tags, val)
  end

  @doc """
  All `DiodeProtocol` variants in tag order.
  """
  @spec all_diode_protocols() :: [diode_protocol()]
  def all_diode_protocols, do: [:udp, :tcp, :file_transfer, :syslog, :snmp]

  # ===========================================================================
  # TransferState (tags 0-4)
  # ===========================================================================

  @typedoc """
  TransferState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transfer_state :: :queued | :sending | :confirming | :complete | :failed

  @transfer_state_tags %{
    queued: 0,
    sending: 1,
    confirming: 2,
    complete: 3,
    failed: 4,
  }

  @tag_to_transfer_state Map.new(@transfer_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransferState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Diode.transfer_state_from_tag(0)
      {:ok, :queued}
  """
  @spec transfer_state_from_tag(non_neg_integer()) :: {:ok, transfer_state()} | :error
  def transfer_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_transfer_state, tag)}
  end

  def transfer_state_from_tag(_tag), do: :error

  @doc """
  Encode a `TransferState` to the C-ABI tag value.
  """
  @spec transfer_state_to_tag(transfer_state()) :: non_neg_integer()
  def transfer_state_to_tag(val) when is_map_key(@transfer_state_tags, val) do
    Map.fetch!(@transfer_state_tags, val)
  end

  @doc """
  All `TransferState` variants in tag order.
  """
  @spec all_transfer_states() :: [transfer_state()]
  def all_transfer_states, do: [:queued, :sending, :confirming, :complete, :failed]

  # ===========================================================================
  # ValidationResult (tags 0-3)
  # ===========================================================================

  @typedoc """
  ValidationResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type validation_result :: :passed | :format_error | :size_exceeded | :policy_blocked

  @validation_result_tags %{
    passed: 0,
    format_error: 1,
    size_exceeded: 2,
    policy_blocked: 3,
  }

  @tag_to_validation_result Map.new(@validation_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ValidationResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Diode.validation_result_from_tag(0)
      {:ok, :passed}
  """
  @spec validation_result_from_tag(non_neg_integer()) :: {:ok, validation_result()} | :error
  def validation_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_validation_result, tag)}
  end

  def validation_result_from_tag(_tag), do: :error

  @doc """
  Encode a `ValidationResult` to the C-ABI tag value.
  """
  @spec validation_result_to_tag(validation_result()) :: non_neg_integer()
  def validation_result_to_tag(val) when is_map_key(@validation_result_tags, val) do
    Map.fetch!(@validation_result_tags, val)
  end

  @doc """
  All `ValidationResult` variants in tag order.
  """
  @spec all_validation_results() :: [validation_result()]
  def all_validation_results, do: [:passed, :format_error, :size_exceeded, :policy_blocked]

  # ===========================================================================
  # IntegrityCheck (tags 0-2)
  # ===========================================================================

  @typedoc """
  IntegrityCheck types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type integrity_check :: :crc32 | :sha256 | :hmac

  @integrity_check_tags %{
    crc32: 0,
    sha256: 1,
    hmac: 2,
  }

  @tag_to_integrity_check Map.new(@integrity_check_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `IntegrityCheck` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Diode.integrity_check_from_tag(0)
      {:ok, :crc32}
  """
  @spec integrity_check_from_tag(non_neg_integer()) :: {:ok, integrity_check()} | :error
  def integrity_check_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_integrity_check, tag)}
  end

  def integrity_check_from_tag(_tag), do: :error

  @doc """
  Encode a `IntegrityCheck` to the C-ABI tag value.
  """
  @spec integrity_check_to_tag(integrity_check()) :: non_neg_integer()
  def integrity_check_to_tag(val) when is_map_key(@integrity_check_tags, val) do
    Map.fetch!(@integrity_check_tags, val)
  end

  @doc """
  All `IntegrityCheck` variants in tag order.
  """
  @spec all_integrity_checks() :: [integrity_check()]
  def all_integrity_checks, do: [:crc32, :sha256, :hmac]

  # ===========================================================================
  # GatewayState (tags 0-4)
  # ===========================================================================

  @typedoc """
  GatewayState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type gateway_state :: :idle | :configured | :transferring | :validating | :shutdown

  @gateway_state_tags %{
    idle: 0,
    configured: 1,
    transferring: 2,
    validating: 3,
    shutdown: 4,
  }

  @tag_to_gateway_state Map.new(@gateway_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `GatewayState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Diode.gateway_state_from_tag(0)
      {:ok, :idle}
  """
  @spec gateway_state_from_tag(non_neg_integer()) :: {:ok, gateway_state()} | :error
  def gateway_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_gateway_state, tag)}
  end

  def gateway_state_from_tag(_tag), do: :error

  @doc """
  Encode a `GatewayState` to the C-ABI tag value.
  """
  @spec gateway_state_to_tag(gateway_state()) :: non_neg_integer()
  def gateway_state_to_tag(val) when is_map_key(@gateway_state_tags, val) do
    Map.fetch!(@gateway_state_tags, val)
  end

  @doc """
  All `GatewayState` variants in tag order.
  """
  @spec all_gateway_states() :: [gateway_state()]
  def all_gateway_states, do: [:idle, :configured, :transferring, :validating, :shutdown]

end
