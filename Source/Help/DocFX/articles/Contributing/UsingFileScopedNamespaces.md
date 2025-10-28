# Using File Scoped Namespaces

As of version 100, we have moved to using file scoped namespaces, introduced as part of the C# 10 specification. For more information, click [here](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/proposals/csharp-10.0/file-scoped-namespaces).

## Before

```csharp
    namespace Krypton.Toolkit
    {
        public class KryptonClass
        {
            // Logic goes here...
        }
    }
```

## After

```csharp
    namespace Krypton.Toolkit;
    
    public class KryptonClass
    {
        // Logic goes here...
    }
```
