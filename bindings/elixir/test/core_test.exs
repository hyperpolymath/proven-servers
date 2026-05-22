# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

defmodule ProvenServers.CoreTest do
  use ExUnit.Case, async: true
  doctest ProvenServers.Core

  alias ProvenServers.Core

  describe "result_code_from_tag/1" do
    test "roundtrips all valid tags 0..4" do
      for tag <- 0..4 do
        {:ok, code} = Core.result_code_from_tag(tag)
        assert Core.result_code_to_tag(code) == tag
      end
    end

    test "rejects invalid tags" do
      assert Core.result_code_from_tag(5) == :error
      assert Core.result_code_from_tag(255) == :error
    end
  end

  describe "result classification" do
    test "ok is ok" do
      assert Core.result_ok?(:ok)
      refute Core.result_error?(:ok)
    end

    test "errors are errors" do
      for code <- [:error, :invalid_param, :out_of_memory, :null_pointer] do
        refute Core.result_ok?(code)
        assert Core.result_error?(code)
      end
    end
  end

  describe "handle" do
    test "non-zero pointer succeeds" do
      assert {:ok, 42} = Core.new_handle(42)
    end

    test "zero pointer fails" do
      assert Core.new_handle(0) == :error
    end
  end

  describe "platform" do
    test "ptr_size_bits returns 64 for non-wasm" do
      for platform <- [:linux, :windows, :macos, :bsd] do
        assert Core.ptr_size_bits(platform) == 64
      end
    end

    test "ptr_size_bits returns 32 for wasm" do
      assert Core.ptr_size_bits(:wasm) == 32
    end

    test "ptr_size_bytes is consistent" do
      assert Core.ptr_size_bytes(:linux) == 8
      assert Core.ptr_size_bytes(:wasm) == 4
    end

    test "current_platform returns a valid platform" do
      platform = Core.current_platform()
      assert platform in [:linux, :windows, :macos, :bsd]
    end
  end

  describe "alignment helpers" do
    test "padding_for matches Idris2 Layout" do
      assert Core.padding_for(0, 8) == 0
      assert Core.padding_for(4, 8) == 4
      assert Core.padding_for(8, 8) == 0
      assert Core.padding_for(1, 4) == 3
    end

    test "align_up matches Idris2 Layout" do
      assert Core.align_up(4, 8) == 8
      assert Core.align_up(8, 8) == 8
      assert Core.align_up(9, 8) == 16
      assert Core.align_up(0, 8) == 0
    end
  end
end
