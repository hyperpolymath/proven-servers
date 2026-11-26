// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

//! Native Rust connector for the uniform proven-servers surface.
//!
//! A protocol library exports `ps_abi_version`, `ps_manifest` and
//! `ps_invoke` (see `ffi/zig/connector/ps_connector.zig`). This crate binds
//! only those three. Function tags, kind tags, status tags and the value-cell
//! layout are read from the Idris2-emitted manifest when the library is
//! opened, so one connector serves every protocol. No dependencies; POSIX
//! `dlopen` only.

use std::collections::HashMap;
use std::ffi::{c_char, c_int, c_void, CStr, CString};
use std::fmt;
use std::marker::PhantomData;

/// Connector ABI version this crate speaks.
pub const CONNECTOR_ABI: u32 = 1;

/// One argument or result cell, laid out as the manifest's `PS_VALUE_*`
/// constants say (checked in [`Library::open`]).
#[repr(C)]
#[derive(Clone, Copy, Debug, Default)]
pub struct Value {
    pub kind: u8,
    pub pad: [u8; 7],
    pub word: u64,
    pub addr: u64,
    pub len: u64,
}

/// Logical argument / result kinds.
#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub enum Kind {
    Void,
    I32,
    U8,
    U16,
    U32,
    U64,
    Bytes,
}

impl Kind {
    const ALL: [Kind; 7] = [
        Kind::Void,
        Kind::I32,
        Kind::U8,
        Kind::U16,
        Kind::U32,
        Kind::U64,
        Kind::Bytes,
    ];

    fn name(self) -> &'static str {
        match self {
            Kind::Void => "VOID",
            Kind::I32 => "I32",
            Kind::U8 => "U8",
            Kind::U16 => "U16",
            Kind::U32 => "U32",
            Kind::U64 => "U64",
            Kind::Bytes => "BYTES",
        }
    }

    fn parse(s: &str) -> Option<Kind> {
        Kind::ALL.into_iter().find(|k| k.name() == s)
    }
}

/// An argument. `Bytes` borrows its buffer for the duration of the call.
#[derive(Clone, Copy, Debug)]
pub enum Arg<'a> {
    I32(i32),
    U8(u8),
    U16(u16),
    U32(u32),
    U64(u64),
    Bytes(&'a [u8]),
}

impl Arg<'_> {
    fn kind(&self) -> Kind {
        match self {
            Arg::I32(_) => Kind::I32,
            Arg::U8(_) => Kind::U8,
            Arg::U16(_) => Kind::U16,
            Arg::U32(_) => Kind::U32,
            Arg::U64(_) => Kind::U64,
            Arg::Bytes(_) => Kind::Bytes,
        }
    }
}

/// A function's result.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Ret {
    Void,
    I32(i32),
    U8(u8),
    U16(u16),
    U32(u32),
    U64(u64),
}

impl Ret {
    /// The result as an `i64`, or `None` for `Void`.
    pub fn as_i64(self) -> Option<i64> {
        match self {
            Ret::Void => None,
            Ret::I32(v) => Some(v.into()),
            Ret::U8(v) => Some(v.into()),
            Ret::U16(v) => Some(v.into()),
            Ret::U32(v) => Some(v.into()),
            Ret::U64(v) => i64::try_from(v).ok(),
        }
    }
}

/// One entry of the manifest's function table.
#[derive(Clone, Debug)]
pub struct FnSig {
    pub tag: u16,
    pub name: String,
    pub ret: Kind,
    pub args: Vec<(String, Kind)>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Error {
    Open(String),
    Manifest(String),
    NoSuchFunction(String),
    /// The arguments do not match the manifest signature.
    BadArgs(String),
    /// `ps_invoke` returned a non-OK status (by manifest name).
    Status(String, u8),
}

impl fmt::Display for Error {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Error::Open(m) => write!(f, "open: {m}"),
            Error::Manifest(m) => write!(f, "manifest: {m}"),
            Error::NoSuchFunction(n) => write!(f, "no function {n} in manifest"),
            Error::BadArgs(m) => write!(f, "bad arguments: {m}"),
            Error::Status(n, s) => write!(f, "ps_invoke status {n} ({s})"),
        }
    }
}

impl std::error::Error for Error {}

const RTLD_NOW: c_int = 2;

extern "C" {
    fn dlopen(filename: *const c_char, flags: c_int) -> *mut c_void;
    fn dlsym(handle: *mut c_void, symbol: *const c_char) -> *mut c_void;
    fn dlclose(handle: *mut c_void) -> c_int;
    fn dlerror() -> *const c_char;
}

type AbiFn = unsafe extern "C" fn() -> u32;
type ManifestFn = unsafe extern "C" fn() -> *const c_char;
type InvokeFn = unsafe extern "C" fn(u16, *const Value, u32, *mut Value) -> u8;

/// An opened protocol library.
pub struct Library {
    handle: *mut c_void,
    invoke: InvokeFn,
    manifest: String,
    consts: HashMap<(String, String), u64>,
    fns: HashMap<String, FnSig>,
    kind_tag: HashMap<Kind, u8>,
    tag_kind: HashMap<u8, Kind>,
    status_name: HashMap<u8, String>,
    _not_send: PhantomData<*mut ()>,
}

fn last_dl_error() -> String {
    // SAFETY: dlerror returns NULL or a valid C string owned by libc.
    unsafe {
        let p = dlerror();
        if p.is_null() {
            "unknown dlopen error".into()
        } else {
            CStr::from_ptr(p).to_string_lossy().into_owned()
        }
    }
}

impl Library {
    /// Open a protocol library and validate its manifest.
    pub fn open(path: &str) -> Result<Library, Error> {
        let cpath = CString::new(path).map_err(|e| Error::Open(e.to_string()))?;
        // SAFETY: cpath is a valid NUL-terminated string.
        let handle = unsafe { dlopen(cpath.as_ptr(), RTLD_NOW) };
        if handle.is_null() {
            return Err(Error::Open(last_dl_error()));
        }
        let sym = |name: &CStr| -> Result<*mut c_void, Error> {
            // SAFETY: handle is a live dlopen handle; name is NUL-terminated.
            let p = unsafe { dlsym(handle, name.as_ptr()) };
            if p.is_null() {
                Err(Error::Open(format!(
                    "{path} does not export {}",
                    name.to_string_lossy()
                )))
            } else {
                Ok(p)
            }
        };
        let resolved = (|| {
            let abi = sym(c"ps_abi_version")?;
            let man = sym(c"ps_manifest")?;
            let inv = sym(c"ps_invoke")?;
            // SAFETY: the ps_* symbols have these C signatures by contract
            // (ffi/zig/connector/ps_connector.zig).
            unsafe {
                Ok::<_, Error>((
                    std::mem::transmute::<*mut c_void, AbiFn>(abi),
                    std::mem::transmute::<*mut c_void, ManifestFn>(man),
                    std::mem::transmute::<*mut c_void, InvokeFn>(inv),
                ))
            }
        })();
        let (abi, man, invoke) = match resolved {
            Ok(t) => t,
            Err(e) => {
                // SAFETY: handle came from dlopen and is closed once.
                unsafe { dlclose(handle) };
                return Err(e);
            }
        };
        // SAFETY: calling the library's own exports.
        let version = unsafe { abi() };
        // SAFETY: ps_manifest returns a static NUL-terminated string.
        let manifest = unsafe { CStr::from_ptr(man()) }
            .to_string_lossy()
            .into_owned();
        let mut lib = Library {
            handle,
            invoke,
            manifest,
            consts: HashMap::new(),
            fns: HashMap::new(),
            kind_tag: HashMap::new(),
            tag_kind: HashMap::new(),
            status_name: HashMap::new(),
            _not_send: PhantomData,
        };
        if version != CONNECTOR_ABI {
            return Err(Error::Open(format!(
                "connector ABI {version}, this crate speaks {CONNECTOR_ABI}"
            )));
        }
        lib.parse_manifest()?;
        Ok(lib)
    }

    fn parse_manifest(&mut self) -> Result<(), Error> {
        for line in self.manifest.lines() {
            let f: Vec<&str> = line.split(' ').collect();
            if f.first() == Some(&"FN") {
                if f.len() < 4 {
                    return Err(Error::Manifest(format!("short FN line: {line}")));
                }
                let tag: u16 = f[1]
                    .parse()
                    .map_err(|_| Error::Manifest(format!("bad tag: {line}")))?;
                let ret = Kind::parse(f[3])
                    .ok_or_else(|| Error::Manifest(format!("bad kind: {line}")))?;
                let mut args = Vec::new();
                for a in &f[4..] {
                    let (n, k) = a
                        .split_once(':')
                        .ok_or_else(|| Error::Manifest(format!("bad arg: {line}")))?;
                    let k = Kind::parse(k)
                        .ok_or_else(|| Error::Manifest(format!("bad kind: {line}")))?;
                    args.push((n.to_string(), k));
                }
                self.fns.insert(
                    f[2].to_string(),
                    FnSig {
                        tag,
                        name: f[2].to_string(),
                        ret,
                        args,
                    },
                );
            } else if f.len() == 3 {
                if let Ok(v) = f[2].parse::<u64>() {
                    self.consts.insert((f[0].to_string(), f[1].to_string()), v);
                }
            }
        }
        for (name, want) in [
            ("PS_VALUE_SIZE", std::mem::size_of::<Value>()),
            ("PS_VALUE_ALIGN", std::mem::align_of::<Value>()),
            ("PS_VALUE_OFF_KIND", std::mem::offset_of!(Value, kind)),
            ("PS_VALUE_OFF_WORD", std::mem::offset_of!(Value, word)),
            ("PS_VALUE_OFF_ADDR", std::mem::offset_of!(Value, addr)),
            ("PS_VALUE_OFF_LEN", std::mem::offset_of!(Value, len)),
        ] {
            if self.constant("LAYOUT", name) != Some(want as u64) {
                return Err(Error::Manifest(format!(
                    "layout {name} does not match Value"
                )));
            }
        }
        for k in Kind::ALL {
            let tag = self
                .constant("KIND", k.name())
                .and_then(|v| u8::try_from(v).ok())
                .ok_or_else(|| Error::Manifest(format!("no KIND {}", k.name())))?;
            self.kind_tag.insert(k, tag);
            self.tag_kind.insert(tag, k);
        }
        for ((kind, name), v) in &self.consts {
            if kind == "STATUS" {
                if let Ok(t) = u8::try_from(*v) {
                    self.status_name.insert(t, name.clone());
                }
            }
        }
        if !self.status_name.values().any(|n| n == "OK") {
            return Err(Error::Manifest("no STATUS OK".into()));
        }
        Ok(())
    }

    /// The raw Idris2-emitted manifest.
    pub fn manifest(&self) -> &str {
        &self.manifest
    }

    /// A `KIND NAME VALUE` constant, e.g. `constant("EXCH", "TOPIC")`.
    pub fn constant(&self, kind: &str, name: &str) -> Option<u64> {
        self.consts
            .get(&(kind.to_string(), name.to_string()))
            .copied()
    }

    /// The signature of NAME, if the manifest lists it.
    pub fn signature(&self, name: &str) -> Option<&FnSig> {
        self.fns.get(name)
    }

    /// Every function the manifest lists.
    pub fn functions(&self) -> impl Iterator<Item = &FnSig> {
        self.fns.values()
    }

    /// Call NAME with ARGS, checked against the manifest signature first.
    pub fn call(&self, name: &str, args: &[Arg<'_>]) -> Result<Ret, Error> {
        let sig = self
            .fns
            .get(name)
            .ok_or_else(|| Error::NoSuchFunction(name.into()))?;
        if sig.args.len() != args.len() {
            return Err(Error::BadArgs(format!(
                "{name} takes {} arguments, got {}",
                sig.args.len(),
                args.len()
            )));
        }
        for ((pname, k), a) in sig.args.iter().zip(args) {
            if a.kind() != *k {
                return Err(Error::BadArgs(format!(
                    "{name}: {pname} is {}, got {}",
                    k.name(),
                    a.kind().name()
                )));
            }
        }
        let cells: Vec<Value> = args.iter().map(|a| self.cell(a)).collect();
        // SAFETY: `cells` and the slices they point into outlive the call.
        unsafe { self.invoke_raw(sig.tag, &cells) }
    }

    /// Build one value cell for ARG.
    pub fn cell(&self, arg: &Arg<'_>) -> Value {
        let mut v = Value {
            kind: self.kind_tag[&arg.kind()],
            ..Value::default()
        };
        match *arg {
            Arg::I32(x) => v.word = i64::from(x) as u64,
            Arg::U8(x) => v.word = x.into(),
            Arg::U16(x) => v.word = x.into(),
            Arg::U32(x) => v.word = x.into(),
            Arg::U64(x) => v.word = x,
            Arg::Bytes(b) => {
                v.addr = b.as_ptr() as usize as u64;
                v.len = b.len() as u64;
            }
        }
        v
    }

    /// Call by tag with prepared cells, without the manifest check. Used to
    /// exercise the dispatcher's own validation.
    ///
    /// # Safety
    /// Every BYTES cell must point at memory valid for its length for the
    /// duration of the call.
    pub unsafe fn invoke_raw(&self, tag: u16, cells: &[Value]) -> Result<Ret, Error> {
        let mut out = Value::default();
        let n = u32::try_from(cells.len()).map_err(|_| Error::BadArgs("too many".into()))?;
        let ptr = if cells.is_empty() {
            std::ptr::null()
        } else {
            cells.as_ptr()
        };
        let st = (self.invoke)(tag, ptr, n, &mut out);
        let st_name = self
            .status_name
            .get(&st)
            .cloned()
            .unwrap_or_else(|| "UNKNOWN".into());
        if st_name != "OK" {
            return Err(Error::Status(st_name, st));
        }
        let kind = self
            .tag_kind
            .get(&out.kind)
            .copied()
            .ok_or_else(|| Error::Manifest(format!("unknown result kind {}", out.kind)))?;
        Ok(match kind {
            Kind::Void => Ret::Void,
            Kind::I32 => Ret::I32(out.word as i64 as i32),
            Kind::U8 => Ret::U8(out.word as u8),
            Kind::U16 => Ret::U16(out.word as u16),
            Kind::U32 => Ret::U32(out.word as u32),
            Kind::U64 => Ret::U64(out.word),
            Kind::Bytes => return Err(Error::Manifest("BYTES result".into())),
        })
    }
}

impl Drop for Library {
    fn drop(&mut self) {
        // SAFETY: handle came from dlopen and is closed exactly once.
        unsafe { dlclose(self.handle) };
    }
}
