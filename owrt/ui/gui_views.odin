package owrt

import nv "vendor:nanovg"
import st "core:strings"
import s8 "core:unicode/utf8/utf8string"
import "core:math/fixed"

import "../types"

View :: types.View

get_transform_scale :: proc(m: ^nv.Matrix) -> (scale: [2]f32) {
    return { m[0], m[4] }
}
get_transform_skew :: proc(m: ^nv.Matrix) -> (skew: [2]f32) {
    return { m[1], m[3] }
}
get_transform_translation :: proc(m: ^nv.Matrix) -> (translation: [2]f32) {
    return { m[2], m[5] }
}

View_Render_Function :: proc(_: ^Runtime_Gui, _: ^View)

draw_view :: proc(rg: ^Runtime_Gui, view: ^View) {
    info := view.style_info
    panic("Todo! finish draw view")    
}
/* 
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
} */