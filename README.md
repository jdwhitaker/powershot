# powershot
PowerShell snapshot

## Example: Starting a process

```
PS C:\Users\justi\git\powershot> $snapshot1 = .\powershot.ps1
PS C:\Users\justi\git\powershot> notepad.exe
PS C:\Users\justi\git\powershot> $snapshot2 = .\powershot.ps1
PS C:\Users\justi\git\powershot> $paths1 = $snapshot1 | Sort-Object -Unique -Property Path | select-object -ExpandProperty Path
PS C:\Users\justi\git\powershot> $paths2 = $snapshot2 | Sort-Object -Unique -Property Path | select-object -ExpandProperty Path
PS C:\Users\justi\git\powershot> Compare-Object $paths1 $paths2


InputObject                                SideIndicator
-----------                                -------------
C:\WINDOWS\system32\notepad.exe            =>
C:\Windows\System32\smartscreen.exe        =>
C:\WINDOWS\system32\backgroundTaskHost.exe <=

PS C:\Users\justi\git\powershot>
```

You can see notepad.exe started in the second one.

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

PS C:\Users\justi\git\powershot> $snapshot1 | Export-Clixml snapshot1.xml
PS C:\Users\justi\git\powershot> $loaded = Import-Clixml .\snapshot1.xml

# Todo

- Add helper function to compare snapshots by process paths and modules per process
