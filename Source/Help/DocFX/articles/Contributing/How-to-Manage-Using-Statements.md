# Krypton Developer Documentation - How to Manage Using Statements

As part of C# 10 & .NET 6, it is now possible to contain all `using` statements in one central file. The benefits to doing this is that it frees up system resources, and avoids a spider web of `using` declarations.

As a result, **all** projects contain a `GlobalDeclarations` file in a directory named ***Globals***. If you need to add a new `using` statement, please add it to the aforementioned file, while removing the unneeded statements from the source code file. 

**If** a resource is only being used within one class itself, for example `ContentAlignment`, then you need to define it under the license header, as follows:

```cs
using ContentAlignment = System.Drawing.ContentAlignment;
```