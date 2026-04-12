# Tutorial – 3 Pane Application

## Steps

### Step 1: Create a new Windows Forms project

This will automatically create a form in design mode as below.

![Normal WinForm Form](Images/Normal%20WinForm%20Form.png)

### Step 2: Add a reference to the Krypton.Toolkit assembly

**C\#** : Right click the 'References' group in your project and select the 'Add
Reference...' option. Use the 'Browse' tab of the shown dialog box to navigate
to the location you installed the library and choose the
'\\bin\\Krypton.Toolkit.dll' file. This will then add the
toolkit assembly to the list of references for the project.

**VB.NET** : Right click the project in the 'Solution Explorer' window and choose
the 'Add Reference' option. Use the 'Browse' tab of the shown dialog box to
navigate to the location you installed the library and choose the
'\\bin\\Krypton.Toolkit.dll' file. This will then add the
toolkit assembly to the list of references for the project.

### Step 3: Ensure that the Krypton Toolkit components are in the Toolbox

If not the [Using Krypton in Visual Studio 2022](UsingKryptoninVisualStudio2022.md)
tutorial can be used to add them.

### Step 4: Open the code view for the form and change the base class

Change the base class from the default of 'Form' to be
'Krypton.Toolkit.KryptonForm'. Your new definition for C\#
would be: -

```cs
public partial class Form1 : KryptonForm
```

If using VB.NET then your new definition should like this: -

```vb
Partial Class Form1
    Inherits Krypton.Toolkit.KryptonForm
```

Recompile the project and then show the form in design mode again, this time you
should see custom chrome applied to the form.

![Form designer with KryptonForm custom chrome applied](Images/Three%20Pane%20Application/ThreePaneA1.png)

### Step 5: Drag a MenuStrip from the toolbox and drop it on the form

This will automatically dock itself to the top of the form.

![Form with MenuStrip docked at the top](Images/Three%20Pane%20Application/ThreePaneA2.png)

### Step 6: Use the MenuStrip smart tag and click ‘Insert Standard Items’

Click the small box on the top right of the MenuStrip to open the smart tag.

![MenuStrip smart tag with Insert Standard Items](Images/Three%20Pane%20Application/ThreePaneA3.png)

### Step 7: Drag a ToolStrip from the toolbox and drop it on the form

This will automatically dock itself underneath the MenuStrip

![ToolStrip docked below the MenuStrip](Images/Three%20Pane%20Application/ThreePaneA4.png)

### Step 8: Use the ToolStrip smart tag and click ‘Embed in ToolStripContainer’

This will create a box with four edge markers and a tool bar area at the top.

![ToolStrip embedded in a ToolStripContainer](Images/Three%20Pane%20Application/ThreePaneA5.png)

### Step 9: Drag a StatusStrip from the toolbox and drop it on the form

This will automatically be docked to the bottom of the form as shown here.

![StatusStrip docked at the bottom of the form](Images/Three%20Pane%20Application/ThreePaneA6.png)

### Step 10: Use the StatusStrip smart tag and change the 'RenderMode' to ‘ManagerRenderMode'

By default the StatusStrip uses the system renderer but Krypton needs to have
all tool strips use the global ToolStripManager renderer in order to ensure a
consistent look and feel across all the strips. So we change the rendering mode
to ensure the consistent appearance.

![StatusStrip RenderMode set to ManagerRenderMode](Images/Three%20Pane%20Application/ThreePaneA7.png)

### Step 11: Use the properties window to select the 'toolStripContainer1'

You cannot select the tool strip container by clicking on the container itself
in the designer and so we need to use the properties window to manually cause
the selection to change. Once selected you will notice the designer view change
to show the entire tool strip container selected with the smart tag button
displayed.

![Properties window with toolStripContainer1 selected](Images/Three%20Pane%20Application/ThreePaneA8.png)

### Step 12: Use the ToolStripContainer smart tag and select ‘Dock Fill in Form'

We do this so the container takes up all the space left over after positioning
the menu and status strips.

![ToolStripContainer smart tag Dock Fill in Form](Images/Three%20Pane%20Application/ThreePaneA9.png)

### Step 13: Select the tool strip and use the smart tag to select 'Insert Standard Items'

Click the small box on the top right of the ToolStrip to open the smart tag.

![ToolStrip smart tag Insert Standard Items](Images/Three%20Pane%20Application/ThreePaneA10.png)

### Step 14: Click center of the client area then use properties window to set 'RenderMode' to 'ManagerRenderMode'

By default the content panel in the center of the tool strip container uses the
system renderer but Krypton needs to have all tool strips use the global
ToolStripManager renderer in order to ensure a consistent look and feel across
all areas. So we change the rendering mode to ensure the consistent appearance.

![Content panel RenderMode set to ManagerRenderMode](Images/Three%20Pane%20Application/ThreePaneA11.png)

You should now have the following appearance which is the starting point for
building the specific functionality of this tutorial.

![Form shell with menu, tool strip container, and status strip](Images/Three%20Pane%20Application/ThreePaneA12.png)

### Step 15: Modify the Padding property for the ‘toolStripContainer1.ContentPanel’ to 5 on all sides

You should still have the content panel of the tool strip container selected in
the properties window, if not then just click in the center of the client area
and the content panel will be selected again. Then alter the padding property as
shown here. This adds padding around the four form edges otherwise all the
panels would be placed hard against the edges.

![ContentPanel Padding set to 5 on all sides](Images/Three%20Pane%20Application/ThreePane21.png)

### Step 16: Drag a KryptonSplitContainer from the toolbox and drop it inside the KryptonPanel

You should see text indicating the position of Panel1 and Panel2 areas.

![KryptonSplitContainer inside the content panel showing Panel1 and Panel2](Images/Three%20Pane%20Application/ThreePaneA13.png)

### Step 17: Drag a KryptonSplitContainer from the toolbox and drop it inside the area marked ‘Pane2’

There will now be two areas marked as Panel1 but only one marked as Panel2.

![Nested KryptonSplitContainer in the right-hand Pane2 area](Images/Three%20Pane%20Application/ThreePaneA14.png)

### Step 18: Use the smart tag for the second KryptonSplitContainer and click ‘Horizontal splitter orientation’

This will switch the splitter from being vertical to horizontal in direction.

![Second split container with horizontal splitter orientation](Images/Three%20Pane%20Application/ThreePaneA15.png)

### Step 19: Drag a KryptonHeaderGroup from the toolbox and drop onto the left most ‘Panel1’

The first pane needs a top and bottom header so we use a KryptonHeaderGroup.
Once dropped you will need to use the smart tag of the header group in order to
select the 'Dock in parent container' so that it fills the entire 'Panel1' area
it was dropped into.

![KryptonHeaderGroup docked in the leftmost Panel1](Images/Three%20Pane%20Application/ThreePaneA16.png)

### Step 20: Drag a KryptonHeaderGroup from the toolbox and drop onto the top most ‘Panel1’

The second pane needs one header so we still need to use a KryptonHeaderGroup.
Once dropped you will need to use the smart tag of the header group in order to
select the 'Dock in parent container' so that it fills the entire 'Panel1' area
it was dropped into.

![KryptonHeaderGroup docked in the top-right Panel1](Images/Three%20Pane%20Application/ThreePaneA17.png)

### Step 21: Use the smart tag for the second KryptonHeaderGroup and click ‘Hide secondary header’

We remove the bottom header from being displayed.

![Header group with secondary header hidden](Images/Three%20Pane%20Application/ThreePaneA18.png)

### Step 22: Drag a KryptonGroup from the toolbox and drop onto the ‘Panel2’ area

The third pane does not need any headers so a KryptonGroup is used. Once dropped
you will need to use the smart tag of the group in order to select the 'Dock in
parent container' so that it fills the entire 'Panel2' area it was dropped into.

![KryptonGroup docked in the bottom-right Panel2 area](Images/Three%20Pane%20Application/ThreePaneA19.png)

### Step 23: Modify the ‘StateCommon -\> Back -\> Color1’ property to ‘AppWorkspace’

We want the padding area to be distinctive and so change the color.

![StateCommon Back Color1 set to AppWorkspace on the outer group](Images/Three%20Pane%20Application/ThreePane22.png)

### Step 24: Modify the Padding property for the new kryptonGroup1.Panel to 5 on all sides

Click on the center of the new group to select the kryptonGroup1.Panel control.
This is the Panel instance that is positioned inside the border of the group.
Once the panel is selected set the border to 5 by using the properties window as
can be seen below.

![kryptonGroup1.Panel Padding set to 5 on all sides](Images/Three%20Pane%20Application/ThreePane21.png)

### Step 25: Drag a KryptonGroup from the toolbox and drop into the existing KryptonGroup

![Nested KryptonGroup placed inside the existing KryptonGroup](Images/Three%20Pane%20Application/ThreePaneA20.png)

### Step 26: Use the smart tag for the KryptonGroup and click ‘Dock in parent container’

We need the content panel to always fill the entire available area.

![Inner KryptonGroup docked in parent container](Images/Three%20Pane%20Application/ThreePaneA21.png)

### Step 27: Select the ‘kryptonHeaderGroup1’ instance in the properties window

![Properties window with kryptonHeaderGroup1 selected](Images/Three%20Pane%20Application/ThreePane28.png)

### Step 28: Set the ‘ValuesPrimary -\> Image’ property to (none)

We do not want the left pane to have an image in our example.

![ValuesPrimary Image set to none for kryptonHeaderGroup1](Images/Three%20Pane%20Application/ThreePane30.png)

### Step 29: Select the ‘kryptonHeaderGroup2’ instance in the properties window

![Properties window with kryptonHeaderGroup2 selected](Images/Three%20Pane%20Application/ThreePane31.png)

### Step 30: Modify the ‘StateCommon -\> HeaderPrimary -\> Content -\> Image –\> ImageH’ property to be ‘Far’

By default the image appears on the left, we want to reverse this to the
opposite side.

![Header primary content ImageH property set to Far](Images/Three%20Pane%20Application/ThreePane29.png)

### Step 31: Select the ‘kryptonSplitContainer1’ instance in the properties window

![Properties window with kryptonSplitContainer1 selected](Images/Three%20Pane%20Application/ThreePane32.png)

### Step 32: Modify the ‘FixedPanel’ property to be ‘Panel1’

Now resizing the main form will not change the size of left pane.

![kryptonSplitContainer1 FixedPanel set to Panel1](Images/Three%20Pane%20Application/ThreePanel33.png)

### Step 33: Compile and run the application

At runtime you should be able to resize the main form and notice that the left
pane stays a constant width as the right hand panes are modified. The top and
bottom panes on the right hand side will retain the same relative sizing as the
height of the form is changed.

![Running application with three-pane layout and resizable splitters](Images/Three%20Pane%20Application/ThreePaneA22.png)
