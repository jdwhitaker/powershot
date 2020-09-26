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
PS C:\Tools> $modsExplorerEXE1 = $snapshot1 | where-object -Property Path -like '*explorer*' | select-object -ExpandProperty Modules | select-object -expandproperty Path | Sort-Object -Unique
PS C:\Tools> $modsExplorerEXE2 = $snapshot2 | where-object -Property Path -like '*explorer*' | select-object -ExpandProperty Modules | select-object -expandproperty Path | Sort-Object -Unique
PS C:\Tools> compare-object -ReferenceObject $modsExplorerEXE1 -DifferenceObject $modsExplorerEXE2

InputObject                          SideIndicator
-----------                          -------------
C:\WINDOWS\system32\mswsock.dll      =>
C:\WINDOWS\System32\PSAPI.DLL        =>
C:\Windows\System32\cdprt.dll        <=
C:\Windows\System32\EhStorAPI.dll    <=
C:\Windows\System32\PlayToDevice.dll <=


PS C:\Tools>
```

You can see Explorer loaded PSAPI.dll and mswsock.dll (for bad things).

## Saving and loading

```
PS C:\Users\justi\git\powershot> $snapshot1 | Export-Clixml snapshot1.xml
PS C:\Users\justi\git\powershot> $loaded = Import-Clixml .\snapshot1.xml
```

# Todo

- Add helper function to compare snapshots by process paths and modules per process
