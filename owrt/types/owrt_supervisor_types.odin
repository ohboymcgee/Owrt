package types


import "core:mem"
import "core:os/os2"
import "core:sys/info"

Supervisor :: struct {

    allocator: mem.Allocator,
    temp_allocator: mem.Allocator,
    
    runtimes: [dynamic]Runtime,
    module_reader: Module_Reader,
    //comms: Dual_Chan,

    /* owrt_network: map[Owrt_Address]Owrt_Socket,

    data_passing: ^Simple_Message_Channel, */
    info_allocator: mem.Allocator,
    sys_info: System_Info,
    owned_processes: [dynamic]Process_Info,
    external_processes: [dynamic]Process_Info,
    file_system: File_System,
    init: proc(self: ^Supervisor),
    destroy: proc(self: ^Supervisor),

}



System_Info :: struct {
    cpu_features: Maybe(info.CPU_Features),
    cpu_name: Maybe(string),
    ram: info.RAM,
    gpus: []info.GPU,
}



Process_Info :: struct {
    process: os2.Process,
    info: os2.Process_Info,
}

File_System :: struct {    
    infos: [dynamic]os2.File_Info,

}

