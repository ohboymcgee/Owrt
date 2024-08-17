package main

import ow "../owrt"


main :: proc() {
    gui := ow.gui_init()

    ow.gui_run(gui)
}