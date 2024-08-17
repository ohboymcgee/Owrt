package message

import "core:mem"
import "core:sync/chan"
import "../types"
import "../wasm"

Runtime_Gui :: types.Runtime_Gui
Dual_Chan :: types.Dual_Chan
supervisor_init :: wasm.supervisor_init
default_dual_chan_allocator: mem.Allocator

Json_Rpc_Channel :: types.Json_Rpc_Channel




/* 

dual_chan_bind :: proc(dc: Dual_Chan) -> (first, second: Dual_Chan) {
    return Dual_Chan { 
        input = dc.input, 
        output = dc.output 
    }, 
        Dual_Chan { 
            input = dc.output, 
            output = dc.input,
    }
}

make_dual_chan :: proc() -> (dc: Dual_Chan = {}) {
    err1, err2: mem.Allocator_Error
    dc.input, err1 = chan.create_raw_buffered(128, align_of(i128), 16, default_dual_chan_allocator)
    dc.output, err2 = chan.create_raw_buffered(128, align_of(i128), 16, default_dual_chan_allocator)
    return
}

dual_chan_send :: proc(dc: Dual_Chan, data: rawptr) -> (ok: bool) {
    return chan.try_send_raw(dc.output, data)
}

dual_chan_recieve :: proc(dc: Dual_Chan, buf: []byte) -> (ok: bool) {
    return chan.try_recv_raw(dc.input, raw_data(buf))
}

/* init_gui_and_supervisor :: proc(x, y: i32) -> (^types.Runtime_Gui, ^wasm.Supervisor) {
    dual_chan := make_dual_chan()
    gui_c, sup_c := dual_chan_bind(dual_chan)
    su := new(types.Supervisor)
    wasm.supervisor_init(su, sup_c)
    rg := new(types.Runtime_Gui)
    ui.gui_init(rg, gui_c)
    
    return rg, su
}
 */
close_dual_channel :: proc(dc: Dual_Chan) -> (mem.Allocator_Error, mem.Allocator_Error) {
    return chan.destroy(dc.input), chan.destroy(dc.output)
}

 */