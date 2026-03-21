# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Airgap do
  @moduledoc """
  Air Gap types for the proven-servers ABI.
  
  Formally verified air-gapped transfer types.
  Mirrors the Idris2 module `AirgapABI.Types`.
  
  - `TransferDirection` -- Air gap transfer direction.
  - `MediaType` -- Physical transfer media types.
  - `ScanResult` -- Content scan results.
  - `TransferState` -- Air gap transfer lifecycle.
  - `ValidationCheck` -- Validation check types.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # TransferDirection (tags 0-1)
  # ===========================================================================

  @typedoc """
  TransferDirection types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transfer_direction :: :import | :export

  @transfer_direction_tags %{
    import: 0,
    export: 1,
  }

  @tag_to_transfer_direction Map.new(@transfer_direction_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransferDirection` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Airgap.transfer_direction_from_tag(0)
      {:ok, :import}
  """
  @spec transfer_direction_from_tag(non_neg_integer()) :: {:ok, transfer_direction()} | :error
  def transfer_direction_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_transfer_direction, tag)}
  end

  def transfer_direction_from_tag(_tag), do: :error

  @doc """
  Encode a `TransferDirection` to the C-ABI tag value.
  """
  @spec transfer_direction_to_tag(transfer_direction()) :: non_neg_integer()
  def transfer_direction_to_tag(val) when is_map_key(@transfer_direction_tags, val) do
    Map.fetch!(@transfer_direction_tags, val)
  end

  @doc """
  All `TransferDirection` variants in tag order.
  """
  @spec all_transfer_directions() :: [transfer_direction()]
  def all_transfer_directions, do: [:import, :export]

  # ===========================================================================
  # MediaType (tags 0-3)
  # ===========================================================================

  @typedoc """
  MediaType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type media_type :: :usb | :optical_disc | :tape_cartridge | :diode_link

  @media_type_tags %{
    usb: 0,
    optical_disc: 1,
    tape_cartridge: 2,
    diode_link: 3,
  }

  @tag_to_media_type Map.new(@media_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `MediaType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Airgap.media_type_from_tag(0)
      {:ok, :usb}
  """
  @spec media_type_from_tag(non_neg_integer()) :: {:ok, media_type()} | :error
  def media_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_media_type, tag)}
  end

  def media_type_from_tag(_tag), do: :error

  @doc """
  Encode a `MediaType` to the C-ABI tag value.
  """
  @spec media_type_to_tag(media_type()) :: non_neg_integer()
  def media_type_to_tag(val) when is_map_key(@media_type_tags, val) do
    Map.fetch!(@media_type_tags, val)
  end

  @doc """
  All `MediaType` variants in tag order.
  """
  @spec all_media_types() :: [media_type()]
  def all_media_types, do: [:usb, :optical_disc, :tape_cartridge, :diode_link]

  # ===========================================================================
  # ScanResult (tags 0-3)
  # ===========================================================================

  @typedoc """
  ScanResult types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type scan_result :: :clean | :suspicious | :malicious | :unscannable

  @scan_result_tags %{
    clean: 0,
    suspicious: 1,
    malicious: 2,
    unscannable: 3,
  }

  @tag_to_scan_result Map.new(@scan_result_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ScanResult` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Airgap.scan_result_from_tag(0)
      {:ok, :clean}
  """
  @spec scan_result_from_tag(non_neg_integer()) :: {:ok, scan_result()} | :error
  def scan_result_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_scan_result, tag)}
  end

  def scan_result_from_tag(_tag), do: :error

  @doc """
  Encode a `ScanResult` to the C-ABI tag value.
  """
  @spec scan_result_to_tag(scan_result()) :: non_neg_integer()
  def scan_result_to_tag(val) when is_map_key(@scan_result_tags, val) do
    Map.fetch!(@scan_result_tags, val)
  end

  @doc """
  All `ScanResult` variants in tag order.
  """
  @spec all_scan_results() :: [scan_result()]
  def all_scan_results, do: [:clean, :suspicious, :malicious, :unscannable]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether the content is safe to transfer.
  """
  @spec is_safe?(scan_result()) :: boolean()
  def is_safe?(val) when val in [:clean], do: true
  def is_safe?(_val), do: false

  # ===========================================================================
  # TransferState (tags 0-6)
  # ===========================================================================

  @typedoc """
  TransferState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type transfer_state ::
          :pending
          | :scanning
          | :approved
          | :rejected
          | :in_progress
          | :complete
          | :failed

  @transfer_state_tags %{
    pending: 0,
    scanning: 1,
    approved: 2,
    rejected: 3,
    in_progress: 4,
    complete: 5,
    failed: 6,
  }

  @tag_to_transfer_state Map.new(@transfer_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `TransferState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Airgap.transfer_state_from_tag(0)
      {:ok, :pending}
  """
  @spec transfer_state_from_tag(non_neg_integer()) :: {:ok, transfer_state()} | :error
  def transfer_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
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
  def all_transfer_states do
    [
      :pending, :scanning, :approved, :rejected, :in_progress, :complete,
      :failed
    ]
  end

  # ===========================================================================
  # ValidationCheck (tags 0-4)
  # ===========================================================================

  @typedoc """
  ValidationCheck types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type validation_check ::
          :hash_verify
          | :signature_verify
          | :format_check
          | :content_inspection
          | :malware_scan

  @validation_check_tags %{
    hash_verify: 0,
    signature_verify: 1,
    format_check: 2,
    content_inspection: 3,
    malware_scan: 4,
  }

  @tag_to_validation_check Map.new(@validation_check_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ValidationCheck` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Airgap.validation_check_from_tag(0)
      {:ok, :hash_verify}
  """
  @spec validation_check_from_tag(non_neg_integer()) :: {:ok, validation_check()} | :error
  def validation_check_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_validation_check, tag)}
  end

  def validation_check_from_tag(_tag), do: :error

  @doc """
  Encode a `ValidationCheck` to the C-ABI tag value.
  """
  @spec validation_check_to_tag(validation_check()) :: non_neg_integer()
  def validation_check_to_tag(val) when is_map_key(@validation_check_tags, val) do
    Map.fetch!(@validation_check_tags, val)
  end

  @doc """
  All `ValidationCheck` variants in tag order.
  """
  @spec all_validation_checks() :: [validation_check()]
  def all_validation_checks do
    [
      :hash_verify, :signature_verify, :format_check, :content_inspection,
      :malware_scan
    ]
  end

end
