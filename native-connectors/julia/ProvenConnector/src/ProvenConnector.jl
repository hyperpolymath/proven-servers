# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

"""
Native Julia connector for the uniform proven-servers surface.

A protocol library exports `ps_abi_version`, `ps_manifest` and `ps_invoke`
(see `ffi/zig/connector/ps_connector.zig`). This module binds only those
three. Function tags, kind tags, status tags and the value-cell layout are
read from the Idris2-emitted manifest at open time, so one connector serves
every protocol.
"""
module ProvenConnector

using Libdl

export Library, call, constant, signature, close_library, PSError

const CONNECTOR_ABI = UInt32(1)

"One argument or result cell; layout checked against the manifest at open."
struct Value
    kind::UInt8
    pad::NTuple{7,UInt8}
    word::UInt64
    addr::UInt64
    len::UInt64
end
Value(kind::UInt8; word::UInt64 = UInt64(0), addr::UInt64 = UInt64(0), len::UInt64 = UInt64(0)) =
    Value(kind, ntuple(_ -> 0x00, 7), word, addr, len)

const KIND_NAMES = ("VOID", "I32", "U8", "U16", "U32", "U64", "BYTES")

struct FnSig
    tag::UInt16
    name::String
    ret::String
    args::Vector{Pair{String,String}}
end

struct PSError <: Exception
    msg::String
    status::String
end
PSError(msg) = PSError(msg, "")
Base.showerror(io::IO, e::PSError) = print(io, "PSError: ", e.msg)

mutable struct Library
    handle::Ptr{Cvoid}
    invoke::Ptr{Cvoid}
    manifest::String
    consts::Dict{Tuple{String,String},UInt64}
    fns::Dict{String,FnSig}
    kind_tag::Dict{String,UInt8}
    tag_kind::Dict{UInt8,String}
    status_name::Dict{UInt8,String}
end

"Open a protocol library and validate its manifest."
function Library(path::AbstractString)
    h = Libdl.dlopen(path)
    abi = Libdl.dlsym(h, :ps_abi_version; throw_error = false)
    man = Libdl.dlsym(h, :ps_manifest; throw_error = false)
    inv = Libdl.dlsym(h, :ps_invoke; throw_error = false)
    if abi === nothing || man === nothing || inv === nothing
        Libdl.dlclose(h)
        throw(PSError("$path does not export the ps_* connector surface"))
    end
    v = ccall(abi, UInt32, ())
    if v != CONNECTOR_ABI
        Libdl.dlclose(h)
        throw(PSError("connector ABI $v, this module speaks $CONNECTOR_ABI"))
    end
    text = unsafe_string(ccall(man, Cstring, ()))
    lib = Library(h, inv, text, Dict(), Dict(), Dict(), Dict(), Dict())
    try
        parse_manifest!(lib)
    catch
        Libdl.dlclose(h)
        rethrow()
    end
    finalizer(close_library, lib)
    return lib
end

function close_library(lib::Library)
    if lib.handle != C_NULL
        Libdl.dlclose(lib.handle)
        lib.handle = C_NULL
    end
    nothing
end

function parse_manifest!(lib::Library)
    for line in split(lib.manifest, '\n'; keepempty = false)
        f = split(line, ' ')
        if f[1] == "FN"
            length(f) >= 4 || throw(PSError("short FN line: $line"))
            args = Pair{String,String}[]
            for a in f[5:end]
                n, k = split(a, ':')
                k in KIND_NAMES || throw(PSError("bad kind: $line"))
                push!(args, String(n) => String(k))
            end
            f[4] in KIND_NAMES || throw(PSError("bad kind: $line"))
            lib.fns[String(f[3])] = FnSig(parse(UInt16, f[2]), String(f[3]), String(f[4]), args)
        elseif length(f) == 3
            v = tryparse(UInt64, f[3])
            v === nothing || (lib.consts[(String(f[1]), String(f[2]))] = v)
        end
    end
    for (name, want) in (("PS_VALUE_SIZE", sizeof(Value)),
                         ("PS_VALUE_OFF_KIND", fieldoffset(Value, 1)),
                         ("PS_VALUE_OFF_WORD", fieldoffset(Value, 3)),
                         ("PS_VALUE_OFF_ADDR", fieldoffset(Value, 4)),
                         ("PS_VALUE_OFF_LEN", fieldoffset(Value, 5)))
        get(lib.consts, ("LAYOUT", name), nothing) == want ||
            throw(PSError("layout $name does not match Value"))
    end
    for k in KIND_NAMES
        t = get(lib.consts, ("KIND", k), nothing)
        t === nothing && throw(PSError("no KIND $k"))
        lib.kind_tag[k] = UInt8(t)
        lib.tag_kind[UInt8(t)] = k
    end
    for ((kind, name), v) in lib.consts
        kind == "STATUS" && (lib.status_name[UInt8(v)] = name)
    end
    "OK" in values(lib.status_name) || throw(PSError("no STATUS OK"))
    lib
end

"A `KIND NAME VALUE` manifest constant, or `nothing`."
constant(lib::Library, kind::AbstractString, name::AbstractString) =
    get(lib.consts, (String(kind), String(name)), nothing)

signature(lib::Library, name::AbstractString) = get(lib.fns, String(name), nothing)

"Byte buffers whose `pointer` addresses their own logical bytes."
const DenseBytes = Union{Vector{UInt8},Base.CodeUnits{UInt8,String}}

"Copy a byte view or other non-dense byte array into a fresh `Vector{UInt8}`."
bytes_arg(a) = a isa AbstractString ? codeunits(String(a)) :
               (a isa AbstractVector{UInt8} && !(a isa DenseBytes)) ? Vector{UInt8}(a) : a

const INT_KINDS = Dict("I32" => Int32, "U8" => UInt8, "U16" => UInt16, "U32" => UInt32, "U64" => UInt64)

function cell(lib::Library, kind::String, x)
    if kind == "BYTES"
        b = x isa AbstractString ? codeunits(String(x)) : x
        b isa DenseBytes ||
            throw(PSError("BYTES cell needs a String or a dense byte vector, got $(typeof(b))"))
        return Value(lib.kind_tag["BYTES"]; addr = UInt64(UInt(pointer(b))), len = UInt64(length(b)))
    end
    T = INT_KINDS[kind]
    v = convert(T, x)  # throws InexactError when out of range
    word = T === Int32 ? reinterpret(UInt64, Int64(v)) : UInt64(v)
    return Value(lib.kind_tag[kind]; word = word)
end

"""
    invoke_raw(lib, tag, cells, roots...)

Call by tag without the manifest check. `roots` are kept alive for the call.
Returns `(status_name, out::Value)`.
"""
function invoke_raw(lib::Library, tag::Integer, cells::Vector{Value}, roots...)
    lib.handle == C_NULL && throw(PSError("library is closed"))
    out = Ref(Value(0x00))
    st = GC.@preserve cells roots begin
        ccall(lib.invoke, UInt8, (UInt16, Ptr{Value}, UInt32, Ptr{Value}),
              UInt16(tag), isempty(cells) ? Ptr{Value}(C_NULL) : pointer(cells),
              UInt32(length(cells)), out)
    end
    return get(lib.status_name, st, "UNKNOWN"), out[]
end

"""
    call(lib, name, args...)

Call NAME, checked against the manifest signature. Strings and byte vectors
pass as BYTES. Returns `nothing` for a VOID result, else the integer.
"""
function call(lib::Library, name::AbstractString, args...)
    sig = signature(lib, name)
    sig === nothing && throw(PSError("no function $name in manifest"))
    length(args) == length(sig.args) ||
        throw(PSError("$name takes $(length(sig.args)) arguments, got $(length(args))"))
    bufs = Any[bytes_arg(a) for a in args]
    cells = Value[cell(lib, k, b) for ((_, k), b) in zip(sig.args, bufs)]
    st, out = invoke_raw(lib, sig.tag, cells, bufs)
    st == "OK" || throw(PSError("ps_invoke status $st", st))
    k = lib.tag_kind[out.kind]
    k == "VOID" && return nothing
    T = INT_KINDS[k]
    return T === Int32 ? Int32(reinterpret(Int64, out.word)) : T(out.word)
end

end # module
