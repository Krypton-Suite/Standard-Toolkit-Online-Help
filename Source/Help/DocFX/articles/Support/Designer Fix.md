# How To Fix the components in the designer

If you are experiencing issues while using the components in the designer, you might need to replace  `<TargetFramework>net[##Current-Version##]-windows</TargetFramework>` with `<TargetFrameworks>net481;net[##Current-Version##]-windows</TargetFrameworks>` in your project configuration files.

To learn more about the `TargetFrameworks` attribute, [click here](https://docs.microsoft.com/en-us/dotnet/standard/frameworks).

## N.B: This action will produce binaries for multiple frameworks.