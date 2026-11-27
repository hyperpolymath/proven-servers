/* SPDX-License-Identifier: MPL-2.0 */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * smoke.c -- C connector smoke test against proven-amqp.
 * Usage: smoke /path/to/libproven_amqp.so
 */
#include "ps_connector.h"

#include <stdio.h>
#include <string.h>

static int failures = 0;

#define CHECK(cond, what)                                   \
  do {                                                      \
    if (cond) { printf("ok   %s\n", what); }                \
    else { printf("FAIL %s\n", what); failures++; }         \
  } while (0)

static uint64_t status(const ps_lib *lib, const char *name) {
  uint64_t v = 255;
  ps_const(lib, "STATUS", name, &v);
  return v;
}

int main(int argc, char **argv) {
  if (argc != 2) { fprintf(stderr, "usage: %s LIB\n", argv[0]); return 2; }
  ps_lib lib;
  char err[256];
  if (ps_open(&lib, argv[1], err, sizeof err) != 0) { fprintf(stderr, "%s\n", err); return 1; }

  ps_value out;
  uint64_t ok = status(&lib, "OK");

  CHECK(ps_call(&lib, "abi_version", NULL, 0, &out) == ok && out.word == 1, "abi_version == 1");

  const char *vhost = "/";
  ps_value create_args[4] = {
    ps_bytes(&lib, vhost, strlen(vhost)), ps_int(&lib, PS_U32, 131072),
    ps_int(&lib, PS_U16, 16), ps_int(&lib, PS_U16, 60),
  };
  CHECK(ps_call(&lib, "create", create_args, 4, &out) == ok && (int64_t)out.word >= 0, "create returns a slot");
  int64_t slot = (int64_t)out.word;

  ps_value open_args[2] = { ps_int(&lib, PS_I32, slot), ps_int(&lib, PS_U16, 1) };
  CHECK(ps_call(&lib, "channel_open", open_args, 2, &out) == ok && out.word == 0, "channel_open accepted");

  uint64_t channel_open = 0;
  ps_const(&lib, "BROKER", "CHANNEL_OPEN", &channel_open);
  ps_value slot_arg = ps_int(&lib, PS_I32, slot);
  CHECK(ps_call(&lib, "state", &slot_arg, 1, &out) == ok && out.word == channel_open, "state is BROKER CHANNEL_OPEN");

  uint64_t topic = 0;
  ps_const(&lib, "EXCH", "TOPIC", &topic);
  const char *key = "stock.usd.nyse";
  const char *pat = "stock.*.nyse";
  ps_value rm_args[3] = {
    ps_bytes(&lib, key, strlen(key)), ps_bytes(&lib, pat, strlen(pat)), ps_int(&lib, PS_U8, (int64_t)topic),
  };
  CHECK(ps_call(&lib, "routing_match", rm_args, 3, &out) == ok && out.word == 1, "topic routing_match");

  CHECK(ps_call(&lib, "destroy", &slot_arg, 1, &out) == ok, "destroy (VOID result)");

  /* The dispatcher's own checks. */
  CHECK(lib.invoke(9999, NULL, 0, &out) == status(&lib, "UNKNOWN_FN"), "unknown tag rejected");
  CHECK(ps_call(&lib, "state", NULL, 0, &out) == status(&lib, "ARITY"), "wrong arity rejected");
  ps_value wrong_kind = ps_int(&lib, PS_U8, 0);
  CHECK(ps_call(&lib, "state", &wrong_kind, 1, &out) == status(&lib, "KIND_MISMATCH"), "wrong kind rejected");
  ps_value too_big = ps_int(&lib, PS_U16, 70000);
  ps_value range_args[2] = { slot_arg, too_big };
  CHECK(ps_call(&lib, "channel_open", range_args, 2, &out) == status(&lib, "RANGE"), "out-of-range u16 rejected");
  CHECK(lib.invoke(ps_fn_tag(&lib, "state"), &slot_arg, 1, NULL) == status(&lib, "NULL_PTR"), "null out rejected");

  ps_close(&lib);
  printf("%s (%d failure%s)\n", failures ? "FAILED" : "PASSED", failures, failures == 1 ? "" : "s");
  return failures ? 1 : 0;
}
