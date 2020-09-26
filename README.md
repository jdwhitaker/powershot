# powershot
PowerShell snapshot

## Example: Starting a process

```
PS C:\Users\justi\git\powershot> . .\powershot.ps1 
PS C:\Users\justi\git\powershot> $snap1 = get-snapshot
PS C:\Users\justi\git\powershot> $snap2 = get-snapshot
PS C:\Users\justi\git\powershot> $diff = Compare-Snapshot $snap1 $snap2      
PS C:\Users\justi\git\powershot> $diff

NewModules NewProcesses
---------- ------------
{}         {C:\Program Files\Notepad++\notepad++.exe, C:\Windows\System32\smartscreen.exe}

PS C:\Users\justi\git\powershot> $diff | Select-Object -ExpandProperty NewProcesses

C:\Program Files\Notepad++\notepad++.exe
C:\Windows\System32\smartscreen.exe
```

## Example: Comparing modules to find Meterpreter in Explorer.exe

```
PS C:\Tools> $diff = Compare-Snapshot $snapshot1 $snapshot2
PS C:\Tools> $diff

Hashes      Path                            Name       Modules
------      ----                            ----       -------
{SHA1, MD5} C:\WINDOWS\Explorer.EXE         explorer   {@{Hashes=System.Collections.Hashtable; Path=C:\WINDOWS\System32\wscinterop.dll; Name=wscinterop.dll}, @{Hashes=System.Collections.Hashtable; Path=C:\WI...
{SHA1, MD5} C:\WINDOWS\system32\lsass.exe   lsass      {@{Hashes=System.Collections.Hashtable; Path=C:\Windows\System32\vaultsvc.dll; Name=vaultsvc.dll}, @{Hashes=System.Collections.Hashtable; Path=C:\WINDOW...
{SHA1, MD5}                                 SgrmBroker
{SHA1, MD5} c:\windows\system32\svchost.exe svchost    {@{Hashes=System.Collections.Hashtable; Path=C:\Windows\System32\Windows.Web.dll; Name=Windows.Web.dll}, @{Hashes=System.Collections.Hashtable; Path=C:\...
{SHA1, MD5} c:\windows\system32\svchost.exe svchost    {@{Hashes=System.Collections.Hashtable; Path=C:\WINDOWS\system32\WaaSMedicPS.dll; Name=WaaSMedicPS.dll}, @{Hashes=System.Collections.Hashtable; Path=C:\...
{SHA1, MD5} c:\windows\system32\svchost.exe svchost    {@{Hashes=System.Collections.Hashtable; Path=c:\windows\system32\aphostservice.dll; Name=aphostservice.dll}, @{Hashes=System.Collections.Hashtable; Path...
{SHA1, MD5} c:\windows\system32\svchost.exe svchost    {@{Hashes=System.Collections.Hashtable; Path=c:\windows\system32\wscsvc.dll; Name=wscsvc.dll}, @{Hashes=System.Collections.Hashtable; Path=C:\WINDOWS\SY...


PS C:\Tools> $diff[1]

Hashes      Path                          Name  Modules
------      ----                          ----  -------
{SHA1, MD5} C:\WINDOWS\system32\lsass.exe lsass {@{Hashes=System.Collections.Hashtable; Path=C:\Windows\System32\vaultsvc.dll; Name=vaultsvc.dll}, @{Hashes=System.Collections.Hashtable; Path=C:\WINDOWS\SYSTE...


PS C:\Tools> $diff[1].Modules

Hashes      Path                               Name
------      ----                               ----
{SHA1, MD5} C:\Windows\System32\vaultsvc.dll   vaultsvc.dll
{SHA1, MD5} C:\WINDOWS\SYSTEM32\certpoleng.dll certpoleng.dll
{SHA1, MD5} C:\WINDOWS\system32\wkscli.dll     wkscli.dll
{SHA1, MD5} C:\WINDOWS\system32\WININET.dll    WININET.dll
{SHA1, MD5} C:\WINDOWS\system32\WINHTTP.dll    WINHTTP.dll
{SHA1, MD5} C:\WINDOWS\System32\USER32.dll     USER32.dll
{SHA1, MD5} C:\WINDOWS\System32\win32u.dll     win32u.dll
{SHA1, MD5} C:\WINDOWS\System32\GDI32.dll      GDI32.dll
{SHA1, MD5} C:\WINDOWS\System32\gdi32full.dll  gdi32full.dll
{SHA1, MD5} C:\WINDOWS\System32\ole32.dll      ole32.dll
{SHA1, MD5} C:\WINDOWS\System32\PSAPI.DLL      PSAPI.DLL
{SHA1, MD5} C:\WINDOWS\system32\WINMM.dll      WINMM.dll
{SHA1, MD5} C:\WINDOWS\system32\WINMMBASE.dll  WINMMBASE.dll
{SHA1, MD5} C:\WINDOWS\System32\cfgmgr32.dll   cfgmgr32.dll
{SHA1, MD5} C:\WINDOWS\System32\SHLWAPI.dll    SHLWAPI.dll
{SHA1, MD5} C:\WINDOWS\system32\MPR.dll        MPR.dll
{SHA1, MD5} C:\WINDOWS\system32\NETAPI32.dll   NETAPI32.dll
{SHA1, MD5} C:\WINDOWS\system32\cscapi.dll     cscapi.dll
```

You can see meterpreter loaded several additional modules into Lsass.exe.

## Saving and loading

```
PS C:\Users\justi\git\powershot> $snapshot1 | Export-Clixml snapshot1.xml
PS C:\Users\justi\git\powershot> $loaded = Import-Clixml .\snapshot1.xml
```
