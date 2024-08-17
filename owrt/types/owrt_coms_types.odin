package types


import "core:sync/chan"
import "base:runtime"
import "core:reflect"
import "core:encoding/json"
import "core:testing"
import "core:mem"
import "core:strings"
import "core:log"
import "core:strconv"
import "core:fmt"


/* Message :: struct(T: typeid) {
    header: u64 `json:`, 

} */

Json_Rpc_Version_Kind :: enum {
    ONE_ZERO = 1,
    TWO_ZERO = 2,
}
Json_Rpc_Version :: bit_set[Json_Rpc_Version_Kind]



/* Json_Rpc_Version :: union {
    JRPC_ONE,
    JRPC_TWO,
}

JRPC_ONE :: 1.0
JRPC_TWO :: 2.0 */







@test
marshal_test :: proc(t: ^testing.T) {
    if context.allocator == mem.nil_allocator() {
        context.allocator = runtime.default_allocator()
        defer mem.free_all(context.allocator)
    }
    if context.logger == log.nil_logger() {
        
        context.logger = log.create_console_logger()
        defer log.destroy_console_logger(context.logger)
    }
    
    
    //fmt.register_user_formatter(Json_Rpc_Version, proc())
    rs := mem.Rollback_Stack {}
    mem.rollback_stack_init(&rs)
    defer mem.rollback_stack_destroy(&rs)
    sb := strings.Builder {}
    strings.builder_init(&sb)
    defer strings.builder_destroy(&sb)
    test_rpc := Json_Rpc {
        jsonrpc = "2.0",
        //method = "get",
        result =  []string{ "a", "b" },
        params = { "sysinfo" },
        id = 0,
    }

    


    
    marshal_options := json.Marshal_Options {
        spec = .JSON,
        pretty = true,
        use_spaces = true,
        spaces = 2,
        write_uint_as_hex = true,
        mjson_keys_use_quotes = true,
        sort_maps_by_key = false,
        //use_enum_names = true//false
        
        
        //use_enum_names = true,
    }

    
    
    log.infof("\nMartial Error: %#v\n\n----",
        json.marshal_to_builder(&sb, test_rpc, &marshal_options),
        
    )

    //chan.send(t.channel, testing)
    log.infof("\n\n%s",strings.to_string(sb))
    
    


    
}

Json_Rpc_Channel :: chan.Chan(Json_Rpc)

Json_Rpc :: struct {
    jsonrpc: string `validate:"oneof=1.0 2.0"` ,
    method: string `json:",omitempty"`,
    result: union {
        []string,
        string,
    } `json:",omitempty"`,
    params: []string,
    id: int,
}





Data_Message :: struct {
    header: u64, //arbitrary flags or whatever
    data: []byte,
}

Simple_Message_Channel :: chan.Chan(Data_Message)

send_data_message :: proc(ch: ^Simple_Message_Channel, msg: u64, data: []byte) -> (ok: bool) {
    
    return chan.try_send(ch^, Data_Message { header = msg, data = data})
}

/* decode_simple_data_message :: proc(dm: Data_Message) {
    data, id := reflect.any_data(dm.data)
    type := type_info_of(id)


    
} */

Dual_Chan :: struct {
    input: ^chan.Raw_Chan,
    output: ^chan.Raw_Chan,
}


