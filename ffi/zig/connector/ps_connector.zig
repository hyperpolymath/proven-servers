// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ps_connector.zig -- the uniform native-connector dispatcher (pilot).
//
// A protocol exports three C symbols:
//
//   uint32_t     ps_abi_version(void);
//   const char * ps_manifest(void);   // the Idris2-emitted manifest, NUL-terminated
//   uint8_t      ps_invoke(uint16_t fn_tag, const ps_value *args, uint32_t n,
//                          ps_value *out);
//
// A connector in any language binds only those three, reads the manifest to
// learn the function table, and calls through ps_invoke. One connector per
// language then serves every protocol that exports this surface.
//
// The function table, kind tags, status tags and value-cell layout all come
// from the protocol's generated `<name>_abi_gen.zig`, which tools/gen-abi.sh
// renders from the Idris2 `<Name>ABI.Connector` module. `Dispatcher` checks
// at comptime that every table entry names a real export whose Zig parameter
// types match the Idris2 kinds, so drift is a build error, not a runtime bug.
//
// The Zig code here is FFI only (pure Zig). The ABI it is checked against is
// pure Idris2.

const std = @import("std");

/// One argument or result cell. 32 bytes on every target (see the
/// PS_VALUE_* layout constants in the generated file).
pub const Value = extern struct {
    kind: u8,
    _pad: [7]u8 = [_]u8{0} ** 7,
    word: u64 align(8) = 0,
    addr: u64 = 0,
    len: u64 = 0,
};

/// Logical kind of a Zig parameter or result type.
fn kindOf(comptime T: type) []const u8 {
    if (T == void) return "VOID";
    if (T == c_int or T == i32) return "I32";
    if (T == u8) return "U8";
    if (T == u16) return "U16";
    if (T == u32) return "U32";
    if (T == u64) return "U64";
    @compileError("ps_connector: unsupported type " ++ @typeName(T));
}

fn isBytesPtr(comptime T: type) bool {
    return T == [*]const u8;
}

/// The space-separated logical kinds of a function's parameters. A
/// `[*]const u8` followed by a `u32` is one BYTES argument.
fn paramKinds(comptime F: type) []const u8 {
    const params = @typeInfo(F).@"fn".params;
    comptime var out: []const u8 = "";
    comptime var i: usize = 0;
    inline while (i < params.len) {
        const P = params[i].type.?;
        const k = if (isBytesPtr(P)) blk: {
            if (i + 1 >= params.len or params[i + 1].type.? != u32)
                @compileError("ps_connector: a [*]const u8 parameter must be followed by its u32 length");
            i += 2;
            break :blk "BYTES";
        } else blk: {
            i += 1;
            break :blk kindOf(P);
        };
        out = if (out.len == 0) k else out ++ " " ++ k;
    }
    return out;
}

fn logicalArity(comptime kinds: []const u8) usize {
    if (kinds.len == 0) return 0;
    return std.mem.count(u8, kinds, " ") + 1;
}

const empty_bytes = [_]u8{0};

/// Build the dispatcher for one protocol.
///   impl   -- the protocol's Zig file (`@This()`), holding the exports
///   prefix -- the export prefix, e.g. "amqp_"
///   gen    -- the generated `<name>_abi_gen.zig`
pub fn Dispatcher(comptime impl: type, comptime prefix: []const u8, comptime gen: type) type {
    return struct {
        comptime {
            if (@sizeOf(Value) != gen.PS_VALUE_SIZE) @compileError("ABI drift: ps_value size");
            if (@alignOf(Value) != gen.PS_VALUE_ALIGN) @compileError("ABI drift: ps_value align");
            if (@offsetOf(Value, "kind") != gen.PS_VALUE_OFF_KIND) @compileError("ABI drift: ps_value.kind");
            if (@offsetOf(Value, "word") != gen.PS_VALUE_OFF_WORD) @compileError("ABI drift: ps_value.word");
            if (@offsetOf(Value, "addr") != gen.PS_VALUE_OFF_ADDR) @compileError("ABI drift: ps_value.addr");
            if (@offsetOf(Value, "len") != gen.PS_VALUE_OFF_LEN) @compileError("ABI drift: ps_value.len");

            @setEvalBranchQuota(200_000);
            for (gen.FNS, 0..) |f, i| {
                if (f.tag != i + 1) @compileError("ABI drift: FN tags must run 1..n in order, at " ++ f.name);
                const sym = prefix ++ f.name;
                if (!@hasDecl(impl, sym)) @compileError("ABI drift: Idris2 lists " ++ sym ++ " but Zig has no such export");
                const F = @TypeOf(@field(impl, sym));
                const ret = kindOf(@typeInfo(F).@"fn".return_type.?);
                if (!std.mem.eql(u8, ret, f.ret))
                    @compileError("ABI drift: " ++ sym ++ " returns " ++ ret ++ ", Idris2 says " ++ f.ret);
                const got = paramKinds(F);
                if (!std.mem.eql(u8, got, f.kinds))
                    @compileError("ABI drift: " ++ sym ++ " takes (" ++ got ++ "), Idris2 says (" ++ f.kinds ++ ")");
            }
        }

        fn status(comptime name: []const u8) u8 {
            return @field(gen, "STATUS_" ++ name);
        }

        fn kindTag(comptime name: []const u8) u8 {
            return @field(gen, "KIND_" ++ name);
        }

        fn decodeInt(comptime P: type, comptime kname: []const u8, v: Value) ?P {
            if (v.kind != kindTag(kname)) return null;
            if (P == c_int or P == i32) {
                const s: i64 = @bitCast(v.word);
                if (s < std.math.minInt(i32) or s > std.math.maxInt(i32)) return null;
                return @intCast(s);
            }
            if (v.word > std.math.maxInt(P)) return null;
            return @intCast(v.word);
        }

        fn call(comptime f: gen.FnSig, args: ?[*]const Value, n: u32, out: *Value) u8 {
            const func = @field(impl, prefix ++ f.name);
            const F = @TypeOf(func);
            const params = @typeInfo(F).@"fn".params;
            const arity = comptime logicalArity(f.kinds);
            if (n != arity) return status("ARITY");
            if (arity > 0 and args == null) return status("NULL_PTR");

            var tuple: std.meta.ArgsTuple(F) = undefined;
            comptime var pi: usize = 0;
            comptime var li: usize = 0;
            inline while (pi < params.len) {
                const P = params[pi].type.?;
                const v = args.?[li];
                if (comptime isBytesPtr(P)) {
                    if (v.kind != kindTag("BYTES")) return status("KIND_MISMATCH");
                    if (v.len > std.math.maxInt(u32)) return status("RANGE");
                    if (v.addr == 0 and v.len != 0) return status("NULL_PTR");
                    if (v.addr > std.math.maxInt(usize)) return status("RANGE");
                    tuple[pi] = if (v.addr == 0) &empty_bytes else @ptrFromInt(@as(usize, @intCast(v.addr)));
                    tuple[pi + 1] = @intCast(v.len);
                    pi += 2;
                } else {
                    const kname = comptime kindOf(P);
                    if (v.kind != kindTag(kname)) return status("KIND_MISMATCH");
                    tuple[pi] = decodeInt(P, kname, v) orelse return status("RANGE");
                    pi += 1;
                }
                li += 1;
            }

            const R = @typeInfo(F).@"fn".return_type.?;
            const r = @call(.auto, func, tuple);
            out.* = .{ .kind = kindTag(comptime kindOf(R)) };
            if (R == c_int or R == i32) {
                out.word = @bitCast(@as(i64, r));
            } else if (R != void) {
                out.word = r;
            }
            return status("OK");
        }

        /// Body of the protocol's `ps_invoke` export.
        pub fn invoke(tag: u16, args: ?[*]const Value, n: u32, out: ?*Value) u8 {
            const o = out orelse return status("NULL_PTR");
            inline for (gen.FNS) |f| {
                if (f.tag == tag) return call(f, args, n, o);
            }
            return status("UNKNOWN_FN");
        }
    };
}
