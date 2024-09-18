package owrt

import "./types"
Runtime :: types.Runtime
Func_Addr :: types.Func_Addr
Extern_Addr :: types.Extern_Addr
Stack_Label :: types.Stack_Label
Activation_Frame :: types.Activation_Frame

/* _trap :: proc() 

_ref :: proc(state: ^Runtime, addr: Func_Addr) 

_ref_extrern :: proc(state: ^Runtime, addr: Extern_Addr) 

_invoke :: proc(state: ^Runtime, addr: Func_Addr) 

_label :: proc(state: ^Runtime, label: ^Stack_Label) 

_frame :: proc(state: ^Runtime, frame_state: Activation_Frame)  */