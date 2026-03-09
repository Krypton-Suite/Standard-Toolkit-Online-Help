# How to Build the Standard Toolkit

If you want to build the Standard Toolkit project, there are a number of prerequisites you will need to have first before continuing.

* A supported copy of Windows 10/11
* Microsoft Visual Studio/Build Tools 2022 or later
* Microsoft .NET Framework 4.6.2 or later
  * As of version 100, Microsoft .NET Framework 4.7.2 is required as a minimum
* .NET 6 or later
  * As of version 100, .NET 8 is required as a minimum
* Windows Terminal (optional)
* Ensure that [Long path name support](AllowingforLongerPathandFileNames.md) is enabled
* Time :slightly_smiling_face:

To compile the source tree for yourself, run `run.cmd` from the repository root (Command Prompt or Windows Terminal). This launches an interactive menu for building Nightly, Canary, or Stable versions and creating NuGet packages. Alternatively, use `dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug` for a quick Debug build, or `Scripts/VS2022/build-stable.cmd` for a Stable build. Outputs are stored in `Bin/<Configuration>/` (e.g., `Bin/Release`, `Bin/Nightly`, `Bin/Canary`); NuGet packages go to `Bin/Packages/<Configuration>/`.
