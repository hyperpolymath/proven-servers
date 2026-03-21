# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Wasm do
  @moduledoc """
  WASM Runtime types for the proven-servers ABI.
  
  Formally verified WebAssembly runtime types.
  Mirrors the Idris2 module `WasmABI.Types`.
  
  - `ValType` -- WebAssembly value types.
  - `ExternKind` -- WebAssembly external kinds.
  - `Mutability` -- WebAssembly global mutability.
  
  All discriminant values match the Idris2 ABI tag definitions exactly.

  All tag values match the Idris2 ABI definitions exactly.
  """

  # ===========================================================================
  # ValType (tags 0-6)
  # ===========================================================================

  @typedoc """
  ValType types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type val_type :: :i32 | :i64 | :f32 | :f64 | :v128 | :func_ref | :extern_ref

  @val_type_tags %{
    i32: 0,
    i64: 1,
    f32: 2,
    f64: 3,
    v128: 4,
    func_ref: 5,
    extern_ref: 6,
  }

  @tag_to_val_type Map.new(@val_type_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ValType` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..6, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Wasm.val_type_from_tag(0)
      {:ok, :i32}
  """
  @spec val_type_from_tag(non_neg_integer()) :: {:ok, val_type()} | :error
  def val_type_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 6 do
    {:ok, Map.fetch!(@tag_to_val_type, tag)}
  end

  def val_type_from_tag(_tag), do: :error

  @doc """
  Encode a `ValType` to the C-ABI tag value.
  """
  @spec val_type_to_tag(val_type()) :: non_neg_integer()
  def val_type_to_tag(val) when is_map_key(@val_type_tags, val) do
    Map.fetch!(@val_type_tags, val)
  end

  @doc """
  All `ValType` variants in tag order.
  """
  @spec all_val_types() :: [val_type()]
  def all_val_types, do: [:i32, :i64, :f32, :f64, :v128, :func_ref, :extern_ref]

  @doc """
  Decode from an ABI tag value.

  Encode to the ABI tag value.

  Whether this is a numeric type.
  """
  @spec is_numeric?(val_type()) :: boolean()
  def is_numeric?(val) when val in [:i32, :i64, :f32, :f64], do: true
  def is_numeric?(_val), do: false

  @doc """
  Whether this is a reference type.
  """
  @spec is_reference?(val_type()) :: boolean()
  def is_reference?(val) when val in [:func_ref, :extern_ref], do: true
  def is_reference?(_val), do: false

  # ===========================================================================
  # ExternKind (tags 0-3)
  # ===========================================================================

  @typedoc """
  ExternKind types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type extern_kind :: :func_extern | :table_extern | :mem_extern | :global_extern

  @extern_kind_tags %{
    func_extern: 0,
    table_extern: 1,
    mem_extern: 2,
    global_extern: 3,
  }

  @tag_to_extern_kind Map.new(@extern_kind_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `ExternKind` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..3, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Wasm.extern_kind_from_tag(0)
      {:ok, :func_extern}
  """
  @spec extern_kind_from_tag(non_neg_integer()) :: {:ok, extern_kind()} | :error
  def extern_kind_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 3 do
    {:ok, Map.fetch!(@tag_to_extern_kind, tag)}
  end

  def extern_kind_from_tag(_tag), do: :error

  @doc """
  Encode a `ExternKind` to the C-ABI tag value.
  """
  @spec extern_kind_to_tag(extern_kind()) :: non_neg_integer()
  def extern_kind_to_tag(val) when is_map_key(@extern_kind_tags, val) do
    Map.fetch!(@extern_kind_tags, val)
  end

  @doc """
  All `ExternKind` variants in tag order.
  """
  @spec all_extern_kinds() :: [extern_kind()]
  def all_extern_kinds, do: [:func_extern, :table_extern, :mem_extern, :global_extern]

  # ===========================================================================
  # Mutability (tags 0-1)
  # ===========================================================================

  @typedoc """
  Mutability types.

  Tag values match the Idris2 ABI definitions exactly.
  """
  @type mutability :: :immutable | :mutable

  @mutability_tags %{
    immutable: 0,
    mutable: 1,
  }

  @tag_to_mutability Map.new(@mutability_tags, fn {k, v} -> {v, k} end)

  @doc """
  Decode a `Mutability` from the C-ABI tag value.

  Returns `{:ok, atom}` for valid tags 0..1, `:error` for invalid.

  ## Examples

      iex> ProvenServers.Wasm.mutability_from_tag(0)
      {:ok, :immutable}
  """
  @spec mutability_from_tag(non_neg_integer()) :: {:ok, mutability()} | :error
  def mutability_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 1 do
    {:ok, Map.fetch!(@tag_to_mutability, tag)}
  end

  def mutability_from_tag(_tag), do: :error

  @doc """
  Encode a `Mutability` to the C-ABI tag value.
  """
  @spec mutability_to_tag(mutability()) :: non_neg_integer()
  def mutability_to_tag(val) when is_map_key(@mutability_tags, val) do
    Map.fetch!(@mutability_tags, val)
  end

  @doc """
  All `Mutability` variants in tag order.
  """
  @spec all_mutabilitys() :: [mutability()]
  def all_mutabilitys, do: [:immutable, :mutable]

end
