# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.Logcollector do
  @moduledoc """
  Log Collector types for the proven-servers ABI.
  
  Formally verified log collection/pipeline types.
  Mirrors the Idris2 module `LogcollectorABI.Types`.
  
  - `LogLevel` -- Log severity levels.
  - `InputFormat` -- Log input formats.
  - `OutputTarget` -- Log output targets.
  - `FilterOp` -- Log filter operations.
  - `PipelineStage` -- Log pipeline stages.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # LogLevel (tags 0-5)
  # ===========================================================================

  @typedoc """
  LogLevel types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type log_level :: :trace | :debug | :info | :warn | :err | :fatal

  @log_level_tags %{
    trace: 0,
    debug: 1,
    info: 2,
    warn: 3,
    err: 4,
    fatal: 5,
  }

  @tag_to_log_level Map.new(@log_level_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LogLevel` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Logcollector.log_level_from_tag(0)
      {:ok, :trace}
  """
  @spec log_level_from_tag(non_neg_integer()) :: {:ok, log_level()} | :error
  def log_level_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_log_level, tag)}
  end

  def log_level_from_tag(_tag), do: :error

  @doc """
  Encode a `LogLevel` to the C-ABI tag value.
  """
  @spec log_level_to_tag(log_level()) :: non_neg_integer()
  def log_level_to_tag(val) when is_map_key(@log_level_tags, val) do
    Map.fetch!(@log_level_tags, val)
  end

  @doc """
  All `LogLevel` variants in tag order.
  """
  @spec all_log_levels() :: [log_level()]
  def all_log_levels, do: [:trace, :debug, :info, :warn, :err, :fatal]

  # ===========================================================================
  # InputFormat (tags 0-5)
  # ===========================================================================

  @typedoc """
  InputFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type input_format :: :json | :logfmt | :syslog | :cef | :gelf | :raw

  @input_format_tags %{
    json: 0,
    logfmt: 1,
    syslog: 2,
    cef: 3,
    gelf: 4,
    raw: 5,
  }

  @tag_to_input_format Map.new(@input_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `InputFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Logcollector.input_format_from_tag(0)
      {:ok, :json}
  """
  @spec input_format_from_tag(non_neg_integer()) :: {:ok, input_format()} | :error
  def input_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_input_format, tag)}
  end

  def input_format_from_tag(_tag), do: :error

  @doc """
  Encode a `InputFormat` to the C-ABI tag value.
  """
  @spec input_format_to_tag(input_format()) :: non_neg_integer()
  def input_format_to_tag(val) when is_map_key(@input_format_tags, val) do
    Map.fetch!(@input_format_tags, val)
  end

  @doc """
  All `InputFormat` variants in tag order.
  """
  @spec all_input_formats() :: [input_format()]
  def all_input_formats, do: [:json, :logfmt, :syslog, :cef, :gelf, :raw]

  # ===========================================================================
  # OutputTarget (tags 0-4)
  # ===========================================================================

  @typedoc """
  OutputTarget types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type output_target :: :file | :elasticsearch | :s3 | :kafka | :stdout

  @output_target_tags %{
    file: 0,
    elasticsearch: 1,
    s3: 2,
    kafka: 3,
    stdout: 4,
  }

  @tag_to_output_target Map.new(@output_target_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `OutputTarget` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Logcollector.output_target_from_tag(0)
      {:ok, :file}
  """
  @spec output_target_from_tag(non_neg_integer()) :: {:ok, output_target()} | :error
  def output_target_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_output_target, tag)}
  end

  def output_target_from_tag(_tag), do: :error

  @doc """
  Encode a `OutputTarget` to the C-ABI tag value.
  """
  @spec output_target_to_tag(output_target()) :: non_neg_integer()
  def output_target_to_tag(val) when is_map_key(@output_target_tags, val) do
    Map.fetch!(@output_target_tags, val)
  end

  @doc """
  All `OutputTarget` variants in tag order.
  """
  @spec all_output_targets() :: [output_target()]
  def all_output_targets, do: [:file, :elasticsearch, :s3, :kafka, :stdout]

  # ===========================================================================
  # FilterOp (tags 0-4)
  # ===========================================================================

  @typedoc """
  FilterOp types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type filter_op :: :include | :exclude | :transform | :redact | :sample

  @filter_op_tags %{
    include: 0,
    exclude: 1,
    transform: 2,
    redact: 3,
    sample: 4,
  }

  @tag_to_filter_op Map.new(@filter_op_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `FilterOp` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Logcollector.filter_op_from_tag(0)
      {:ok, :include}
  """
  @spec filter_op_from_tag(non_neg_integer()) :: {:ok, filter_op()} | :error
  def filter_op_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_filter_op, tag)}
  end

  def filter_op_from_tag(_tag), do: :error

  @doc """
  Encode a `FilterOp` to the C-ABI tag value.
  """
  @spec filter_op_to_tag(filter_op()) :: non_neg_integer()
  def filter_op_to_tag(val) when is_map_key(@filter_op_tags, val) do
    Map.fetch!(@filter_op_tags, val)
  end

  @doc """
  All `FilterOp` variants in tag order.
  """
  @spec all_filter_ops() :: [filter_op()]
  def all_filter_ops, do: [:include, :exclude, :transform, :redact, :sample]

  # ===========================================================================
  # PipelineStage (tags 0-4)
  # ===========================================================================

  @typedoc """
  PipelineStage types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type pipeline_stage :: :input | :parse | :filter | :pipeline_transform | :output

  @pipeline_stage_tags %{
    input: 0,
    parse: 1,
    filter: 2,
    pipeline_transform: 3,
    output: 4,
  }

  @tag_to_pipeline_stage Map.new(@pipeline_stage_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PipelineStage` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Logcollector.pipeline_stage_from_tag(0)
      {:ok, :input}
  """
  @spec pipeline_stage_from_tag(non_neg_integer()) :: {:ok, pipeline_stage()} | :error
  def pipeline_stage_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_pipeline_stage, tag)}
  end

  def pipeline_stage_from_tag(_tag), do: :error

  @doc """
  Encode a `PipelineStage` to the C-ABI tag value.
  """
  @spec pipeline_stage_to_tag(pipeline_stage()) :: non_neg_integer()
  def pipeline_stage_to_tag(val) when is_map_key(@pipeline_stage_tags, val) do
    Map.fetch!(@pipeline_stage_tags, val)
  end

  @doc """
  All `PipelineStage` variants in tag order.
  """
  @spec all_pipeline_stages() :: [pipeline_stage()]
  def all_pipeline_stages, do: [:input, :parse, :filter, :pipeline_transform, :output]

end
