# powershot
PowerShell snapshot

```
PS C:\Users\justi\git\powershot> $snapshot1 = .\powershot.ps1
PS C:\Users\justi\git\powershot> # do something
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
