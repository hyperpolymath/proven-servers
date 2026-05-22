# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.GrpcTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Grpc

  alias ProvenServers.Grpc

  describe "status code roundtrip" do
    test "all codes 0..16 roundtrip" do
      for code <- 0..16 do
        {:ok, status} = Grpc.status_from_code(code)
        assert Grpc.status_to_code(status) == code
      end
    end

    test "invalid code returns error" do
      assert Grpc.status_from_code(17) == :error
      assert Grpc.status_from_code(255) == :error
    end
  end

  describe "stream type classification" do
    test "unary has no streaming" do
      refute Grpc.client_streaming?(:unary)
      refute Grpc.server_streaming?(:unary)
    end

    test "server streaming" do
      assert Grpc.server_streaming?(:server_streaming)
      refute Grpc.client_streaming?(:server_streaming)
    end

    test "client streaming" do
      assert Grpc.client_streaming?(:client_streaming)
      refute Grpc.server_streaming?(:client_streaming)
    end

    test "bidi streaming" do
      assert Grpc.client_streaming?(:bidi_streaming)
      assert Grpc.server_streaming?(:bidi_streaming)
    end
  end

  describe "stream state data capabilities" do
    test "can send data from open and half_closed_remote" do
      assert Grpc.can_send_data?(:open)
      assert Grpc.can_send_data?(:half_closed_remote)
      refute Grpc.can_send_data?(:half_closed_local)
      refute Grpc.can_send_data?(:idle)
      refute Grpc.can_send_data?(:closed)
    end

    test "can receive data from open and half_closed_local" do
      assert Grpc.can_receive_data?(:open)
      assert Grpc.can_receive_data?(:half_closed_local)
      refute Grpc.can_receive_data?(:half_closed_remote)
      refute Grpc.can_receive_data?(:closed)
    end
  end

  describe "closed is terminal" do
    test "no transitions from closed" do
      for to_tag <- 0..5 do
        {:ok, to} = Grpc.stream_state_from_tag(to_tag)

        assert Grpc.validate_stream_transition(:closed, to) == :error,
               "Closed -> #{to} should be impossible"
      end
    end
  end

  describe "valid stream transitions" do
    test "all valid transitions succeed" do
      valid_pairs = [
        {:idle, :open},
        {:open, :half_closed_local},
        {:open, :half_closed_remote},
        {:open, :closed},
        {:half_closed_local, :closed},
        {:half_closed_remote, :closed},
        {:idle, :reserved},
        {:reserved, :half_closed_remote},
        {:reserved, :closed}
      ]

      for {from, to} <- valid_pairs do
        assert {:ok, _transition} = Grpc.validate_stream_transition(from, to),
               "transition #{from} -> #{to} should be valid"
      end
    end

    test "impossible transitions fail" do
      impossible_pairs = [
        {:idle, :half_closed_local},
        {:half_closed_local, :open},
        {:reserved, :open}
      ]

      for {from, to} <- impossible_pairs do
        assert Grpc.validate_stream_transition(from, to) == :error,
               "transition #{from} -> #{to} should be impossible"
      end
    end
  end
end
