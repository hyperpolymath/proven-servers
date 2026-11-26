/* SPDX-License-Identifier: MPL-2.0 */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * ps_connector.c -- loader for the uniform proven-servers connector surface.
 * POSIX dlopen only (Linux, macOS, BSD).
 */
#include "ps_connector.h"

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static const char *const kind_names[PS_KIND_COUNT] = {
  "VOID", "I32", "U8", "U16", "U32", "U64", "BYTES"
};

static void set_err(char *err, size_t errlen, const char *msg, const char *detail) {
  if (err && errlen) snprintf(err, errlen, "%s%s%s", msg, detail ? ": " : "", detail ? detail : "");
}

/* Find a line whose first two fields are a and b; return a pointer just past
 * them (at the separating space), or NULL. */
static const char *find_line(const char *text, const char *a, const char *b) {
  size_t la = strlen(a), lb = strlen(b);
  const char *p = text;
  while (p && *p) {
    if (strncmp(p, a, la) == 0 && p[la] == ' ' && strncmp(p + la + 1, b, lb) == 0 &&
        (p[la + 1 + lb] == ' ' || p[la + 1 + lb] == '\n' || p[la + 1 + lb] == '\0'))
      return p + la + 1 + lb;
    p = strchr(p, '\n');
    if (p) p++;
  }
  return NULL;
}

int ps_const(const ps_lib *lib, const char *kind, const char *name, uint64_t *out) {
  const char *p = find_line(lib->text, kind, name);
  if (!p || *p != ' ') return 0;
  char *end = NULL;
  unsigned long long v = strtoull(p + 1, &end, 10);
  if (end == p + 1) return 0;
  *out = (uint64_t)v;
  return 1;
}

uint16_t ps_fn_tag(const ps_lib *lib, const char *name) {
  /* FN <tag> <name> ... : the name is the third field. */
  size_t ln = strlen(name);
  const char *p = lib->text;
  while (p && *p) {
    if (strncmp(p, "FN ", 3) == 0) {
      char *end = NULL;
      unsigned long tag = strtoul(p + 3, &end, 10);
      if (end && *end == ' ' && strncmp(end + 1, name, ln) == 0 && end[1 + ln] == ' ')
        return (uint16_t)tag;
    }
    p = strchr(p, '\n');
    if (p) p++;
  }
  return 0;
}

int ps_open(ps_lib *lib, const char *path, char *err, size_t errlen) {
  memset(lib, 0, sizeof *lib);
  lib->dl = dlopen(path, RTLD_NOW | RTLD_LOCAL);
  if (!lib->dl) { set_err(err, errlen, "dlopen failed", dlerror()); return -1; }
  *(void **)&lib->abi_version = dlsym(lib->dl, "ps_abi_version");
  *(void **)&lib->manifest = dlsym(lib->dl, "ps_manifest");
  *(void **)&lib->invoke = dlsym(lib->dl, "ps_invoke");
  if (!lib->abi_version || !lib->manifest || !lib->invoke) {
    set_err(err, errlen, "library does not export the ps_* connector surface", path);
    ps_close(lib);
    return -1;
  }
  if (lib->abi_version() != PS_CONNECTOR_ABI) {
    set_err(err, errlen, "unsupported connector ABI version", NULL);
    ps_close(lib);
    return -1;
  }
  lib->text = lib->manifest();

  static const struct { const char *name; uint64_t want; } layout[] = {
    { "PS_VALUE_SIZE", sizeof(ps_value) },
    { "PS_VALUE_ALIGN", _Alignof(ps_value) },
    { "PS_VALUE_OFF_KIND", offsetof(ps_value, kind) },
    { "PS_VALUE_OFF_WORD", offsetof(ps_value, word) },
    { "PS_VALUE_OFF_ADDR", offsetof(ps_value, addr) },
    { "PS_VALUE_OFF_LEN", offsetof(ps_value, len) },
  };
  for (size_t i = 0; i < sizeof layout / sizeof layout[0]; i++) {
    uint64_t got;
    if (!ps_const(lib, "LAYOUT", layout[i].name, &got) || got != layout[i].want) {
      set_err(err, errlen, "manifest layout does not match ps_value", layout[i].name);
      ps_close(lib);
      return -1;
    }
  }
  for (int k = 0; k < PS_KIND_COUNT; k++) {
    uint64_t tag;
    if (!ps_const(lib, "KIND", kind_names[k], &tag) || tag > 255) {
      set_err(err, errlen, "manifest lacks kind tag", kind_names[k]);
      ps_close(lib);
      return -1;
    }
    lib->kind_tag[k] = (uint8_t)tag;
  }
  return 0;
}

void ps_close(ps_lib *lib) {
  if (lib->dl) dlclose(lib->dl);
  memset(lib, 0, sizeof *lib);
}

ps_value ps_int(const ps_lib *lib, ps_kind kind, int64_t v) {
  ps_value c;
  memset(&c, 0, sizeof c);
  c.kind = lib->kind_tag[kind];
  c.word = (uint64_t)v;
  return c;
}

ps_value ps_bytes(const ps_lib *lib, const void *ptr, size_t len) {
  ps_value c;
  memset(&c, 0, sizeof c);
  c.kind = lib->kind_tag[PS_BYTES];
  c.addr = (uint64_t)(uintptr_t)ptr;
  c.len = (uint64_t)len;
  return c;
}

uint8_t ps_call(const ps_lib *lib, const char *name, const ps_value *args,
                uint32_t n, ps_value *out) {
  uint16_t tag = ps_fn_tag(lib, name);
  uint64_t unknown = 1;
  if (tag == 0) {
    ps_const(lib, "STATUS", "UNKNOWN_FN", &unknown);
    return (uint8_t)unknown;
  }
  return lib->invoke(tag, args, n, out);
}
