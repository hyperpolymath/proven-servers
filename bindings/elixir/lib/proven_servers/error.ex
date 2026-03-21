# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Error do
  @moduledoc """
  Shared error types for the proven-servers Elixir bindings.

  Provides a unified error structure that aggregates protocol-specific
  error conditions alongside the core result codes from
  `ProvenServers.Core`. All proven-servers FFI calls return
  `{:ok, result} | {:error, proven_error()}` so that callers get a
  single, exhaustive error surface to match against.
  """

  # ===========================================================================
  # Protocol identifier
  # ===========================================================================

  @typedoc """
  Identifies the protocol that produced an error.
  """
  @type protocol ::
          :httpd
          | :dns
          | :smtp
          | :ftp
          | :ssh_bastion
          | :mqtt
          | :grpc
          | :graphql
          | :tls
          | :firewall
          | :websocket
          | {:other, String.t()}

  @protocol_names %{
    httpd: "httpd",
    dns: "dns",
    smtp: "smtp",
    ftp: "ftp",
    ssh_bastion: "ssh-bastion",
    mqtt: "mqtt",
    grpc: "grpc",
    graphql: "graphql",
    tls: "tls",
    firewall: "firewall",
    websocket: "websocket"
  }

  @doc """
  Human-readable protocol name.

  ## Examples

      iex> ProvenServers.Error.protocol_name(:httpd)
      "httpd"

      iex> ProvenServers.Error.protocol_name({:other, "custom"})
      "custom"
  """
  @spec protocol_name(protocol()) :: String.t()
  def protocol_name({:other, name}) when is_binary(name), do: name

  def protocol_name(protocol) when is_map_key(@protocol_names, protocol) do
    Map.fetch!(@protocol_names, protocol)
  end

  # ===========================================================================
  # Unified error type
  # ===========================================================================

  @typedoc """
  Unified error type for all proven-servers FFI calls.

  Variants cover:
    * `{:ffi_error, result_code, message}` -- FFI returned a non-OK result code
    * `{:handle_error, message}` -- null or uninitialised library handle
    * `{:decode_error, protocol, type_name, raw_tag}` -- unknown C-ABI tag value
    * `{:transition_error, protocol, from_state, to_state}` -- rejected state machine transition
    * `{:init_error, message}` -- library initialisation failure
    * `{:unsupported_error, message}` -- unsupported operation/platform
    * `{:unknown_error, message}` -- catch-all for unexpected FFI errors
  """
  @type proven_error ::
          {:ffi_error, ProvenServers.Core.result_code(), String.t()}
          | {:handle_error, String.t()}
          | {:decode_error, protocol(), String.t(), non_neg_integer()}
          | {:transition_error, protocol(), String.t(), String.t()}
          | {:init_error, String.t()}
          | {:unsupported_error, String.t()}
          | {:unknown_error, String.t()}

  # ===========================================================================
  # Constructors
  # ===========================================================================

  @doc """
  Build an FFI error from a result code.

  ## Examples

      iex> ProvenServers.Error.from_result_code(:error)
      {:ffi_error, :error, "Generic error"}
  """
  @spec from_result_code(ProvenServers.Core.result_code()) :: proven_error()
  def from_result_code(code) do
    {:ffi_error, code, ProvenServers.Core.result_description(code)}
  end

  @doc """
  Build a decode error for an unknown tag.

  ## Examples

      iex> ProvenServers.Error.unknown_tag(:httpd, "Method", 99)
      {:decode_error, :httpd, "Method", 99}
  """
  @spec unknown_tag(protocol(), String.t(), non_neg_integer()) :: proven_error()
  def unknown_tag(protocol, type_name, raw_tag) do
    {:decode_error, protocol, type_name, raw_tag}
  end

  @doc """
  Build a transition error.

  ## Examples

      iex> ProvenServers.Error.invalid_transition(:smtp, "Connected", "Data")
      {:transition_error, :smtp, "Connected", "Data"}
  """
  @spec invalid_transition(protocol(), String.t(), String.t()) :: proven_error()
  def invalid_transition(protocol, from_state, to_state) do
    {:transition_error, protocol, from_state, to_state}
  end

  # ===========================================================================
  # Classification
  # ===========================================================================

  @doc """
  Whether this error is recoverable (transient FFI errors, decode mismatches).

  ## Examples

      iex> ProvenServers.Error.recoverable?({:ffi_error, :error, "Generic error"})
      true

      iex> ProvenServers.Error.recoverable?({:init_error, "failed"})
      false
  """
  @spec recoverable?(proven_error()) :: boolean()
  def recoverable?({:ffi_error, :error, _}), do: true
  def recoverable?({:decode_error, _, _, _}), do: true
  def recoverable?({:transition_error, _, _, _}), do: true
  def recoverable?(_error), do: false

  @doc """
  Human-readable error description suitable for logging.

  ## Examples

      iex> ProvenServers.Error.describe({:handle_error, "null pointer"})
      "Handle error: null pointer"
  """
  @spec describe(proven_error()) :: String.t()
  def describe({:ffi_error, code, message}) do
    tag = ProvenServers.Core.result_code_to_tag(code)
    "FFI error (code #{tag}): #{message}"
  end

  def describe({:handle_error, message}), do: "Handle error: #{message}"

  def describe({:decode_error, protocol, type_name, raw_tag}) do
    "Decode error in #{protocol_name(protocol)}: unknown #{type_name} tag #{raw_tag}"
  end

  def describe({:transition_error, protocol, from_state, to_state}) do
    "Invalid transition in #{protocol_name(protocol)}: #{from_state} -> #{to_state}"
  end

  def describe({:init_error, message}), do: "Initialisation error: #{message}"
  def describe({:unsupported_error, message}), do: "Unsupported: #{message}"
  def describe({:unknown_error, message}), do: "Unknown error: #{message}"
end
