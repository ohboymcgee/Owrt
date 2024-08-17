package wasmrt

import "core:sys/wasm/wasi"

import "core:mem"
import "core:mem/virtual"
import "core:os/os2"
import "core:bytes"

import "core:sys/info"

import "base:runtime"
import "core:sync/chan"
import "../types"
Supervisor :: types.Supervisor
Process_Info :: types.Process_Info
Wasm_Store :: types.Wasm_Store


supervisor_init :: proc(su: ^Supervisor, dc: ^types.Simple_Message_Channel) -> () {
    su^ = {}//new(Supervisor)

    //su.comms = dc
    su.data_passing = dc
    su.allocator = runtime.default_allocator()
    
    

    su.file_system = {}
    su.module_reader = {}
    su.runtimes = {}
    su.file_system.infos = {}
    su.sys_info.cpu_features = info.cpu_features
    su.sys_info.cpu_name = info.cpu_name
    su.sys_info.ram = info.ram
    su.sys_info.gpus = info.gpus
    
    su.owned_processes = {}
    su.external_processes = {}
    
 
    return 
}
ALL_INFO :: os2.Process_Info_Fields{.Executable_Path, .PPid, .Priority, .Command_Line, .Command_Args, .Environment, .Username, .Working_Dir}
get_extenal_process_info :: proc(su: ^Supervisor, id: int) {
    process_ids, err := os2.process_list(su.info_allocator)
    for id, index in process_ids {
        p := Process_Info {}
        p.process.pid = id
        p.info, err = os2.process_info_by_pid(id, ALL_INFO, su.info_allocator)
        append(&su.external_processes, p)
    }
}

free_external_process_handles :: proc(su: ^Supervisor) {
    for &p, i in su.external_processes {
        os2.free_process_info(p.info, su.info_allocator)
        _ = os2.process_close(p.process)
    }
}

supervisor_destroy :: proc(su: ^Supervisor) {
    for &p, i in su.owned_processes {
        os2.free_process_info(p.info, su.info_allocator)
        //
        if i > 0 do _ = os2.process_kill(p.process)
        _ = os2.process_close(p.process)

    }
    free_external_process_handles(su)
    
    os2.file_info_slice_delete(su.file_system.infos[:], su.info_allocator)
    //os2.free_process_info( su.info_allocator)
}

add_runtime :: proc(su: ^Supervisor) -> (err: mem.Allocator_Error = .None) {    
    n := append(&su.runtimes, Runtime{}) or_return
    return
    
    
    
}

add_store :: proc(rt: ^Runtime) -> (err: mem.Allocator_Error = .None) {
    rt.store = new(Wasm_Store, rt.allocator) or_return
    rt.flags += {.Has_Store}
    return
}

add_module_supervisor :: proc(su: ^Supervisor, rt: ^Runtime, path: string) {
    if !os2.exists(path) {
        panic("Path Does Not Exist")
    }
    file, err := os2.open(path, {.Read})
    module_reader_init(&su.module_reader, file)

    add_module_rt(rt, su.module_reader.module)
}

add_module_rt :: proc(rt: ^Runtime, mod: ^Wasm_Module) -> (err: mem.Allocator_Error = .None) {
    append(&rt.modules, mod^) or_return
    return
}

run :: proc(su: ^Supervisor) {
    @static read_buf: [1024]byte = {}
    //chan.select_raw()
    msg: (types.Data_Message)
    ok: bool
    msg, ok = chan.try_recv(su.data_passing^)
    if ok {
        switch msg.header {
            case 0:

        }
    }
}