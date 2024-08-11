package owrt

MODULE_MAGIC :: [4]byte{ 0x00, 0x61, 0x73, 0x6d }
WASM_VERSION :: [4]byte{ 0x01, 0x00, 0x00, 0x00 }

Wasm_Module :: struct {
    magic: [4]byte,
    version: [4]byte,
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