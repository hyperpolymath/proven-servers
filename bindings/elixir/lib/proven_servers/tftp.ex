# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Tftp do
  @moduledoc """
  TFTP (Trivial File Transfer Protocol) types for the proven-servers ABI.
  
  Mirrors the Idris2 module `TFTPABI.Types` and its type definitions:
  - `Opcode`        — TFTP opcodes (5 constructors, tags 0-4)
  - `TransferMode`  — TFTP transfer modes (3 constructors, tags 0-2)
  - `TftpError`     — TFTP error codes (8 constructors, tags 0-7)
  - `TransferState` — TFTP transfer lifecycle (5 constructors, tags 0-4)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard TFTP port (RFC 1350)."
  @spec tftp_port() :: non_neg_integer()
  def tftp_port, do: 69

  @doc "TFTP data block size (RFC 1350)."
  @spec tftp_block_size() :: non_neg_integer()
  def tftp_block_size, do: 512

  # ===========================================================================
  # Opcode (tags 0-4)
  # ===========================================================================

  @typedoc """
  Opcode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type opcode :: :rrq | :wrq | :data | :ack | :error

  @opcode_tags %{
    rrq: 0,
    wrq: 1,
    data: 2,
    ack: 3,
    error: 4,
  }

  @tag_to_opcode Map.new(@opcode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Opcode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tftp.opcode_from_tag(0)
      {:ok, :rrq}
  """
  @spec opcode_from_tag(non_neg_integer()) :: {:ok, opcode()} | :error
  def opcode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_opcode, tag)}
  end

  def opcode_from_tag(_tag), do: :error

  @doc """
  Encode a `Opcode` to the C-ABI tag value.
  """
  @spec opcode_to_tag(opcode()) :: non_neg_integer()
  def opcode_to_tag(val) when is_map_key(@opcode_tags, val) do
    Map.fetch!(@opcode_tags, val)
  end

  @doc """
  All `Opcode` variants in tag order.
  """
  @spec all_opcodes() :: [opcode()]
  def all_opcodes, do: [:rrq, :wrq, :data, :ack, :error]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this opcode initiates a transfer.
  """
  @spec is_request?(opcode()) :: boolean()
  def is_request?(val) when val in [:rrq, :wrq], do: true
  def is_request?(_val), do: false

  @doc """
  Whether this opcode carries payload data.
  """
  @spec is_data?(opcode()) :: boolean()
  def is_data?(val) when val in [:data], do: true
  def is_data?(_val), do: false

  # ===========================================================================
  # TransferMode (tags 0-2)
  # ===========================================================================

  @typedoc """
  TransferMode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transfer_mode :: :net_ascii | :octet | :mail

  @transfer_mode_tags %{
    net_ascii: 0,
    octet: 1,
    mail: 2,
  }

  @tag_to_transfer_mode Map.new(@transfer_mode_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransferMode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tftp.transfer_mode_from_tag(0)
      {:ok, :net_ascii}
  """
  @spec transfer_mode_from_tag(non_neg_integer()) :: {:ok, transfer_mode()} | :error
  def transfer_mode_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_transfer_mode, tag)}
  end

  def transfer_mode_from_tag(_tag), do: :error

  @doc """
  Encode a `TransferMode` to the C-ABI tag value.
  """
  @spec transfer_mode_to_tag(transfer_mode()) :: non_neg_integer()
  def transfer_mode_to_tag(val) when is_map_key(@transfer_mode_tags, val) do
    Map.fetch!(@transfer_mode_tags, val)
  end

  @doc """
  All `TransferMode` variants in tag order.
  """
  @spec all_transfer_modes() :: [transfer_mode()]
  def all_transfer_modes, do: [:net_ascii, :octet, :mail]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The TFTP mode string (case-insensitive per RFC).
        match self {

  Whether this mode performs character set conversion.
  """
  @spec is_text_mode?(transfer_mode()) :: boolean()
  def is_text_mode?(val) when val in [:net_ascii], do: true
  def is_text_mode?(_val), do: false

  @doc """
  Whether this transfer mode is deprecated.
  """
  @spec is_deprecated?(transfer_mode()) :: boolean()
  def is_deprecated?(val) when val in [:mail], do: true
  def is_deprecated?(_val), do: false

  # ===========================================================================
  # TftpError (tags 0-7)
  # ===========================================================================

  @typedoc """
  TftpError types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type tftp_error ::
          :not_defined
          | :file_not_found
          | :access_violation
          | :disk_full
          | :illegal_operation
          | :unknown_tid
          | :file_exists
          | :no_such_user

  @tftp_error_tags %{
    not_defined: 0,
    file_not_found: 1,
    access_violation: 2,
    disk_full: 3,
    illegal_operation: 4,
    unknown_tid: 5,
    file_exists: 6,
    no_such_user: 7,
  }

  @tag_to_tftp_error Map.new(@tftp_error_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TftpError` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..7, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tftp.tftp_error_from_tag(0)
      {:ok, :not_defined}
  """
  @spec tftp_error_from_tag(non_neg_integer()) :: {:ok, tftp_error()} | :error
  def tftp_error_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_tftp_error, tag)}
  end

  def tftp_error_from_tag(_tag), do: :error

  @doc """
  Encode a `TftpError` to the C-ABI tag value.
  """
  @spec tftp_error_to_tag(tftp_error()) :: non_neg_integer()
  def tftp_error_to_tag(val) when is_map_key(@tftp_error_tags, val) do
    Map.fetch!(@tftp_error_tags, val)
  end

  @doc """
  All `TftpError` variants in tag order.
  """
  @spec all_tftp_errors() :: [tftp_error()]
  def all_tftp_errors do
    [
      :not_defined, :file_not_found, :access_violation, :disk_full, :illegal_operation,
      :unknown_tid, :file_exists, :no_such_user
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this error relates to access control.
  """
  @spec is_access_error?(tftp_error()) :: boolean()
  def is_access_error?(val) when val in [:access_violation, :no_such_user], do: true
  def is_access_error?(_val), do: false

  @doc """
  Whether this error relates to storage capacity.
  """
  @spec is_storage_error?(tftp_error()) :: boolean()
  def is_storage_error?(val) when val in [:disk_full, :file_exists], do: true
  def is_storage_error?(_val), do: false

  # ===========================================================================
  # TransferState (tags 0-4)
  # ===========================================================================

  @typedoc """
  TransferState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transfer_state :: :idle | :reading | :writing | :in_error | :complete

  @transfer_state_tags %{
    idle: 0,
    reading: 1,
    writing: 2,
    in_error: 3,
    complete: 4,
  }

  @tag_to_transfer_state Map.new(@transfer_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransferState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Tftp.transfer_state_from_tag(0)
      {:ok, :idle}
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
  def all_transfer_states, do: [:idle, :reading, :writing, :in_error, :complete]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether a transfer is actively in progress.
  """
  @spec is_active?(transfer_state()) :: boolean()
  def is_active?(val) when val in [:reading, :writing], do: true
  def is_active?(_val), do: false

  @doc """
  Whether the transfer has reached a terminal state.
  """
  @spec is_terminal?(transfer_state()) :: boolean()
  def is_terminal?(val) when val in [:in_error, :complete], do: true
  def is_terminal?(_val), do: false

end
