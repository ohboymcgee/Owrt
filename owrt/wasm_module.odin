package owrt

import "core:mem"
import vmem "core:mem/virtual"

import "types"

wasm_module_bootstrap_allocator :: proc() -> (mod: ^types.Wasm_Module, error: Error) {
    return vmem.arena_growing_bootstrap_new_by_name(types.Wasm_Module, "arena")
}

get_allocator :: proc(mod: ^types.Wasm_Module) -> (a: mem.Allocator) {
    return vmem.arena_allocator(&mod.arena)
}