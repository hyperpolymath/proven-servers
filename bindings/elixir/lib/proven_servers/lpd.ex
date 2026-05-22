# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Lpd do
  @moduledoc """
  LPD types for the proven-servers ABI.
  
  Formally verified LPD (Line Printer Daemon, RFC 1179) types.
  Mirrors the Idris2 module `LpdABI.Types`.
  
  - `CommandCode` -- LPD command codes (RFC 1179).
  - `SubCommandCode` -- LPD sub-command codes.
  - `JobStatus` -- Print job status.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "Standard LPD port."
  @spec lpd_port() :: non_neg_integer()
  def lpd_port, do: 515

  # ===========================================================================
  # CommandCode (tags 0-5)
  # ===========================================================================

  @typedoc """
  CommandCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type command_code :: :print_job | :receive_job | :short_queue | :long_queue | :remove_jobs

  @command_code_tags %{
    print_job: 1,
    receive_job: 2,
    short_queue: 3,
    long_queue: 4,
    remove_jobs: 5,
  }

  @tag_to_command_code Map.new(@command_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `CommandCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Lpd.command_code_from_tag(0)
      {:ok, :print_job}
  """
  @spec command_code_from_tag(non_neg_integer()) :: {:ok, command_code()} | :error
  def command_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_command_code, tag)}
  end

  def command_code_from_tag(_tag), do: :error

  @doc """
  Encode a `CommandCode` to the C-ABI tag value.
  """
  @spec command_code_to_tag(command_code()) :: non_neg_integer()
  def command_code_to_tag(val) when is_map_key(@command_code_tags, val) do
    Map.fetch!(@command_code_tags, val)
  end

  @doc """
  All `CommandCode` variants in tag order.
  """
  @spec all_command_codes() :: [command_code()]
  def all_command_codes, do: [:print_job, :receive_job, :short_queue, :long_queue, :remove_jobs]

  # ===========================================================================
  # SubCommandCode (tags 0-3)
  # ===========================================================================

  @typedoc """
  SubCommandCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type sub_command_code :: :abort_job | :control_file | :data_file

  @sub_command_code_tags %{
    abort_job: 1,
    control_file: 2,
    data_file: 3,
  }

  @tag_to_sub_command_code Map.new(@sub_command_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SubCommandCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Lpd.sub_command_code_from_tag(0)
      {:ok, :abort_job}
  """
  @spec sub_command_code_from_tag(non_neg_integer()) :: {:ok, sub_command_code()} | :error
  def sub_command_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_sub_command_code, tag)}
  end

  def sub_command_code_from_tag(_tag), do: :error

  @doc """
  Encode a `SubCommandCode` to the C-ABI tag value.
  """
  @spec sub_command_code_to_tag(sub_command_code()) :: non_neg_integer()
  def sub_command_code_to_tag(val) when is_map_key(@sub_command_code_tags, val) do
    Map.fetch!(@sub_command_code_tags, val)
  end

  @doc """
  All `SubCommandCode` variants in tag order.
  """
  @spec all_sub_command_codes() :: [sub_command_code()]
  def all_sub_command_codes, do: [:abort_job, :control_file, :data_file]

  # ===========================================================================
  # JobStatus (tags 0-3)
  # ===========================================================================

  @typedoc """
  JobStatus types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type job_status :: :pending | :printing | :complete | :failed

  @job_status_tags %{
    pending: 0,
    printing: 1,
    complete: 2,
    failed: 3,
  }

  @tag_to_job_status Map.new(@job_status_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `JobStatus` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Lpd.job_status_from_tag(0)
      {:ok, :pending}
  """
  @spec job_status_from_tag(non_neg_integer()) :: {:ok, job_status()} | :error
  def job_status_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_job_status, tag)}
  end

  def job_status_from_tag(_tag), do: :error

  @doc """
  Encode a `JobStatus` to the C-ABI tag value.
  """
  @spec job_status_to_tag(job_status()) :: non_neg_integer()
  def job_status_to_tag(val) when is_map_key(@job_status_tags, val) do
    Map.fetch!(@job_status_tags, val)
  end

  @doc """
  All `JobStatus` variants in tag order.
  """
  @spec all_job_statuss() :: [job_status()]
  def all_job_statuss, do: [:pending, :printing, :complete, :failed]

end
