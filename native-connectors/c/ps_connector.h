/* SPDX-License-Identifier: MPL-2.0 */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * ps_connector.h -- native C connector for the uniform proven-servers surface.
 *
 * A protocol library exports ps_abi_version, ps_manifest and ps_invoke
 * (see ffi/zig/connector/ps_connector.zig). This connector binds only those
 * three. Function tags, kind tags, status tags and the value-cell layout are
 * read from the Idris2-emitted manifest at open time; nothing about any
 * protocol is hard-coded here, so the same connector serves every protocol.
 *
 * ps_open refuses a library whose manifest layout differs from ps_value.
 */
#ifndef PS_CONNECTOR_H
#define PS_CONNECTOR_H

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Connector ABI version this connector speaks. */
#define PS_CONNECTOR_ABI 1u

typedef struct ps_value {
  uint8_t kind;
  uint8_t _pad[7];
  uint64_t word; /* integer payload; I32 is sign-extended */
  uint64_t addr; /* BYTES: buffer address */
  uint64_t len;  /* BYTES: buffer length */
} ps_value;

/* Logical kinds. Their wire tags come from the manifest (KIND lines). */
typedef enum ps_kind {
  PS_VOID, PS_I32, PS_U8, PS_U16, PS_U32, PS_U64, PS_BYTES, PS_KIND_COUNT
} ps_kind;

typedef struct ps_lib {
  void *dl;
  uint32_t (*abi_version)(void);
  const char *(*manifest)(void);
  uint8_t (*invoke)(uint16_t, const ps_value *, uint32_t, ps_value *);
  const char *text;              /* manifest, static lifetime in the library */
  uint8_t kind_tag[PS_KIND_COUNT];
} ps_lib;

/* Open a protocol library. Returns 0 on success; on failure writes a
 * message to err (if non-NULL) and returns -1. */
int ps_open(ps_lib *lib, const char *path, char *err, size_t errlen);
void ps_close(ps_lib *lib);

/* Look up `KIND NAME VALUE` in the manifest (e.g. "EXCH", "TOPIC").
 * Returns 1 and sets *out when found, 0 otherwise. */
int ps_const(const ps_lib *lib, const char *kind, const char *name, uint64_t *out);

/* Function tag for NAME (without protocol prefix), or 0 if absent. */
uint16_t ps_fn_tag(const ps_lib *lib, const char *name);

/* Argument constructors. */
ps_value ps_int(const ps_lib *lib, ps_kind kind, int64_t v);
ps_value ps_bytes(const ps_lib *lib, const void *ptr, size_t len);

/* Call NAME. Returns the ps_invoke status (0 = OK); 1 (UNKNOWN_FN) when the
 * name is not in the manifest. */
uint8_t ps_call(const ps_lib *lib, const char *name, const ps_value *args,
                uint32_t n, ps_value *out);

#ifdef __cplusplus
}
#endif

#endif /* PS_CONNECTOR_H */
