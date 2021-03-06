open Extend_protocol.Reader

let () =
  Reason_config.recoverable := true

module Reason_reader = struct
  type t = buffer

  let load buffer = buffer

  let parse {text; path} =
    let l = String.length path in
    let buf = Lexing.from_string text in
    Location.init buf (Filename.basename path);
    if l > 0 && path.[l - 1] = 'i' then
      Signature (Reason_toolchain.JS.canonical_interface buf)
    else
      Structure (Reason_toolchain.JS.canonical_implementation buf)

  let for_completion t _ =
    ({complete_labels = true}, parse t)

  let parse_line t pos line =
    let buf = Lexing.from_string line in
    Structure (Reason_toolchain.JS.canonical_implementation buf)

  let ident_at t _ = []

  let print_outcome ppf =
    let open Reason_oprint in function
    | Out_value          x -> print_out_value          ppf x
    | Out_type           x -> print_out_type           ppf x
    | Out_class_type     x -> print_out_class_type     ppf x
    | Out_module_type    x -> print_out_module_type    ppf x
    | Out_sig_item       x -> print_out_sig_item       ppf x
    | Out_signature      x -> print_out_signature      ppf x
    | Out_type_extension x -> print_out_type_extension ppf x
    | Out_phrase         x -> print_out_phrase         ppf x
end

let () =
  let open Extend_main in
  extension_main
    ~reader:(Reader.make_v0 (module Reason_reader : V0))
    (Description.make_v0 ~name:"reason" ~version:"0.1")
