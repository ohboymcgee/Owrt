package owrt

import "core:math/bits"
import sdl "vendor:sdl2"


import "../types"

Gui_User :: types.Gui_User 
BUTTON_LEFT :: types.BUTTON_LEFT


_update_user_state :: proc(u: ^Gui_User) {
    u.keyboard_state = sdl.GetKeyboardStateAsSlice()
    m := [6]i32{}
    sdl.GetGlobalMouseState(&m[0], &m[1])
    sdl.GetMouseState(&m[2], &m[3])
    b := sdl.GetRelativeMouseState(&m[4], &m[5])
    
    u.mouse_buttons = 
        {(int)(sdl.BUTTON(BUTTON_LEFT))} |
         { (int)(sdl.BUTTON(sdl.BUTTON_RIGHT)) } |
         { (int)(sdl.BUTTON(sdl.BUTTON_MIDDLE)) } |
         { (int)(sdl.BUTTON(sdl.BUTTON_X1)) } |
         { (int)(sdl.BUTTON(sdl.BUTTON_X2)) }
    

    u.mouse_global = { (f32)(m[0]), (f32)(m[1]) }    
    u.mouse_window = { (f32)(m[2]), (f32)(m[3]) }
    u.mouse_delta = { f32(m[4]), f32(m[5]) }
    
    

    
}