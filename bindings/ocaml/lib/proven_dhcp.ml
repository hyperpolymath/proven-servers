(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** DHCP protocol types for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-dhcp/ffi/zig/src/dhcp.zig]. *)

(** MessageType matching [MessageType] in dhcp.zig. *)
type message_type =
  | Discover  (** DHCPDISCOVER — client broadcasts to find servers (tag 0). *)
  | Offer  (** DHCPOFFER — server response with address offer (tag 1). *)
  | Request  (** DHCPREQUEST — client requests offered address (tag 2). *)
  | Ack  (** DHCPACK — server confirms address assignment (tag 3). *)
  | Nak  (** DHCPNAK — server rejects request (tag 4). *)
  | Release  (** DHCPRELEASE — client releases address (tag 5). *)
  | Inform  (** DHCPINFORM — client requests config without address (tag 6). *)
  | Decline  (** DHCPDECLINE — client rejects offered address (tag 7). *)

let message_type_to_tag = function
  | Discover -> 0
  | Offer -> 1
  | Request -> 2
  | Ack -> 3
  | Nak -> 4
  | Release -> 5
  | Inform -> 6
  | Decline -> 7

let message_type_of_tag = function
  | 0 -> Some Discover
  | 1 -> Some Offer
  | 2 -> Some Request
  | 3 -> Some Ack
  | 4 -> Some Nak
  | 5 -> Some Release
  | 6 -> Some Inform
  | 7 -> Some Decline
  | _ -> None

(** OptionCode matching [OptionCode] in dhcp.zig. *)
type option_code =
  | SubnetMask  (** Subnet Mask (option 1) (tag 0). *)
  | Router  (** Router (option 3) (tag 1). *)
  | Dns  (** DNS Server (option 6) (tag 2). *)
  | DomainName  (** Domain Name (option 15) (tag 3). *)
  | LeaseTime  (** IP Address Lease Time (option 51) (tag 4). *)
  | ServerId  (** Server Identifier (option 54) (tag 5). *)
  | RequestedIp  (** Requested IP Address (option 50) (tag 6). *)
  | MsgType  (** DHCP Message Type (option 53) (tag 7). *)

let option_code_to_tag = function
  | SubnetMask -> 0
  | Router -> 1
  | Dns -> 2
  | DomainName -> 3
  | LeaseTime -> 4
  | ServerId -> 5
  | RequestedIp -> 6
  | MsgType -> 7

let option_code_of_tag = function
  | 0 -> Some SubnetMask
  | 1 -> Some Router
  | 2 -> Some Dns
  | 3 -> Some DomainName
  | 4 -> Some LeaseTime
  | 5 -> Some ServerId
  | 6 -> Some RequestedIp
  | 7 -> Some MsgType
  | _ -> None

(** HardwareType matching [HardwareType] in dhcp.zig. *)
type hardware_type =
  | Ethernet  (** Ethernet (10Mb) (tag 0). *)
  | Ieee802  (** IEEE 802 Networks (tag 1). *)
  | Arcnet  (** ARCNET (tag 2). *)
  | FrameRelay  (** Frame Relay (tag 3). *)

let hardware_type_to_tag = function
  | Ethernet -> 0 | Ieee802 -> 1 | Arcnet -> 2 | FrameRelay -> 3

let hardware_type_of_tag = function
  | 0 -> Some Ethernet
  | 1 -> Some Ieee802
  | 2 -> Some Arcnet
  | 3 -> Some FrameRelay
  | _ -> None

(** DhcpState matching [DhcpState] in dhcp.zig. *)
type dhcp_state =
  | Idle  (** Idle — awaiting DHCPDISCOVER (tag 0). *)
  | DiscoverReceived  (** DHCPDISCOVER received (tag 1). *)
  | OfferSent  (** DHCPOFFER sent (tag 2). *)
  | RequestReceived  (** DHCPREQUEST received (tag 3). *)
  | AckSent  (** DHCPACK sent (tag 4). *)
  | NakSent  (** DHCPNAK sent (tag 5). *)

let dhcp_state_to_tag = function
  | Idle -> 0
  | DiscoverReceived -> 1
  | OfferSent -> 2
  | RequestReceived -> 3
  | AckSent -> 4
  | NakSent -> 5

let dhcp_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some DiscoverReceived
  | 2 -> Some OfferSent
  | 3 -> Some RequestReceived
  | 4 -> Some AckSent
  | 5 -> Some NakSent
  | _ -> None

(** LeaseState matching [LeaseState] in dhcp.zig. *)
type lease_state =
  | Available  (** Available in pool (tag 0). *)
  | Offered  (** Offered to a client (tag 1). *)
  | Bound  (** Bound — client actively using (tag 2). *)
  | Renewing  (** Renewing — client requesting lease extension (tag 3). *)
  | Rebinding  (** Rebinding — broadcast renewal attempt (tag 4). *)
  | Expired  (** Expired — lease no longer valid (tag 5). *)

let lease_state_to_tag = function
  | Available -> 0
  | Offered -> 1
  | Bound -> 2
  | Renewing -> 3
  | Rebinding -> 4
  | Expired -> 5

let lease_state_of_tag = function
  | 0 -> Some Available
  | 1 -> Some Offered
  | 2 -> Some Bound
  | 3 -> Some Renewing
  | 4 -> Some Rebinding
  | 5 -> Some Expired
  | _ -> None

(** RelaySubOption matching [RelaySubOption] in dhcp.zig. *)
type relay_sub_option =
  | CircuitId  (** Circuit ID — identifies the relay agent port (tag 0). *)
  | RemoteId  (** Remote ID — identifies the remote host (tag 1). *)

let relay_sub_option_to_tag = function
  | CircuitId -> 0 | RemoteId -> 1

let relay_sub_option_of_tag = function
  | 0 -> Some CircuitId
  | 1 -> Some RemoteId
  | _ -> None

(* --- C FFI declarations --- *)

external c_dhcp_abi_version : unit -> int = "dhcp_abi_version"
external c_dhcp_create_context : unit -> int = "dhcp_create_context"
external c_dhcp_destroy_context : int -> unit = "dhcp_destroy_context"
external c_dhcp_state : int -> int = "dhcp_state"
external c_dhcp_lease_state : int -> int = "dhcp_lease_state"
external c_dhcp_can_transition : int -> int -> int = "dhcp_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_dhcp_abi_version ()

let create_context () = Proven_error.from_slot (c_dhcp_create_context ())

let destroy_context slot = c_dhcp_destroy_context slot

let get_state slot = dhcp_state_of_tag (c_dhcp_state slot)

let can_transition ~from ~to_ =
  c_dhcp_can_transition (dhcp_state_to_tag from) (dhcp_state_to_tag to_) = 1
