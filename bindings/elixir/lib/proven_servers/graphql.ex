# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Graphql do
  @moduledoc """
  GraphQL protocol types for the proven-servers ABI.

  Mirrors the Idris2 module `GraphQL.Types` which defines:

    * `operation_type` — query, mutation, subscription
    * `type_kind` — introspection `__TypeKind` values
    * `directive_location` — executable and type system locations
    * `error_category` — structured error classification
  """

  # ===========================================================================
  # Operation Type (GraphQL.Types.OperationType)
  # ===========================================================================

  @typedoc """
  GraphQL root operation types.

  Matches `OperationType` in `GraphQL.Types`.
  """
  @type operation_type :: :query | :mutation | :subscription

  @operation_tags %{query: 0, mutation: 1, subscription: 2}
  @tag_to_operation Map.new(@operation_tags, fn {k, v} -> {v, k} end)

  @operation_strings %{query: "query", mutation: "mutation", subscription: "subscription"}

  @doc """
  Decode from a tag value.

  ## Examples

      iex> ProvenServers.Graphql.operation_from_tag(0)
      {:ok, :query}
  """
  @spec operation_from_tag(non_neg_integer()) :: {:ok, operation_type()} | :error
  def operation_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_operation, tag)}
  end

  def operation_from_tag(_tag), do: :error

  @doc """
  Encode to a tag value.
  """
  @spec operation_to_tag(operation_type()) :: non_neg_integer()
  def operation_to_tag(op) when is_map_key(@operation_tags, op) do
    Map.fetch!(@operation_tags, op)
  end

  @doc """
  GraphQL keyword for this operation type.

  ## Examples

      iex> ProvenServers.Graphql.operation_to_string(:query)
      "query"
  """
  @spec operation_to_string(operation_type()) :: String.t()
  def operation_to_string(op) when is_map_key(@operation_strings, op) do
    Map.fetch!(@operation_strings, op)
  end

  # ===========================================================================
  # Type Kind (GraphQL.Types.TypeKind)
  # ===========================================================================

  @typedoc """
  GraphQL type system kinds (introspection `__TypeKind`).

  Matches `TypeKind` in `GraphQL.Types`.
  """
  @type type_kind ::
          :scalar | :object | :interface | :union | :enum | :input_object | :list | :non_null

  @type_kind_tags %{
    scalar: 0,
    object: 1,
    interface: 2,
    union: 3,
    enum: 4,
    input_object: 5,
    list: 6,
    non_null: 7
  }

  @tag_to_type_kind Map.new(@type_kind_tags, fn {k, v} -> {v, k} end)

  @type_kind_names %{
    scalar: "SCALAR",
    object: "OBJECT",
    interface: "INTERFACE",
    union: "UNION",
    enum: "ENUM",
    input_object: "INPUT_OBJECT",
    list: "LIST",
    non_null: "NON_NULL"
  }

  @doc """
  Decode from a tag value.

  ## Examples

      iex> ProvenServers.Graphql.type_kind_from_tag(1)
      {:ok, :object}
  """
  @spec type_kind_from_tag(non_neg_integer()) :: {:ok, type_kind()} | :error
  def type_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 7 do
    {:ok, Map.fetch!(@tag_to_type_kind, tag)}
  end

  def type_kind_from_tag(_tag), do: :error

  @doc """
  Encode to a tag value.
  """
  @spec type_kind_to_tag(type_kind()) :: non_neg_integer()
  def type_kind_to_tag(tk) when is_map_key(@type_kind_tags, tk) do
    Map.fetch!(@type_kind_tags, tk)
  end

  @doc """
  Introspection name string (e.g. `"SCALAR"`, `"OBJECT"`).

  Matches the `Show` instance in `GraphQL.Types`.

  ## Examples

      iex> ProvenServers.Graphql.type_kind_introspection_name(:scalar)
      "SCALAR"

      iex> ProvenServers.Graphql.type_kind_introspection_name(:input_object)
      "INPUT_OBJECT"
  """
  @spec type_kind_introspection_name(type_kind()) :: String.t()
  def type_kind_introspection_name(tk) when is_map_key(@type_kind_names, tk) do
    Map.fetch!(@type_kind_names, tk)
  end

  @doc """
  Whether this is a wrapper type (List or NonNull).

  ## Examples

      iex> ProvenServers.Graphql.type_kind_wrapper?(:list)
      true

      iex> ProvenServers.Graphql.type_kind_wrapper?(:scalar)
      false
  """
  @spec type_kind_wrapper?(type_kind()) :: boolean()
  def type_kind_wrapper?(tk) when tk in [:list, :non_null], do: true
  def type_kind_wrapper?(_tk), do: false

  @doc """
  Whether this is a composite type (Object, Interface, or Union).

  ## Examples

      iex> ProvenServers.Graphql.type_kind_composite?(:object)
      true

      iex> ProvenServers.Graphql.type_kind_composite?(:enum)
      false
  """
  @spec type_kind_composite?(type_kind()) :: boolean()
  def type_kind_composite?(tk) when tk in [:object, :interface, :union], do: true
  def type_kind_composite?(_tk), do: false

  # ===========================================================================
  # Directive Location (GraphQL.Types.DirectiveLocation)
  # ===========================================================================

  @typedoc """
  GraphQL directive locations (executable and type system).

  Matches `DirectiveLocation` in `GraphQL.Types`.
  """
  @type directive_location ::
          :query
          | :mutation
          | :subscription
          | :field
          | :fragment_definition
          | :fragment_spread
          | :inline_fragment
          | :schema
          | :scalar
          | :object
          | :field_definition
          | :argument_definition
          | :interface
          | :union
          | :enum
          | :enum_value
          | :input_object
          | :input_field_definition

  @directive_location_tags %{
    query: 0,
    mutation: 1,
    subscription: 2,
    field: 3,
    fragment_definition: 4,
    fragment_spread: 5,
    inline_fragment: 6,
    schema: 7,
    scalar: 8,
    object: 9,
    field_definition: 10,
    argument_definition: 11,
    interface: 12,
    union: 13,
    enum: 14,
    enum_value: 15,
    input_object: 16,
    input_field_definition: 17
  }

  @tag_to_directive_location Map.new(@directive_location_tags, fn {k, v} -> {v, k} end)

  @directive_location_names %{
    query: "QUERY",
    mutation: "MUTATION",
    subscription: "SUBSCRIPTION",
    field: "FIELD",
    fragment_definition: "FRAGMENT_DEFINITION",
    fragment_spread: "FRAGMENT_SPREAD",
    inline_fragment: "INLINE_FRAGMENT",
    schema: "SCHEMA",
    scalar: "SCALAR",
    object: "OBJECT",
    field_definition: "FIELD_DEFINITION",
    argument_definition: "ARGUMENT_DEFINITION",
    interface: "INTERFACE",
    union: "UNION",
    enum: "ENUM",
    enum_value: "ENUM_VALUE",
    input_object: "INPUT_OBJECT",
    input_field_definition: "INPUT_FIELD_DEFINITION"
  }

  @doc """
  Decode from a tag value.

  ## Examples

      iex> ProvenServers.Graphql.directive_location_from_tag(3)
      {:ok, :field}
  """
  @spec directive_location_from_tag(non_neg_integer()) :: {:ok, directive_location()} | :error
  def directive_location_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 17 do
    {:ok, Map.fetch!(@tag_to_directive_location, tag)}
  end

  def directive_location_from_tag(_tag), do: :error

  @doc """
  Encode to a tag value.
  """
  @spec directive_location_to_tag(directive_location()) :: non_neg_integer()
  def directive_location_to_tag(loc) when is_map_key(@directive_location_tags, loc) do
    Map.fetch!(@directive_location_tags, loc)
  end

  @doc """
  GraphQL spec name for the directive location.

  ## Examples

      iex> ProvenServers.Graphql.directive_location_name(:field_definition)
      "FIELD_DEFINITION"
  """
  @spec directive_location_name(directive_location()) :: String.t()
  def directive_location_name(loc) when is_map_key(@directive_location_names, loc) do
    Map.fetch!(@directive_location_names, loc)
  end

  @doc """
  Whether this is an executable location (query/mutation/subscription/field/fragment).

  ## Examples

      iex> ProvenServers.Graphql.directive_location_executable?(:query)
      true

      iex> ProvenServers.Graphql.directive_location_executable?(:schema)
      false
  """
  @spec directive_location_executable?(directive_location()) :: boolean()
  def directive_location_executable?(loc) when is_map_key(@directive_location_tags, loc) do
    Map.fetch!(@directive_location_tags, loc) <= 6
  end

  @doc """
  Whether this is a type system location.
  """
  @spec directive_location_type_system?(directive_location()) :: boolean()
  def directive_location_type_system?(loc), do: not directive_location_executable?(loc)

  # ===========================================================================
  # Error Category (GraphQL.Types.ErrorCategory)
  # ===========================================================================

  @typedoc """
  GraphQL error categories for structured error reporting.

  Matches `ErrorCategory` in `GraphQL.Types`.
  """
  @type error_category ::
          :parse_error | :validation_error | :execution_error | :auth_error | :rate_limited

  @error_category_tags %{
    parse_error: 0,
    validation_error: 1,
    execution_error: 2,
    auth_error: 3,
    rate_limited: 4
  }

  @tag_to_error_category Map.new(@error_category_tags, fn {k, v} -> {v, k} end)

  @error_category_codes %{
    parse_error: "PARSE_ERROR",
    validation_error: "VALIDATION_ERROR",
    execution_error: "EXECUTION_ERROR",
    auth_error: "AUTH_ERROR",
    rate_limited: "RATE_LIMITED"
  }

  @doc """
  Decode from a tag value.

  ## Examples

      iex> ProvenServers.Graphql.error_category_from_tag(0)
      {:ok, :parse_error}
  """
  @spec error_category_from_tag(non_neg_integer()) :: {:ok, error_category()} | :error
  def error_category_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_error_category, tag)}
  end

  def error_category_from_tag(_tag), do: :error

  @doc """
  Encode to a tag value.
  """
  @spec error_category_to_tag(error_category()) :: non_neg_integer()
  def error_category_to_tag(ec) when is_map_key(@error_category_tags, ec) do
    Map.fetch!(@error_category_tags, ec)
  end

  @doc """
  GraphQL extensions code string.

  Matches the `Show` instance in `GraphQL.Types`.

  ## Examples

      iex> ProvenServers.Graphql.error_category_code(:parse_error)
      "PARSE_ERROR"
  """
  @spec error_category_code(error_category()) :: String.t()
  def error_category_code(ec) when is_map_key(@error_category_codes, ec) do
    Map.fetch!(@error_category_codes, ec)
  end
end
