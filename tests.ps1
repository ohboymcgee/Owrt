$Tool_Path = ".\external_tools" 
$Wat_2_Wasm = "$Tool_Path\wat2wasm.exe"
$Wasm_Validate = "$Tool_Path\wasm-validate.exe"

$Src_Path = ".\owrt"

$Test_Path = ".\wasmtests"
$Test_Build_Path = "$Test_Path\compiled_modules"

function Invoke-WasmTests  {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]
        $F_Info
    )
    Write-Output $F_Info.FullName
    $Out_Path = $F_Info.BaseName
    $Input_Path = $F_Info.FullName
    Write-Output $Out_Path
    Invoke-Expression "$Wat_2_Wasm  $Input_Path -o $Test_Build_Path\$Out_Path.wasm" 
    
    #Invoke-Expression -Command "$Wasm_Validate -v $Test_Build_Path\$Out_Path.wasm" -PipelineVariable $P > "$Test_Build_Path\validation_info.txt"
    


}



foreach ($Test_File in (Get-ChildItem -Path $Test_Path -File)) {
    Write-Output $Test_File
    Invoke-WasmTests $Test_File
}



