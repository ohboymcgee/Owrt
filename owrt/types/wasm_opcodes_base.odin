package types

import "core:encoding/varint"
import "core:simd"
import "core:math/bits"




TYPE_INDEX :: distinct u32
FUNC_INDEX :: distinct u32
TABLE_INDEX :: distinct u32
MEM_INDEX :: distinct u32
GLOBAL_INDEX :: distinct u32
DATA_INDEX :: distinct u32
LOCAL_INDEX :: distinct u32
LABEL_INDEX :: distinct u32

Index_Kind :: union {
    TYPE_INDEX,
    FUNC_INDEX,
    TABLE_INDEX,
    MEM_INDEX,
    GLOBAL_INDEX,
    DATA_INDEX,
    LOCAL_INDEX,
    LABEL_INDEX,
}

Import_Index_Kind :: union {
    FUNC_INDEX,
    TABLE_INDEX,
    MEM_INDEX,
    GLOBAL_INDEX
}

Export_Index :: Import_Index_Kind

Address :: distinct u32
Func_Addr :: distinct Address
Table_Addr :: distinct Address
Mem_Addr :: distinct Address
Global_Addr :: distinct Address
Element_Addr :: distinct Address
Data_Addr :: distinct Address
Extern_Addr :: distinct Address



Wasm_I32 :: i32
Wasm_I64 :: i64
Wasm_U32 :: u32
Wasm_u64 :: u64
Wasm_F32 :: f32
Wasm_F64 :: f64
Wasm_v128 :: [16]byte
Wasm_Ref_Null :: struct {}

/* Wasm_Int_Max_Bytes :: enum {
    I32 = (32/7),
    I64 = (64/7),
    U32 = (32/7),
    U64 = (32/7),
} */


Wasm_Values :: union {
    Wasm_I32,
    Wasm_I64,
    Wasm_U32,
    Wasm_u64,
    Wasm_F32,
    Wasm_F64,
    Wasm_Ref,
    Wasm_Ref_Null,
    Wasm_v128,
}


Type_Encodings :: union {
    Number_Type_Ecoding,
    Simd_Vector_Type_Ecoding,
    Reference_Type_Encoding,
    Value_Type_Encoding,
    Result_Type_Encoding,
    Function_Type_Encoding,
    Limit_Type_Encoding_Encoding,
    Memory_Type_Encoding,
}


Encoding_Base :: enum byte {
    //Number
    I32 = 0x7f,
    I64 = 0x7e,
    F32 = 0x7d,
    F64 = 0x7c,

    //Simd Vector
    V128 = 0x7b,

    //Ref
    FUNC_REF = 0x70,
    EXTERN_REF = 0x6f,

    //Function
    FUNC = 0x60,
    
    //Limits
    MIN = 0x00,
    MIN_MAX = 0x01,

    //Global
    CONST = 0x00,
    VAR = 0x01,

}

Wasm_Number_Type :: union {
    Wasm_I32,
    Wasm_I64,
    Wasm_F32,
    Wasm_F64,
}

Base_Set :: bit_set[Encoding_Base]


Limit_Type_Encoding_Encoding :: enum byte {
    MIN = 0x00,
    MAX = 0x01,
}

Number_Type_Ecoding :: enum byte {
    I32 = 0x7f,
    I64 = 0x7e,
    F32 = 0x7d,
    F64 = 0x7c,
}

Simd_Vector_Type_Ecoding :: enum byte {
    V128 = 0x7b,
}

Reference_Type_Encoding :: enum byte {
    FUNC_REF = 0x70,
    EXTERN_REF = 0x6f,
}

Value_Type_Encoding :: union {
    Number_Type_Ecoding,
    Simd_Vector_Type_Ecoding,
    Reference_Type_Encoding,
}

Value_Type :: struct {
    enc: Value_Type_Encoding,
    val: Wasm_Values,
}


Result_Type_Encoding :: struct {
    size: u32,
    value_encoding: Value_Type_Encoding,
}

Result_Type :: Wasm_Vector(Value_Type_Encoding)//distinct []Value_Type_Encoding

Function_Type_Encoding :: enum byte {
    FUNCTION_TYPE = 0x60,
}


Wasm_Simd_Vector_Type :: struct {
    data: union {
        i128,
        u128,
        simd.f32x4,
        simd.f64x2,
        simd.i8x16,
        simd.i16x8,
        simd.i32x4,
        simd.i64x2,
        simd.u8x16,
        simd.u16x8,
        simd.u32x4,
        simd.u64x2,

    }
}


Memory_Type_Encoding :: distinct Limit_Type_Encoding_Encoding

Table_Type_Encoding :: struct {
    ref: Reference_Type_Encoding,
    lim: Limit_Type_Encoding_Encoding,
}

Wasm_Global_Type :: struct {
    val_t: Value_Type,
    mut: enum byte {
        CONST = 0x00,
        VAR = 0x01,
    },
    
}

Wasm_Global :: struct {
    type: Wasm_Global_Type,
    expression: Wasm_Expression,
}

Wasm_Expression :: struct {
    instructions: []WASM_OPCODES,
    end: WASM_OPCODES, // use end opcode
}

Wasm_Function_Type :: struct {
    //encoding: Function_Type_Encoding,
    args: Result_Type_Encoding,
    returns: Result_Type_Encoding,
}

Wasm_Vector :: struct($T: typeid) {
    size: u32,
    encoding: Type_Encodings,
    data: []T `fmt:"x"`,
}

Wasm_Name :: string//Wasm_Vector(byte)

Mode_Passive :: struct {}
Mode_Active :: struct {
    table: u32,
    offset: Wasm_Expression,
}
Mode_Declarative :: struct {}
Element_Mode :: union {
    Mode_Passive,
    Mode_Active,
    Mode_Declarative,
}

Elem_Type :: bit_field u32 {

}

Wasm_Elem :: struct {
    t: Reference_Type_Encoding,
    init: Wasm_Vector(Wasm_Expression),
    mode: Element_Mode,
}


Wasm_Ref :: struct {
    t: Reference_Type_Encoding,
    address: Address,
}

WASM_OPCODES :: enum byte {
   UNREACHABLE = 0x00,
   NOP = 0x01,
   BLOCK = 0x02,
   LOOP = 0x03,
   IF = 0x04,
   ELSE = 0x05,
   PROPOSAL_TRY = 0x06,
   PROPOSAL_CATCH = 0x07,
   PROPOSAL_THROW = 0x08,
   PROPOSAL_RETHROW = 0x09,
   PROPOSAL_THROW_REF = 0x0A,
   END = 0x0B,
   BR = 0x0C,
   BR_IF = 0x0D,
   BR_TABLE = 0x0E,
   RETURN = 0x0F,
   CALL = 0x10,
   CALL_INDIRECT = 0x11,
   PROPOSAL_RETURN_CALL = 0x12,
   PROPOSAL_RETURN_CALL_INDIRECT = 0x13,
   PROPOSAL_CALL_REF = 0x14,
   PROPOSAL_RETURN_CALL_REF = 0x15,
   PROPOSAL_DELEGATE = 0x18,
   PROPOSAL_CATCH_ALL = 0x19,
   DROP = 0x1A,
   SELECT = 0x1B,
   PROPOSAL_SELECT_T = 0x1C,
   PROPOSAL_TRY_TABLE = 0x1F,
   LOCAL_GET = 0x20,
   LOCAL_SET = 0x21,
   LOCAL_TEE = 0x22,
   GLOBAL_GET = 0x23,
   GLOBAL_SET = 0x24,
   PROPOSAL_TABLE_GET = 0x25,
   PROPOSAL_TABLE_SET = 0x26,
   I32_LOAD = 0x28,
   I64_LOAD = 0x29,
   F32_LOAD = 0x2A,
   F64_LOAD = 0x2B,
   I32_LOAD8_S = 0x2C,
   I32_LOAD8_U = 0x2D,
   I32_LOAD16_S = 0x2E,
   I32_LOAD16_U = 0x2F,
   I64_LOAD8_S = 0x30,
   I64_LOAD8_U = 0x31,
   I64_LOAD16_S = 0x32,
   I64_LOAD16_U = 0x33,
   I64_LOAD32_S = 0x34,
   I64_LOAD32_U = 0x35,
   I32_STORE = 0x36,
   I64_STORE = 0x37,
   F32_STORE = 0x38,
   F64_STORE = 0x39,
   I32_STORE8 = 0x3A,
   I32_STORE16 = 0x3B,
   I64_STORE8 = 0x3C,
   I64_STORE16 = 0x3D,
   I64_STORE32 = 0x3E,
   MEMORY_SIZE = 0x3F,
   MEMORY_GROW = 0x40,
   I32_CONST = 0x41,
   I64_CONST = 0x42,
   F32_CONST = 0x43,
   F64_CONST = 0x44,
   I32_EQZ = 0x45,
   I32_EQ = 0x46,
   I32_NE = 0x47,
   I32_LT_S = 0x48,
   I32_LT_U = 0x49,
   I32_GT_S = 0x4A,
   I32_GT_U = 0x4B,
   I32_LE_S = 0x4C,
   I32_LE_U = 0x4D,
   I32_GE_S = 0x4E,
   I32_GE_U = 0x4F,
   I64_EQZ = 0x50,
   I64_EQ = 0x51,
   I64_NE = 0x52,
   I64_LT_S = 0x53,
   I64_LT_U = 0x54,
   I64_GT_S = 0x55,
   I64_GT_U = 0x56,
   I64_LE_S = 0x57,
   I64_LE_U = 0x58,
   I64_GE_S = 0x59,
   I64_GE_U = 0x5A,
   F32_EQ = 0x5B,
   F32_NE = 0x5C,
   F32_LT = 0x5D,
   F32_GT = 0x5E,
   F32_LE = 0x5F,
   F32_GE = 0x60,
   F64_EQ = 0x61,
   F64_NE = 0x62,
   F64_LT = 0x63,
   F64_GT = 0x64,
   F64_LE = 0x65,
   F64_GE = 0x66,
   I32_CLZ = 0x67,
   I32_CTZ = 0x68,
   I32_POPCNT = 0x69,
   I32_ADD = 0x6A,
   I32_SUB = 0x6B,
   I32_MUL = 0x6C,
   I32_DIV_S = 0x6D,
   I32_DIV_U = 0x6E,
   I32_REM_S = 0x6F,
   I32_REM_U = 0x70,
   I32_AND = 0x71,
   I32_OR = 0x72,
   I32_XOR = 0x73,
   I32_SHL = 0x74,
   I32_SHR_S = 0x75,
   I32_SHR_U = 0x76,
   I32_ROTL = 0x77,
   I32_ROTR = 0x78,
   I64_CLZ = 0x79,
   I64_CTZ = 0x7A,
   I64_POPCNT = 0x7B,
   I64_ADD = 0x7C,
   I64_SUB = 0x7D,
   I64_MUL = 0x7E,
   I64_DIV_S = 0x7F,
   I64_DIV_U = 0x80,
   I64_REM_S = 0x81,
   I64_REM_U = 0x82,
   I64_AND = 0x83,
   I64_OR = 0x84,
   I64_XOR = 0x85,
   I64_SHL = 0x86,
   I64_SHR_S = 0x87,
   I64_SHR_U = 0x88,
   I64_ROTL = 0x89,
   I64_ROTR = 0x8A,
   F32_ABS = 0x8B,
   F32_NEG = 0x8C,
   F32_CEIL = 0x8D,
   F32_FLOOR = 0x8E,
   F32_TRUNC = 0x8F,
   F32_NEAREST = 0x90,
   F32_SQRT = 0x91,
   F32_ADD = 0x92,
   F32_SUB = 0x93,
   F32_MUL = 0x94,
   F32_DIV = 0x95,
   F32_MIN = 0x96,
   F32_MAX = 0x97,
   F32_COPYSIGN = 0x98,
   F64_ABS = 0x99,
   F64_NEG = 0x9A,
   F64_CEIL = 0x9B,
   F64_FLOOR = 0x9C,
   F64_TRUNC = 0x9D,
   F64_NEAREST = 0x9E,
   F64_SQRT = 0x9F,
   F64_ADD = 0xA0,
   F64_SUB = 0xA1,
   F64_MUL = 0xA2,
   F64_DIV = 0xA3,
   F64_MIN = 0xA4,
   F64_MAX = 0xA5,
   F64_COPYSIGN = 0xA6,
   I32_WRAP_I64 = 0xA7,
   I32_TRUNC_F32_S = 0xA8,
   I32_TRUNC_F32_U = 0xA9,
   I32_TRUNC_F64_S = 0xAA,
   I32_TRUNC_F64_U = 0xAB,
   I64_EXTEND_I32_S = 0xAC,
   I64_EXTEND_I32_U = 0xAD,
   I64_TRUNC_F32_S = 0xAE,
   I64_TRUNC_F32_U = 0xAF,
   I64_TRUNC_F64_S = 0xB0,
   I64_TRUNC_F64_U = 0xB1,
   F32_CONVERT_I32_S = 0xB2,
   F32_CONVERT_I32_U = 0xB3,
   F32_CONVERT_I64_S = 0xB4,
   F32_CONVERT_I64_U = 0xB5,
   F32_DEMOTE_F64 = 0xB6,
   F64_CONVERT_I32_S = 0xB7,
   F64_CONVERT_I32_U = 0xB8,
   F64_CONVERT_I64_S = 0xB9,
   F64_CONVERT_I64_U = 0xBA,
   F64_PROMOTE_F32 = 0xBB,
   I32_REINTERPRET_F32 = 0xBC,
   I64_REINTERPRET_F64 = 0xBD,
   F32_REINTERPRET_I32 = 0xBE,
   F64_REINTERPRET_I64 = 0xBF,
   PROPOSAL_I32_EXTEND8_S = 0xC0,
   PROPOSAL_I32_EXTEND16_S = 0xC1,
   PROPOSAL_I64_EXTEND8_S = 0xC2,
   PROPOSAL_I64_EXTEND16_S = 0xC3,
   PROPOSAL_I64_EXTEND32_S = 0xC4,
   PROPOSAL_REF_NULL = 0xD0,
   PROPOSAL_REF_IS_NULL = 0xD1,
   PROPOSAL_REF_FUNC = 0xD2,
   PROPOSAL_REF_AS_NON_NULL = 0xD3,
   PROPOSAL_BR_ON_NULL = 0xD4,
   PROPOSAL_REF_EQ = 0xD5,
   PROPOSAL_BR_ON_NON_NULL = 0xD6,
    GC, STR = 0xFB,
    FC = 0xFC,
    SIMD = 0xFD,
    THREADS = 0xFE,

}

FC_OPCODES :: enum {
    I32_TRUNC_SAT_F32_S
}

