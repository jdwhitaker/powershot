$cache_md5 = @{}
$cache_sha1 = @{}

function getHashes($path){
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
            'Hashes' = getHashes($module.FileName);
        }
        $moduleReturnObject = New-Object PSObject -Property $moduleProperties
        write-output $moduleReturnObject
    }
    $properties = @{
        'Name' = $name;
        'Path' = $path;
        'Hashes' = getHashes($path);
        'Modules' = $modules;
    }
    $retval = New-Object PSObject -Property $properties
    write-output $retval
}