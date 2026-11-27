// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

//! Smoke test against proven-amqp. Set PS_AMQP_LIB to the built
//! libproven_amqp shared library; the test is skipped (with a message) when
//! it is unset.

use proven_connector::{Arg, Error, Library, Ret, Value};

fn lib() -> Option<Library> {
    let path = match std::env::var("PS_AMQP_LIB") {
        Ok(p) => p,
        Err(_) => {
            eprintln!("PS_AMQP_LIB not set; skipping");
            return None;
        }
    };
    // SAFETY: PS_AMQP_LIB names the proven-amqp build from this repo, whose
    // initialisers and finalisers are trivial and whose ps_* exports are
    // generated from the Idris2 connector table.
    Some(unsafe { Library::open(&path) }.expect("open proven-amqp"))
}

#[test]
fn amqp_session_round_trip() {
    let Some(lib) = lib() else { return };
    assert_eq!(lib.call("abi_version", &[]).unwrap(), Ret::U32(1));

    let slot = match lib
        .call(
            "create",
            &[
                Arg::Bytes(b"/"),
                Arg::U32(131072),
                Arg::U16(16),
                Arg::U16(60),
            ],
        )
        .unwrap()
    {
        Ret::I32(s) => s,
        other => panic!("create returned {other:?}"),
    };
    assert!(slot >= 0);

    assert_eq!(
        lib.call("channel_open", &[Arg::I32(slot), Arg::U16(1)])
            .unwrap(),
        Ret::U8(0)
    );
    let channel_open = lib.constant("BROKER", "CHANNEL_OPEN").unwrap() as u8;
    assert_eq!(
        lib.call("state", &[Arg::I32(slot)]).unwrap(),
        Ret::U8(channel_open)
    );

    let topic = lib.constant("EXCH", "TOPIC").unwrap() as u8;
    assert_eq!(
        lib.call(
            "routing_match",
            &[
                Arg::Bytes(b"stock.usd.nyse"),
                Arg::Bytes(b"stock.*.nyse"),
                Arg::U8(topic)
            ]
        )
        .unwrap(),
        Ret::U8(1)
    );

    assert_eq!(lib.call("destroy", &[Arg::I32(slot)]).unwrap(), Ret::Void);
}

#[test]
fn manifest_lists_every_signature() {
    let Some(lib) = lib() else { return };
    let create = lib.signature("create").unwrap();
    let kinds: Vec<_> = create.args.iter().map(|(n, _)| n.as_str()).collect();
    assert_eq!(kinds, ["vhost", "frame_max", "channel_max", "heartbeat"]);
    assert!(lib.functions().count() >= 24);
}

#[test]
fn connector_and_dispatcher_reject_bad_calls() {
    let Some(lib) = lib() else { return };
    assert!(matches!(
        lib.call("nope", &[]),
        Err(Error::NoSuchFunction(_))
    ));
    assert!(matches!(lib.call("state", &[]), Err(Error::BadArgs(_))));
    assert!(matches!(
        lib.call("state", &[Arg::U8(0)]),
        Err(Error::BadArgs(_))
    ));

    // Bypass the connector's own check to reach the Zig dispatcher.
    let state = lib.signature("state").unwrap().tag;
    let wrong = lib.cell(&Arg::U8(0));
    // SAFETY: no BYTES cells.
    unsafe {
        assert!(matches!(lib.invoke_raw(9999, &[]), Err(Error::Status(n, _)) if n == "UNKNOWN_FN"));
        assert!(matches!(lib.invoke_raw(state, &[]), Err(Error::Status(n, _)) if n == "ARITY"));
        assert!(
            matches!(lib.invoke_raw(state, &[wrong]), Err(Error::Status(n, _)) if n == "KIND_MISMATCH")
        );
    }
    let open = lib.signature("channel_open").unwrap().tag;
    let mut too_big = lib.cell(&Arg::U16(0));
    too_big.word = 70_000;
    let null_bytes = Value {
        len: 4,
        ..lib.cell(&Arg::Bytes(b""))
    };
    let rm = lib.signature("routing_match").unwrap().tag;
    let topic = lib.cell(&Arg::U8(2));
    // SAFETY: the null BYTES cell is rejected before any read.
    unsafe {
        assert!(matches!(
            lib.invoke_raw(open, &[lib.cell(&Arg::I32(0)), too_big]),
            Err(Error::Status(n, _)) if n == "RANGE"
        ));
        let mut null_cell = null_bytes;
        null_cell.addr = 0;
        assert!(matches!(
            lib.invoke_raw(rm, &[null_cell, null_cell, topic]),
            Err(Error::Status(n, _)) if n == "NULL_PTR"
        ));
    }
}
