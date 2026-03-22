-- SPDX-License-Identifier: MPL-2.0
-- (PMPL-1.0-or-later preferred; MPL-2.0 required for GNAT ecosystem)
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Ada bindings for the proven-media server protocol.
--
-- Wraps the C-ABI functions exported by the Zig FFI layer.
-- All enumeration representation clauses match the Idris2 ABI tags exactly.

with Interfaces.C; use Interfaces.C;
with Proven_Error;

package Proven_Media is

   ---------------------------------------------------------------------------
   -- Enumeration types matching Idris2 ABI
   ---------------------------------------------------------------------------

   -- Media content types (tags 0-4).
   type Media_Content_Type is
     (Mc_Audio, Mc_Video, Mc_Live_Stream, Mc_Playlist, Mc_Subtitle);
   for Media_Content_Type use
     (Mc_Audio => 0, Mc_Video => 1, Mc_Live_Stream => 2,
      Mc_Playlist => 3, Mc_Subtitle => 4);
   pragma Convention (C, Media_Content_Type);

   -- Media codecs (tags 0-7).
   type Codec is
     (Codec_H264, Codec_H265, Codec_Av1, Codec_Vp9,
      Codec_Aac, Codec_Opus, Codec_Flac, Codec_Mp3);
   for Codec use
     (Codec_H264 => 0, Codec_H265 => 1, Codec_Av1 => 2, Codec_Vp9 => 3,
      Codec_Aac => 4, Codec_Opus => 5, Codec_Flac => 6, Codec_Mp3 => 7);
   pragma Convention (C, Codec);

   -- Media streaming protocols (tags 0-5).
   type Stream_Protocol is
     (Sp_Hls, Sp_Dash, Sp_Rtmp, Sp_Rtsp, Sp_Web_Rtc, Sp_Srt);
   for Stream_Protocol use
     (Sp_Hls => 0, Sp_Dash => 1, Sp_Rtmp => 2,
      Sp_Rtsp => 3, Sp_Web_Rtc => 4, Sp_Srt => 5);
   pragma Convention (C, Stream_Protocol);

   -- Transcoding quality profiles (tags 0-4).
   type Transcode_Profile is
     (Tp_Passthrough, Tp_Low, Tp_Medium, Tp_High, Tp_Ultra);
   for Transcode_Profile use
     (Tp_Passthrough => 0, Tp_Low => 1, Tp_Medium => 2,
      Tp_High => 3, Tp_Ultra => 4);
   pragma Convention (C, Transcode_Profile);

   -- Media player events (tags 0-7).
   type Player_Event is
     (Pe_Play, Pe_Pause, Pe_Seek, Pe_Stop,
      Pe_Buffer_Start, Pe_Buffer_End, Pe_Error, Pe_Quality_Change);
   for Player_Event use
     (Pe_Play => 0, Pe_Pause => 1, Pe_Seek => 2, Pe_Stop => 3,
      Pe_Buffer_Start => 4, Pe_Buffer_End => 5, Pe_Error => 6,
      Pe_Quality_Change => 7);
   pragma Convention (C, Player_Event);

   -- Media player states (tags 0-4).
   type Player_State is
     (Ps_Idle, Ps_Ready, Ps_Playing, Ps_Paused, Ps_Stopping);
   for Player_State use
     (Ps_Idle => 0, Ps_Ready => 1, Ps_Playing => 2,
      Ps_Paused => 3, Ps_Stopping => 4);
   pragma Convention (C, Player_State);


   ---------------------------------------------------------------------------
   -- Raw FFI imports (C ABI via Zig .so)
   ---------------------------------------------------------------------------

   function Abi_Version return unsigned;
   pragma Import (C, Abi_Version, "media_abi_version");

   function Create_Context return int;
   pragma Import (C, Create_Context, "media_create_context");

   procedure Destroy_Context (Slot : int);
   pragma Import (C, Destroy_Context, "media_destroy_context");

   function Get_State (Slot : int) return unsigned_char;
   pragma Import (C, Get_State, "media_state");

   function Can_Transition
     (From : unsigned_char;
      To   : unsigned_char) return unsigned_char;
   pragma Import (C, Can_Transition, "media_can_transition");

   ---------------------------------------------------------------------------
   -- Safe wrappers
   ---------------------------------------------------------------------------

   function Safe_Create_Context return Proven_Error.Slot_Id;
   procedure Safe_Destroy_Context (Slot : Proven_Error.Slot_Id);

end Proven_Media;
