# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.Websocket do
  @moduledoc """
  WebSocket protocol types for the proven-servers ABI.

  Mirrors the Idris2 modules:

    * `WS.Opcode` — frame opcodes (RFC 6455 Section 5.2)
    * `WS.CloseCode` — close status codes (RFC 6455 Section 7.4)
    * `WS.Frame` — frame structure and validation

  All numeric encodings match the wire values from RFC 6455.

  ## Frame Validation

  The `validate_client_frame/2` and `validate_server_frame/2` functions
  enforce RFC 6455 constraints:

    * Client frames MUST be masked
    * Server frames MUST NOT be masked
    * Control frames MUST NOT be fragmented
    * Control frames MUST NOT exceed 125 bytes payload
  """

  # ===========================================================================
  # Opcode (WS.Opcode, RFC 6455 Section 5.2)
  # ===========================================================================

  @typedoc """
  WebSocket frame opcodes (RFC 6455 Section 11.8).

  Matches the `Opcode` type in `WS.Opcode`.
  Values are the 4-bit wire values from the spec.
  """
  @type opcode :: :continuation | :text | :binary | :close | :ping | :pong

  @opcode_nibbles %{
    continuation: 0x0,
    text: 0x1,
    binary: 0x2,
    close: 0x8,
    ping: 0x9,
    pong: 0xA
  }

  @nibble_to_opcode Map.new(@opcode_nibbles, fn {k, v} -> {v, k} end)

  @opcode_names %{
    continuation: "continuation",
    text: "text",
    binary: "binary",
    close: "close",
    ping: "ping",
    pong: "pong"
  }

  @doc """
  Parse a 4-bit nibble to an opcode.

  Returns `:error` for reserved opcodes (0x3-0x7, 0xB-0xF),
  matching `opcodeFromNibble` in `WS.Opcode`.

  ## Examples

      iex> ProvenServers.Websocket.opcode_from_nibble(0x1)
      {:ok, :text}

      iex> ProvenServers.Websocket.opcode_from_nibble(0x3)
      :error
  """
  @spec opcode_from_nibble(non_neg_integer()) :: {:ok, opcode()} | :error
  def opcode_from_nibble(nibble) when is_integer(nibble) do
    case Map.fetch(@nibble_to_opcode, nibble) do
      {:ok, _opcode} = result -> result
      :error -> :error
    end
  end

  @doc """
  Convert to the 4-bit wire value.

  Matches `opcodeToNibble` in `WS.Opcode`.

  ## Examples

      iex> ProvenServers.Websocket.opcode_to_nibble(:text)
      0x1
  """
  @spec opcode_to_nibble(opcode()) :: non_neg_integer()
  def opcode_to_nibble(opcode) when is_map_key(@opcode_nibbles, opcode) do
    Map.fetch!(@opcode_nibbles, opcode)
  end

  @doc """
  Whether this is a data opcode (Continuation, Text, Binary).

  Data opcodes carry application payload and can be fragmented.
  Matches `isData` in `WS.Opcode`.

  ## Examples

      iex> ProvenServers.Websocket.opcode_data?(:text)
      true

      iex> ProvenServers.Websocket.opcode_data?(:close)
      false
  """
  @spec opcode_data?(opcode()) :: boolean()
  def opcode_data?(op) when op in [:continuation, :text, :binary], do: true
  def opcode_data?(_op), do: false

  @doc """
  Whether this is a control opcode (Close, Ping, Pong).

  Control frames MUST NOT be fragmented and MUST have a payload
  length of 125 bytes or less (RFC 6455 Section 5.5).
  Matches `isControl` in `WS.Opcode`.

  ## Examples

      iex> ProvenServers.Websocket.opcode_control?(:ping)
      true

      iex> ProvenServers.Websocket.opcode_control?(:text)
      false
  """
  @spec opcode_control?(opcode()) :: boolean()
  def opcode_control?(op), do: not opcode_data?(op)

  @doc """
  Whether this opcode begins a new message (Text or Binary).

  Matches `isMessageStart` in `WS.Opcode`.
  """
  @spec opcode_message_start?(opcode()) :: boolean()
  def opcode_message_start?(op) when op in [:text, :binary], do: true
  def opcode_message_start?(_op), do: false

  @doc """
  Whether this opcode requires a mandatory response.

  Ping frames MUST be responded to with Pong.
  Close frames MUST be responded to with Close.
  Matches `requiresResponse` in `WS.Opcode`.
  """
  @spec opcode_requires_response?(opcode()) :: boolean()
  def opcode_requires_response?(op) when op in [:ping, :close], do: true
  def opcode_requires_response?(_op), do: false

  @doc """
  Human-readable name for the opcode.

  Matches `opcodeName` in `WS.Opcode`.
  """
  @spec opcode_name(opcode()) :: String.t()
  def opcode_name(op) when is_map_key(@opcode_names, op) do
    Map.fetch!(@opcode_names, op)
  end

  # ===========================================================================
  # Close Code (WS.CloseCode, RFC 6455 Section 7.4)
  # ===========================================================================

  @typedoc """
  WebSocket close status codes (RFC 6455 Section 7.4.1).

  Matches the `CloseCode` type in `WS.CloseCode`.
  """
  @type close_code ::
          :normal
          | :going_away
          | :protocol_error
          | :unsupported_data
          | :no_status
          | :abnormal
          | :invalid_payload
          | :policy_violation
          | :message_too_big
          | :mandatory_extension
          | :internal_error

  @close_code_wires %{
    normal: 1000,
    going_away: 1001,
    protocol_error: 1002,
    unsupported_data: 1003,
    no_status: 1005,
    abnormal: 1006,
    invalid_payload: 1007,
    policy_violation: 1008,
    message_too_big: 1009,
    mandatory_extension: 1010,
    internal_error: 1011
  }

  @wire_to_close_code Map.new(@close_code_wires, fn {k, v} -> {v, k} end)

  @close_code_reasons %{
    normal: "Normal closure",
    going_away: "Endpoint going away",
    protocol_error: "Protocol error",
    unsupported_data: "Unsupported data type",
    no_status: "No status code present",
    abnormal: "Abnormal closure (no close frame)",
    invalid_payload: "Invalid payload data",
    policy_violation: "Policy violation",
    message_too_big: "Message too big",
    mandatory_extension: "Mandatory extension missing",
    internal_error: "Internal server error"
  }

  @doc """
  Parse a 16-bit wire value to a close code.

  Returns `:error` for unrecognised codes, matching
  `closeCodeFromWord` in `WS.CloseCode`.

  ## Examples

      iex> ProvenServers.Websocket.close_code_from_wire(1000)
      {:ok, :normal}

      iex> ProvenServers.Websocket.close_code_from_wire(1004)
      :error
  """
  @spec close_code_from_wire(non_neg_integer()) :: {:ok, close_code()} | :error
  def close_code_from_wire(wire) when is_integer(wire) do
    case Map.fetch(@wire_to_close_code, wire) do
      {:ok, _code} = result -> result
      :error -> :error
    end
  end

  @doc """
  Convert to the 16-bit wire value.

  Matches `closeCodeToWord` in `WS.CloseCode`.

  ## Examples

      iex> ProvenServers.Websocket.close_code_to_wire(:normal)
      1000
  """
  @spec close_code_to_wire(close_code()) :: non_neg_integer()
  def close_code_to_wire(code) when is_map_key(@close_code_wires, code) do
    Map.fetch!(@close_code_wires, code)
  end

  @doc """
  Whether this represents a normal (clean) closure.

  Matches `isNormalClose` in `WS.CloseCode`.

  ## Examples

      iex> ProvenServers.Websocket.close_code_normal?(:normal)
      true

      iex> ProvenServers.Websocket.close_code_normal?(:protocol_error)
      false
  """
  @spec close_code_normal?(close_code()) :: boolean()
  def close_code_normal?(code) when code in [:normal, :going_away], do: true
  def close_code_normal?(_code), do: false

  @doc """
  Whether this represents an error condition.

  Matches `isErrorClose` in `WS.CloseCode`.
  """
  @spec close_code_error?(close_code()) :: boolean()
  def close_code_error?(:normal), do: false
  def close_code_error?(:going_away), do: false
  def close_code_error?(:no_status), do: false
  def close_code_error?(_code), do: true

  @doc """
  Whether this code may be sent in a Close frame.

  Codes 1005 (NoStatus) and 1006 (Abnormal) are internal-only
  and MUST NOT appear on the wire.
  Matches `isSendable` in `WS.CloseCode`.

  ## Examples

      iex> ProvenServers.Websocket.close_code_sendable?(:normal)
      true

      iex> ProvenServers.Websocket.close_code_sendable?(:no_status)
      false
  """
  @spec close_code_sendable?(close_code()) :: boolean()
  def close_code_sendable?(code) when code in [:no_status, :abnormal], do: false
  def close_code_sendable?(_code), do: true

  @doc """
  Human-readable description.

  Matches `closeReason` in `WS.CloseCode`.
  """
  @spec close_code_reason(close_code()) :: String.t()
  def close_code_reason(code) when is_map_key(@close_code_reasons, code) do
    Map.fetch!(@close_code_reasons, code)
  end

  @doc """
  Check if a raw 16-bit value is in the application-use range
  (4000-4999, RFC 6455 Section 7.4.2).

  Matches `isApplicationCode` in `WS.CloseCode`.

  ## Examples

      iex> ProvenServers.Websocket.application_code?(4000)
      true

      iex> ProvenServers.Websocket.application_code?(3999)
      false
  """
  @spec application_code?(non_neg_integer()) :: boolean()
  def application_code?(code) when is_integer(code) and code >= 4000 and code <= 4999, do: true
  def application_code?(_code), do: false

  @doc """
  Check if a raw 16-bit value is in the private-use range
  (3000-3999, reserved for libraries/frameworks).

  Matches `isPrivateCode` in `WS.CloseCode`.
  """
  @spec private_code?(non_neg_integer()) :: boolean()
  def private_code?(code) when is_integer(code) and code >= 3000 and code <= 3999, do: true
  def private_code?(_code), do: false

  # ===========================================================================
  # Frame (WS.Frame)
  # ===========================================================================

  # Maximum payload size for control frames (RFC 6455 Section 5.5).
  # Matches `maxControlPayload` in `WS.Frame`.
  @max_control_payload 125

  @doc """
  Maximum payload size for control frames (125 bytes).
  """
  @spec max_control_payload() :: non_neg_integer()
  def max_control_payload, do: @max_control_payload

  @typedoc """
  A parsed WebSocket frame with all header fields and payload.

  Mirrors the `Frame` record in `WS.Frame`.

    * `:fin` — true if this is the final fragment of a message
    * `:opcode` — frame type opcode
    * `:masked` — true if payload is XOR-masked (required from clients)
    * `:payload_length` — declared payload length in bytes
    * `:masking_key` — 4-byte masking key (present only if masked)
    * `:payload` — payload data (unmasked)
  """
  @type frame :: %{
          fin: boolean(),
          opcode: opcode(),
          masked: boolean(),
          payload_length: non_neg_integer(),
          masking_key: binary() | nil,
          payload: binary()
        }

  @typedoc """
  Errors detected during frame validation.

  Matches the `FrameError` type in `WS.Frame`.
  """
  @type frame_error ::
          {:control_frame_too_large, opcode(), non_neg_integer()}
          | {:control_frame_fragmented, opcode()}
          | :client_frame_not_masked
          | :server_frame_masked
          | {:payload_too_large, non_neg_integer(), non_neg_integer()}
          | {:reserved_opcode, non_neg_integer()}
          | {:payload_length_mismatch, non_neg_integer(), non_neg_integer()}

  @doc """
  Validate a frame received from a client.

  Checks: masking required, control frame size and fragmentation,
  payload length consistency.
  Matches `validateClientFrame` in `WS.Frame`.

  ## Parameters

    * `frame` — the frame map to validate
    * `max_frame_size` — maximum allowed payload size

  ## Returns

    * `:ok` if the frame is valid
    * `{:error, frame_error}` describing the validation failure
  """
  @spec validate_client_frame(frame(), non_neg_integer()) :: :ok | {:error, frame_error()}
  def validate_client_frame(%{masked: false}, _max_frame_size) do
    {:error, :client_frame_not_masked}
  end

  def validate_client_frame(frame, max_frame_size) do
    validate_common(frame, max_frame_size)
  end

  @doc """
  Validate a frame received from a server.

  Server frames MUST NOT be masked (RFC 6455 Section 5.1).
  Matches `validateServerFrame` in `WS.Frame`.
  """
  @spec validate_server_frame(frame(), non_neg_integer()) :: :ok | {:error, frame_error()}
  def validate_server_frame(%{masked: true}, _max_frame_size) do
    {:error, :server_frame_masked}
  end

  def validate_server_frame(frame, max_frame_size) do
    validate_common(frame, max_frame_size)
  end

  @doc false
  @spec validate_common(frame(), non_neg_integer()) :: :ok | {:error, frame_error()}
  defp validate_common(frame, max_frame_size) do
    cond do
      opcode_control?(frame.opcode) and frame.payload_length > @max_control_payload ->
        {:error, {:control_frame_too_large, frame.opcode, frame.payload_length}}

      opcode_control?(frame.opcode) and not frame.fin ->
        {:error, {:control_frame_fragmented, frame.opcode}}

      frame.payload_length > max_frame_size ->
        {:error, {:payload_too_large, frame.payload_length, max_frame_size}}

      frame.payload_length != byte_size(frame.payload) ->
        {:error,
         {:payload_length_mismatch, frame.payload_length, byte_size(frame.payload)}}

      true ->
        :ok
    end
  end

  @doc """
  Build a server-to-client text frame (unmasked, FIN set).

  Matches `makeTextFrame` in `WS.Frame`.

  ## Examples

      iex> frame = ProvenServers.Websocket.text_frame("hello")
      iex> frame.opcode
      :text
      iex> frame.fin
      true
  """
  @spec text_frame(binary()) :: frame()
  def text_frame(payload) when is_binary(payload) do
    %{
      fin: true,
      opcode: :text,
      masked: false,
      payload_length: byte_size(payload),
      masking_key: nil,
      payload: payload
    }
  end

  @doc """
  Build a server-to-client binary frame (unmasked, FIN set).

  Matches `makeBinaryFrame` in `WS.Frame`.
  """
  @spec binary_frame(binary()) :: frame()
  def binary_frame(payload) when is_binary(payload) do
    %{
      fin: true,
      opcode: :binary,
      masked: false,
      payload_length: byte_size(payload),
      masking_key: nil,
      payload: payload
    }
  end

  @doc """
  Build a Pong frame echoing a Ping's payload.

  Matches `makePongFrame` in `WS.Frame`.
  """
  @spec pong_frame(binary()) :: frame()
  def pong_frame(ping_payload) when is_binary(ping_payload) do
    %{
      fin: true,
      opcode: :pong,
      masked: false,
      payload_length: byte_size(ping_payload),
      masking_key: nil,
      payload: ping_payload
    }
  end

  @doc """
  Build a Ping frame with optional payload.

  Matches `makePingFrame` in `WS.Frame`.
  """
  @spec ping_frame(binary()) :: frame()
  def ping_frame(payload \\ <<>>) when is_binary(payload) do
    %{
      fin: true,
      opcode: :ping,
      masked: false,
      payload_length: byte_size(payload),
      masking_key: nil,
      payload: payload
    }
  end

  @doc """
  Build a Close frame with an optional status code and reason.

  Matches `makeCloseFrame` in `WS.Frame`.

  ## Examples

      iex> frame = ProvenServers.Websocket.close_frame(1000, "bye")
      iex> frame.opcode
      :close
      iex> byte_size(frame.payload)
      5
  """
  @spec close_frame(non_neg_integer() | nil, binary()) :: frame()
  def close_frame(status_code \\ nil, reason \\ <<>>) do
    payload =
      case status_code do
        nil ->
          reason

        code when is_integer(code) ->
          <<code::16>> <> reason
      end

    %{
      fin: true,
      opcode: :close,
      masked: false,
      payload_length: byte_size(payload),
      masking_key: nil,
      payload: payload
    }
  end
end
