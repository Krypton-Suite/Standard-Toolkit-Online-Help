# KryptonOutlookGrid - Save & Restore User's Grid Configuration

## Save a user's grid configuration

This will produce a XML file with the necessary information to restore the grid.

```cs
private void Save()
{
    OutlookGrid1.PersistConfiguration(Application.StartupPath + "/grid.xml", StaticInfos._GRIDCONFIG_VERSION.ToString());
}
```

## Restore a user's grid configuration at loading

At loading you can choose trying to restore a configuration file of the grid you've previously saved or you can launch the default configuration.

```cs
public void SetupDataGridView(KryptonOutlookGrid Grid, bool restoreIfPossible)
{
    if (File.Exists(Application.StartupPath + "/grid.xml") & restoreIfPossible)
    {
        try
        {
            LoadConfigFromFile(Application.StartupPath + "/grid.xml", Grid);
        }
        catch (Exception ex)
        {
            KryptonMessageBox.Show("Error when retrieving configuration : " + ex.Message, "Error", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Error);
            Grid.ClearEverything();
            LoadDefaultConfiguration(Grid);
        }
    }
    else
    {
        LoadDefaultConfiguration(Grid);
    }
}
```

This is a sort of deserialization. As some actions such as creating columns (many options can be defined here) are specific to each application, the grid deserialization is located out of the main *OutlookGrid* code.

```cs
private void LoadConfigFromFile(string file, KryptonOutlookGrid Grid)
 {
     if (string.IsNullOrEmpty(file))
     {
        throw new Exception("Grid config file is missing !");
     }

     XDocument doc = XDocument.Load(file);
     int versionGrid = -1;
     int.TryParse(doc.Element("OutlookGrid").Attribute("V").Value, out versionGrid);

     //Upgrade if necessary the config file
     CheckAndUpgradeConfigFile(versionGrid, doc, Grid, LoadState.After);
     Grid.ClearEverything();
     Grid.GroupBox.Visible = CommonHelper.StringToBool(doc.XPathSelectElement("OutlookGrid/GroupBox").Value);
     Grid.HideColumnOnGrouping = CommonHelper.StringToBool(doc.XPathSelectElement("OutlookGrid/HideColumnOnGrouping").Value);

     //Initialize
     int NbColsInFile = doc.XPathSelectElements("//Column").Count();
     DataGridViewColumn[] columnsToAdd = new DataGridViewColumn[NbColsInFile];
     SandBoxGridColumn[] enumCols = new SandBoxGridColumn[NbColsInFile];
     OutlookGridColumn[] OutlookColumnsToAdd = new OutlookGridColumn[columnsToAdd.Length];
     SortedList<int, int> hash = new SortedList<int, int>();// (DisplayIndex , Index)


     int i = 0;
     IOutlookGridGroup group;
     XElement node2;

     foreach (XElement node in doc.XPathSelectElement("OutlookGrid/Columns").Nodes())
     {
         //Create the columns and restore the saved properties
         //As the OutlookGrid receives constructed DataGridViewColumns, only the parent application can recreate them (dgvcolumn not serializable)
         enumCols[i] = (SandBoxGridColumn)Enum.Parse(typeof(SandBoxGridColumn), node.Element("Name").Value);
         columnsToAdd[i] = SetupColumn(enumCols[i]);
         columnsToAdd[i].Width = int.Parse(node.Element("Width").Value);
         columnsToAdd[i].Visible = CommonHelper.StringToBool(node.Element("Visible").Value);
         hash.Add(int.Parse(node.Element("DisplayIndex").Value), i);
         //Reinit the group if it has been set previously
         group = null;
         if (!node.Element("GroupingType").IsEmpty && node.Element("GroupingType").HasElements)
         {
             node2 = node.Element("GroupingType");
             group = (IOutlookGridGroup)Activator.CreateInstance(Type.GetType(TypeConverter.ProcessType(node2.Element("Name").Value), true));
             group.OneItemText = node2.Element("OneItemText").Value;
             group.XXXItemsText = node2.Element("XXXItemsText").Value;
             group.SortBySummaryCount = CommonHelper.StringToBool(node2.Element("SortBySummaryCount").Value);
             if (!string.IsNullOrEmpty((node2.Element("ItemsComparer").Value)))
             {
                 Object comparer = Activator.CreateInstance(Type.GetType(TypeConverter.ProcessType(node2.Element("ItemsComparer").Value), true));
                 group.ItemsComparer = (IComparer)comparer;
             }
             if (node2.Element("Name").Value.Contains("OutlookGridDateTimeGroup"))
             {
                 ((OutlookGridDateTimeGroup)group).Interval = (OutlookGridDateTimeGroup.DateInterval)Enum.Parse(typeof(OutlookGridDateTimeGroup.DateInterval), node2.Element("GroupDateInterval").Value);
             }
         }
         OutlookColumnsToAdd[i] = new OutlookGridColumn(columnsToAdd[i], group, (SortOrder)Enum.Parse(typeof(SortOrder), node.Element("SortDirection").Value), int.Parse(node.Element("GroupIndex").Value), int.Parse(node.Element("SortIndex").Value));

         i += 1;
     }
     //First add the underlying DataGridViewColumns to the grid
     Grid.Columns.AddRange(columnsToAdd);
     //And then the outlookgrid columns
     Grid.AddRangeInternalColumns(OutlookColumnsToAdd);

     //Add conditionnal formatting to the grid
     EnumConditionalFormatType conditionFormatType = default(EnumConditionalFormatType);
     IFormatParams conditionFormatParams = default(IFormatParams);
     foreach (XElement node in doc.XPathSelectElement("OutlookGrid/ConditionalFormatting").Nodes())
     {
         conditionFormatType = (EnumConditionalFormatType)Enum.Parse(typeof(EnumConditionalFormatType), node.Element("FormatType").Value);
         XElement nodeParams = node.Element("FormatParams");
         switch (conditionFormatType)
         {
             case EnumConditionalFormatType.Bar:
                 conditionFormatParams = new BarParams(Color.FromArgb(int.Parse(nodeParams.Element("BarColor").Value)), CommonHelper.StringToBool(nodeParams.Element("GradientFill").Value));
                 break;
             case EnumConditionalFormatType.ThreeColorsRange:
                 conditionFormatParams = new ThreeColorsParams(Color.FromArgb(int.Parse(nodeParams.Element("MinimumColor").Value)), Color.FromArgb(int.Parse(nodeParams.Element("MediumColor").Value)), Color.FromArgb(int.Parse(nodeParams.Element("MaximumColor").Value)));
                 break;
             case EnumConditionalFormatType.TwoColorsRange:
                 conditionFormatParams = new TwoColorsParams(Color.FromArgb(int.Parse(nodeParams.Element("MinimumColor").Value)), Color.FromArgb(int.Parse(nodeParams.Element("MaximumColor").Value)));
                 break;
             default:
                 conditionFormatParams = null;
                 //will never happened but who knows ? throw exception ?
                 break;
         }
         Grid.ConditionalFormatting.Add(new ConditionalFormatting(node.Element("ColumnName").Value, conditionFormatType, conditionFormatParams));
     }

     //We need to loop through the columns in the order of the display order, starting at zero; otherwise the columns will fall out of order as the loop progresses.
     foreach (KeyValuePair<int, int> kvp in hash)
     {
         columnsToAdd[kvp.Value].DisplayIndex = kvp.Key;
     }

     activeColumns = enumCols;
 }
```

In the life of your application you may want to do some changes to the default configuration grid such as adding a new column. This is why you have a *CheckAndUpgradeConfigFile* function.

```cs
private void CheckAndUpgradeConfigFile(int versionGrid, XDocument doc, KryptonOutlookGrid grid, LoadState state)
{
    while (versionGrid < StaticInfos._GRIDCONFIG_VERSION)
    {
        UpgradeGridConfigToVX(doc, versionGrid + 1, grid, state);
        versionGrid += 1;
    }
}

private void UpgradeGridConfigToVX(XDocument doc, int version, KryptonOutlookGrid Grid, LoadState state)
{
    // Do changes according to version
    // For example you can add automatically new columns. This can be useful when you update your application to add columns and would like to display them to the user for the first time.
    switch (version)
    {
        //case 2:
        //    // Do changes to match the V2
        //    if (state == DataGridViewSetup.LoadState.Before)
        //    {
        //        doc.Element("OutlookGrid").Attribute("V").Value = version.ToString();
        //        Array.Resize(ref activeColumns, activeColumns.Length + 1);
        //        DataGridViewColumn columnToAdd = SetupColumn(SandBoxGridColumn.ColumnPrice2);
        //        Grid.Columns.Add(columnToAdd);
        //        Grid.AddInternalColumn(columnToAdd, new OutlookGridDefaultGroup(null)
        //        {
        //            OneItemText = "Example",
        //            XXXItemsText = "Examples"
        //        }, SortOrder.None, -1, -1);
        //        activeColumns[activeColumns.Length - 1] = SandBoxGridColumn.ColumnPrice2;
        //        Grid.PersistConfiguration(PublicFcts.GetGridConfigFile, version);
        //    }
        //    break;
    }
}
```

In case of a breaking modification of an *IOutlookGridGroup* object (from the base *Krypton OutlookGrid* or from your own) you can write changes for allowing correct reflection.

```cs
public class TypeConverter
{
    public static string ProcessType(string fullQualifiedName)
    {
        // Translate types here to accommodate code changes, namespaces and version
        //  switch(fullQualifiedName)
        //  {
        //    case "KryptonOutlookGrid.SandBox.OutlookGridPriceGroup, KryptonOutlookGrid.SandBox, Version=1.6.0.0, Culture=neutral, PublicKeyToken=null" :
        //        Change with new version or namespace or both !
        //        FullQualifiedName = "TestMe, Version=1.2.0.0, Culture=neutral, PublicKeyToken=null"
        //        break;
        //  }
        return FullQualifiedName;
    }
}
```