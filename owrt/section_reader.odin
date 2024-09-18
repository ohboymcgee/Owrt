package owrt

import "types"
import "core:bytes"
import "core:fmt"
import "core:unicode/utf8"
import "core:slice"
import "core:strings"
import "core:log"
import "core:io"


reader_read_type_section :: proc(reader: ^types.Module_Reader/* , section_info: types.Wasm_Section_Base */) -> (error: Error) {
    

    _reader_check_flag(reader, .TYPE_SECTION) or_return
    
    //defer delete(buf)
    //read := bufio.reader_read(reader, buf) or_return
    
    c := reader.current_section.(^types.Type_Section_Contents)
    //buf := make([]byte, section_info.size)
    //bytes.reader_read(&reader.rd, buf) or_return
    //reader.rd.
    size := reader_read_size(reader) or_return
    c.vec.size = size
    enc := bytes.reader_read_byte(&reader.rd) or_return
    if enc != (byte)(Encoding_Base.FUNC) {
        err := new(types.Wasm_Error)
        err.code = .IMPROPERLY_FORMED_SECTION
        err.message = fmt.aprintf("type section improperly formed. Got %x expected %x", enc, (byte)(Encoding_Base.FUNC))
        return err
    }

    c.vec.encoding = types.Function_Type_Encoding.FUNCTION_TYPE
    function_types := make([dynamic]types.Wasm_Function_Type)

    for i in 0..<size {
        s := reader_read_size(reader) or_return
        t := bytes.reader_read_byte(&reader.rd) or_return
        enc := is_value_encoding(t) or_return
        arg_t := types.Result_Type_Encoding{}
        arg_t.size = s
        arg_t.value_encoding = enc

        s = reader_read_size(reader) or_return
        t = bytes.reader_read_byte(&reader.rd) or_return
        enc = is_value_encoding(t) or_return
        res_t := types.Result_Type_Encoding{}
        res_t.size = s
        res_t.value_encoding = enc

        f := types.Wasm_Function_Type {}
        f.args = arg_t
        f.returns = res_t
        append(&function_types, f)
        //append(&function_types, {})
        
    }

    c.vec.data = function_types[:]

    
    _reader_add_flag(reader, .TYPE_SECTION)
    reader.mode = .Read_Section_Info
  

    return
}

reader_read_import_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    

    _reader_check_flag(reader, .IMPORT_SECTION) or_return

    allocator := get_allocator(reader.module)
    c := reader.current_section.(^types.Import_Section_Contents)
    
    
    size := reader_read_size(reader) or_return
    c.vec.size = size
    imports := make([dynamic]types.Wasm_Import, allocator)
    for i in 0..<size {
        imp := types.Wasm_Import{}
        
        //m_buf := new([]byte, allocator)
        //n_buf := new([]byte, allocator)
        imp.mod = reader_read_name(reader) or_return
        imp.nm = reader_read_name(reader) or_return
        desc := bytes.reader_read_byte(&reader.rd) or_return
        switch desc {
            case 0x04..=0xff: 
                err := new(types.Wasm_Error)
                err.code = .IMPROPERLY_FORMED_SECTION
                err.message = "Invalid import description"
                return err
            case:
                imp.import_description.encoding = types.IMPORT_DESCRIPTION_ENCODING(desc)
                //bytes.reader_unread_byte(&reader.rd)
                switch imp.import_description.encoding {
                    case .FUNC:
                        idx := reader_read_index(reader) or_return
                        imp.import_description.kind = types.TYPE_INDEX(idx)
                        idx2 := reader_read_index(reader) or_return
                        imp.import_description.index  = types.FUNC_INDEX(idx2)
                        
                    case .MEM:
                        lim := reader_read_limit(reader) or_return
                        imp.import_description.kind = types.Wasm_Memory_Type { limit = lim }
                        
                    case .TABLE:
                        ref_t := reader_read_reftype(reader) or_return
                        lim := reader_read_limit(reader) or_return
                        imp.import_description.kind = types.Wasm_Table_Type { ref_t = ref_t, limit = lim }
                    case .GLOBAL:
                        glob_t := reader_read_global_type(reader) or_return
                        imp.import_description.kind = glob_t
                }

        }
       

        append(&imports, imp)
    }
    c.vec.data = imports[:]
    
    _reader_add_flag(reader, .IMPORT_SECTION)
    reader.mode = .Read_Section_Info
    return
}

reader_read_name :: proc(reader: ^types.Module_Reader) -> (name: types.Wasm_Name, error: Error) {
    size := reader_read_size(reader) or_return
    name = strings.string_from_ptr(&reader.module.buf[reader.rd.i], int(size))
    reader.rd.i += i64(size)
    
    
    return
}

reader_read_func_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    

    _reader_check_flag(reader, .FUNCTION_SECTION) or_return
    c := reader.current_section.(^types.Function_Section_Contents)
    //c.size = reader_read_size(reader) or_return
    c.vec.size = reader_read_size(reader) or_return

    idx_v := make([dynamic]u32)

    for i in 0..<c.vec.size {
        idx := reader_read_index(reader) or_return
        append(&idx_v, idx)
    }
    c.vec.data = idx_v[:]

    //reader.module.flags.section_flags += {.FUNCTION_SECTION}
    _reader_add_flag(reader, .FUNCTION_SECTION)
    reader.mode = .Read_Section_Info

    return

}

reader_read_table_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {

    
    _reader_check_flag(reader, .TABLE_SECTION) or_return

    c := reader.current_section.(^types.Table_Section_Contents)
    tables := make([dynamic]types.Wasm_Table_Type) 

    
    size := reader_read_size(reader) or_return
    c.vec.size = size

    for i in 0..<size {
        ref_t := reader_read_reftype(reader) or_return
        lim := reader_read_limit(reader) or_return
        append(&tables, types.Wasm_Table_Type{limit = lim, ref_t = ref_t})
    }
    c.vec.data = tables[:]
    
    _reader_add_flag(reader, .TABLE_SECTION)
    reader.mode = .Read_Section_Info
    return
    
}

reader_read_mem_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    

    _reader_check_flag(reader, .MEMORY_SECTION) or_return

    mems := make([dynamic]types.Wasm_Memory_Type)

    c := reader.current_section.(^types.Memory_Section_Contents)
    size := reader_read_size(reader) or_return
    for i in 0..<size {
        m := reader_read_limit(reader) or_return
        
        
        append(&mems, types.Wasm_Memory_Type{ limit = m })
    }

    c.vec.data = mems[:]
    
    _reader_add_flag(reader, .MEMORY_SECTION)
    reader.mode = .Read_Section_Info
    return
}

reader_read_global_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    
    _reader_check_flag(reader, .GLOBAL_SECTION) or_return

    globals := make([dynamic]types.Wasm_Global)

    c := reader.current_section.(^types.Global_Section_Contents)
    size := reader_read_size(reader) or_return
    for i in 0..<size {
        g := types.Wasm_Global{}
        g.type = reader_read_global_type(reader) or_return
        g.expression = reader_read_expression(reader) or_return
        append(&globals, g)
    }

    c.vec.data = globals[:]
    c.vec.size = size

    
    _reader_add_flag(reader, .GLOBAL_SECTION)
    reader.mode = .Read_Section_Info
    return
    
}

@(private)
_reader_check_flag :: #force_inline proc(reader: ^types.Module_Reader, section: types.Section_Id) -> (error: Error) {
    if (section in reader.module.flags.section_flags) {
        err := new(types.Wasm_Error)
        err.code = .DUPLICATE_SECTION
        err.message = "This module already has a types section"
        return err
    }
    return
}

@(private)
_reader_add_flag :: #force_inline proc(reader: ^types.Module_Reader, section: types.Section_Id) {
    reader.module.flags.section_flags += {section}
}


reader_read_export_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    
    _reader_check_flag(reader, .EXPORT_SECTION) or_return

    exports := make([dynamic]types.Wasm_Export)

    c := reader.current_section.(^types.Export_Section_Contents)
    size := reader_read_size(reader) or_return

    for i in 0..<size {
        export := types.Wasm_Export{}
        export.nm = reader_read_name(reader) or_return
        export_desc := types.Export_Description{}
        kind :=  bytes.reader_read_byte(&reader.rd) or_return
        export_desc.kind = types.EXPORT_DESCRIPTION_KIND(kind)
        index_err : Error
        export_desc.index, index_err = reader_read_index(reader)
        if index_err != nil && index_err != io.Error.EOF {
            error = index_err
            return
        }
        append(&exports, export)
    }

    c.vec.size = size
    c.vec.data = exports[:]
    
    
    _reader_add_flag(reader, .EXPORT_SECTION)
    reader.mode = .Read_Section_Info
    return

}


reader_read_start_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    _reader_check_flag(reader, .START_SECTION) or_return

    c := reader.current_section.(^types.Start_Section_Contents)
    index_err: Error
    c.size = reader_read_size(reader) or_return
    c.start, index_err = reader_read_index(reader)
    if index_err != nil && index_err != io.Error.EOF {
        error = index_err
        return
    }
    _reader_add_flag(reader, .START_SECTION)
    reader.mode = .Read_Section_Info
    return
}
/* 
Elem_T :: bit_field u32 {
    tbl: u32 | 29,
    elem_t_or_elem_k: bool | 1,
    passive_or_declarative: bool | 1,
    active_or_passive: bool | 1,
} */

reader_read_element_section :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    _reader_check_flag(reader, .ELEMENT_SECTION) or_return

    c := reader.current_section.(^types.Element_Section_Contents)
    
    elements := make([dynamic]types.Wasm_Elem) 
    size := reader_read_size(reader) or_return

    elem := types.Wasm_Elem{}
    elem_info := reader_read_size(reader) or_return
    
    
    switch elem_info {
        case 0:
            elem.t = .FUNC_REF
            mode :=  types.Mode_Active{}
            mode.offset = reader_read_expression(reader) or_return
            mode.table = 0
            elem.mode = mode
            idx_vec_size := reader_read_size(reader) or_return
            function_indicies := make([]types.FUNC_INDEX, idx_vec_size)
            index_read_error: Error
            func_idx: u32
            for i in 0..<idx_vec_size {
                func_idx, index_read_error = reader_read_index(reader)
                if index_read_error != nil && index_read_error != io.Error.EOF {
                    error = index_read_error
                    return
                }
                function_indicies[i] = types.FUNC_INDEX(func_idx)
            }
            
            //elem.init. = function_indicies

            
    }

    
    //elem.t = reader_read_reftype(reader) or_return
    /* exp_size := reader_read_size(reader) or_return
    elem.init.data = make([]types.Wasm_Expression, exp_size)
    for i in 0..<exp_size {
        elem.init.data[i] = reader_read_expression(reader) or_return
    }
    em := types.Element_Mode{} */
    
        

    
} 

reader_read_section_info :: proc(reader: ^types.Module_Reader) -> (error: Error) {
    //buf := [4096]byte{}
    //section_id := bufio.reader_read_byte(reader) or_return
    start_index := reader.rd.i
    section_id := bytes.reader_read_byte(&reader.rd) or_return
    s_base := types.Wasm_Section_Base{}
    s_base.id = types.Section_Id(section_id)
    s_base.size = reader_read_size(reader) or_return

    when ODIN_DEBUG {

        log.debugf("\nsection id: %v\nread section info: %v\nsection base: %v", section_id, start_index, s_base)
    }


    

    s_base.contents = reader.module.buf[reader.rd.i - 1: reader.rd.i + (i64)(s_base.size)]
    reader.meta[reader.rd.i] = fmt.aprintf("section: %v", s_base.id)


   

    reader_set_current_section(reader, s_base.id, true)
    set_section_base(&reader.current_section, s_base)
    //s_base.size := transmute(u32)(buf[:4]))
    /* switch s_base.id {
        case SECTION_ID.TYPE_SECTION:
            

    } */

    //reader.module.type_sec.section_id = id
    reader.mode = id_to_readmode(s_base.id)
    //reader.module.
    return

}
