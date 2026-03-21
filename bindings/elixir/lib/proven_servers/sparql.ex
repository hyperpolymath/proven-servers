# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Sparql do
  @moduledoc """
  SPARQL types for the proven-servers ABI.
  
  Formally verified SPARQL endpoint types.
  Mirrors the Idris2 module `SparqlABI.Types`.
  
  - `SparqlQueryType` -- SPARQL query types.
  - `UpdateType` -- SPARQL update types.
  - `ResultFormat` -- SPARQL result formats.
  - `SparqlErrorType` -- SPARQL error types.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # SparqlQueryType (tags 0-3)
  # ===========================================================================

  @typedoc """
  SparqlQueryType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type sparql_query_type :: :select | :construct | :ask | :describe

  @sparql_query_type_tags %{
    select: 0,
    construct: 1,
    ask: 2,
    describe: 3,
  }

  @tag_to_sparql_query_type Map.new(@sparql_query_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SparqlQueryType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sparql.sparql_query_type_from_tag(0)
      {:ok, :select}
  """
  @spec sparql_query_type_from_tag(non_neg_integer()) :: {:ok, sparql_query_type()} | :error
  def sparql_query_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_sparql_query_type, tag)}
  end

  def sparql_query_type_from_tag(_tag), do: :error

  @doc """
  Encode a `SparqlQueryType` to the C-ABI tag value.
  """
  @spec sparql_query_type_to_tag(sparql_query_type()) :: non_neg_integer()
  def sparql_query_type_to_tag(val) when is_map_key(@sparql_query_type_tags, val) do
    Map.fetch!(@sparql_query_type_tags, val)
  end

  @doc """
  All `SparqlQueryType` variants in tag order.
  """
  @spec all_sparql_query_types() :: [sparql_query_type()]
  def all_sparql_query_types, do: [:select, :construct, :ask, :describe]

  # ===========================================================================
  # UpdateType (tags 0-5)
  # ===========================================================================

  @typedoc """
  UpdateType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type update_type :: :insert | :delete | :load | :clear | :create | :drop

  @update_type_tags %{
    insert: 0,
    delete: 1,
    load: 2,
    clear: 3,
    create: 4,
    drop: 5,
  }

  @tag_to_update_type Map.new(@update_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `UpdateType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sparql.update_type_from_tag(0)
      {:ok, :insert}
  """
  @spec update_type_from_tag(non_neg_integer()) :: {:ok, update_type()} | :error
  def update_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_update_type, tag)}
  end

  def update_type_from_tag(_tag), do: :error

  @doc """
  Encode a `UpdateType` to the C-ABI tag value.
  """
  @spec update_type_to_tag(update_type()) :: non_neg_integer()
  def update_type_to_tag(val) when is_map_key(@update_type_tags, val) do
    Map.fetch!(@update_type_tags, val)
  end

  @doc """
  All `UpdateType` variants in tag order.
  """
  @spec all_update_types() :: [update_type()]
  def all_update_types, do: [:insert, :delete, :load, :clear, :create, :drop]

  # ===========================================================================
  # ResultFormat (tags 0-3)
  # ===========================================================================

  @typedoc """
  ResultFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type result_format :: :xml | :json | :csv | :tsv

  @result_format_tags %{
    xml: 0,
    json: 1,
    csv: 2,
    tsv: 3,
  }

  @tag_to_result_format Map.new(@result_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ResultFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sparql.result_format_from_tag(0)
      {:ok, :xml}
  """
  @spec result_format_from_tag(non_neg_integer()) :: {:ok, result_format()} | :error
  def result_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_result_format, tag)}
  end

  def result_format_from_tag(_tag), do: :error

  @doc """
  Encode a `ResultFormat` to the C-ABI tag value.
  """
  @spec result_format_to_tag(result_format()) :: non_neg_integer()
  def result_format_to_tag(val) when is_map_key(@result_format_tags, val) do
    Map.fetch!(@result_format_tags, val)
  end

  @doc """
  All `ResultFormat` variants in tag order.
  """
  @spec all_result_formats() :: [result_format()]
  def all_result_formats, do: [:xml, :json, :csv, :tsv]

  # ===========================================================================
  # SparqlErrorType (tags 0-4)
  # ===========================================================================

  @typedoc """
  SparqlErrorType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type sparql_error_type ::
          :parse_error
          | :query_timeout
          | :results_too_large
          | :unknown_graph
          | :access_denied

  @sparql_error_type_tags %{
    parse_error: 0,
    query_timeout: 1,
    results_too_large: 2,
    unknown_graph: 3,
    access_denied: 4,
  }

  @tag_to_sparql_error_type Map.new(@sparql_error_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SparqlErrorType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Sparql.sparql_error_type_from_tag(0)
      {:ok, :parse_error}
  """
  @spec sparql_error_type_from_tag(non_neg_integer()) :: {:ok, sparql_error_type()} | :error
  def sparql_error_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_sparql_error_type, tag)}
  end

  def sparql_error_type_from_tag(_tag), do: :error

  @doc """
  Encode a `SparqlErrorType` to the C-ABI tag value.
  """
  @spec sparql_error_type_to_tag(sparql_error_type()) :: non_neg_integer()
  def sparql_error_type_to_tag(val) when is_map_key(@sparql_error_type_tags, val) do
    Map.fetch!(@sparql_error_type_tags, val)
  end

  @doc """
  All `SparqlErrorType` variants in tag order.
  """
  @spec all_sparql_error_types() :: [sparql_error_type()]
  def all_sparql_error_types do
    [
      :parse_error, :query_timeout, :results_too_large, :unknown_graph,
      :access_denied
    ]
  end

end
