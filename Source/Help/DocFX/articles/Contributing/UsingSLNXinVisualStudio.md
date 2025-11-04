# Using SLNX in Visual Studio

Starting with version 100, **all** Krypton source code supports Visual Studio's `slnx` file formats. The question you might be asking yourself is why the change? There is a very simple answer... simplicity!

For 20+ years, the default format has been `sln`. The issue is that the file structure is incredibly messy to deal with.

![Krypton Toolkit Suite SLN](Images/Krypton%20Toolkit%20Suite%20SLN.png)

*Figure 1: Krypton Toolkit Suite SLN file format*

With the new `slnx` file format, it's entirely XML based, which means it is more maintainable.

![Krypton Toolkit Suite SLNX](Images/Krypton%20Toolkit%20Suite%20SLNX.png)

*Figure 2: Krypton Toolkit Suite SLNX file format*

If you are using Visual Studio 17.13 or later, please watch the following to enable `slnx` support.

![Activating SLNX Support](https://github.com/Krypton-Suite/Documentation/blob/main/Assets/Miscellaneous/Activating%20SLNX%20Support.gif?raw=true)

For more information, click [here](https://devblogs.microsoft.com/visualstudio/new-simpler-solution-file-format/).
