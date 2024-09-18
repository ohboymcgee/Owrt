package types

import "core:bufio"
import "core:bytes"
import "core:os"
import "core:fmt"

import "core:mem"
import vmem "core:mem/virtual"


MODULE_MAGIC :: [4]byte{ 0x00, 0x61, 0x73, 0x6d }
WASM_VERSION :: [4]byte{ 0x01, 0x00, 0x00, 0x00 }

MAGIC_AND_VERSION :: [8]byte{ 0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00 }

Module_Flag :: enum {
    MAGIC_AND_VERSION,
    VALIDATED,
    

}

Module_Flags :: bit_set[Module_Flag]

Section_Flags :: bit_set[Section_Id]




Wasm_Module :: struct {
    flags: struct {
        module_flags: Module_Flags,
        section_flags: Section_Flags,
    },
    file_path: string,
    buf: []byte `fmt:"2x"`,
    
    custom_sections: [dynamic]Custom_Section_Contents,
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

    arena: vmem.Arena `fmt:"-"`,
    //allocator: mem.Allocator,
}

/* Module_Reader :: struct {
    mode: Module_Reader_Mode,
    module: ^Wasm_Module,
    using reader: ^bufio.Reader,
    section_buffer: []Wasm_Section_Base,
    //offset: int,
}
 */

Reader_Metadata :: map[i64]string


Module_Reader :: struct {
    mode: Module_Reader_Mode,
    module_path: string,
    //file: Maybe(os.Handle),
    module: ^Wasm_Module,
    current_section: Section,
    meta: Reader_Metadata,
    rd: bytes.Reader  `fmt:"-"`,
    //_rd: bufio.Reader,
}


Module_Reader_Function_Table :: [Module_Reader_Mode]proc(m: ^Module_Reader) -> (Error)

Module_Reader_Mode :: enum {
    No_File,
    Read_Magic_And_Version,
    Read_Section_Info,
    Read_Section_Name,
    Read_Custom_Section,
    
    Read_Custom_Section_Contents,
    Read_Type_Section_Contents,
    Read_Import_Section_Contents,
    Read_Function_Section_Contents,    
    Read_Table_Section_Contents,
    Read_Memory_Section_Contents,
    Read_Global_Section_Contents,
    Read_Export_Section_Contents,
    Read_Start_Section_Contents,
    Read_Element_Section_Contents,
    Read_Code_Section_Contents,
    Read_Data_Section_Contents,
    Read_Data_Count_Section_Contents,

    Read_Type_Encoding,
    Read_Value,
    Read_Vector,
    Read_Index,
    Read_Address,
    Error_Handling,

    Done,
}




