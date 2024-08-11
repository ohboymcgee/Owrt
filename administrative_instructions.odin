package owrt


trap :: proc() {
    panic("Trap encounteded")
}

ref :: proc(state: ^Runtime, addr: Func_Addr) 

ref_extrern :: proc(state: ^Runtime, addr: Extern_Addr) 

invoke :: proc(state: ^Runtime, addr: Func_Addr) 

label :: proc(state: ^Runtime, label: ^Stack_Label) 

frame :: proc(state: ^Runtime, frame_state: Activation_Frame) 