package owrt

import nv "vendor:nanovg"
import nvgl "vendor:nanovg/gl"
import sdl "vendor:sdl2"
import gl "vendor:OpenGL"
import "core:fmt"

import "core:sys/info"
import "vendor:stb/truetype"

import "core:strings"
import "core:bytes"
import "base:runtime"
import "core:reflect"

import win "core:sys/windows"
import "core:os"
import "core:os/os2"

import u8s "core:unicode/utf8/utf8string"
import "core:text/edit"
import "core:text/table"
import "base:intrinsics"
import "core:slice"
import "core:io"
import "core:sort"

import "core:slice/heap"
import "../types"

import "../message"

Runtime_Gui :: types.Runtime_Gui
//View :: types.View
FONT_DATA :: types.FONT_DATA
Module_Inspector_View :: types.Module_Inspector_View
System_Info :: types.System_Info
Sys_Info_View :: types.Sys_Info_View
Gui_Text_Buffer_View :: types.Gui_Text_Buffer_View
Render_Context :: types.Render_Context
Tree_Root :: types.Tree_Root
Brush_Info :: types.Brush_Info

render_module_inspector_view :: proc(rg: ^Runtime_Gui, view: ^Module_Inspector_View) {
    if view.num_columns == 0 do view.num_columns = 8
    
    


    nv.Save(rg.nvg_ctx)
    translate := view.base.style_info.transforms.translate//get_transform_translation(&view.base.style_info.trafo)
    nv.Translate(rg.nvg_ctx, translate.x, translate.y)
    
    string_buffer := [2048]byte{}
    nv.FontSize(rg.nvg_ctx, view.base.style_info.font_info.size)
    text_x, text_y : f32 = 0,0
    //bounds := [4]f32{}

    //view.view_base.
    

    
    
    /* for b, index in view.module.bytes.buf[:] {
        byte_string := fmt.bprintf(
            string_buffer[:],
            "0x%0x",
            b
        )
        
        nv.TextBounds(
            rg.nvg_ctx, 
            text_x, 
            text_y, 
            byte_string,
            &bounds,
        )
        nv.Text(rg.nvg_ctx, bounds.x, bounds.y, byte_string)
    } */
    
    nv.Restore(rg.nvg_ctx)
}



format_sys_info :: proc(inf: ^System_Info, sb: ^strings.Builder) {
    runtime.DEFAULT_TEMP_ALLOCATOR_TEMP_GUARD()
    //fields := reflect.struct_fields_zipped(Sys_Info_View)
    cpu_feature_names : []info.CPU_Feature = slice.bitset_to_enum_slice_with_make(
        (inf.cpu_features.(info.CPU_Features) or_else {}), 
        info.CPU_Feature, 
        context.temp_allocator
    )

    cpu_name := inf.cpu_name.(string) or_else "Unknown Cpu Name"
    buf := [2048]byte{}
    indent_level := 0
    
    strings.write_string(sb, "|System Info:\n|  ")
    //indent_level += 2
    strings.write_string(sb, "CPU Name: ")
    strings.write_string(sb, cpu_name)
    strings.write_string(sb, "\n|  ")

    strings.write_string(sb, "Cpu Features:")
    
    

    for name, i in cpu_feature_names {
        if i % 6 == 0 {
            strings.write_string(sb, "\n|    ")
        }
        strings.write_string(sb, fmt.bprintf(buf[:], "%v, ", name))
        
    } 
    strings.write_string(
        sb, 
        fmt.bprintf(
            buf[:],
            "\n|  Ram:\n|    free ram: %v / total ram: %v\n|    free swap: %v / total swap: %v\n|  ", 
            inf.ram.free_ram, 
            inf.ram.total_ram, 
            inf.ram.free_swap, 
            inf.ram.total_swap)
        )

    
    strings.write_string(sb, "GPUs:\n|    vendor - model       ram\n")
    for gpu, i in inf.gpus {
        strings.write_string(
            sb, 
            fmt.bprintf(
                buf[:],
                "|    %s - %s\n|      %i\n",
                gpu.model_name,
                gpu.vendor_name,
                gpu.total_ram,
            ))
    }
    return 

    
    
}







render_sys_info_view :: proc(rg: ^Runtime_Gui, v: ^Sys_Info_View) {
    strings.builder_init(&v.sb)
    
    if !v.initialized {
        
        //format_sys_info(&rg.sv.sys_info, &v.sb)
        //message
        
        v.str = strings.to_string(v.sb)
        
        
        
        v.initialized = true 
    }
    //nv.TextBreakLines(rg.nvg_ctx, &v.str, )
    //nv.FontSize(rg.nvg_ctx, v.base.font_size)
    bounds := v.base.style_info.bounds
    nv.Save(rg.nvg_ctx)
    nv.Translate(rg.nvg_ctx, bounds.content.x, bounds.content.y)
    nv.Save(rg.nvg_ctx)
    
    
    nv.BeginPath(rg.nvg_ctx)
    
    nv.FillColor(rg.nvg_ctx, [4]f32{ 0.2, 0.2, 0.2, 1.0 })
    nv.StrokeColor(rg.nvg_ctx,  [4]f32{ 1.0, 0.3, 0.3, 1.0})
    nv.StrokeWidth(rg.nvg_ctx, 2.0)
    nv.RoundedRect(rg.nvg_ctx, bounds.content.x, bounds.content.y, bounds.content.z, bounds.content.w, 2)
    nv.Stroke(rg.nvg_ctx)
    nv.Fill(rg.nvg_ctx)
    nv.ClosePath(rg.nvg_ctx)
    
    
    nv.Restore(rg.nvg_ctx)
    nv.BeginPath(rg.nvg_ctx)
    nv.FillColor(rg.nvg_ctx, [4]f32{ 0.90, 0.90, 0.90, 1.0 })
    nv.TextBox(rg.nvg_ctx, bounds.content.x + 36, bounds.content.y + 36, bounds.content.z, v.str)
    nv.ClosePath(rg.nvg_ctx)
    //nv.BeginPath(rg.nvg_ctx)

    nv.Restore(rg.nvg_ctx)
    //nv.FillColor(rg.nvg_ctx, {0.5,0,0,1})
    
    
    
   
    
}
/* 
get_transform_scale :: proc(m: ^nv.Matrix) -> (scale: [2]f32) {
    return { m[0], m[4] }
}
get_transform_skew :: proc(m: ^nv.Matrix) -> (skew: [2]f32) {
    return { m[1], m[3] }
}
get_transform_translation :: proc(m: ^nv.Matrix) -> (translation: [2]f32) {
    return { m[2], m[5] }
}


*/

init_gui_text_buffer :: proc(tb: ^Gui_Text_Buffer_View) {
    tb^ = {}
    strings.builder_init(&tb.sb)
    u8s.init(&tb.str, strings.to_string(tb.sb))
    
}

get_visible_text_region :: proc(tb: ^Gui_Text_Buffer_View) -> string {
    return u8s.slice(&tb.str, tb.visible_area.x, tb.visible_area.y)
}

draw_text_buffer :: proc(rg: ^Runtime_Gui, text_buf: ^Gui_Text_Buffer_View, x, y, w: f32) {
    nv.TextBox(rg.nvg_ctx, x, y, w, get_visible_text_region(text_buf))
}

//FONT_FOLDER := #load_directory("../fonts/")



add_font :: proc(ctx: ^Render_Context, name: string, data: []byte) -> (font_index: int, error: runtime.Allocator_Error) { 
    
    n := strings.intern_get(&ctx._font_names, name) or_return
    append(&ctx.fonts, n)
    return nv.CreateFontMem(ctx.nvg_ctx, n, data, false), .None
}




build_view_tree :: proc(rg: ^Runtime_Gui, tree_allocator: runtime.Allocator) {
    
}

gui_init :: proc(rg: ^Runtime_Gui, chan: ^types.Simple_Message_Channel) {//, supervisor_init_cb: (proc(^types.Supervisor))) {

    fmt.assertf(sdl.Init({.VIDEO}) == 0, "failed to init sdl: %")

    rg^ = {} //new(Runtime_Gui)
    //rg.comms = chan
    rg.data_passing = chan
    
    sdl.GL_SetAttribute(.STENCIL_SIZE, 8)
    sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
    sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 2)
    sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK, gl.CONTEXT_CORE_PROFILE_BIT)

    sdl.GL_SetAttribute(.DOUBLEBUFFER, 1)
    sdl.GL_SetAttribute(.MULTISAMPLEBUFFERS, 1)
    sdl.GL_SetAttribute(.MULTISAMPLESAMPLES, 8)

    rg.window._w = sdl.CreateWindow("Owrt", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 1280, 720, {.OPENGL} | {.SHOWN})
    rg.gl_ctx = sdl.GL_CreateContext(&rg.window)
    sdl.GL_MakeCurrent(rg.window, rg.gl_ctx)
    gl.load_up_to(3, 2, sdl.gl_set_proc_address)
    rg.nvg_ctx = nvgl.Create({.ANTI_ALIAS} | {.DEBUG} | {.STENCIL_STROKES})
    
    sdl.GetWindowSize(rg.window, &rg.window.w, &rg.window.h)
    sdl.GetWindowPosition(rg.window, &rg.window.x, &rg.window.y)
    rg.brushes = { nv.Color{0.0,0.0,0.0,1.0}, nv.Color{0.9, 0.9, 0.9, 1.0 }, nv.Color{ 0.1, 0.1, 0.1, 1.0 }, nv.Color{0.8, 0.1, 0.1, 1.0} }
    rg.window.ratio = (f32)(rg.window.w) / (f32)(rg.window.h)
    rg.window.views = {}
    
    view := new(Tree_Root)//View{}
    view.base.style_info.brushes = Brush_Info { num_brushes = 1, bg = 0, border = -1 }// = rg.brushes[0]
    view.base.style_info.align_info.view_align = .Horizontal
    view.base.style_info.align_info.content_align = .Left
    view.base.style_info.align_info.text_align_horizontal = .LEFT
    view.base.style_info.align_info.text_align_vertical = .TOP
    view.base.depth = 0
    view.base.style_info.bounds.content = { 0, 0, (f32)(rg.window.w), (f32)(rg.window.h) }
    //view.base.style_info..ratio = rg.window.ratio
    //view.base.trafo = { 1, 0, 0, 1, 0, 0 }
    //view.base.style_info.bounds =  { 0, 0, 1280, 720 }
    view.base.variant = view//new(Tree_Root)    
    
    sys_info_view := new(Sys_Info_View)//View{}
    sys_info_view.base.style_info.font_info.size = 14
    sys_info_view.base.depth = 1
    //sys_info_view.base.trafo = { 1, 0, 0, 1, 0, 0 }
    sys_info_view.base.variant = sys_info_view
    sys_info_view.base.style_info.bounds.content = { 4, 4, 800, 700 }
    sys_info_view.base.style_info.brushes = Brush_Info {  num_brushes = 4, bg = 0, border = 3} //.bg =  rg.brushes[2]
    
    //sys_info_view.variant.(^Sys_Info_View).view_base = &sys_info_view
    append(&rg.window.views, view.base, sys_info_view.base)

    rg.window.views[0].children = rg.window.views[1:]

    
    
   /*  rg.sv.init = supervisor_init_cb
    rg.sv->init() */
    
    return
}

@(deferred_in=gui_close)
gui_run :: proc(rg: ^Runtime_Gui) {
    event: sdl.Event = {}
    @static string_buffer := [2048]byte {}
    sb := strings.builder_from_bytes(string_buffer[:])
    strings.write_string(&sb, "Hi\n")
    //sdl.GL_SetSwapInterval(60)

    
    
    font_index, font_add_err := add_font(&rg.render_context, "cruft", FONT_DATA)
    

    


    
    
    
    
    
    event_loop: for { 
        for sdl.PollEvent(&event) {
        #partial switch event.type {
            //sdl.LogInfo()
            case .QUIT:
                break event_loop
            case .KEYUP:
                if event.key.keysym.sym == .ESCAPE {
                    e: sdl.Event = {}
                    e.type = .QUIT
                    e.quit.timestamp = sdl.GetTicks()
                    sdl.PushEvent(&e)
                }
            /* case .WINDOWEVENT:
                if event.window.event == .CLOSE {
                    fmt.println("Exiting Event Loop")
                    break event_loop
                }

            */
            } 
        }
        gl.ClearColor(0, 0, 0, 1)
        gl.Clear(  gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT  )
        nv.BeginFrame(rg.nvg_ctx, f32(rg.window.w), f32(rg.window.h), 1)
        

        
        
        
        /* for &n, i in rg.window.views {
            n.
        } */
        
        nv.FontSize(rg.nvg_ctx, 24)
        //nv.BeginPath(rg.nvg_ctx)
        //nv.TextBox(rg.nvg_ctx, 10, 42, 720/2, strings.to_string(sb))
        nv.ResetTransform(rg.nvg_ctx)
        nv.Save(rg.nvg_ctx)
        render_sys_info_view(rg, rg.window.views[1].variant.(^Sys_Info_View))
        //nv.Restore(rg.nvg_ctx)
        //nv.FillColor(rg.nvg_ctx, {0.5,0,0,1})
        nv.BeginPath(rg.nvg_ctx)
        nv.Translate(rg.nvg_ctx, 20, 20)
        nv.RoundedRect(rg.nvg_ctx, 0, 0, 20, 20, 1)
        nv.ClosePath(rg.nvg_ctx)
        nv.Fill(rg.nvg_ctx)

        

        
        
        nv.EndFrame(rg.nvg_ctx)
        sdl.GL_SwapWindow(rg.window)
    }
}

gui_close :: proc(rg: ^Runtime_Gui) {
    fmt.println("Closing Gui")
    nvgl.Destroy(rg.nvg_ctx)
    sdl.GL_DeleteContext(rg.gl_ctx)
    sdl.DestroyWindow(rg.window)
    

}