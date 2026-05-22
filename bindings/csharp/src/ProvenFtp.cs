// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-ftp protocol.
// Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>FTP session states (tags 0-4).</summary>
    public enum FtpSessionState : byte
    {
        Connected = 0, UserOk = 1, Authenticated = 2, Renaming = 3, Quit = 4
    }

    /// <summary>FTP transfer states (tags 0-3).</summary>
    public enum FtpTransferState : byte
    {
        Idle = 0, InProgress = 1, Completed = 2, Aborted = 3
    }

    /// <summary>
    /// C# bindings for the proven FTP server protocol.
    /// Session: Connected -> UserOk -> Authenticated -> Quit.
    /// </summary>
    public static class ProvenFtp
    {
        private const string Lib = "proven_ftp";

        [DllImport(Lib)] private static extern uint ftp_abi_version();
        [DllImport(Lib)] private static extern int ftp_create();
        [DllImport(Lib)] private static extern void ftp_destroy(int slot);
        [DllImport(Lib)] private static extern byte ftp_state(int slot);
        [DllImport(Lib)] private static extern byte ftp_transfer_type(int slot);
        [DllImport(Lib)] private static extern byte ftp_data_mode(int slot);
        [DllImport(Lib)] private static extern byte ftp_transfer_state(int slot);
        [DllImport(Lib)] private static extern ulong ftp_bytes_transferred(int slot);
        [DllImport(Lib)] private static extern uint ftp_file_count(int slot);
        [DllImport(Lib)] private static extern ushort ftp_last_reply_code(int slot);
        [DllImport(Lib)] private static extern uint ftp_cwd(int slot, byte[] buf, uint bufLen);
        [DllImport(Lib)] private static extern byte ftp_user(int slot, byte[] name, uint len);
        [DllImport(Lib)] private static extern byte ftp_pass(int slot, byte[] pass, uint len);
        [DllImport(Lib)] private static extern byte ftp_quit(int slot);
        [DllImport(Lib)] private static extern byte ftp_cwd_cmd(int slot, byte[] path, uint pathLen);
        [DllImport(Lib)] private static extern byte ftp_cdup(int slot);
        [DllImport(Lib)] private static extern byte ftp_set_type(int slot, byte typeTag);
        [DllImport(Lib)] private static extern byte ftp_set_passive(int slot);
        [DllImport(Lib)] private static extern byte ftp_set_active(int slot, ushort port);
        [DllImport(Lib)] private static extern byte ftp_begin_transfer(int slot);
        [DllImport(Lib)] private static extern byte ftp_add_bytes(int slot, ulong count);
        [DllImport(Lib)] private static extern byte ftp_complete_transfer(int slot);
        [DllImport(Lib)] private static extern byte ftp_abort_transfer(int slot);
        [DllImport(Lib)] private static extern byte ftp_begin_rename(int slot);
        [DllImport(Lib)] private static extern byte ftp_complete_rename(int slot);
        [DllImport(Lib)] private static extern byte ftp_can_transfer(byte stateTag);
        [DllImport(Lib)] private static extern byte ftp_can_transition(byte from, byte to);

        public static uint AbiVersion() => ftp_abi_version();
        public static int Create() => ProvenError.CheckSlot(ftp_create());
        public static void Destroy(int slot) => ftp_destroy(slot);

        public static FtpSessionState? State(int slot)
        {
            byte tag = ftp_state(slot);
            return tag <= 4 ? (FtpSessionState)tag : null;
        }

        public static byte TransferType(int slot) => ftp_transfer_type(slot);
        public static byte DataMode(int slot) => ftp_data_mode(slot);

        public static FtpTransferState? GetTransferState(int slot)
        {
            byte tag = ftp_transfer_state(slot);
            return tag <= 3 ? (FtpTransferState)tag : null;
        }

        public static ulong BytesTransferred(int slot) => ftp_bytes_transferred(slot);
        public static uint FileCount(int slot) => ftp_file_count(slot);
        public static ushort LastReplyCode(int slot) => ftp_last_reply_code(slot);
        public static uint Cwd(int slot, byte[] buf) => ftp_cwd(slot, buf, (uint)buf.Length);

        /// <summary>USER command. Transitions Connected -> UserOk.</summary>
        public static void User(int slot, byte[] name) =>
            ProvenError.CheckStatus(ftp_user(slot, name, (uint)name.Length));

        /// <summary>PASS command. Transitions UserOk -> Authenticated.</summary>
        public static void Pass(int slot, byte[] pass) =>
            ProvenError.CheckStatus(ftp_pass(slot, pass, (uint)pass.Length));

        /// <summary>QUIT command.</summary>
        public static void Quit(int slot) => ProvenError.CheckStatus(ftp_quit(slot));

        /// <summary>CWD command.</summary>
        public static void ChangeDir(int slot, byte[] path) =>
            ProvenError.CheckStatus(ftp_cwd_cmd(slot, path, (uint)path.Length));

        /// <summary>CDUP command.</summary>
        public static void ChangeDirUp(int slot) => ProvenError.CheckStatus(ftp_cdup(slot));

        /// <summary>TYPE command. 0=ASCII, 1=binary.</summary>
        public static void SetType(int slot, byte typeTag) =>
            ProvenError.CheckStatus(ftp_set_type(slot, typeTag));

        public static void SetPassive(int slot) => ProvenError.CheckStatus(ftp_set_passive(slot));
        public static void SetActive(int slot, ushort port) => ProvenError.CheckStatus(ftp_set_active(slot, port));
        public static void BeginTransfer(int slot) => ProvenError.CheckStatus(ftp_begin_transfer(slot));
        public static void AddBytes(int slot, ulong count) => ProvenError.CheckStatus(ftp_add_bytes(slot, count));
        public static void CompleteTransfer(int slot) => ProvenError.CheckStatus(ftp_complete_transfer(slot));
        public static void AbortTransfer(int slot) => ProvenError.CheckStatus(ftp_abort_transfer(slot));
        public static void BeginRename(int slot) => ProvenError.CheckStatus(ftp_begin_rename(slot));
        public static void CompleteRename(int slot) => ProvenError.CheckStatus(ftp_complete_rename(slot));

        public static bool CanTransfer(FtpSessionState state) => ftp_can_transfer((byte)state) == 1;
        public static bool CanTransition(FtpSessionState from, FtpSessionState to) =>
            ftp_can_transition((byte)from, (byte)to) == 1;
    }
}
