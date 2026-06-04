# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Modbus do
  @moduledoc """
  Modbus protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `abi.Types` (Modbus) and its type definitions:
  - `FunctionCode`  — Modbus function codes (10 constructors, tags 0-9)
  - `ExceptionCode` — Modbus exception codes (9 constructors, tags 0-8)
  - `DeviceRole`    — Master/Slave roles (2 constructors, tags 0-1)
  - `GatewayState`  — Modbus TCP gateway lifecycle (5 constructors, tags 0-4)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard Modbus TCP port (Modbus/TCP specification)."
  @spec modbus_tcp_port() :: non_neg_integer()
  def modbus_tcp_port, do: 502

  @doc "Maximum number of coils in a single read request."
  @spec modbus_max_coils() :: non_neg_integer()
  def modbus_max_coils, do: 2000

  @doc "Maximum number of registers in a single read request."
  @spec modbus_max_registers() :: non_neg_integer()
  def modbus_max_registers, do: 125

  # ===========================================================================
  # FunctionCode (tags 0-9)
  # ===========================================================================

  @typedoc """
  FunctionCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type function_code ::
          :read_coils
          | :read_discrete_inputs
          | :read_holding_registers
          | :read_input_registers
          | :write_single_coil
          | :write_single_register
          | :write_multiple_coils
          | :write_multiple_registers
          | :read_write_multiple_registers
          | :mask_write_register

  @function_code_tags %{
    read_coils: 0,
    read_discrete_inputs: 1,
    read_holding_registers: 2,
    read_input_registers: 3,
    write_single_coil: 4,
    write_single_register: 5,
    write_multiple_coils: 6,
    write_multiple_registers: 7,
    read_write_multiple_registers: 8,
    mask_write_register: 9,
  }

  @tag_to_function_code Map.new(@function_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FunctionCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..9, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Modbus.function_code_from_tag(0)
      {:ok, :read_coils}
  """
  @spec function_code_from_tag(non_neg_integer()) :: {:ok, function_code()} | :error
  def function_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 9 do
    {:ok, Map.fetch!(@tag_to_function_code, tag)}
  end

  def function_code_from_tag(_tag), do: :error

  @doc """
  Encode a `FunctionCode` to the C-ABI tag value.
  """
  @spec function_code_to_tag(function_code()) :: non_neg_integer()
  def function_code_to_tag(val) when is_map_key(@function_code_tags, val) do
    Map.fetch!(@function_code_tags, val)
  end

  @doc """
  All `FunctionCode` variants in tag order.
  """
  @spec all_function_codes() :: [function_code()]
  def all_function_codes do
    [
      :read_coils, :read_discrete_inputs, :read_holding_registers, :read_input_registers,
      :write_single_coil, :write_single_register, :write_multiple_coils,
      :write_multiple_registers, :read_write_multiple_registers, :mask_write_register,
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this function code is a read operation.
  """
  @spec is_read?(function_code()) :: boolean()
  def is_read?(val) when val in [:read_coils, :read_discrete_inputs, :read_holding_registers, :read_input_registers, :read_write_multiple_registers], do: true
  def is_read?(_val), do: false

  @doc """
  Whether this function code is a write operation.
  """
  @spec is_write?(function_code()) :: boolean()
  def is_write?(val) when val in [:write_single_coil, :write_single_register, :write_multiple_coils, :write_multiple_registers, :read_write_multiple_registers, :mask_write_register], do: true
  def is_write?(_val), do: false

  @doc """
  Whether this function code operates on coils (bits).
  """
  @spec is_coil_operation?(function_code()) :: boolean()
  def is_coil_operation?(val) when val in [:read_coils, :read_discrete_inputs, :write_single_coil, :write_multiple_coils], do: true
  def is_coil_operation?(_val), do: false

  # ===========================================================================
  # ExceptionCode (tags 0-8)
  # ===========================================================================

  @typedoc """
  ExceptionCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type exception_code ::
          :illegal_function
          | :illegal_data_address
          | :illegal_data_value
          | :slave_device_failure
          | :acknowledge
          | :slave_device_busy
          | :memory_parity_error
          | :gateway_path_unavailable
          | :gateway_target_device_failed

  @exception_code_tags %{
    illegal_function: 0,
    illegal_data_address: 1,
    illegal_data_value: 2,
    slave_device_failure: 3,
    acknowledge: 4,
    slave_device_busy: 5,
    memory_parity_error: 6,
    gateway_path_unavailable: 7,
    gateway_target_device_failed: 8,
  }

  @tag_to_exception_code Map.new(@exception_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ExceptionCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..8, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Modbus.exception_code_from_tag(0)
      {:ok, :illegal_function}
  """
  @spec exception_code_from_tag(non_neg_integer()) :: {:ok, exception_code()} | :error
  def exception_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 8 do
    {:ok, Map.fetch!(@tag_to_exception_code, tag)}
  end

  def exception_code_from_tag(_tag), do: :error

  @doc """
  Encode a `ExceptionCode` to the C-ABI tag value.
  """
  @spec exception_code_to_tag(exception_code()) :: non_neg_integer()
  def exception_code_to_tag(val) when is_map_key(@exception_code_tags, val) do
    Map.fetch!(@exception_code_tags, val)
  end

  @doc """
  All `ExceptionCode` variants in tag order.
  """
  @spec all_exception_codes() :: [exception_code()]
  def all_exception_codes do
    [
      :illegal_function, :illegal_data_address, :illegal_data_value,
      :slave_device_failure, :acknowledge, :slave_device_busy, :memory_parity_error,
      :gateway_path_unavailable, :gateway_target_device_failed
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this exception indicates the request can be retried.
  """
  @spec is_retryable?(exception_code()) :: boolean()
  def is_retryable?(val) when val in [:acknowledge, :slave_device_busy], do: true
  def is_retryable?(_val), do: false

  @doc """
  Whether this exception relates to gateway operation.
  """
  @spec is_gateway_error?(exception_code()) :: boolean()
  def is_gateway_error?(val) when val in [:gateway_path_unavailable, :gateway_target_device_failed], do: true
  def is_gateway_error?(_val), do: false

  # ===========================================================================
  # DeviceRole (tags 0-1)
  # ===========================================================================

  @typedoc """
  DeviceRole types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type device_role :: :master | :slave

  @device_role_tags %{
    master: 0,
    slave: 1,
  }

  @tag_to_device_role Map.new(@device_role_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `DeviceRole` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Modbus.device_role_from_tag(0)
      {:ok, :master}
  """
  @spec device_role_from_tag(non_neg_integer()) :: {:ok, device_role()} | :error
  def device_role_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_device_role, tag)}
  end

  def device_role_from_tag(_tag), do: :error

  @doc """
  Encode a `DeviceRole` to the C-ABI tag value.
  """
  @spec device_role_to_tag(device_role()) :: non_neg_integer()
  def device_role_to_tag(val) when is_map_key(@device_role_tags, val) do
    Map.fetch!(@device_role_tags, val)
  end

  @doc """
  All `DeviceRole` variants in tag order.
  """
  @spec all_device_roles() :: [device_role()]
  def all_device_roles, do: [:master, :slave]

  # ===========================================================================
  # GatewayState (tags 0-4)
  # ===========================================================================

  @typedoc """
  GatewayState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type gateway_state :: :idle | :listening | :processing | :error | :stopping

  @gateway_state_tags %{
    idle: 0,
    listening: 1,
    processing: 2,
    error: 3,
    stopping: 4,
  }

  @tag_to_gateway_state Map.new(@gateway_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `GatewayState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Modbus.gateway_state_from_tag(0)
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
  def all_gateway_states, do: [:idle, :listening, :processing, :error, :stopping]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the gateway is in a healthy operational state.
  """
  @spec is_healthy?(gateway_state()) :: boolean()
  def is_healthy?(val) when val in [:listening, :processing], do: true
  def is_healthy?(_val), do: false

  @doc """
  Whether the gateway needs operator attention.
  """
  @spec needs_intervention?(gateway_state()) :: boolean()
  def needs_intervention?(val) when val in [:error], do: true
  def needs_intervention?(_val), do: false

end
