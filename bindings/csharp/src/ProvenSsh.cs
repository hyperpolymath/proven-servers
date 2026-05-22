// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-ssh-bastion protocol.
// Wraps the C-ABI functions from protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>SSH bastion connection states (tags 0-5).</summary>
    public enum BastionState : byte
    {
        Connected = 0, KeyExchanged = 1, Authenticated = 2,
        ChannelOpen = 3, Active = 4, Closed = 5
    }

    /// <summary>SSH authentication methods (tags 0-3).</summary>
    public enum SshAuthMethod : byte
    {
        Publickey = 0, Password = 1, KeyboardInteractive = 2, None = 3
    }

    /// <summary>SSH key exchange methods (tags 0-5).</summary>
    public enum SshKexMethod : byte
    {
        DiffieHellmanGroup14Sha256 = 0, Curve25519Sha256 = 1,
        DiffieHellmanGroup16Sha512 = 2, DiffieHellmanGroup18Sha512 = 3,
        EcdhSha2Nistp256 = 4, EcdhSha2Nistp384 = 5
    }

    /// <summary>SSH channel types (tags 0-3).</summary>
    public enum SshChannelType : byte
    {
        Session = 0, DirectTcpip = 1, ForwardedTcpip = 2, X11 = 3
    }

    /// <summary>SSH channel states (tags 0-3).</summary>
    public enum SshChannelState : byte
    {
        Opening = 0, Open = 1, Closing = 2, Closed = 3
    }

    /// <summary>SSH disconnect reason codes (tags 0-11).</summary>
    public enum SshDisconnectReason : byte
    {
        HostNotAllowed = 0, ProtocolError = 1, KeyExchangeFailed = 2,
        HostAuthFailed = 3, MacError = 4, ServiceNotAvailable = 5,
        VersionNotSupported = 6, HostKeyNotVerifiable = 7,
        ConnectionLost = 8, ByApplication = 9,
        TooManyConnections = 10, AuthCancelled = 11
    }

    /// <summary>
    /// C# bindings for the proven SSH Bastion protocol.
    /// Lifecycle: Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active -> Closed.
    /// </summary>
    public static class ProvenSsh
    {
        private const string Lib = "proven_ssh_bastion";

        [DllImport(Lib)] private static extern uint ssh_bastion_abi_version();
        [DllImport(Lib)] private static extern int ssh_bastion_create(byte kexMethod, byte authMethod);
        [DllImport(Lib)] private static extern void ssh_bastion_destroy(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_state(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_kex_method(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_auth_method(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_can_transfer(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_disconnect_reason(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_auth_failures(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_complete_kex(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_authenticate(int slot, ushort userLen);
        [DllImport(Lib)] private static extern byte ssh_bastion_record_auth_failure(int slot);
        [DllImport(Lib)] private static extern int ssh_bastion_open_channel(int slot, byte chType);
        [DllImport(Lib)] private static extern byte ssh_bastion_confirm_channel(int slot, byte chId);
        [DllImport(Lib)] private static extern byte ssh_bastion_close_channel(int slot, byte chId);
        [DllImport(Lib)] private static extern byte ssh_bastion_channel_state(int slot, byte chId);
        [DllImport(Lib)] private static extern byte ssh_bastion_channel_type(int slot, byte chId);
        [DllImport(Lib)] private static extern byte ssh_bastion_channel_count(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_rekey(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_disconnect(int slot, byte reason);
        [DllImport(Lib)] private static extern byte ssh_bastion_can_transition(byte from, byte to);
        [DllImport(Lib)] private static extern uint ssh_bastion_audit_count(int slot);
        [DllImport(Lib)] private static extern byte ssh_bastion_audit_entry(int slot, uint entryIdx);
        [DllImport(Lib)] private static extern byte ssh_bastion_audit_entry_to(int slot, uint entryIdx);
        [DllImport(Lib)] private static extern byte ssh_bastion_set_recording(int slot, byte enabled);
        [DllImport(Lib)] private static extern byte ssh_bastion_is_recording(int slot);

        public static uint AbiVersion() => ssh_bastion_abi_version();

        /// <summary>Create a new SSH bastion session.</summary>
        public static int Create(SshKexMethod kex, SshAuthMethod auth) =>
            ProvenError.CheckSlot(ssh_bastion_create((byte)kex, (byte)auth));

        public static void Destroy(int slot) => ssh_bastion_destroy(slot);

        public static BastionState? State(int slot)
        {
            byte tag = ssh_bastion_state(slot);
            return tag <= 5 ? (BastionState)tag : null;
        }

        public static SshKexMethod? KexMethod(int slot)
        {
            byte tag = ssh_bastion_kex_method(slot);
            return tag <= 5 ? (SshKexMethod)tag : null;
        }

        public static SshAuthMethod? AuthMethod(int slot)
        {
            byte tag = ssh_bastion_auth_method(slot);
            return tag <= 3 ? (SshAuthMethod)tag : null;
        }

        public static bool CanTransferData(int slot) => ssh_bastion_can_transfer(slot) == 1;

        public static SshDisconnectReason? DisconnectReason(int slot)
        {
            byte tag = ssh_bastion_disconnect_reason(slot);
            return tag <= 11 ? (SshDisconnectReason)tag : null;
        }

        public static byte AuthFailures(int slot) => ssh_bastion_auth_failures(slot);

        /// <summary>Complete key exchange. Connected -> KeyExchanged.</summary>
        public static void CompleteKex(int slot) =>
            ProvenError.CheckStatus(ssh_bastion_complete_kex(slot));

        /// <summary>Authenticate user. KeyExchanged -> Authenticated.</summary>
        public static void Authenticate(int slot) =>
            ProvenError.CheckStatus(ssh_bastion_authenticate(slot, 0));

        /// <summary>Record a failed auth attempt. Returns true if locked out (3+).</summary>
        public static bool RecordAuthFailure(int slot) =>
            ssh_bastion_record_auth_failure(slot) == 1;

        /// <summary>Open a channel. Returns channel ID (0-9).</summary>
        public static int OpenChannel(int slot, SshChannelType chType) =>
            ProvenError.CheckSlot(ssh_bastion_open_channel(slot, (byte)chType));

        /// <summary>Confirm a channel (Opening -> Open).</summary>
        public static void ConfirmChannel(int slot, byte chId) =>
            ProvenError.CheckStatus(ssh_bastion_confirm_channel(slot, chId));

        /// <summary>Close a channel.</summary>
        public static void CloseChannel(int slot, byte chId) =>
            ProvenError.CheckStatus(ssh_bastion_close_channel(slot, chId));

        public static SshChannelState? GetChannelState(int slot, byte chId)
        {
            byte tag = ssh_bastion_channel_state(slot, chId);
            return tag <= 3 ? (SshChannelState)tag : null;
        }

        public static SshChannelType? GetChannelType(int slot, byte chId)
        {
            byte tag = ssh_bastion_channel_type(slot, chId);
            return tag <= 3 ? (SshChannelType)tag : null;
        }

        public static byte ChannelCount(int slot) => ssh_bastion_channel_count(slot);

        /// <summary>Re-key the session. Only valid in Active state.</summary>
        public static void Rekey(int slot) => ProvenError.CheckStatus(ssh_bastion_rekey(slot));

        /// <summary>Disconnect with a reason.</summary>
        public static void Disconnect(int slot, SshDisconnectReason reason) =>
            ProvenError.CheckStatus(ssh_bastion_disconnect(slot, (byte)reason));

        public static bool CanTransition(BastionState from, BastionState to) =>
            ssh_bastion_can_transition((byte)from, (byte)to) == 1;

        public static uint AuditCount(int slot) => ssh_bastion_audit_count(slot);

        public static BastionState? AuditEntryFrom(int slot, uint index)
        {
            byte tag = ssh_bastion_audit_entry(slot, index);
            return tag <= 5 ? (BastionState)tag : null;
        }

        public static BastionState? AuditEntryTo(int slot, uint index)
        {
            byte tag = ssh_bastion_audit_entry_to(slot, index);
            return tag <= 5 ? (BastionState)tag : null;
        }

        /// <summary>Enable or disable session recording.</summary>
        public static void SetRecording(int slot, bool enabled) =>
            ProvenError.CheckStatus(ssh_bastion_set_recording(slot, (byte)(enabled ? 1 : 0)));

        public static bool IsRecording(int slot) => ssh_bastion_is_recording(slot) == 1;
    }
}
