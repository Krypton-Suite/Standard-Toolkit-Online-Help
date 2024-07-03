# Introduction
The `Krypton Suite` contains user interface components designed to make it quick and easy for developers to create professional looking applications. It provides the essential building blocks needed to create a consistent look and feel across all your products. You can use the built-in palettes to achieve the same appearance as industry standard applications such as _Microsoft Office 2007/2010/2013/365_ and _Visual Studio_. Alternatively you can create your own custom palettes to create a completely unique user interface.
The `Krypton Suite` consists of five products called `Krypton Toolkit`, `Krypton Ribbon`, `Krypton Navigator`, `Krypton Workspace` and `Krypton Docking`.


## https://github.com/Krypton-Suite/Standard-Toolkit
* Modifications by Peter Wagner (aka Wagnerp) & Simon Coghlan (aka Smurf-IV)  have been fixing and adding more capabilities to this toolkit.
* There is also an Extensions project, which takes these base controls and add more useful complete controls (Currently outside the scope of this help). To find out more, please head to [this link](https://github.com/Krypton-Suite/Extended-Toolkit)
* All .NET Versions from 4.6.2 are catered for 
* New versions of NuGet packages can be obtained via [this link](https://www.nuget.org/profiles/Krypton_Suite), or via your package manager by searching `Krypton.`.

## [Overview](./articles/intro.md)
If you are new to the Krypton Toolkit, please start here to gain a basic understanding of what the toolkit can do first, before using it in your own applications.

## [Krypton Toolkit](./articles/Krypton_Toolkit.md)
The `Krypton Toolkit` provides a set of basic user interface components for free. You can distribute the signed Krypton Toolkit assembly without charge or royalty with your own products. 
The `Krypton Toolkit` is great resource for speeding up development of professional looking applications. It works in tandem with the `MenuStrip`, `StatusStrip` and `ToolStrip` controls that come with _.NET Framework_ and _.NET_ controls. Using the `Krypton Toolkit` you can create a great looking application in just minutes. 
 

## [Krypton Ribbon](./articles/Krypton_Ribbon.md)
The `Krypton Ribbon` is designed to mimic the look, feel and operation of the ribbon control seen in the _Microsoft Office 2007/2010/2013/365_ applications such as _Word_ and _Excel_. It provides advanced capabilities including the quick access toolbar, contextual tabs and auto shrinking groups. With rich design time support and sample code you can be up and running with the ribbon in no time at all. It integrates with the `Krypton Toolkit` architecture to ensure a consistent look and feel. 


## [Krypton Navigator](./articles/Krypton_Navigator.md)
The `Krypton Navigator` is a user interface control that provides the user with a variety of ways to navigate around a set of pages. Think of it as a traditional `TabControl` on steroids. It has many different modes of operation allowing you to achieve exactly the right operation for your application. It integrates with the `Krypton Toolkit` architecture to ensure a consistent look and feel.
 
## [Krypton Workspace](./articles/Krypton_Workspace.md)
The `Krypton Workspace` allows a document area to be created that the user can customize by dragging and dropping pages into new positions. Similar to the Visual Studio document area but with far greater flexibility and functionality. Each cell within the workspace uses an instance of the `Krypton Navigator` allowing a wide range of options for organizing and displaying pages. It integrates with the Krypton Toolkit architecture to ensure a consistent look and feel.
 
## [Krypton Docking](./articles/Krypton_Docking.md)
The `Krypton Docking` set of components allow the user to drag and drop docking pages into new locations in order to customize the organization of the application content. It allows this in a way similar to that of Visual Studio 2008/2010. Each docking area uses an instance of the `Krypton Workspace` allowing a wide range of options for organizing and displaying pages. It integrates with the `Krypton Toolkit` architecture to ensure a consistent look and feel.

## [Krypton Custom Controls](./articles/Krypton_CustomControls.md)
When writing your own custom controls that are working alongside the Krypton controls you may want to ensure that the look and feel of your custom control matches that of the Krypton components. There are two levels of integration that you can aim for. The first is to use the same palette of colors, font, widths and other metrics when drawing and sizing your custom control. This is the purpose of the [Using PaletteBase](articles/Custom%20Controls/Using%20PaletteBase.md) article. Recovering these metrics is actually very simple and you can examine the Custom Control using Palettes sample project to see the principle in action.

Alternatively you might want to leverage the same rendering code that the Krypton Toolkit controls use. In this case follow the [Using IRenderer](articles/Custom%20Controls/Using%20IRenderer.md) article to understand how to render background, border and content elements within your custom control client area. Although a little more complicated this technique has the advantage of performing the hard work for you. You can use the renderer to draw vertical orientated text and elements with tiled images without the need to write the actual drawing code yourself.

## [Contributing to the Standard Toolkit](./articles/Contributing.md)
Want to contribute to the Standard Toolkit project? Learn more [here](articles/Contributing.md).