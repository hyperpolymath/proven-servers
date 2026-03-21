# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Webdav do
  @moduledoc """
  WebDAV protocol types for the proven-servers ABI.
  
  Mirrors the Idris2 module `WebDAVABI.Types` and its type definitions:
  - `Method`     — WebDAV HTTP extension methods (7 constructors, tags 0-6)
  - `StatusCode` — WebDAV-specific HTTP status codes (5 constructors, tags 0-4)
  - `LockScope`  — Lock scope types (2 constructors, tags 0-1)
  - `LockType`   — Lock types (1 constructor, tag 0)
  - `Depth`      — Request depth header values (3 constructors, tags 0-2)
  - `PropertyOp` — PROPPATCH operations (2 constructors, tags 0-1)
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  @doc "WebDAV uses standard HTTP/HTTPS ports."
  @spec webdav_default_port() :: non_neg_integer()
  def webdav_default_port, do: 80

  @doc "WebDAV over TLS uses standard HTTPS port."
  @spec webdav_tls_port() :: non_neg_integer()
  def webdav_tls_port, do: 443

  # ===========================================================================
  # Method (tags 0-6)
  # ===========================================================================

  @typedoc """
  Method types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type method :: :propfind | :proppatch | :mkcol | :copy | :move | :lock | :unlock

  @method_tags %{
    propfind: 0,
    proppatch: 1,
    mkcol: 2,
    copy: 3,
    move: 4,
    lock: 5,
    unlock: 6,
  }

  @tag_to_method Map.new(@method_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Method` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Webdav.method_from_tag(0)
      {:ok, :propfind}
  """
  @spec method_from_tag(non_neg_integer()) :: {:ok, method()} | :error
  def method_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_method, tag)}
  end

  def method_from_tag(_tag), do: :error

  @doc """
  Encode a `Method` to the C-ABI tag value.
  """
  @spec method_to_tag(method()) :: non_neg_integer()
  def method_to_tag(val) when is_map_key(@method_tags, val) do
    Map.fetch!(@method_tags, val)
  end

  @doc """
  All `Method` variants in tag order.
  """
  @spec all_methods() :: [method()]
  def all_methods, do: [:propfind, :proppatch, :mkcol, :copy, :move, :lock, :unlock]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  The HTTP method name string.
        match self {

  Whether this method modifies server state.
  """
  @spec is_write?(method()) :: boolean()
  def is_write?(val) when val in [:proppatch, :mkcol, :copy, :move], do: true
  def is_write?(_val), do: false

  @doc """
  Whether this method relates to locking.
  """
  @spec is_lock_related?(method()) :: boolean()
  def is_lock_related?(val) when val in [:lock, :unlock], do: true
  def is_lock_related?(_val), do: false

  # ===========================================================================
  # StatusCode (tags 0-4)
  # ===========================================================================

  @typedoc """
  StatusCode types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type status_code ::
          :multi_status
          | :unprocessable_entity
          | :locked
          | :failed_dependency
          | :insufficient_storage

  @status_code_tags %{
    multi_status: 0,
    unprocessable_entity: 1,
    locked: 2,
    failed_dependency: 3,
    insufficient_storage: 4,
  }

  @tag_to_status_code Map.new(@status_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `StatusCode` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Webdav.status_code_from_tag(0)
      {:ok, :multi_status}
  """
  @spec status_code_from_tag(non_neg_integer()) :: {:ok, status_code()} | :error
  def status_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_status_code, tag)}
  end

  def status_code_from_tag(_tag), do: :error

  @doc """
  Encode a `StatusCode` to the C-ABI tag value.
  """
  @spec status_code_to_tag(status_code()) :: non_neg_integer()
  def status_code_to_tag(val) when is_map_key(@status_code_tags, val) do
    Map.fetch!(@status_code_tags, val)
  end

  @doc """
  All `StatusCode` variants in tag order.
  """
  @spec all_status_codes() :: [status_code()]
  def all_status_codes do
    [
      :multi_status, :unprocessable_entity, :locked, :failed_dependency,
      :insufficient_storage
    ]
  end

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this status is an error (4xx or 5xx).
  """
  @spec is_error?(status_code()) :: boolean()
  def is_error?(val) when val in [:multi_status], do: false
  def is_error?(_val), do: true

  # ===========================================================================
  # LockScope (tags 0-1)
  # ===========================================================================

  @typedoc """
  LockScope types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lock_scope :: :exclusive | :shared

  @lock_scope_tags %{
    exclusive: 0,
    shared: 1,
  }

  @tag_to_lock_scope Map.new(@lock_scope_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LockScope` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Webdav.lock_scope_from_tag(0)
      {:ok, :exclusive}
  """
  @spec lock_scope_from_tag(non_neg_integer()) :: {:ok, lock_scope()} | :error
  def lock_scope_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_lock_scope, tag)}
  end

  def lock_scope_from_tag(_tag), do: :error

  @doc """
  Encode a `LockScope` to the C-ABI tag value.
  """
  @spec lock_scope_to_tag(lock_scope()) :: non_neg_integer()
  def lock_scope_to_tag(val) when is_map_key(@lock_scope_tags, val) do
    Map.fetch!(@lock_scope_tags, val)
  end

  @doc """
  All `LockScope` variants in tag order.
  """
  @spec all_lock_scopes() :: [lock_scope()]
  def all_lock_scopes, do: [:exclusive, :shared]

  # ===========================================================================
  # LockType (tags 0-0)
  # ===========================================================================

  @typedoc """
  LockType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type lock_type :: :write

  @lock_type_tags %{
    write: 0,
  }

  @tag_to_lock_type Map.new(@lock_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `LockType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..0, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Webdav.lock_type_from_tag(0)
      {:ok, :write}
  """
  @spec lock_type_from_tag(non_neg_integer()) :: {:ok, lock_type()} | :error
  def lock_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 0 do
    {:ok, Map.fetch!(@tag_to_lock_type, tag)}
  end

  def lock_type_from_tag(_tag), do: :error

  @doc """
  Encode a `LockType` to the C-ABI tag value.
  """
  @spec lock_type_to_tag(lock_type()) :: non_neg_integer()
  def lock_type_to_tag(val) when is_map_key(@lock_type_tags, val) do
    Map.fetch!(@lock_type_tags, val)
  end

  @doc """
  All `LockType` variants in tag order.
  """
  @spec all_lock_types() :: [lock_type()]
  def all_lock_types, do: [:write]

  # ===========================================================================
  # Depth (tags 0-2)
  # ===========================================================================

  @typedoc """
  Depth types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type depth :: :zero | :one | :infinity

  @depth_tags %{
    zero: 0,
    one: 1,
    infinity: 2,
  }

  @tag_to_depth Map.new(@depth_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Depth` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..2, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Webdav.depth_from_tag(0)
      {:ok, :zero}
  """
  @spec depth_from_tag(non_neg_integer()) :: {:ok, depth()} | :error
  def depth_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 2 do
    {:ok, Map.fetch!(@tag_to_depth, tag)}
  end

  def depth_from_tag(_tag), do: :error

  @doc """
  Encode a `Depth` to the C-ABI tag value.
  """
  @spec depth_to_tag(depth()) :: non_neg_integer()
  def depth_to_tag(val) when is_map_key(@depth_tags, val) do
    Map.fetch!(@depth_tags, val)
  end

  @doc """
  All `Depth` variants in tag order.
  """
  @spec all_depths() :: [depth()]
  def all_depths, do: [:zero, :one, :infinity]

  # ===========================================================================
  # PropertyOp (tags 0-1)
  # ===========================================================================

  @typedoc """
  PropertyOp types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type property_op :: :set | :remove

  @property_op_tags %{
    set: 0,
    remove: 1,
  }

  @tag_to_property_op Map.new(@property_op_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `PropertyOp` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Webdav.property_op_from_tag(0)
      {:ok, :set}
  """
  @spec property_op_from_tag(non_neg_integer()) :: {:ok, property_op()} | :error
  def property_op_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_property_op, tag)}
  end

  def property_op_from_tag(_tag), do: :error

  @doc """
  Encode a `PropertyOp` to the C-ABI tag value.
  """
  @spec property_op_to_tag(property_op()) :: non_neg_integer()
  def property_op_to_tag(val) when is_map_key(@property_op_tags, val) do
    Map.fetch!(@property_op_tags, val)
  end

  @doc """
  All `PropertyOp` variants in tag order.
  """
  @spec all_property_ops() :: [property_op()]
  def all_property_ops, do: [:set, :remove]

end
