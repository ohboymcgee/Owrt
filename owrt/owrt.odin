package owrt

import "core:mem"


import "ui"
import "wasm"
import "types"
import "core:sync/chan"

import "core:thread"

Dual_Chan :: types.Dual_Chan




set_gui_allocator :: proc(allocator: mem.Allocator) -> (ok: bool)

set_wasm_allocator :: proc(allocator: mem.Allocator) -> (ok: bool)
