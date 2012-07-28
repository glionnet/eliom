(* Ocsigen
 * http://www.ocsigen.org
 * Module eliom_client_types.ml
 * Copyright (C) 2010 Vincent Balat
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

(** Types shared by client and server. *)

open Eliom_lib
open Eliom_content_core

type sitedata = {
  site_dir: string list;
  site_dir_string: string;
}

type server_params
val sp : server_params

(* Marshal an OCaml value into a string. All characters are escaped *)
val jsmarshal : 'a -> string
val string_escape : string -> string

(**/**)

type eliom_js_page_data = {
  (* Event handlers *)
  ejs_event_handler_table: Xml.event_handler_table;
  ejs_initializations: (int64 * int * poly) list;
  ejs_onload: Dom_html.event Xml.caml_event_handler list;
  ejs_onunload: Dom_html.event Xml.caml_event_handler list;
  (* Session info *)
  ejs_sess_info: Eliom_common.sess_info;
}

type 'a eliom_caml_service_data = {
  ecs_onload: Dom_html.event Xml.caml_event_handler list;
  ecs_data: 'a;
}

(* the data sent on channels *)
type 'a eliom_comet_data_type = 'a Eliom_wrap.wrapped_value

(*SGO* Server generated onclicks/onsubmits

val a_closure_id : int
val a_closure_id_string : string
val get_closure_id : int
val get_closure_id_string : string
val post_closure_id : int
val post_closure_id_string : string

val eliom_temporary_form_node_name : string
*)

(*POSTtabcookies* forms with tab cookies in POST params:

val add_tab_cookies_to_get_form_id : int
val add_tab_cookies_to_get_form_id_string : string
val add_tab_cookies_to_post_form_id : int
val add_tab_cookies_to_post_form_id_string : string

*)


val encode_eliom_data : 'a -> string

val string_escape : string -> string
