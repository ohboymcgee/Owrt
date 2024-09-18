package owrt

import "types"
import "core:bufio"
import "core:bytes"
import "core:os"
import "core:io"
import "core:slice"
import "core:fmt"
import "core:encoding/varint"
import "core:log"

Module_Reader_Mode :: types.Module_Reader_Mode
Error :: types.Error
Section_Id :: types.Section_Id

Encoding_Base :: types.Encoding_Base

reader_make_allocator :: proc(allocator := context.allocator) -> (res: ^types.Module_Reader, error: Error) {
    res = new(types.Module_Reader) or_return
    res.mode = .No_File
    res.meta = make(types.Reader_Metadata)
    
    //bufio.lookahead_reader_buffer()
    //bytes.buffer_init_allocator(&res.buf, 0, 4096, allocator)
    return
}

reader_reset :: proc(reader: ^types.Module_Reader, free_previous_module: bool = true) {
    if free_previous_module {
        free(reader.module)
    }
    clear(&reader.meta)
    reader.module = nil
    reader.mode = .No_File
    reader.current_section = nil
    reader.rd.i = 0
    reader.rd.prev_rune = 0
    reader.rd.s = nil
    
    //reader.rd.i = 0
    
}

reader_open_wasm_mem :: proc(reader: ^types.Module_Reader, data: []byte) -> (error: Error) {
    reader.module = wasm_module_bootstrap_allocator() or_return //new(types.Wasm_Module) or_return
    reader.module.buf = data
    bytes.reader_init(&reader.rd, reader.module.buf)
    
    reader.mode = .Read_Magic_And_Version
    
    return
}

reader_open_wasm_file :: proc(reader: ^types.Module_Reader, path: string) -> (error: Error) {
    //reader.file = os.open(path) or_return
    file_data := os.read_entire_file_from_filename_or_err(path) or_return
    reader.module = wasm_module_bootstrap_allocator() or_return //new(types.Wasm_Module) or_return
    reader.module_path = path
    reader.module.file_path = path
    reader.module.buf = file_data
    
    bytes.reader_init(&reader.rd, file_data)

    reader.mode = .Read_Magic_And_Version
    return
    
}



reader_destroy :: proc(reader: ^types.Module_Reader) {
    //bytes.buffer_destroy(&reader.buf)
    //bufio.reader_destroy((^bufio.Reader)(&reader._rd))
    
    delete(reader.module_path)
    delete(reader.meta)
    free(reader)
}
reader_read :: proc(reader: ^types.Module_Reader) -> (done: bool = false, error: Error) {

    when ODIN_DEBUG {
        log.debugf("\n Reader Index:\n%v of %v", reader.rd.i, len(&reader.module.buf))
    }
    #partial switch reader.mode {
        case .No_File:
            done = true
            error = reader_no_file(reader)
            
        case .Read_Magic_And_Version:
            verify_magic(reader) or_return
            if len(reader.module.buf) == 8 {
                reader.module.flags.module_flags += {.VALIDATED}
                return true, nil
            }
            reader.mode = .Read_Section_Info
            
        case .Read_Section_Info:
            error = reader_read_section_info(reader)
            
        case .Read_Type_Section_Contents:
            error = reader_read_type_section(reader)
            
        
        case .Read_Import_Section_Contents:
            error = reader_read_import_section(reader)
            

        case .Read_Function_Section_Contents:
            error = reader_read_func_section(reader)
            
        case .Read_Table_Section_Contents:
            error = reader_read_table_section(reader)

        case .Read_Memory_Section_Contents:
            error = reader_read_mem_section(reader)

        case .Read_Export_Section_Contents:
            error = reader_read_export_section(reader)

        case:
            err := new(types.Wasm_Error)
            err.code = .FUNCTIONALITY_NOT_IMPLEMENTED
            err.message = fmt.aprintf("readmode %v is not currently implemented", reader.mode)
            error = err

            
            
    }
    if error == io.Error.EOF {
        done = true
    }
    return
    
}
    
reader_no_file :: proc(reader: ^types.Module_Reader) -> (Error) {
    err := new(types.Wasm_Error)
    err.code = .NO_FILE
    err.message = "Module Reader has no file.  Try setting one with reader_load_wasm_file"
    return err
}

reader_read_index :: reader_read_size

reader_read_size :: proc(reader: ^types.Module_Reader) -> (size: u32, error: Error) {
    //data := bufio.reader_peek(reader, 5) or_return
    buf := [5]byte{}
    data := buf[:]
    n_read, err := bytes.reader_read(&reader.rd, data)
    if err != nil && err != .EOF {
        error = err 
        return
    }
    v, s := varint.decode_uleb128_buffer(data) or_return
    when ODIN_DEBUG {
        log.debugf("\nLEB DECODE: %x -> %i\n%i bytes read, size %i\n", data, v, n_read, s)
    }
    
    if s > 5 {
        err := new(types.Wasm_Error)
        err.code = .IMPROPER_LEB_DECODE
        err.message = fmt.aprintf("Failed to decode leb string, %x, %i, %i", data, v, s)
        return 0, err
    }
    size = u32(v)
    for i in 0..<(n_read - s) {
        bytes.reader_unread_byte(&reader.rd) or_return
    }

    //bufio.reader_discard(reader, s) or_return
    return
    
}

is_value_encoding :: proc(b: byte) -> (t: types.Value_Type_Encoding, error: Error) {
    switch b {
        case 0x6f..=0x70:
            t = (types.Reference_Type_Encoding)(b)
            return
        case 0x7b:
            t = types.Simd_Vector_Type_Ecoding.V128
            return
        case 0x7c..=0x7f:
            t = (types.Number_Type_Ecoding)(b)
            return
        case:
            err := new(types.Wasm_Error)
            err.code = .IMPROPERLY_FORMED_SECTION
            err.message = fmt.aprintf("Expected value type encoding got %x", b)
            error = err
            return
    }
    return
}



set_section_base :: proc(section: ^types.Section, base: types.Wasm_Section_Base) {
    switch v in section {
        case ^types.Custom_Section_Contents:
            v.base = base
        case ^types.Type_Section_Contents:
            v.base = base
        case ^types.Import_Section_Contents:
            v.base = base
        case ^types.Function_Section_Contents:
            v.base = base
        case ^types.Table_Section_Contents:
            v.base = base
        case ^types.Memory_Section_Contents:
            v.base = base
        case ^types.Global_Section_Contents:
            v.base = base
        case ^types.Export_Section_Contents:
            v.base = base
        case ^types.Start_Section_Contents:
            v.base = base
        case ^types.Element_Section_Contents:
            v.base = base
        case ^types.Code_Section_Contents:
            v.base = base
        case ^types.Data_Section_Contents:
            v.base = base
        case ^types.Data_Count_Section_Contents:
            v.base = base
    }
}

reader_set_current_section :: proc(using reader: ^types.Module_Reader, sid: Section_Id, append_custom: bool) {
    switch sid {
        case .TYPE_SECTION: current_section = &module.type_sec
        case .IMPORT_SECTION: current_section = &module.import_sec
        case .FUNCTION_SECTION: current_section = &module.func_sec
        case .TABLE_SECTION: current_section = &module.table_sec
        case .MEMORY_SECTION: current_section = &module.mem_sec
        case .GLOBAL_SECTION: current_section = &module.global_sec
        case .EXPORT_SECTION: current_section = &module.export_sec
        case .START_SECTION: current_section = &module.start_sec
        case .ELEMENT_SECTION: current_section = &module.elem_sec
        case .CODE_SECTION: current_section = &module.code_sec
        case .DATA_SECTION: current_section = &module.data_sec
        case .DATA_COUNT_SECTION: current_section = &module.data_count_sec
        case .CUSTOM_SECTION:
            if module.custom_sections == nil {
                module.custom_sections = make([dynamic]types.Custom_Section_Contents)
                append_elem(&module.custom_sections, types.Custom_Section_Contents{})
            }
            if append_custom do append_elem(&module.custom_sections, types.Custom_Section_Contents{})
            
            current_section = slice.last_ptr(module.custom_sections[:])

    }
}

id_to_readmode :: proc(sid: Section_Id) -> (mode: Module_Reader_Mode) {
    switch sid {
        case .TYPE_SECTION: mode = .Read_Type_Section_Contents
        case .IMPORT_SECTION: mode = .Read_Import_Section_Contents
        case .FUNCTION_SECTION: mode = .Read_Function_Section_Contents
        case .TABLE_SECTION: mode = .Read_Table_Section_Contents
        case .MEMORY_SECTION: mode = .Read_Memory_Section_Contents
        case .GLOBAL_SECTION: mode = .Read_Global_Section_Contents
        case .EXPORT_SECTION: mode = .Read_Export_Section_Contents
        case .START_SECTION: mode = .Read_Start_Section_Contents
        case .ELEMENT_SECTION: mode = .Read_Element_Section_Contents
        case .CODE_SECTION: mode = .Read_Code_Section_Contents
        case .DATA_SECTION: mode = .Read_Data_Section_Contents
        case .DATA_COUNT_SECTION: mode = .Read_Data_Count_Section_Contents
        case .CUSTOM_SECTION: mode = .Read_Custom_Section
    }
    return
}


reader_read_limit :: proc(reader: ^types.Module_Reader) -> (l: types.Limit, error: Error) {
    limit_encoding := bytes.reader_read_byte(&reader.rd) or_return
    switch limit_encoding {
        case 0x00:
            min_bound := reader_read_size(reader) or_return
            l = types.Limit_Unbounded{ min = min_bound }
        case 0x01:
            min_bound := reader_read_size(reader) or_return
            max_bound := reader_read_size(reader) or_return
            l = types.Limit_Bounded{min = min_bound, max = max_bound}
        case:
            err := new(types.Wasm_Error)
            err.code = .IMPROPERLY_ENCODED_LIMIT
            err.message = "Limit is not properly encoed"
            error = err
            
    }
    return
} 

reader_read_reftype :: proc(reader: ^types.Module_Reader) -> (rt: types.Reference_Type_Encoding, error: Error) {
    ref_t := bytes.reader_read_byte(&reader.rd) or_return
    switch ref_t {
        case 0x70:
            return .FUNC_REF, nil
        case 0x6f:
            return .EXTERN_REF, nil
        case:
            err := new(types.Wasm_Error)
            err.code = .IMPROPERLY_ENCODED_REFTYPE
            err.message = "Reftype must be 0x70 or 0x6f"
            error = err
            return
    }
}

reader_read_numtype :: proc(reader: ^types.Module_Reader) -> (n: types.Wasm_Values, error: Error) {
    val_enc := bytes.reader_read_byte(&reader.rd) or_return
    switch val_enc {
        case 0x7c:
            buf := [8]byte{}
            f := bytes.reader_read(&reader.rd, buf[:]) or_return
            n = transmute(f64)(buf)
        case 0x7d:
            buf := [4]byte{}
            f := bytes.reader_read(&reader.rd, buf[:]) or_return
            n = transmute(f32)(buf)
        case 0x7e:
            buf := [9]byte{}
            f := bytes.reader_read(&reader.rd, buf[:]) or_return
            v, s := varint.decode_ileb128_buffer(buf[:]) or_return
            n = i64(v)
            for i in 0..<(9-s) {
                bytes.reader_unread_byte(&reader.rd)
            }
            
        case 0x7f:
            buf := [5]byte{}
            f := bytes.reader_read(&reader.rd, buf[:]) or_return
            v, s := varint.decode_ileb128_buffer(buf[:]) or_return
            n = i32(v)
            for i in 0..<(5-s) {
                bytes.reader_unread_byte(&reader.rd)
            }
        case:
            err := new(types.Wasm_Error)
            err.code = .INCORRECT_TYPE_ENCODING
            err.message = "Expected a number type encoding"
            error = err

    }
    return
}

reader_read_value_type :: proc(reader: ^types.Module_Reader) -> (v: types.Value_Type, error: Error) {
    val_enc := bytes.reader_read_byte(&reader.rd) or_return
    switch val_enc {
        case 0x7b:
            v_buf := [16]byte{}
            v.enc = .V128
            bytes.reader_read(&reader.rd, v_buf[:]) or_return
            v.val = v_buf            
        case 0x70: case 0x6f:
            //bytes.reader_unread_byte(&reader.rd)
            v.enc = reader_read_reftype(reader) or_return
        case 0x7c..=0x7f:
            //bytes.reader_unread_byte(&reader.rd)
            v.val = reader_read_numtype(reader) or_return
        case:
            err := new(types.Wasm_Error)
            err.code = .INCORRECT_TYPE_ENCODING
            err.message = "Expected value types"
            error = err
    }
    return
}

reader_read_global_type :: proc(reader: ^types.Module_Reader) -> (g: types.Wasm_Global_Type, error: Error) {
    g.val_t = reader_read_value_type(reader) or_return
    log.debugf("val_t: %v", g.val_t)
    mut := bytes.reader_read_byte(&reader.rd) or_return
    log.debugf("mutablity: %v", mut)
    if mut == 0x00 do g.mut = .CONST
    else if mut == 0x01 do g.mut = .VAR
    else {
        err := new(types.Wasm_Error)
        err.code = .INCORRECT_TYPE_ENCODING
        err.message = "Expecting global mutablility encoding"
        error = err
    }
    return

}

reader_read_instruction :: proc(reader: ^types.Module_Reader) -> (op: types.WASM_OPCODES, error: Error) {
    b, b_err := bytes.reader_read_byte(&reader.rd)
    if b_err != nil && b_err != .EOF {
        error = b_err
        return
    }
    
    if b >= 0xbf {
        op = types.WASM_OPCODES(b)
        
    } else {
        err := new(types.Wasm_Error)
        err.code = .UNSUPPORTED_OPCODE
        err.message = fmt.aprintf("byte %x is not a supported opcode", b)
        error = err
    }
    return


}

reader_read_expression :: proc(reader: ^types.Module_Reader) -> (exp: types.Wasm_Expression, error: Error) {
    exp.end = .END
    opcodes := make([dynamic]types.WASM_OPCODES)
    for {
        op := reader_read_instruction(reader) or_return
        if op == .END do break
        append(&opcodes, op)
    }
    exp.instructions = opcodes[:]
    return
}
/* reader_read_encoding :: proc(reader: ^types.Module_Reader) -> (t: types.Type_Encodings, error: Error) {
    encoding := bytes.reader_read_byte(&reader.rd) or_return
    if (encoding in )
    switch encoding {
        case 
    }
} */




/*
0000000000000000 0061736d01000000 //Magic & Version
0000000000000008 01060160017e017e //Type Section
0000000000000016 0302010007090105 
0000000000000024 676172626f00000a 
0000000000000032 0701050020000f0b
*/

verify_magic :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    magic := types.MAGIC_AND_VERSION
    buf := [8]byte{}
    //data := bufio.lookahead_reader_peek(reader, 8) or_return
    
    //_ = bufio.reader_read(reader, buf[:]) or_return
    bytes.reader_read(&reader.rd, buf[:]) or_return
    if !slice.equal(buf[:], magic[:]) {
        err := new(types.Wasm_Error)
        err.code = .INVALID_MAGIC
        err.message = fmt.aprintf("Expeced: %x Got: %x", magic[:], buf[:])
        return err
    }
    reader.module.flags.module_flags += {.MAGIC_AND_VERSION}
    
    //if bufio.reader_read()
    //bufio.lookahead_reader_consume(reader, 8) or_return
    return
    
    
    

}