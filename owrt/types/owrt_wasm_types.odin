package types


/* import "core:sys/wasm/wasi"


import "core:mem/virtual"


import "base:runtime" */

import "core:mem"

import "core:os/os2"
import "core:bytes"

import "core:sys/info"
import "core:thread"
import "core:sync"

WASM_PAGE_SIZE :: 65536

_trap :: proc() 

_ref :: proc(state: ^Runtime, addr: Func_Addr) 

_ref_extrern :: proc(state: ^Runtime, addr: Extern_Addr) 

_invoke :: proc(state: ^Runtime, addr: Func_Addr) 

_label :: proc(state: ^Runtime, label: ^Stack_Label) 

_frame :: proc(state: ^Runtime, frame_state: Activation_Frame) 




/* 


Supervisor :: struct {

    allocator: mem.Allocator,
    temp_allocator: mem.Allocator,
    
    runtimes: [dynamic]Runtime,
    module_reader: Module_Reader,
    //comms: Dual_Chan,
    data_passing: ^Simple_Message_Channel,
    info_allocator: mem.Allocator,
    sys_info: System_Info,
    owned_processes: [dynamic]Process_Info,
    external_processes: [dynamic]Process_Info,
    file_system: File_System,
    init: proc(self: ^Supervisor),
    destroy: proc(self: ^Supervisor),

}



System_Info :: struct {
    cpu_features: Maybe(info.CPU_Features),
    cpu_name: Maybe(string),
    ram: info.RAM,
    gpus: []info.GPU,
}



Process_Info :: struct {
    process: os2.Process,
    info: os2.Process_Info,
}

File_System :: struct {    
    infos: [dynamic]os2.File_Info,

}

 */
Runtime_Flag :: enum {
    Initialized,
    Has_Store,
    Has_Stack,
    Has_Module,

}

Runtime_Flags :: bit_set[Runtime_Flag]

Runtime :: struct {
    flags: Runtime_Flags,
    allocator: mem.Allocator,
    store: ^Wasm_Store,
    stack: ^Wasm_Stack,
    modules: [dynamic]Wasm_Module,

}

Wasm_Store :: struct {
    funcs: []Wasm_Function_Instance,
    tables: []Wasm_Table_Instance,
    memories: []Wasm_Memory_Instance,
    globals: []Wasm_Global_Instance,
    elems: []Wasm_Element_Instance,
    data: []Wasm_Data_Instance,
    exports: []Wasm_Export_Instance,
}

Stack_Label :: struct {
    arity: uint,
    target: []WASM_OPCODES,
}

Activation_Frame :: struct {
    return_arity: uint,
    locals: Wasm_Vector(Wasm_Values),
    module: Wasm_Module_Instance,
}

Wasm_Stack :: struct {
    values: []Wasm_Values,
    labels: []Stack_Label,
    frames: []Activation_Frame,
}

Wasm_Global_Instance :: struct {
    type: Wasm_Global_Type,
    value: Wasm_Values,
}

Wasm_Element_Instance :: struct {
    type: Reference_Type_Encoding,
    elem: Wasm_Vector(Wasm_Ref),
}

Wasm_Data_Instance :: struct {
    data: Wasm_Vector(byte),
}

Wasm_External_Value :: union {
    Func_Addr,
    Table_Addr,
    Mem_Addr,
    Global_Addr,
}

Wasm_Export_Instance :: struct {
    name: Wasm_Name,
    value: Wasm_External_Value,
}



Func :: struct {
    type: TYPE_INDEX,
    locals: Wasm_Vector(Value_Type_Encoding),
    body: Wasm_Expression,
}

Host_Func :: struct {
    type: TYPE_INDEX,
    host_code: rawptr,
}

Wasm_Function_Instance :: struct {
    type: Wasm_Function_Type,
    module: ^Wasm_Module_Instance,
    code: union { Func, Host_Func },
}
/* 
Wasm_Reference :: struct {
    t: Reference_Type_Encoding,
    v: Wasm_Ref,
} */

Wasm_Table_Instance :: struct {
    type: Table_Type_Encoding,
    elem: Wasm_Vector(Wasm_Ref),
}

Wasm_Module_Instance :: struct {
    types: []Wasm_Function_Type,
    func_addrs: []Func_Addr,
    table_addrs: []Table_Addr,
    mem_addrs: []Mem_Addr,
    global_addrs: []Global_Addr,
    elem_addrs: []Element_Addr,
    data_addrs: []Data_Addr,
    exports: []Wasm_Export_Instance
}

Wasm_Memory_Instance :: struct {
    type: Memory_Type_Encoding,
    data: Wasm_Vector(byte),
}