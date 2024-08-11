package owrt

WASM_PAGE_SIZE :: 65536

Runtime :: struct {
    store: ^Wasm_Store,
    stack: ^Wasm_Stack,
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
    type: Global_Type_Encoding,
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