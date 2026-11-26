# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Smoke test against proven-amqp. Set PS_AMQP_LIB to the built
# libproven_amqp shared library; the tests are skipped when it is unset.

using Test
using ProvenConnector
using ProvenConnector: invoke_raw, cell, Value

path = get(ENV, "PS_AMQP_LIB", "")
if isempty(path)
    @info "PS_AMQP_LIB not set; skipping"
else
    lib = Library(path)
    @testset "proven-amqp through ps_invoke" begin
        @test call(lib, "abi_version") == UInt32(1)
        slot = call(lib, "create", "/", 131072, 16, 60)
        @test slot isa Int32 && slot >= 0
        @test call(lib, "channel_open", slot, 1) == 0x00
        @test call(lib, "state", slot) == UInt8(constant(lib, "BROKER", "CHANNEL_OPEN"))
        topic = constant(lib, "EXCH", "TOPIC")
        @test call(lib, "routing_match", "stock.usd.nyse", "stock.*.nyse", topic) == 0x01
        @test call(lib, "destroy", slot) === nothing
        @test [n for (n, _) in signature(lib, "create").args] == ["vhost", "frame_max", "channel_max", "heartbeat"]
    end
    @testset "rejections" begin
        @test_throws PSError call(lib, "nope")
        @test_throws PSError call(lib, "state")
        @test_throws InexactError call(lib, "channel_open", 0, 70000)
        state = signature(lib, "state").tag
        @test invoke_raw(lib, 9999, Value[])[1] == "UNKNOWN_FN"
        @test invoke_raw(lib, state, Value[])[1] == "ARITY"
        @test invoke_raw(lib, state, [cell(lib, "U8", 0)])[1] == "KIND_MISMATCH"
        big = Value(lib.kind_tag["U16"]; word = UInt64(70000))
        @test invoke_raw(lib, signature(lib, "channel_open").tag, [cell(lib, "I32", 0), big])[1] == "RANGE"
        nul = Value(lib.kind_tag["BYTES"]; len = UInt64(4))
        @test invoke_raw(lib, signature(lib, "routing_match").tag, [nul, nul, cell(lib, "U8", 2)])[1] == "NULL_PTR"
    end
    close_library(lib)
end
