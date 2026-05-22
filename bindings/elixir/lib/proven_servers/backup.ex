# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Backup do
  @moduledoc """
  Backup Server types for the proven-servers ABI.
  
  Formally verified backup/restore types.
  Mirrors the Idris2 module `BackupABI.Types`.
  
  - `BackupType` -- Backup types.
  - `ScheduleFreq` -- Backup schedule frequencies.
  - `CompressionAlg` -- Backup compression algorithms.
  - `EncryptionAlg` -- Backup encryption algorithms.
  - `BackupState` -- Backup job states.
  - `RetentionPolicy` -- Backup retention policies.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # BackupType (tags 0-4)
  # ===========================================================================

  @typedoc """
  BackupType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type backup_type :: :full | :incremental | :differential | :snapshot | :mirror

  @backup_type_tags %{
    full: 0,
    incremental: 1,
    differential: 2,
    snapshot: 3,
    mirror: 4,
  }

  @tag_to_backup_type Map.new(@backup_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BackupType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Backup.backup_type_from_tag(0)
      {:ok, :full}
  """
  @spec backup_type_from_tag(non_neg_integer()) :: {:ok, backup_type()} | :error
  def backup_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_backup_type, tag)}
  end

  def backup_type_from_tag(_tag), do: :error

  @doc """
  Encode a `BackupType` to the C-ABI tag value.
  """
  @spec backup_type_to_tag(backup_type()) :: non_neg_integer()
  def backup_type_to_tag(val) when is_map_key(@backup_type_tags, val) do
    Map.fetch!(@backup_type_tags, val)
  end

  @doc """
  All `BackupType` variants in tag order.
  """
  @spec all_backup_types() :: [backup_type()]
  def all_backup_types, do: [:full, :incremental, :differential, :snapshot, :mirror]

  # ===========================================================================
  # ScheduleFreq (tags 0-4)
  # ===========================================================================

  @typedoc """
  ScheduleFreq types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type schedule_freq :: :hourly | :daily | :weekly | :monthly | :on_demand

  @schedule_freq_tags %{
    hourly: 0,
    daily: 1,
    weekly: 2,
    monthly: 3,
    on_demand: 4,
  }

  @tag_to_schedule_freq Map.new(@schedule_freq_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ScheduleFreq` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Backup.schedule_freq_from_tag(0)
      {:ok, :hourly}
  """
  @spec schedule_freq_from_tag(non_neg_integer()) :: {:ok, schedule_freq()} | :error
  def schedule_freq_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_schedule_freq, tag)}
  end

  def schedule_freq_from_tag(_tag), do: :error

  @doc """
  Encode a `ScheduleFreq` to the C-ABI tag value.
  """
  @spec schedule_freq_to_tag(schedule_freq()) :: non_neg_integer()
  def schedule_freq_to_tag(val) when is_map_key(@schedule_freq_tags, val) do
    Map.fetch!(@schedule_freq_tags, val)
  end

  @doc """
  All `ScheduleFreq` variants in tag order.
  """
  @spec all_schedule_freqs() :: [schedule_freq()]
  def all_schedule_freqs, do: [:hourly, :daily, :weekly, :monthly, :on_demand]

  # ===========================================================================
  # CompressionAlg (tags 0-4)
  # ===========================================================================

  @typedoc """
  CompressionAlg types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type compression_alg :: :none | :gzip | :zstd | :lz4 | :xz

  @compression_alg_tags %{
    none: 0,
    gzip: 1,
    zstd: 2,
    lz4: 3,
    xz: 4,
  }

  @tag_to_compression_alg Map.new(@compression_alg_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CompressionAlg` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Backup.compression_alg_from_tag(0)
      {:ok, :none}
  """
  @spec compression_alg_from_tag(non_neg_integer()) :: {:ok, compression_alg()} | :error
  def compression_alg_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_compression_alg, tag)}
  end

  def compression_alg_from_tag(_tag), do: :error

  @doc """
  Encode a `CompressionAlg` to the C-ABI tag value.
  """
  @spec compression_alg_to_tag(compression_alg()) :: non_neg_integer()
  def compression_alg_to_tag(val) when is_map_key(@compression_alg_tags, val) do
    Map.fetch!(@compression_alg_tags, val)
  end

  @doc """
  All `CompressionAlg` variants in tag order.
  """
  @spec all_compression_algs() :: [compression_alg()]
  def all_compression_algs, do: [:none, :gzip, :zstd, :lz4, :xz]

  # ===========================================================================
  # EncryptionAlg (tags 0-2)
  # ===========================================================================

  @typedoc """
  EncryptionAlg types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type encryption_alg :: :no_encryption | :aes256_gcm | :cha_cha20_poly1305

  @encryption_alg_tags %{
    no_encryption: 0,
    aes256_gcm: 1,
    cha_cha20_poly1305: 2,
  }

  @tag_to_encryption_alg Map.new(@encryption_alg_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `EncryptionAlg` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Backup.encryption_alg_from_tag(0)
      {:ok, :no_encryption}
  """
  @spec encryption_alg_from_tag(non_neg_integer()) :: {:ok, encryption_alg()} | :error
  def encryption_alg_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_encryption_alg, tag)}
  end

  def encryption_alg_from_tag(_tag), do: :error

  @doc """
  Encode a `EncryptionAlg` to the C-ABI tag value.
  """
  @spec encryption_alg_to_tag(encryption_alg()) :: non_neg_integer()
  def encryption_alg_to_tag(val) when is_map_key(@encryption_alg_tags, val) do
    Map.fetch!(@encryption_alg_tags, val)
  end

  @doc """
  All `EncryptionAlg` variants in tag order.
  """
  @spec all_encryption_algs() :: [encryption_alg()]
  def all_encryption_algs, do: [:no_encryption, :aes256_gcm, :cha_cha20_poly1305]

  # ===========================================================================
  # BackupState (tags 0-5)
  # ===========================================================================

  @typedoc """
  BackupState types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type backup_state :: :idle | :running | :verifying | :complete | :failed | :cancelled

  @backup_state_tags %{
    idle: 0,
    running: 1,
    verifying: 2,
    complete: 3,
    failed: 4,
    cancelled: 5,
  }

  @tag_to_backup_state Map.new(@backup_state_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `BackupState` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Backup.backup_state_from_tag(0)
      {:ok, :idle}
  """
  @spec backup_state_from_tag(non_neg_integer()) :: {:ok, backup_state()} | :error
  def backup_state_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_backup_state, tag)}
  end

  def backup_state_from_tag(_tag), do: :error

  @doc """
  Encode a `BackupState` to the C-ABI tag value.
  """
  @spec backup_state_to_tag(backup_state()) :: non_neg_integer()
  def backup_state_to_tag(val) when is_map_key(@backup_state_tags, val) do
    Map.fetch!(@backup_state_tags, val)
  end

  @doc """
  All `BackupState` variants in tag order.
  """
  @spec all_backup_states() :: [backup_state()]
  def all_backup_states, do: [:idle, :running, :verifying, :complete, :failed, :cancelled]

  # ===========================================================================
  # RetentionPolicy (tags 0-4)
  # ===========================================================================

  @typedoc """
  RetentionPolicy types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type retention_policy :: :keep_all | :keep_last | :keep_daily | :keep_weekly | :keep_monthly

  @retention_policy_tags %{
    keep_all: 0,
    keep_last: 1,
    keep_daily: 2,
    keep_weekly: 3,
    keep_monthly: 4,
  }

  @tag_to_retention_policy Map.new(@retention_policy_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RetentionPolicy` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Backup.retention_policy_from_tag(0)
      {:ok, :keep_all}
  """
  @spec retention_policy_from_tag(non_neg_integer()) :: {:ok, retention_policy()} | :error
  def retention_policy_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_retention_policy, tag)}
  end

  def retention_policy_from_tag(_tag), do: :error

  @doc """
  Encode a `RetentionPolicy` to the C-ABI tag value.
  """
  @spec retention_policy_to_tag(retention_policy()) :: non_neg_integer()
  def retention_policy_to_tag(val) when is_map_key(@retention_policy_tags, val) do
    Map.fetch!(@retention_policy_tags, val)
  end

  @doc """
  All `RetentionPolicy` variants in tag order.
  """
  @spec all_retention_policys() :: [retention_policy()]
  def all_retention_policys, do: [:keep_all, :keep_last, :keep_daily, :keep_weekly, :keep_monthly]

end
