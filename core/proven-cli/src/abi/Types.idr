-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CLIABI.Types: C-ABI-compatible numeric representations of proven-cli types.
--
-- Maps every constructor of the core CLI sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof guaranteeing encoding/decoding never loses information.
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/cli.zig) exactly.
--
-- Types covered:
--   ArgTypeTag     (6 constructors, tags 0-5)
--   ParseResult    (2 constructors, tags 0-1)
--   ParseErrorTag  (7 constructors, tags 0-6)
--   OptionDefErrTag(4 constructors, tags 0-3)
--   CmdDefErrTag   (5 constructors, tags 0-4)

module CLIABI.Types

import CLI.ArgType
import CLI.Option
import CLI.Command

%default total

---------------------------------------------------------------------------
-- ArgTypeTag (6 constructors, tags 0-5)
-- Note: EnumArg carries data; at the ABI level we use a sentinel tag.
---------------------------------------------------------------------------

public export
argTypeTagSize : Nat
argTypeTagSize = 1

||| ABI-level tag for argument type (data-free discriminant).
public export
data ArgTypeTag = StringTag | IntTag | BoolTag | FloatTag | PathTag | EnumTag

||| Encode ArgType to its ABI tag value.
public export
argTypeToTag : ArgType -> Bits8
argTypeToTag StringArg    = 0
argTypeToTag IntArg       = 1
argTypeToTag BoolArg      = 2
argTypeToTag FloatArg     = 3
argTypeToTag PathArg      = 4
argTypeToTag (EnumArg _)  = 5

public export
tagToArgTypeTag : Bits8 -> Maybe ArgTypeTag
tagToArgTypeTag 0 = Just StringTag
tagToArgTypeTag 1 = Just IntTag
tagToArgTypeTag 2 = Just BoolTag
tagToArgTypeTag 3 = Just FloatTag
tagToArgTypeTag 4 = Just PathTag
tagToArgTypeTag 5 = Just EnumTag
tagToArgTypeTag _ = Nothing

public export
argTypeTagToTag : ArgTypeTag -> Bits8
argTypeTagToTag StringTag = 0
argTypeTagToTag IntTag    = 1
argTypeTagToTag BoolTag   = 2
argTypeTagToTag FloatTag  = 3
argTypeTagToTag PathTag   = 4
argTypeTagToTag EnumTag   = 5

public export
argTypeTagRoundtrip : (t : ArgTypeTag) -> tagToArgTypeTag (argTypeTagToTag t) = Just t
argTypeTagRoundtrip StringTag = Refl
argTypeTagRoundtrip IntTag    = Refl
argTypeTagRoundtrip BoolTag   = Refl
argTypeTagRoundtrip FloatTag  = Refl
argTypeTagRoundtrip PathTag   = Refl
argTypeTagRoundtrip EnumTag   = Refl

---------------------------------------------------------------------------
-- ParseResult (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
parseResultSize : Nat
parseResultSize = 1

||| Result tag for parse operations.
public export
data ParseResultTag = ParseOk | ParseErr

public export
parseResultToTag : ParseResultTag -> Bits8
parseResultToTag ParseOk  = 0
parseResultToTag ParseErr = 1

public export
tagToParseResult : Bits8 -> Maybe ParseResultTag
tagToParseResult 0 = Just ParseOk
tagToParseResult 1 = Just ParseErr
tagToParseResult _ = Nothing

public export
parseResultRoundtrip : (r : ParseResultTag) -> tagToParseResult (parseResultToTag r) = Just r
parseResultRoundtrip ParseOk  = Refl
parseResultRoundtrip ParseErr = Refl

---------------------------------------------------------------------------
-- ParseErrorTag (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
parseErrorTagSize : Nat
parseErrorTagSize = 1

||| ABI-level tags for argument parse errors.
public export
data ParseErrorTag
  = NotAnIntegerTag
  | NotABooleanTag
  | NotAFloatTag
  | EmptyPathTag
  | PathContainsNullTag
  | InvalidEnumTag
  | ArgTooLongTag

public export
parseErrorToTag : ParseErrorTag -> Bits8
parseErrorToTag NotAnIntegerTag     = 0
parseErrorToTag NotABooleanTag      = 1
parseErrorToTag NotAFloatTag        = 2
parseErrorToTag EmptyPathTag        = 3
parseErrorToTag PathContainsNullTag = 4
parseErrorToTag InvalidEnumTag      = 5
parseErrorToTag ArgTooLongTag       = 6

public export
tagToParseError : Bits8 -> Maybe ParseErrorTag
tagToParseError 0 = Just NotAnIntegerTag
tagToParseError 1 = Just NotABooleanTag
tagToParseError 2 = Just NotAFloatTag
tagToParseError 3 = Just EmptyPathTag
tagToParseError 4 = Just PathContainsNullTag
tagToParseError 5 = Just InvalidEnumTag
tagToParseError 6 = Just ArgTooLongTag
tagToParseError _ = Nothing

public export
parseErrorRoundtrip : (e : ParseErrorTag) -> tagToParseError (parseErrorToTag e) = Just e
parseErrorRoundtrip NotAnIntegerTag     = Refl
parseErrorRoundtrip NotABooleanTag      = Refl
parseErrorRoundtrip NotAFloatTag        = Refl
parseErrorRoundtrip EmptyPathTag        = Refl
parseErrorRoundtrip PathContainsNullTag = Refl
parseErrorRoundtrip InvalidEnumTag      = Refl
parseErrorRoundtrip ArgTooLongTag       = Refl

---------------------------------------------------------------------------
-- OptionDefErrTag (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
optionDefErrSize : Nat
optionDefErrSize = 1

||| ABI-level tags for option definition errors.
public export
data OptionDefErrTag
  = DupShortTag
  | DupLongTag
  | EmptyLongTag
  | ReqWithDefTag

public export
optionDefErrToTag : OptionDefErrTag -> Bits8
optionDefErrToTag DupShortTag  = 0
optionDefErrToTag DupLongTag   = 1
optionDefErrToTag EmptyLongTag = 2
optionDefErrToTag ReqWithDefTag = 3

public export
tagToOptionDefErr : Bits8 -> Maybe OptionDefErrTag
tagToOptionDefErr 0 = Just DupShortTag
tagToOptionDefErr 1 = Just DupLongTag
tagToOptionDefErr 2 = Just EmptyLongTag
tagToOptionDefErr 3 = Just ReqWithDefTag
tagToOptionDefErr _ = Nothing

public export
optionDefErrRoundtrip : (e : OptionDefErrTag) -> tagToOptionDefErr (optionDefErrToTag e) = Just e
optionDefErrRoundtrip DupShortTag  = Refl
optionDefErrRoundtrip DupLongTag   = Refl
optionDefErrRoundtrip EmptyLongTag = Refl
optionDefErrRoundtrip ReqWithDefTag = Refl

---------------------------------------------------------------------------
-- CmdDefErrTag (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
cmdDefErrSize : Nat
cmdDefErrSize = 1

||| ABI-level tags for command definition errors.
public export
data CmdDefErrTag
  = EmptyCmdNameTag
  | CmdNameSpacesTag
  | SubcmdTooDeepTag
  | DupSubcmdTag
  | OptErrorsTag

public export
cmdDefErrToTag : CmdDefErrTag -> Bits8
cmdDefErrToTag EmptyCmdNameTag  = 0
cmdDefErrToTag CmdNameSpacesTag = 1
cmdDefErrToTag SubcmdTooDeepTag = 2
cmdDefErrToTag DupSubcmdTag     = 3
cmdDefErrToTag OptErrorsTag     = 4

public export
tagToCmdDefErr : Bits8 -> Maybe CmdDefErrTag
tagToCmdDefErr 0 = Just EmptyCmdNameTag
tagToCmdDefErr 1 = Just CmdNameSpacesTag
tagToCmdDefErr 2 = Just SubcmdTooDeepTag
tagToCmdDefErr 3 = Just DupSubcmdTag
tagToCmdDefErr 4 = Just OptErrorsTag
tagToCmdDefErr _ = Nothing

public export
cmdDefErrRoundtrip : (e : CmdDefErrTag) -> tagToCmdDefErr (cmdDefErrToTag e) = Just e
cmdDefErrRoundtrip EmptyCmdNameTag  = Refl
cmdDefErrRoundtrip CmdNameSpacesTag = Refl
cmdDefErrRoundtrip SubcmdTooDeepTag = Refl
cmdDefErrRoundtrip DupSubcmdTag     = Refl
cmdDefErrRoundtrip OptErrorsTag     = Refl
