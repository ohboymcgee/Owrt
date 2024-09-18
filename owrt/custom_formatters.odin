package owrt

import "core:fmt"
import "core:strings"
import "core:io"
import "core:reflect"
import "./types"
import "core:log"
import "core:slice"
import "core:strconv"

//fmt.User_Formatter




module_formatter :: proc(fi: ^fmt.Info, arg: any, verb: rune) -> (bool) {
    log.debug("Entering User Formatter")
    
    //_data, id := reflect.any_data(arg)
    //data : ^[]byte = cast(^[]byte)(_data)

    log.debugf("\nid: %v ptr: %v", arg.id, arg.data)

    contents := cast(^[]byte)(arg.data)
    
    
    //log.debugf("preview: %2x %i", data[:8], data_length)
    switch verb {
        case /* 'v',  */'x':
            n_written: int
            c_len := len(contents)
            remainder := c_len % 8
            io.write_string(fi.writer, "byte [ ")
            fi.indent += 1
            for i := 0; i < c_len; i += 8 {
                io.write_byte(fi.writer, '\n')
                fmt.fmt_write_indent(fi)
                row := [8]byte{}
                for idx, itr in i..<(i + 8) {
                    if idx >= c_len do row[itr] = 0
                    else do row[itr] = contents[idx]
                }

                
                fmt.wprintf(
                    fi.writer, 
                    "0x%2x, 0x%2x, 0x%2x, 0x%2x, 0x%2x, 0x%2x, 0x%2x, 0x%2x", 
                    row[0], row[1], row[2], row[3],
                    row[4], row[5], row[6], row[7],
                )
                //io.write_byte(fi.writer, '\n')
                
            }
            io.write_string(fi.writer, " ]")
            
            
            //io.write_byte(fi.writer, contents[0], &n_written)
            

    
            //grouped := make([][]byte, (data_length / 8) + 1)
            //defer delete(grouped)
            /* prev := 0
            for &g, i in grouped {
                g = data^[prev: i * 8] 
                prev = i * 8
            }
            fmt.fmt_write_array(fi, rawptr(&grouped), (data_length / 8) + 1, size_of([]byte), []byte, 'x')
             */return true

        case:
            return false


    }
    return true
    
}