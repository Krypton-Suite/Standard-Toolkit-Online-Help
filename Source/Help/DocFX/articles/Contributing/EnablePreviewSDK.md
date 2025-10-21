# How to enable preview SDKs inside of stable versions of Visual Studio

The purpose of this article is to describe how to enable preview SDKs inside of stable versions of Visual Studio. Please note that this guide is for people using Visual Studio 2022, older versions may not be supported. If you are using preview versions of Visual Studio, usage of preview SDKs will be enabled by default.

**Step 1:** Open Visual Studio or load a project

**Step 2:** Click `Tools`, and then `Options`

**Step 3:** Scroll down until you can see `Preview Features` and then click on that option

**Step 4:** In the list on the right, check the option that says `Use previews of the .NET SDK (requires restart)` (if not already checked)

**Step 5:** Click `OK`

**Step 6:** Close and restart ***all*** instances of Visual Studio

**Step 7:** Configure your project to use a preview version of .NET and then build

***NOTE:*** By following this guide, you accept that we are _not_ responsible for **any** data loss or damage. It is _your_ responsibility to create backups of your data.

![](https://github.com/Krypton-Suite/Documentation/blob/main/Assets/Miscellaneous/EnablePreviewSDK.gif?raw=true)