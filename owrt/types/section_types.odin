package types



Wasm_Section_Base :: struct {
    id: Section_Id,
    size: u32,
    contents: []byte `fmt:"2x"`,
}

Section :: union #shared_nil {
    ^Custom_Section_Contents,
    ^Type_Section_Contents,
    ^Import_Section_Contents,
    ^Function_Section_Contents,    
    ^Table_Section_Contents,
    ^Memory_Section_Contents,
    ^Global_Section_Contents,
    ^Export_Section_Contents,
    ^Start_Section_Contents,
    ^Element_Section_Contents,
    ^Code_Section_Contents,
    ^Data_Section_Contents,
    ^Data_Count_Section_Contents,
}

IMPORT_DESCRIPTION_ENCODING :: enum byte {
    FUNC = 0x00,
    TABLE = 0x01,
    MEM = 0x02,
    GLOBAL = 0x03,
}

Import_Description :: struct {
    encoding: IMPORT_DESCRIPTION_ENCODING,
    kind: union {
        TYPE_INDEX,
        Wasm_Table_Type,
        Wasm_Memory_Type,
        Wasm_Global_Type,
    },
    index: Import_Index_Kind,
}

Limit_Unbounded :: struct {
    min: u32,

}

Limit_Bounded :: struct {
    min: u32,
    max: u32
}

Limit :: union {
    Limit_Unbounded,
    Limit_Bounded,
    
}


Wasm_Memory_Type :: struct {
    limit: Limit,
}

Wasm_Table_Type :: struct {
    ref_t: Reference_Type_Encoding,
    limit: Limit,
}

Wasm_Import :: struct {
    mod: Wasm_Name,
    nm: Wasm_Name,
    import_description: Import_Description, 
}

Custom_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    name: Wasm_Name,
    data: []byte,
}

Type_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Function_Type)
}

Import_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Import),
}

Function_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(u32),
}

Table_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Table_Type),
}

Memory_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Memory_Type),
}

Global_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Global),
}



EXPORT_DESCRIPTION_KIND :: enum byte {
    FUNC_IDX = 0x00,
    TABLE_IDX = 0x01,
    MEM_IDX = 0x02,
    GLOBAL_IDX = 0x03,
}

Export_Description :: struct {
    kind: EXPORT_DESCRIPTION_KIND,
    index: u32,
}

Wasm_Export :: struct {
    nm: Wasm_Name,
    desc: Export_Description,
}

Export_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Export),
}

Start_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    start: u32,
}


Element_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Elem),
}

Wasm_Code_Entry :: struct {
    locals: Wasm_Vector(Value_Type_Encoding),
    body: Wasm_Expression,
}

Code_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Wasm_Code_Entry),
}


Mode_Bitfield :: bit_field u32 {
    passive: bool | 1,
    active_explicit_address: bool | 1,
    address: u32 | 30,
}


Data_Segment_Active :: struct {
    i: Mode_Bitfield,
    e: Wasm_Expression,
    b: Wasm_Vector(byte),
}

Data_Segment_Passive :: struct {
    i: Mode_Bitfield,
    b: Wasm_Vector(byte),
}

Data_Segment_Active_Addressed :: struct {
    i: Mode_Bitfield,
    x: u32,
    e: Wasm_Expression,
    b: Wasm_Vector(byte),
}


Data_Segment :: union {
    Data_Segment_Active,
    Data_Segment_Passive,
    Data_Segment_Active_Addressed,
}

Data_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    vec: Wasm_Vector(Data_Segment),
}

Data_Count_Section_Contents :: struct {
    using base: Wasm_Section_Base,
    n: Maybe(u32),
}

Section_Id :: enum byte {
    CUSTOM_SECTION = 0,
    TYPE_SECTION,
    IMPORT_SECTION,
    FUNCTION_SECTION,
    TABLE_SECTION,
    MEMORY_SECTION,
    GLOBAL_SECTION,
    EXPORT_SECTION,
    START_SECTION,
    ELEMENT_SECTION,
    CODE_SECTION,
    DATA_SECTION,
    DATA_COUNT_SECTION,
}