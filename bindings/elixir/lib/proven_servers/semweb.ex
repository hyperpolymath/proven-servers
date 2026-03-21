# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Semweb do
  @moduledoc """
  Semantic Web types for the proven-servers ABI.
  
  Formally verified Semantic Web types.
  Mirrors the Idris2 module `SemwebABI.Types`.
  
  - `RdfFormat` -- RDF serialization formats.
  - `SemwebResourceType` -- Semantic web resource types.
  - `HttpMethod` -- Semantic web HTTP methods.
  - `ContentNegotiation` -- Content negotiation preferences.
  - `SemwebErrorCode` -- Semantic web error codes.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # RdfFormat (tags 0-5)
  # ===========================================================================

  @typedoc """
  RdfFormat types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type rdf_format :: :rdf_xml | :turtle | :n_triples | :n_quads | :json_ld | :trig

  @rdf_format_tags %{
    rdf_xml: 0,
    turtle: 1,
    n_triples: 2,
    n_quads: 3,
    json_ld: 4,
    trig: 5,
  }

  @tag_to_rdf_format Map.new(@rdf_format_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `RdfFormat` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..5, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Semweb.rdf_format_from_tag(0)
      {:ok, :rdf_xml}
  """
  @spec rdf_format_from_tag(non_neg_integer()) :: {:ok, rdf_format()} | :error
  def rdf_format_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 5 do
    {:ok, Map.fetch!(@tag_to_rdf_format, tag)}
  end

  def rdf_format_from_tag(_tag), do: :error

  @doc """
  Encode a `RdfFormat` to the C-ABI tag value.
  """
  @spec rdf_format_to_tag(rdf_format()) :: non_neg_integer()
  def rdf_format_to_tag(val) when is_map_key(@rdf_format_tags, val) do
    Map.fetch!(@rdf_format_tags, val)
  end

  @doc """
  All `RdfFormat` variants in tag order.
  """
  @spec all_rdf_formats() :: [rdf_format()]
  def all_rdf_formats, do: [:rdf_xml, :turtle, :n_triples, :n_quads, :json_ld, :trig]

  # ===========================================================================
  # SemwebResourceType (tags 0-4)
  # ===========================================================================

  @typedoc """
  SemwebResourceType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type semweb_resource_type :: :class | :property | :individual | :ontology | :named_graph

  @semweb_resource_type_tags %{
    class: 0,
    property: 1,
    individual: 2,
    ontology: 3,
    named_graph: 4,
  }

  @tag_to_semweb_resource_type Map.new(@semweb_resource_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SemwebResourceType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Semweb.semweb_resource_type_from_tag(0)
      {:ok, :class}
  """
  @spec semweb_resource_type_from_tag(non_neg_integer()) :: {:ok, semweb_resource_type()} | :error
  def semweb_resource_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_semweb_resource_type, tag)}
  end

  def semweb_resource_type_from_tag(_tag), do: :error

  @doc """
  Encode a `SemwebResourceType` to the C-ABI tag value.
  """
  @spec semweb_resource_type_to_tag(semweb_resource_type()) :: non_neg_integer()
  def semweb_resource_type_to_tag(val) when is_map_key(@semweb_resource_type_tags, val) do
    Map.fetch!(@semweb_resource_type_tags, val)
  end

  @doc """
  All `SemwebResourceType` variants in tag order.
  """
  @spec all_semweb_resource_types() :: [semweb_resource_type()]
  def all_semweb_resource_types, do: [:class, :property, :individual, :ontology, :named_graph]

  # ===========================================================================
  # HttpMethod (tags 0-4)
  # ===========================================================================

  @typedoc """
  HttpMethod types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type http_method :: :get | :post | :put | :patch | :delete

  @http_method_tags %{
    get: 0,
    post: 1,
    put: 2,
    patch: 3,
    delete: 4,
  }

  @tag_to_http_method Map.new(@http_method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `HttpMethod` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Semweb.http_method_from_tag(0)
      {:ok, :get}
  """
  @spec http_method_from_tag(non_neg_integer()) :: {:ok, http_method()} | :error
  def http_method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_http_method, tag)}
  end

  def http_method_from_tag(_tag), do: :error

  @doc """
  Encode a `HttpMethod` to the C-ABI tag value.
  """
  @spec http_method_to_tag(http_method()) :: non_neg_integer()
  def http_method_to_tag(val) when is_map_key(@http_method_tags, val) do
    Map.fetch!(@http_method_tags, val)
  end

  @doc """
  All `HttpMethod` variants in tag order.
  """
  @spec all_http_methods() :: [http_method()]
  def all_http_methods, do: [:get, :post, :put, :patch, :delete]

  # ===========================================================================
  # ContentNegotiation (tags 0-3)
  # ===========================================================================

  @typedoc """
  ContentNegotiation types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type content_negotiation :: :neg_rdf_xml | :neg_turtle | :neg_json_ld | :neg_html

  @content_negotiation_tags %{
    neg_rdf_xml: 0,
    neg_turtle: 1,
    neg_json_ld: 2,
    neg_html: 3,
  }

  @tag_to_content_negotiation Map.new(@content_negotiation_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ContentNegotiation` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Semweb.content_negotiation_from_tag(0)
      {:ok, :neg_rdf_xml}
  """
  @spec content_negotiation_from_tag(non_neg_integer()) :: {:ok, content_negotiation()} | :error
  def content_negotiation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_content_negotiation, tag)}
  end

  def content_negotiation_from_tag(_tag), do: :error

  @doc """
  Encode a `ContentNegotiation` to the C-ABI tag value.
  """
  @spec content_negotiation_to_tag(content_negotiation()) :: non_neg_integer()
  def content_negotiation_to_tag(val) when is_map_key(@content_negotiation_tags, val) do
    Map.fetch!(@content_negotiation_tags, val)
  end

  @doc """
  All `ContentNegotiation` variants in tag order.
  """
  @spec all_content_negotiations() :: [content_negotiation()]
  def all_content_negotiations, do: [:neg_rdf_xml, :neg_turtle, :neg_json_ld, :neg_html]

  # ===========================================================================
  # SemwebErrorCode (tags 0-4)
  # ===========================================================================

  @typedoc """
  SemwebErrorCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type semweb_error_code ::
          :not_found
          | :invalid_uri
          | :malformed_rdf
          | :unsupported_format
          | :conflicting_triples

  @semweb_error_code_tags %{
    not_found: 0,
    invalid_uri: 1,
    malformed_rdf: 2,
    unsupported_format: 3,
    conflicting_triples: 4,
  }

  @tag_to_semweb_error_code Map.new(@semweb_error_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `SemwebErrorCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Semweb.semweb_error_code_from_tag(0)
      {:ok, :not_found}
  """
  @spec semweb_error_code_from_tag(non_neg_integer()) :: {:ok, semweb_error_code()} | :error
  def semweb_error_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_semweb_error_code, tag)}
  end

  def semweb_error_code_from_tag(_tag), do: :error

  @doc """
  Encode a `SemwebErrorCode` to the C-ABI tag value.
  """
  @spec semweb_error_code_to_tag(semweb_error_code()) :: non_neg_integer()
  def semweb_error_code_to_tag(val) when is_map_key(@semweb_error_code_tags, val) do
    Map.fetch!(@semweb_error_code_tags, val)
  end

  @doc """
  All `SemwebErrorCode` variants in tag order.
  """
  @spec all_semweb_error_codes() :: [semweb_error_code()]
  def all_semweb_error_codes do
    [
      :not_found, :invalid_uri, :malformed_rdf, :unsupported_format,
      :conflicting_triples
    ]
  end

end
