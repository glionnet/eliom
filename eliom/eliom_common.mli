(* Ocsigen
 * http://www.ocsigen.org
 * Module eliom_common.mli
 * Copyright (C) 2005 Vincent Balat
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

(** Low level functions for Eliom, exceptions and types. *)

open Ocsigen_extensions


exception Eliom_404 (** Page not found *)
exception Eliom_Wrong_parameter (** Service called with wrong parameter names *)
exception Eliom_Session_expired
exception Eliom_Typing_Error of (string * exn) list
    (** The service (GET or POST) parameters do not match expected type *)


exception Eliom_function_forbidden_outside_site_loading of string
    (** That function cannot be used like that outside the
       initialisation phase.
       For some functions, you must add the [~sp] parameter during a session.
     *)

val eliom_link_too_old : bool Polytables.key
(** If present and true in request data, it means that
    the previous coservice does not exist any more *)
val eliom_service_session_expired : (string list) Polytables.key
(** If present in request data,  means that
    the service session cookies does not exist any more.
    The string lists are the list of names of expired sessions
*)


(**/**)

exception Eliom_Suffix_redirection of string 
  (* We redirect to the suffix version of the service *)


(* Service kinds: *)
type att_key_serv =
  | SAtt_no (* regular service *)
  | SAtt_named of string (* named coservice *)
  | SAtt_anon of string (* anonymous coservice *)
  | SAtt_csrf_safe of (int * string option * bool option)
      (* CSRF safe anonymous coservice *)
      (* CSRF safe service registration delayed until form/link creation *)
      (* the int is an unique id,
         the string option is the session name for delayed registration
         (if the service is registered in the global table),
         the bool option is the ?secure parameter for delayed registration
         (if the service is registered in the global table) *)

type na_key_serv =
  | SNa_no (* no na information *)
  | SNa_void_keep (* void coservice that keeps GET na parameters *)
  | SNa_void_dontkeep (* void coservice that does not keep GET na parameters *)
  | SNa_get_ of string (* named *)
  | SNa_post_ of string (* named *)
  | SNa_get' of string (* anonymous *)
  | SNa_post' of string (* anonymous *)
  | SNa_get_csrf_safe of (int * string option * bool option)
      (* CSRF safe anonymous coservice *)
  | SNa_post_csrf_safe of (int * string option * bool option)
      (* CSRF safe anonymous coservice *)

(* the same, for incoming requests: *)
type att_key_req =
  | RAtt_no (* no coservice information *)
  | RAtt_named of string (* named coservice *)
  | RAtt_anon of string (* anonymous coservice *)

type na_key_req =
  | RNa_no (* no na information *)
  | RNa_get_ of string (* named *)
  | RNa_post_ of string (* named *)
  | RNa_get' of string (* anonymous *)
  | RNa_post' of string (* anonymous *)





exception Eliom_duplicate_registration of string
exception Eliom_there_are_unregistered_services of
            (string list * string list list * na_key_serv list)
exception Eliom_page_erasing of string
exception Eliom_error_while_loading_site of string

val defaultpagename : string
val eliom_suffix_name : string
val eliom_suffix_internal_name : string
val eliom_nosuffix_page : string
val naservice_num : string
val naservice_name : string
val get_state_param_name : string
val post_state_param_name : string
val get_numstate_param_name : string
val post_numstate_param_name : string
val co_param_prefix : string
val na_co_param_prefix : string
val nl_param_prefix : string

val datacookiename : string
val servicecookiename : string
val persistentcookiename : string
val sdatacookiename : string
val sservicecookiename : string
val spersistentcookiename : string

val persistent_cookie_table_version : string
val eliom_persistent_cookie_table : string

type cookie =
  | Set of Ocsigen_lib.url_path option * float option * string * string * bool
  | Unset of Ocsigen_lib.url_path option * string
type sess_info = {
  si_other_get_params : (string * string) list;
  si_all_get_params : (string * string) list;
  si_all_post_params : (string * string) list;
  si_service_session_cookies : string Ocsigen_lib.String_Table.t;
  si_data_session_cookies : string Ocsigen_lib.String_Table.t;
  si_persistent_session_cookies : string Ocsigen_lib.String_Table.t;
  si_secure_cookie_info:
    (string Ocsigen_lib.String_Table.t *
       string Ocsigen_lib.String_Table.t *
       string Ocsigen_lib.String_Table.t) option;
  si_nonatt_info : na_key_req;
  si_state_info: (att_key_req * att_key_req);
  si_previous_extension_error : int;

  si_na_get_params: (string * string) list Lazy.t;
  si_nl_get_params: (string * string) list Ocsigen_lib.String_Table.t;
  si_nl_post_params: (string * string) list Ocsigen_lib.String_Table.t;
  si_persistent_nl_get_params: (string * string) list Ocsigen_lib.String_Table.t Lazy.t;

  si_all_get_but_na_nl: (string * string) list Lazy.t;
  si_all_get_but_nl: (string * string) list;
}

module SessionCookies : Hashtbl.S with type key = string

type 'a session_cookie = SCNo_data | SCData_session_expired | SC of 'a

type cookie_exp = 
  | CENothing (* keep current browser value *)
  | CEBrowser (* ask to remove the cookie when the browser is closed *)
  | CESome of float (* date (not duration!) *)

type timeout = TGlobal | TNone | TSome of float
type 'a one_service_cookie_info = {
  sc_value : string;
  sc_table : 'a ref;
  sc_timeout : timeout ref;
  sc_exp : float option ref;
  sc_cookie_exp : cookie_exp ref;
  sc_session_group : Eliommod_sessiongroups.sessgrp option ref;
}
type one_data_cookie_info = {
  dc_value : string;
  dc_timeout : timeout ref;
  dc_exp : float option ref;
  dc_cookie_exp : cookie_exp ref;
  dc_session_group : Eliommod_sessiongroups.sessgrp option ref;
}
type one_persistent_cookie_info = {
  pc_value : string;
  pc_timeout : timeout ref;
  pc_cookie_exp : cookie_exp ref;
  pc_session_group : Eliommod_sessiongroups.perssessgrp option ref;
}

type 'a cookie_info1 =
    (string option * 'a one_service_cookie_info session_cookie ref)
    Ocsigen_lib.String_Table.t ref *
    (string option * one_data_cookie_info session_cookie ref) Lazy.t
    Ocsigen_lib.String_Table.t ref *
    ((string * timeout * float option *
      Eliommod_sessiongroups.perssessgrp option)
     option * one_persistent_cookie_info session_cookie ref)
    Lwt.t Lazy.t Ocsigen_lib.String_Table.t ref

type 'a cookie_info =
    'a cookie_info1 (* unsecure *) * 
      'a cookie_info1 option (* secure, if https *)

type 'a servicecookiestablecontent =
    string * 'a * float option ref * timeout ref *
    Eliommod_sessiongroups.sessgrp option ref
type 'a servicecookiestable = 'a servicecookiestablecontent SessionCookies.t
type datacookiestablecontent =
    string * float option ref * timeout ref *
    Eliommod_sessiongroups.sessgrp option ref
type datacookiestable = datacookiestablecontent SessionCookies.t
type page_table_key = {
  key_state : att_key_serv * att_key_serv;
  key_kind : Ocsigen_http_frame.Http_header.http_method;
}

module NAserv_Table : Map.S with type key = na_key_serv

type anon_params_type = int
type server_params = {
  sp_request : Ocsigen_extensions.request;
  sp_si : sess_info;
  sp_sitedata : sitedata;
  sp_cookie_info : tables cookie_info;
  sp_suffix : Ocsigen_lib.url_path option;
  sp_fullsessname : string option;
}
and page_table =
    (page_table_key *
     ((anon_params_type * anon_params_type) *
      (int *
       (int ref option * (float * float ref) option *
        (bool -> server_params -> Ocsigen_http_frame.result Lwt.t))))
     list)
    list
and naservice_table =
    AVide
  | ATable of
      (int * int ref option * (float * float ref) option *
       (server_params -> Ocsigen_http_frame.result Lwt.t))
      NAserv_Table.t
and dircontent = Vide | Table of direlt ref Ocsigen_lib.String_Table.t
and direlt = Dir of dircontent ref | File of page_table ref
and tables =
    {table_services : dircontent ref;
     table_naservices : naservice_table ref;
    (* Information for the GC: *)
     mutable table_contains_services_with_timeout : bool;
     (* true if dircontent contains services with timeout *)
     mutable table_contains_naservices_with_timeout : bool;
     (* true if naservice_table contains services with timeout *)
     mutable csrf_get_or_na_registration_functions :
       (sp:server_params -> string) Ocsigen_lib.Int_Table.t;
     mutable csrf_post_registration_functions :
       (sp:server_params -> 
         att_key_serv -> string) Ocsigen_lib.Int_Table.t
      (* These two table are used for CSRF safe services:
         We associate to each service unique id the function that will
         register a new anonymous coservice each time we create a link or form.
         Attached POST coservices may have both a GET and POST 
         registration function. That's why there are two tables.
         The functions associated to each service may be different for
         each session. That's why we use these table, and not a field in
         the service record.
      *)
    } 
and sitedata = {
  site_dir : Ocsigen_lib.url_path;
  site_dir_string : string;
  mutable servtimeout : (string * float option) list;
  mutable datatimeout : (string * float option) list;
  mutable perstimeout : (string * float option) list;
  global_services : tables;
  session_services : tables servicecookiestable;
  session_data : datacookiestable;
  mutable remove_session_data : string -> unit;
  mutable not_bound_in_data_tables : string -> bool;
  mutable exn_handler : server_params -> exn -> Ocsigen_http_frame.result Lwt.t;
  mutable unregistered_services : Ocsigen_lib.url_path list;
  mutable unregistered_na_services : na_key_serv list;
  mutable max_volatile_data_sessions_per_group : int option;
  mutable max_service_sessions_per_group : int option;
  mutable max_persistent_data_sessions_per_group : int option;
}
val make_server_params :
  sitedata ->
  tables cookie_info ->
  Ocsigen_extensions.request ->
  Ocsigen_lib.url_path option -> 
  sess_info -> string option -> server_params
val empty_page_table : unit -> 'a list
val empty_dircontent : unit -> dircontent
val empty_naservice_table : unit -> naservice_table
val service_tables_are_empty : tables -> bool
val empty_tables : unit -> tables
val new_service_session_tables : unit -> tables
val split_prefix_param :
  string -> (string * 'a) list -> (string * 'a) list * (string * 'a) list
val getcookies :
  string -> 'a Ocsigen_lib.String_Table.t -> 'a Ocsigen_lib.String_Table.t
val get_session_info :
  Ocsigen_extensions.request ->
  int -> (Ocsigen_extensions.request * sess_info) Lwt.t
type ('a, 'b) foundornot = Found of 'a | Notfound of 'b
val make_full_cookie_name : string -> string -> string
val make_fullsessname : sp:server_params -> string option -> string
val make_fullsessname2 : string -> string option -> string
exception Eliom_retry_with of
            (Ocsigen_extensions.request * sess_info * 
             tables cookie_info)
module Perstables :
  sig
    val empty : 'a list
    val add : 'a -> 'a list -> 'a list
    val fold : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
  end
val perstables : string list ref
val create_persistent_table : string -> 'a Ocsipersist.table
val persistent_cookies_table :
  (string * float option * timeout *
   Eliommod_sessiongroups.perssessgrp option)
  Ocsipersist.table Lazy.t
val remove_from_all_persistent_tables : string -> unit Lwt.t
val absolute_change_sitedata : sitedata -> unit
val get_current_sitedata : unit -> sitedata
val end_current_sitedata : unit -> unit
val add_unregistered : sitedata -> Ocsigen_lib.url_path -> unit
val add_unregistered_na : sitedata -> na_key_serv -> unit
val remove_unregistered : sitedata -> Ocsigen_lib.url_path -> unit
val remove_unregistered_na : sitedata -> na_key_serv -> unit
val verify_all_registered : sitedata -> unit
val during_eliom_module_loading : unit -> bool
val begin_load_eliom_module : unit -> unit
val end_load_eliom_module : unit -> unit
val global_register_allowed : unit -> (unit -> sitedata) option
val close_service_session2 :
  sitedata ->
  Eliommod_sessiongroups.sessgrp option -> SessionCookies.key -> unit


val eliom_params_after_action : 
  ((string * string) list * (string * string) list *
     (string * string) list Ocsigen_lib.String_Table.t *
     (string * string) list Ocsigen_lib.String_Table.t *
     (string * string) list)
  Polytables.key
 
val att_key_serv_of_req : att_key_req -> att_key_serv
val na_key_serv_of_req : na_key_req -> na_key_serv
