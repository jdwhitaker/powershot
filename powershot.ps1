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


function Compare-Snapshot($referenceSnapshot, $differenceSnapshot){
    $referenceNames = $referenceSnapshot |
        Select-Object -ExpandProperty Name
    foreach($proc in $differenceSnapshot){
        if(!($referenceNames -contains $proc.Name)){
            Write-output $proc
        }
        else {
            $referenceModuleNames = $referenceSnapshot |
                where-object -Property Name -eq $proc.Name | 
                select-object -ExpandProperty Modules | 
                Select-Object -ExpandProperty Name | 
                Sort-Object -Unique
	    $newModules = foreach($module in $proc.Modules){
                if($referenceModuleNames -notcontains $module.Name){
			write-output $module
		}
	}
            if($newModules.length -gt 0){
                $properties = @{
                    'Name' = $proc.Name;
                    'Path' = $proc.Path;
                    'Hashes' = $proc.Hashes;
                    'Modules' = $newModules;
                }
                $retval = New-Object PSObject -Property $properties
                write-output $retval
            }
        }
    }
}