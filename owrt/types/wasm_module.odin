package types

import "core:bufio"
import "core:bytes"

Wasm_Error_Code :: enum {
    NONE,
    INVALID_MAGIC,
    UNKNOWN_VERSION,
    FAILED_TO_READ_SECTION_INFO,
}

Wasm_Error :: struct {
    code: Wasm_Error_Code,
    message: string,
    
}

MODULE_MAGIC :: [4]byte{ 0x00, 0x61, 0x73, 0x6d }
WASM_VERSION :: [4]byte{ 0x01, 0x00, 0x00, 0x00 }

MAGIC_AND_VERSION :: [8]byte{ 0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00 }



Wasm_Module :: struct {
    file_path: string,
    bytes: bytes.Buffer,
    custom_sections: []Custom_Section_Contents,
    type_sec: Type_Section_Contents,
    import_sec: Import_Section_Contents,
    func_sec: Function_Section_Contents,
    table_sec: Table_Section_Contents,
    mem_sec: Memory_Section_Contents,
    global_sec: Global_Section_Contents,
    export_sec: Export_Section_Contents,
    start_sec: Start_Section_Contents,
    elem_sec: Element_Section_Contents,
    data_count_sec: Data_Count_Section_Contents,
    code_sec: Code_Section_Contents,
    data_sec: Data_Section_Contents,
}

Module_Reader :: struct {
    mode: Module_Reader_Mode,
    module: ^Wasm_Module,
    using reader: ^bufio.Reader,
    section_buffer: []Wasm_Section_Base,
    //offset: int,
}



Module_Reader_Function_Table :: [Module_Reader_Mode]proc(m: ^Module_Reader) -> (Module_Reader_Mode)

Module_Reader_Mode :: enum {

    Read_Magic_And_Version,
    Read_Section_Info,
    Read_Section_Name,
    Read_Custom_Section,
    Read_Type_Encoding,
    Read_Value,
    Read_Vector,
    Read_Index,
    Read_Address,
    Error_Handling,

    Done,
}
