package wasmrt

import "core:os/os2"
import "base:runtime"
import "core:bytes"
import "core:slice"
import "core:simd"
import "core:strings"
import "core:testing"
import "core:bufio"
import "core:log"
import "core:io"
import "core:fmt"
import "core:mem"

import "../types"



Wasm_Error :: types.Wasm_Error
MAGIC_AND_VERSION :: types.MAGIC_AND_VERSION
MODULE_MAGIC :: types.MODULE_MAGIC
WASM_VERSION :: types.WASM_VERSION
Wasm_Module :: types.Wasm_Module 


module_buffer_reader :: proc(m: ^Wasm_Module) -> (io.Reader, bool) {
    return io.to_reader(bytes.buffer_to_stream(&m.bytes))
}

//format_module_bytes :: proc(reader )


/* reader_table : Module_Reader_Function_Table = {
    Read_Magic_And_Version = read_magic_and_version,
    Read_Section_Info = read_section_info,
} */

read_magic_and_version :: proc(m: ^Module_Reader) -> (mode: Module_Reader_Mode) {
    read_buf := [8]u8{}

    n, e := bufio.reader_read(m, read_buf[:])

    if read_buf != MAGIC_AND_VERSION {
        return .Error_Handling
    }
    return .Read_Section_Info



}

/* read_magic :: proc(m: ^Module_Reader) -> (mode: Module_Reader_Mode) {
    num_read, read_err := bufio.reader_read(m.reader, m.module.magic[:])
    if (m.module.magic != MODULE_MAGIC) {
        return .Error_Handling, 
            { message = "Invalid Magic", code = .INVALID_MAGIC }
    }
    m.offset += num_read
    m.mode = .Read_Version
    mode = .Read_Version
    return
} */
/* 
read_version :: proc(m: ^Module_Reader) -> (mode: Module_Reader_Mode) {
    num_read, read_err := bufio.reader_read(m.reader, m.module.version[:])
    if (m.module.version != WASM_VERSION) {
        return .Error_Handling, { message ="Unknown Version", code = .UNKNOWN_VERSION }
    }
    m.offset += num_read
    m.mode = .Read_Section_Info
    mode = .Read_Section_Info
    return
}
 */
/* read_section_info :: proc(m: ^Module_Reader) -> (mode: Module_Reader_Mode) {
    section_info := Wasm_Section_Base{}
    read_error: io.Error
    section_id: byte
    section_size_buf: [4]byte = {}
    section_size_buf_len: int
    section_id, read_error = bufio.reader_read_byte(m.reader)
    if !(read_error == nil || read_error == .None) {
        return .Error_Handling, { message = "Section Info Read Error: Kind", code = .FAILED_TO_READ_SECTION_INFO }
    }
    m.offset += 1
    if section_id == 0 {
        m.mode = .Read_Custom_Section
        return 
    }
    section_info.section_id = SECTION_ID(section_id)
    section_size_buf_len, read_error = bufio.reader_read(m.reader, section_size_buf[:])
    
    if !(read_error == nil || read_error == .None) {
        return .Error_Handling, { message = "Section Info Read Error: Size", code = .FAILED_TO_READ_SECTION_INFO }
    }
    m.offset += section_size_buf_len
    section_info.size = transmute(u32)(section_size_buf)
    switch section_info.section_id {
        case .TYPE_SECTION:
            m.mode = .Read_Type_Section
            mode = .Read_Type_Section
        case .IMPORT_SECTION:
            m.mode = .Read_Import_Section
            mode = .Read_Import_Section
        case .
    }
} */


/* Module_Section_Reader :: struct {
    kind: SECTION_ID,
    index: 
} */

read_section_decl :: proc()

read_module :: proc(
    path: string, 
    logger: log.Logger,
    allocator: runtime.Allocator = context.allocator,
    
) -> (
        module: ^Wasm_Module, 
        err: Wasm_Error = { code = .NONE, message = "" }) {
    context.logger = logger
    context.allocator = allocator
    reader := bufio.Reader {}    
    when ODIN_DEBUG {
        log.debug("\nIn read_module:")
    }
    file, file_open_err := os2.open(path)
    defer os2.close(file)
    //f_info, f_info_err := file->fstat(context.allocator)
    f_size, f_size_err := os2.file_size(file)
    //os2.file_i

    module_buffer, module_buffer_error := make([]byte, f_size)
    defer delete(module_buffer)
    //defer os2.file_info_delete(f_info, context.allocator)
    bufio.reader_init(&reader, io.to_reader(file.stream))
    
    defer bufio.reader_destroy(&reader)
    data, file_err := bufio.reader_peek(&reader, 8)
    bytes_read, module_read_err := bufio.reader_read(&reader, module_buffer)
    
    //reader_table[.Read_Magic]()
    /* m_rdr := Module_Reader {}
    m_rdr.mode = reader_table[m_rdr.mode](&m) */
    //data, file_err := os2.read_entire_file_from_path(path, context.allocator)
    //data, file_err := os2.o
    when ODIN_DEBUG {
        log.debugf("\nFile Size: %v\nMagic & Version: %v\nFile Err?: %v\n\nModule_Data: %#x\n", f_size, data, file_err, module_buffer)
    }

    

    magic : [4]byte = { data[0], data[1], data[2], data[3] }
    version : [4]byte = { data[4], data[5], data[6], data[7] }
    //slice.simple_equal()
    if magic != MODULE_MAGIC {
        return nil, { code = .INVALID_MAGIC, message = "Invalid Magic" }
    }
    if version != WASM_VERSION {
        return nil, { code = .UNKNOWN_VERSION, message = "Unknown Version" }
    }

    module_allocation_err : runtime.Allocator_Error
    module, module_allocation_err = new(Wasm_Module)

    if f_size == 8 {
        return
    }

    iteration := 0
    
    for b, i in module_buffer {
        
    }
    
    




    return
}

@test
read_test :: proc(t: ^testing.T) {
    
    
    context.allocator = t.channel.impl.allocator
    context.logger = log.create_console_logger()
    

    log.debugf("\nCurrentDir: %#v !! Error: %#v\n", os2.get_working_directory(context.allocator))


    test_dir := ".\\wasmtests\\compiled_modules"
    
    dir_contents, err := os2.read_directory_by_path(test_dir, 2, context.allocator)
    log.debugf("\nDIR-CONTENTS:\n%#v\nERROR:  %#v\n", dir_contents, err)
    defer os2.file_info_slice_delete(dir_contents, context.allocator)

    reader := bufio.Reader{}
    

    for fi, index in dir_contents {
        name := fi.fullpath
        log.debugf("\nPATH NAME %#v\n\n", name)
        if testing.expectf(t, strings.ends_with(name, ".wasm"), "\npath is not a wasm file: %v\n", name ) {
            //file_data, file_read_err := os2.read_entire_file_from_path(name, allocator)
            mod, mod_err := read_module(name, context.logger, context.allocator)
            log.debugf("\nModule:\n%v\nModule Read Error?:\n%#v", mod, mod_err)
        } else {
            log.errorf("\nTest failed:")
            testing.fail(t)
        }
        /* bufio.reader_destroy(&reader) */
        //log.debugf("\nmodule: %#v", module)
        
        
        
    }
    log.debugf("\n TOTAL ERRORS %#v", t.error_count)

    
}

