# SPDX-License-Identifier: MPL-2.0
# Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
defmodule ProvenServers.WebsocketTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Websocket

  alias ProvenServers.Websocket

  describe "opcode roundtrip" do
    test "all valid opcodes roundtrip" do
      opcodes = [
        {0x0, :continuation},
        {0x1, :text},
        {0x2, :binary},
        {0x8, :close},
        {0x9, :ping},
        {0xA, :pong}
      ]

      for {nibble, expected} <- opcodes do
        assert {:ok, ^expected} = Websocket.opcode_from_nibble(nibble)
        assert Websocket.opcode_to_nibble(expected) == nibble
      end
    end

    test "reserved opcodes rejected" do
      for nibble <- [0x3, 0x4, 0x5, 0x6, 0x7, 0xB, 0xC, 0xD, 0xE, 0xF] do
        assert Websocket.opcode_from_nibble(nibble) == :error
      end
    end
  end

  describe "opcode classification" do
    test "data opcodes" do
      assert Websocket.opcode_data?(:text)
      assert Websocket.opcode_data?(:binary)
      assert Websocket.opcode_data?(:continuation)
      refute Websocket.opcode_data?(:close)
    end

    test "control opcodes" do
      assert Websocket.opcode_control?(:close)
      assert Websocket.opcode_control?(:ping)
      assert Websocket.opcode_control?(:pong)
      refute Websocket.opcode_control?(:text)
    end

    test "message start" do
      assert Websocket.opcode_message_start?(:text)
      assert Websocket.opcode_message_start?(:binary)
      refute Websocket.opcode_message_start?(:continuation)
    end

    test "requires response" do
      assert Websocket.opcode_requires_response?(:ping)
      assert Websocket.opcode_requires_response?(:close)
      refute Websocket.opcode_requires_response?(:text)
    end
  end

  describe "close code roundtrip" do
    test "all known codes roundtrip" do
      codes = [1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008, 1009, 1010, 1011]

      for wire <- codes do
        {:ok, code} = Websocket.close_code_from_wire(wire)
        assert Websocket.close_code_to_wire(code) == wire
      end
    end

    test "unknown codes rejected" do
      assert Websocket.close_code_from_wire(1004) == :error
      assert Websocket.close_code_from_wire(999) == :error
    end
  end

  describe "close code classification" do
    test "normal closures" do
      assert Websocket.close_code_normal?(:normal)
      assert Websocket.close_code_normal?(:going_away)
      refute Websocket.close_code_normal?(:protocol_error)
    end

    test "error closures" do
      assert Websocket.close_code_error?(:protocol_error)
      assert Websocket.close_code_error?(:internal_error)
      refute Websocket.close_code_error?(:normal)
      refute Websocket.close_code_error?(:no_status)
    end

    test "sendable codes" do
      assert Websocket.close_code_sendable?(:normal)
      refute Websocket.close_code_sendable?(:no_status)
      refute Websocket.close_code_sendable?(:abnormal)
    end
  end

  describe "close code ranges" do
    test "application codes 4000-4999" do
      assert Websocket.application_code?(4000)
      assert Websocket.application_code?(4999)
      refute Websocket.application_code?(3999)
      refute Websocket.application_code?(5000)
    end

    test "private codes 3000-3999" do
      assert Websocket.private_code?(3000)
      assert Websocket.private_code?(3999)
      refute Websocket.private_code?(2999)
      refute Websocket.private_code?(4000)
    end
  end

  describe "frame construction" do
    test "text frame" do
      frame = Websocket.text_frame("hello")
      assert frame.fin == true
      assert frame.opcode == :text
      refute frame.masked
      assert frame.payload_length == 5
      assert frame.payload == "hello"
    end

    test "close frame with code" do
      frame = Websocket.close_frame(1000, "bye")
      assert frame.opcode == :close
      assert frame.payload_length == 5
      assert frame.payload == <<3, 232, "bye">>
    end
  end
end
