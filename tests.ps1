$Tool_Path = ".\external_tools" 
$Wat_2_Wasm = "$Tool_Path\wat2wasm.exe"
$Wasm_Validate = "$Tool_Path\wasm-validate.exe"

$Src_Path = ".\owrt"

$Test_Path = ".\wasmtests"

$Test_Build_Path = "$Test_Path\compiled_modules"

function Invoke-WasmTests {
    Write-Output "Running WasmTests"
    $Children = (Get-ChildItem -Path "$Test_Path\" -Filter "*.wat" -File)
    foreach ($child in ($Children)) {
        Write-Output "running test on: $child"
        Invoke-WasmTest  $child
    }
}

function Invoke-WasmTest  {
    param (
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]
        $F_Info
        
        
    )
    Write-Output "F_Info: $F_Info"
    $Out_Path = $F_Info.BaseName
    $Input_Path = $F_Info.FullName
    Write-Output "OutPath: $Out_Path"
    Write-Output "running '$Wat_2_Wasm' on '$Input_Path'" 
    Invoke-Expression "$Wat_2_Wasm $Input_Path -o $Test_Build_Path\$Out_Path.wasm"
    Write-Output "running '$Wasm_Validate' for '$Test_Build_Path\$Out_Path.wasm'" 
   <#  $validateOptions = @{
        FilePath = "$Wasm_Validate"
        ArgumentList = "-v", "$Test_Build_Path\$Out_Path.wasm"
        Verbose = $true
        Wait = $true
        
    } #>
    
    Invoke-Expression -Command "Out-File $Test_Build_Path\validation_result_$Out_Path.txt -Encoding utf8 -InputObject ($Wasm_Validate -v $Test_Build_Path\$Out_Path.wasm)"
    
    #Start-Process -FilePath $Wat_2_Wasm -ArgumentList $Input_Path "-o $Test_Build_Path\$Out_Path.wasm" -PassThru  ##-RedirectStandardOutput > ".\build_result.txt"
    #Start-Process -FilePath $Wasm_Validate -ArgumentList "$Test_Build_Path\$Out_Path.wasm" -PassThru ##-RedirectStandardOutput > ".\validate_result.txt"
    
    
    #Invoke-Expression -Command "$Wasm_Validate -v $Test_Build_Path\$Out_Path.wasm" -PipelineVariable $P > "$Test_Build_Path\validation_info.txt"
    


}


function Invoke-OwrtTests {
    Write-Output (Invoke-Expression "odin test $Src_Path  --debug") #-RedirectStandardOutput ".\test_result.txt"#(Start-Process -FilePath "odin.exe" -ArgumentList ["test" ,"$Src_Path\", "--debug"])
}


Invoke-WasmTests

#Invoke-OwrtTests


