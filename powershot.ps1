function get-snapshot(){
    $cache_md5 = @{};
    $cache_sha1 = @{};
    function Get-SnapshotHashes($path){
        if(!$path){
            return @{
                'MD5' = '';
                'SHA1' = '';
            }
        }
        $retMD5 = '';
        $retSHA1 = '';
        if($cache_md5.containsKey($path)){
            $retMD5 = $cache_md5[$path]
        }
        else{
            $retMD5 =  get-filehash -path $path -algorithm MD5
            $cache_md5[$path] = $retMD5
        }
        if($cache_sha1.containsKey($path)){
            $retSHA1 = $cache_sha1[$path]
        }
        else{
            $retSHA1 =  get-filehash -path $path -algorithm SHA1
            $cache_sha1[$path] = $retSHA1
        }
        return @{
            'MD5' = $retMD5;
            'SHA1' = $retSHA1;
        }
    }
    foreach($process in get-process){
        $name = $process.ProcessName
        $path = $process.Path
        $modules = foreach($module in $process.Modules){
            $moduleProperties = @{
                'Name' = $module.ModuleName;
                'Path' = $module.FileName;
                'Hashes' = Get-SnapshotHashes($module.FileName);
            }
            $moduleReturnObject = New-Object PSObject -Property $moduleProperties
            write-output $moduleReturnObject
        }
        $properties = @{
            'Name' = $name;
            'Path' = $path;
            'Hashes' = get-snapshothashes($path);
            'Modules' = $modules;
        }
        $retval = New-Object PSObject -Property $properties
        write-output $retval
    }
}
function Get-SnapshotPaths($snapshot){
    $snapshot | 
        Sort-Object -Unique -Property Path |
        Select-Object -ExpandProperty Path |
        Write-Output
}

function Get-SnapshotNewProcesses($reference, $difference){
    $referenceProcessPaths = get-SnapshotPaths($referenceSnapshot)
    $differenceProcessPaths = get-SnapshotPaths($differenceSnapshot)
    $newProcesses = Compare-Object $referenceProcessPaths $differenceProcessPaths |
        Where-Object -Property SideIndicator -Eq '=>' |
        Select-Object -ExpandProperty InputObject
    write-output $newProcesses
}

function Get-SnapshotNewModules($path, $refSnapshot, $difSnapshot){
    $refModules = $refSnapshot |
        Where-Object -Property Path -EQ $path |
        Select-Object -ExpandProperty Modules |
        Sort-Object -Unique
    $difModules = $difSnapshot |
        Where-Object -Property Path -EQ $path |
        Select-Object -ExpandProperty Modules |
        Sort-Object -Unique
    compare-object -ReferenceObject $refModules -DifferenceObject $difModules |
        Where-Object -Property SideIndicator -Eq '=>' |
        Select-Object -ExpandProperty InputObject |
        Write-Output
}

function Compare-Snapshot($referenceSnapshot, $differenceSnapshot){
    $newProcesses = Get-SnapshotNewProcesses;
    $newModulesByProcess = foreach($process in $differenceSnapshot){
        if(!($newProcesses -contains $process.Path)){
            $newModules = Get-SnapshotNewModules($process.Path, $referenceSnapshot, $differenceSnapshot)
            $properties = @{
                'Name' = $process.Name;
                'Path' = $process.Path;
                'NewModules' = $newModules;
            }
            New-object psobject -Property $properties |
                Write-Output
        }
    }
    $properties = @{
        'NewProcesses' = $newProcesses;
        'NewModules' = $newModulesByProcess;
    }
    $retval = New-Object PSObject -Property $properties
    write-output $retval
}