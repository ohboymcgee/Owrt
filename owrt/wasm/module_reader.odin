package wasmrt

import "core:os/os2"
import "core:bufio"
import "core:mem"
import "core:bytes"
import "core:strings"

import "../types"



Module_Reader :: types.Module_Reader/* :: struct {
    mode: Module_Reader_Mode,
    module: ^Wasm_Module,
    using reader: ^bufio.Reader,
    section_buffer: []Wasm_Section_Base,
    //offset: int,
} */



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


module_reader_init :: proc(rd: ^Module_Reader, file: ^os2.File) {
    rd^ = {}
    rd.reader^ = {} 
    rd.module^ = {}
    f_size, f_size_err := os2.file_size(file)
    bytes.buffer_init_allocator(&rd.module.bytes, 0, mem.align_formula(int(f_size), 16))
    n_read, read_err :=os2.read(file, rd.module.bytes.buf[:])
    rd.module.file_path = strings.clone(os2.name(file))
    
    
    
}