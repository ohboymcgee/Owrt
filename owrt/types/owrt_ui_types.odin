package types

import "core:sys/info"
import st "core:strings"
import sdl "vendor:sdl2"
import nv "vendor:nanovg"
import "core:strings"
import s8 "core:unicode/utf8/utf8string"
import "core:math/fixed"
import "core:thread"
import "core:sync/chan"
//import "core:"


Render_Context :: struct {
    nvg_ctx: ^nv.Context,
    gl_ctx: sdl.GLContext,

    brushes: [dynamic]Brush,
    _font_names: strings.Intern,
    fonts: [dynamic]string,
}

Runtime_Gui :: struct {
    
    window: Gui_Window,
    
    using render_context: Render_Context,

    files: File_System,

    data_passing: ^Json_Rpc_Channel,
    //comms: Dual_Chan,
   /*  msg_in: ^chan.Raw_Chan,
    msg_out: ^chan.Raw_Chan, */

    //sv: ^Supervisor,


}



Gui_Thread :: struct {
    _thread: ^thread.Thread,
    //thread.create()
}


Gui_Window :: struct {
    using _w: ^sdl.Window,
    x, y, w, h: i32,
    ratio: f32,

    views: [dynamic]View,
}




View_Render_Function :: proc(_: ^Runtime_Gui, _: ^View)

FONT_DATA : []byte : #load("../../fonts/cruft.ttf") 

View_Kind :: union {
    ^Tree_Root,
    ^Tab_View,
    ^Gui_Text_Buffer_View,
    ^Sys_Info_View,
    ^Module_Inspector_View,
}

Tab_View :: struct {

}



Tree_Root :: struct {
    win_x, win_y,
    win_w, win_h: f32,
    base: View,
    
    
}



/* Gui_Edit_View :: struct {
    using base: View_Base,
    edit_state: edit.State,
    undo_state: edit.Undo_State,
    
} */

Module_Inspector_View :: struct {
    base: View,
    module: ^Module_Reader,
    num_columns: int,
    rows: [dynamic]nv.Text_Row `fmt:-`,
}


Sys_Info_View :: struct {
    base: View,
    initialized: bool,    
    sb: strings.Builder,
    str: string,
    text_rows: []nv.Text_Row `fmt:-`,
    
    
    

}


/* 
gui_text_formater : fmt.User_Formatter : proc(info: ^fmt.Info, arg: any, verb: rune) -> bool {
    _format :: proc(info: ^fmt.Info, t: reflect.Type_Info, arg: any, verb: rune) -> bool {
        switch v in t.variant {
            case runtime.Type_Info_Integer:
            case runtime.Type_Info_Float:
            
        }
    }
    
    d, t  := reflect.any_data(arg)
    t_info := type_info_of(t)
    switch v in t_info.variant {
        case  runtime.Type_Info_Struct:            
            zipped := reflect.struct_fields_zipped(t)

    }
} */


View_Alignmnet :: enum {
    Vertical,
    Horizontal,
    Dock,
}

Content_Alignment :: enum {
    Left,
    Rignt,
    Center,
    Top,
    Bottom,
}



Align_Info :: bit_field u8 {
    view_align: View_Alignmnet | 2,
    content_align: Content_Alignment | 2,
    text_align_vertical: nv.AlignVertical | 2,
    text_align_horizontal: nv.AlignHorizontal | 2,
}

Font_Info :: struct {
    id: i32,
    size: f32,
    name: ^string,
    brushes: []Brush_Info,
}

Brush_Info :: struct {
    num_brushes: int,
    bg: int,
    border: int,
    //text: []Font_Info,
}

Packed_Ratio :: fixed.Fixed(u16, 15)
Fixed_Point_Ratio :: fixed.Fixed(u32, 31)

Measure_Kind :: enum {
    Ratio,
    Pixels,
}

Measure :: bit_field u16 {
    kind: Measure_Kind | 1,
    data: u16 | 15,
}

Box_Measures :: struct #packed {
    top: Measure,
    left: Measure,
    right: Measure,
    bottom: Measure,
}




Bounds :: struct {
    info: Box_Measures,    
    content: [4]f32,
}




Brush :: union {    
    nv.Color,
    ^nv.Paint,
}



Style_Info :: struct {
    align_info: Align_Info,
    bounds: Bounds,
    brushes: Brush_Info,
    font_info: Font_Info,
    transforms: struct {
        translate: [2]f32,
        skew: [2]f32,
        rotate: [2]f32,
    },

}


View :: struct {
    style_info: Style_Info,
    depth: i32,
    variant: View_Kind,
    children: []View,
}

Gui_Text_Buffer_View :: struct {
    text_buffer: string,
    sb: st.Builder,
    str: s8.String,
    rows: []nv.Text_Row,
    visible_area: [2]int,
}

Gui_User :: struct {
    mouse_buttons: Mouse_State_Flags,
    mouse_delta: [2]f32,
    mouse_window: [2]f32,
    mouse_global: [2]f32,
    keyboard_state: []u8,
}


BUTTON_LEFT     :: 1
BUTTON_MIDDLE   :: 2
BUTTON_RIGHT    :: 3
BUTTON_X1       :: 4
BUTTON_X2       :: 5
BUTTON_LMASK    :: 1<<(BUTTON_LEFT-1)
BUTTON_MMASK    :: 1<<(BUTTON_MIDDLE-1)
BUTTON_RMASK    :: 1<<(BUTTON_RIGHT-1)
BUTTON_X1MASK   :: 1<<(BUTTON_X1-1)
BUTTON_X2MASK   :: 1<<(BUTTON_X2-1)


Mouse_State_Flags :: bit_set[BUTTON_LEFT..=BUTTON_X2; u32]
