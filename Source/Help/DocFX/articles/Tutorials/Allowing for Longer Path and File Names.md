# How to allow longer path/file names

As of V90.##, you will need to allow for longer path/file names, as this is not enabled by default in Windows. Failure to do so will result in the [MSB3553](https://learn.microsoft.com/en-us/visualstudio/msbuild/errors/msb3553?view=vs-2022) compiler error.

There are two ways that you can do this. They are:-

1. Via [`gpedit`](#option-1---via-gpedit)
2. Via an elevated [PowerShell](#option-2---powershell) prompt

## Option 1 - via `gpedit`

**Step 1**

Search for `gpedit.msc` from the start or search menu, then open it.

**Step 2**

Navigate to `Computer Configuration` -> `Administrative Templates` -> `System` -> `Filesystem`.

**Step 3**

Look for a setting called `Enable Win32 Long paths` on the right side.

![](Images/Allowing%20Longer%20File%20Names/Group%20Policy%20Editor.png)

**Step 4**

Double click the `Enable Win32 Long paths` setting, click `Enabled`, then click OK.

![](Images/Allowing%20Longer%20File%20Names/Enable%20Win32%20Long%20Paths.png)

**Step 5**

Close _all_ windows and restart your computer.

_**Note:** It is necessary to do this, so that changes can take effect._


## Option 2 - PowerShell

Open a new _elevated_ PowerShell prompt, then run the command as shown below.

```ps
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" ` -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```