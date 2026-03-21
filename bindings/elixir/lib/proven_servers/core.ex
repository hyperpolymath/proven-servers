# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Core do
  @moduledoc """
  Core ABI types shared across all proven-servers protocols.

  Mirrors the definitions in `src/abi/Types.idr` and `src/abi/Layout.idr`.
  These types form the foundation that every protocol module builds upon.

  ## Result Codes

  The `result_code` type represents FFI operation outcomes. Tag values
  (0..4) match the `resultToInt` function in the Idris2 ABI exactly.

  ## Platform

  The `platform` type identifies compilation targets for ABI layout
  selection. Pointer widths and `size_t` sizes are platform-dependent.

  ## Handle

  Opaque, non-zero handles to library-managed resources. Mirrors the
  Idris2 `Handle` type which uses a `So (ptr /= 0)` proof to enforce
  non-nullity at the type level.

  ## Alignment Utilities

  `padding_for/2` and `align_up/2` mirror the Idris2 `Layout` module's
  alignment calculation functions.
  """

  # ---------------------------------------------------------------------------
  # Result Codes (mirrors ProvenServers.ABI.Types.Result)
  # ---------------------------------------------------------------------------

  @typedoc """
  FFI operation result codes.

  Matches the `Result` type in `src/abi/Types.idr` with identical
  discriminant values from `resultToInt`.

    * `:ok` — Operation succeeded (tag 0)
    * `:error` — Generic error (tag 1)
    * `:invalid_param` — Invalid parameter provided (tag 2)
    * `:out_of_memory` — Out of memory (tag 3)
    * `:null_pointer` — Null pointer encountered (tag 4)
  """
  @type result_code :: :ok | :error | :invalid_param | :out_of_memory | :null_pointer

  @result_code_tags %{
    ok: 0,
    error: 1,
    invalid_param: 2,
    out_of_memory: 3,
    null_pointer: 4
  }

  @tag_to_result_code Map.new(@result_code_tags, fn {k, v} -> {v, k} end)

  @doc """
  Convert a raw `u8` tag to a result code atom.

  Returns `{:ok, atom}` for valid tags 0..4, `:error` for invalid tags.
  Matches the Idris2 partial decoder pattern.

  ## Examples

      iex> ProvenServers.Core.result_code_from_tag(0)
      {:ok, :ok}

      iex> ProvenServers.Core.result_code_from_tag(2)
      {:ok, :invalid_param}

      iex> ProvenServers.Core.result_code_from_tag(99)
      :error
  """
  @spec result_code_from_tag(non_neg_integer()) :: {:ok, result_code()} | :error
  def result_code_from_tag(tag) when is_integer(tag) and tag >= 0 and tag <= 4 do
    {:ok, Map.fetch!(@tag_to_result_code, tag)}
  end

  def result_code_from_tag(_tag), do: :error

  @doc """
  Convert a result code atom to its C-compatible `u8` tag value.

  ## Examples

      iex> ProvenServers.Core.result_code_to_tag(:ok)
      0

      iex> ProvenServers.Core.result_code_to_tag(:null_pointer)
      4
  """
  @spec result_code_to_tag(result_code()) :: non_neg_integer()
  def result_code_to_tag(code) when is_map_key(@result_code_tags, code) do
    Map.fetch!(@result_code_tags, code)
  end

  @doc """
  Whether a result code represents success.

  ## Examples

      iex> ProvenServers.Core.result_ok?(:ok)
      true

      iex> ProvenServers.Core.result_ok?(:error)
      false
  """
  @spec result_ok?(result_code()) :: boolean()
  def result_ok?(:ok), do: true
  def result_ok?(_code), do: false

  @doc """
  Whether a result code represents any kind of error.

  ## Examples

      iex> ProvenServers.Core.result_error?(:error)
      true

      iex> ProvenServers.Core.result_error?(:ok)
      false
  """
  @spec result_error?(result_code()) :: boolean()
  def result_error?(:ok), do: false
  def result_error?(_code), do: true

  @doc """
  Human-readable error description, matching `errorDescription` in
  `src/abi/Foreign.idr`.

  ## Examples

      iex> ProvenServers.Core.result_description(:ok)
      "Success"

      iex> ProvenServers.Core.result_description(:null_pointer)
      "Null pointer"
  """
  @spec result_description(result_code()) :: String.t()
  def result_description(:ok), do: "Success"
  def result_description(:error), do: "Generic error"
  def result_description(:invalid_param), do: "Invalid parameter"
  def result_description(:out_of_memory), do: "Out of memory"
  def result_description(:null_pointer), do: "Null pointer"

  @doc """
  All valid result codes in tag order.
  """
  @spec all_result_codes() :: [result_code()]
  def all_result_codes, do: [:ok, :error, :invalid_param, :out_of_memory, :null_pointer]

  # ---------------------------------------------------------------------------
  # Platform (mirrors ProvenServers.ABI.Types.Platform)
  # ---------------------------------------------------------------------------

  @typedoc """
  Supported target platforms for ABI layout selection.

  Matches the `Platform` data type in `src/abi/Types.idr`.

    * `:linux` — Linux (64-bit pointers, 64-bit size_t)
    * `:windows` — Windows (64-bit pointers, 64-bit size_t)
    * `:macos` — macOS (64-bit pointers, 64-bit size_t)
    * `:bsd` — BSD variants (64-bit pointers, 64-bit size_t)
    * `:wasm` — WebAssembly (32-bit pointers, 32-bit size_t)
  """
  @type platform :: :linux | :windows | :macos | :bsd | :wasm

  @doc """
  Pointer size in bits for the given platform.

  Matches the `ptrSize` function in `src/abi/Types.idr`.

  ## Examples

      iex> ProvenServers.Core.ptr_size_bits(:linux)
      64

      iex> ProvenServers.Core.ptr_size_bits(:wasm)
      32
  """
  @spec ptr_size_bits(platform()) :: 32 | 64
  def ptr_size_bits(:wasm), do: 32
  def ptr_size_bits(platform) when platform in [:linux, :windows, :macos, :bsd], do: 64

  @doc """
  Pointer size in bytes for the given platform.

  ## Examples

      iex> ProvenServers.Core.ptr_size_bytes(:linux)
      8

      iex> ProvenServers.Core.ptr_size_bytes(:wasm)
      4
  """
  @spec ptr_size_bytes(platform()) :: 4 | 8
  def ptr_size_bytes(platform), do: div(ptr_size_bits(platform), 8)

  @doc """
  Detect the current runtime platform.

  Mirrors `thisPlatform` from `src/abi/Types.idr`. Since the BEAM runs
  on multiple platforms, this uses `:os.type/0` for detection.
  """
  @spec current_platform() :: platform()
  def current_platform do
    case :os.type() do
      {:unix, :linux} -> :linux
      {:unix, :darwin} -> :macos
      {:unix, :freebsd} -> :bsd
      {:unix, :openbsd} -> :bsd
      {:unix, :netbsd} -> :bsd
      {:win32, _} -> :windows
      _ -> :linux
    end
  end

  # ---------------------------------------------------------------------------
  # Handle (mirrors ProvenServers.ABI.Types.Handle)
  # ---------------------------------------------------------------------------

  @typedoc """
  Opaque, non-zero handle to a library-managed resource.

  Mirrors the Idris2 `Handle` type which uses a `So (ptr /= 0)` proof
  to enforce non-nullity. Represented as a positive integer.
  """
  @type handle :: pos_integer()

  @doc """
  Create a handle from a raw pointer value.

  Returns `{:ok, handle}` for non-zero values, `:error` for zero.
  Matches `createHandle` in `src/abi/Types.idr`.

  ## Examples

      iex> ProvenServers.Core.new_handle(42)
      {:ok, 42}

      iex> ProvenServers.Core.new_handle(0)
      :error
  """
  @spec new_handle(non_neg_integer()) :: {:ok, handle()} | :error
  def new_handle(ptr) when is_integer(ptr) and ptr > 0, do: {:ok, ptr}
  def new_handle(0), do: :error

  # ---------------------------------------------------------------------------
  # Alignment Utilities (mirrors ProvenServers.ABI.Layout)
  # ---------------------------------------------------------------------------

  @doc """
  Calculate padding needed to reach the next alignment boundary.

  Mirrors `paddingFor` in `src/abi/Layout.idr`.

  ## Examples

      iex> ProvenServers.Core.padding_for(0, 8)
      0

      iex> ProvenServers.Core.padding_for(4, 8)
      4

      iex> ProvenServers.Core.padding_for(1, 4)
      3
  """
  @spec padding_for(non_neg_integer(), pos_integer()) :: non_neg_integer()
  def padding_for(_offset, 0), do: 0

  def padding_for(offset, alignment)
      when is_integer(offset) and is_integer(alignment) and offset >= 0 and alignment > 0 do
    remainder = rem(offset, alignment)
    if remainder == 0, do: 0, else: alignment - remainder
  end

  @doc """
  Round `size` up to the next multiple of `alignment`.

  Mirrors `alignUp` in `src/abi/Layout.idr`.

  ## Examples

      iex> ProvenServers.Core.align_up(4, 8)
      8

      iex> ProvenServers.Core.align_up(8, 8)
      8

      iex> ProvenServers.Core.align_up(9, 8)
      16
  """
  @spec align_up(non_neg_integer(), pos_integer()) :: non_neg_integer()
  def align_up(size, alignment)
      when is_integer(size) and is_integer(alignment) and size >= 0 and alignment > 0 do
    size + padding_for(size, alignment)
  end
end
