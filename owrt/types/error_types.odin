package types

import "core:mem"
import "core:os"
import "core:io"
import "core:encoding/varint"

Error :: union #shared_nil {
    os.Error,
    mem.Allocator_Error,
    io.Error,
    ^Wasm_Error,
    varint.Error,
}

Wasm_Error_Code :: enum {
    NONE,
    NO_FILE,
    INVALID_MAGIC,
    UNKNOWN_VERSION,
    FAILED_TO_READ_SECTION_INFO,
    IMPROPER_LEB_DECODE,
    INCORRECT_TYPE_ENCODING,
    DUPLICATE_SECTION,
    FUNCTIONALITY_NOT_IMPLEMENTED,
    IMPROPERLY_FORMED_SECTION,
    IMPROPERLY_ENCODED_LIMIT,
    IMPROPERLY_ENCODED_REFTYPE,
    UNSUPPORTED_OPCODE,
}

Wasm_Error :: struct {
    code: Wasm_Error_Code,
    message: string,
    
}