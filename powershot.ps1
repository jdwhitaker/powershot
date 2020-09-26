function get-snapshot(){
    $cache_md5 = @{};
    $cache_sha1 = @{};
    function Get-SnapshotHashes($processPath){
        if(!$processPath){
            return @{
                'MD5' = '';
                'SHA1' = '';
            }
        }
        $retMD5 = '';
        $retSHA1 = '';
        if($cache_md5.containsKey($processPath)){
            $retMD5 = $cache_md5[$processPath]
        }
        else{
            $retMD5 =  get-filehash -path $processPath -algorithm MD5
            $cache_md5[$processPath] = $retMD5
        }
        if($cache_sha1.containsKey($processPath)){
            $retSHA1 = $cache_sha1[$processPath]
        }
        else{
            $retSHA1 =  get-filehash -path $processPath -algorithm SHA1
            $cache_sha1[$processPath] = $retSHA1
        }
        return @{
            'MD5' = $retMD5;
            'SHA1' = $retSHA1;
        }
    }
    foreach($process in get-process){
        $name = $process.ProcessName
        $processPath = $process.Path
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
            'Path' = $processPath;
            'Hashes' = get-snapshothashes($processPath);
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
    $referenceProcessPaths = get-SnapshotPaths($reference)
    $differenceProcessPaths = get-SnapshotPaths($difference)
    if(!$referenceProcessPaths){
        Write-Output $differenceProcessPaths
    }
    else{
        Compare-Object $referenceProcessPaths $differenceProcessPaths |
            Where-Object -Property SideIndicator -Eq '=>' |
            Select-Object -ExpandProperty InputObject |
            write-output
    }
}

function Get-SnapshotNewModules($processPath, $refSnapshot, $difSnapshot){
    $refModules = $refSnapshot |
        Where-Object -Property Path -EQ $processPath |
        Select-Object -ExpandProperty Modules |
        Select-Object -ExpandProperty Path | 
        Sort-Object -Unique
    $difModules = $difSnapshot |
        Where-Object -Property Path -EQ $processPath |
        Select-Object -ExpandProperty Modules |
        Select-Object -ExpandProperty Path | 
        Sort-Object -Unique
    if($refModules){
        compare-object -ReferenceObject $refModules -DifferenceObject $difModules |
            Where-Object -Property SideIndicator -Eq '=>' |
            Select-Object -ExpandProperty InputObject |
            Write-Output
    }
    else{
        $difModules |
            Write-Output
    }
}

function Compare-Snapshot($referenceSnapshot, $differenceSnapshot){
    $newProcesses = Get-SnapshotNewProcesses($referenceSnapshot, $differenceSnapshot);
    $newModulesByProcess = foreach($process in $differenceSnapshot){
        $newModules = Get-SnapshotNewModules -processPath $process.Path -refSnapshot $referenceSnapshot -difSnapshot $differenceSnapshot
        $properties = @{
            'Name' = $process.Name;
            'Path' = $process.Path;
            'NewModules' = $newModules;
        }
        New-object psobject -Property $properties | 
            Write-Output
    } 
    $properties = @{
        'NewProcesses' = $newProcesses | sort-object -unique;
        'NewModules' = $newModulesByProcess | Sort-Object -Unique -property Path;
    }
    $retval = New-Object PSObject -Property $properties
    write-output $retval
}