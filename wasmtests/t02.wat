(module 
    (func $garbo (param $p1 i64) (result i64)
        (local.get $p1)
        (return))
        
    (export "garbo" (func $garbo)))