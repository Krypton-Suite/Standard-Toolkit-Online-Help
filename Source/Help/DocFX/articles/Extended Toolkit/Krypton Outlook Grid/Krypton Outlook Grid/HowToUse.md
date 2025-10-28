# KryptonOutlookGrid - How to Use

**1. Drag and drop the KryptonOutlookGrid and KryptonOutlookGridGroupBox on the Form.**

**2. Associate the KryptonOutlookGridGroupBox with the grid by design time or by code using the following:**

```cs
OutlookGrid1.GroupBox = KryptonOutlookGridGroupBox1;
```

**3. We need that the OutlookGrid listens to the GroupBox actions/events.**

```cs
OutlookGrid1.RegisterGroupBoxEvents();
```

Also set to *true* the property *AllowDrop* for the *OutlookGrid*.

**4. Design your grid by configuring your columns as you would do with the standard datagridview in unbound mode. You can do it by code or by design time.**
 
 *Warning you must respect these two rules:*

The column *SortMode* property must be set to "Programmatic" as the grid will handle itself the sorting.
The column Name property must not be empty (whereas the *HeaderText* could be).

```cs
DataGridViewColumn[] columnsToAdd = new DataGridViewColumn[10];
columnsToAdd[0] = SetupColumn(SandBoxGridColumn.ColumnCustomerID);
columnsToAdd[1] = SetupColumn(SandBoxGridColumn.ColumnCustomerName);
columnsToAdd[2] = SetupColumn(SandBoxGridColumn.ColumnAddress);
...
Grid.Columns.AddRange(columnsToAdd);
```

**5. Configure the OutlookGrid. For grouping and sorting abilities we need to precise the columns to the grid.**

```cs
Grid.AddInternalColumn(columnsToAdd[0], new OutlookGridDefaultGroup(null), SortOrder.None, -1, -1);
Grid.AddInternalColumn(columnsToAdd[1], new OutlookGridAlphabeticGroup(null), SortOrder.None, -1, -1);
Grid.AddInternalColumn(columnsToAdd[2], new OutlookGridDefaultGroup(null), SortOrder.None, -1, -1);
...
```

The different parameters for the AddInternalColumn procedure are:
* Parameter 1 : the *DataGridView* column
* Parameter 2 : the *IOutlookGridGroup* that will be used when the column will be grouped
* Parameter 3 : the sort direction
* Parameter 4 : the column position among grouped columns, -1 if not grouped.
* Parameter 5 : the column position among sorted columns, -1 if not sorted.
 
 *Please note that a grouped column will automatically be sorted.*

You can customize the default group with some properties :

* Single (*OneItemText*) and multiple items (*XXXItemsText*) : this allows you to change the word "item" by the current object you are displaying in the grid and manage the specificities of each country regarding the plural.
* SortBySummaryCount : This indicates if the groups should be sorted by the number of elements in each group rather the group element value
* ItemsComparer : for complex objects you can set your own comparer. It will be used during sort operations.
* Interval : only for the *OutlookGridDateTimeGroup*, you can specify type of grouping you want to use : day, month, quarter, year and intelligent (such as Outlook)

**6. Fill the grid with data (unbound mode only).**

```cs
//Setup Rows
OutlookGridRow row = new OutlookGridRow();
List l = new List();
OutlookGrid1.SuspendLayout();
OutlookGrid1.ClearInternalRows();
foreach (item in items)
{
     try
     {
           row = new OutlookGridRow();
           row.CreateCells(OutlookGrid1, new object[] {
                    item.Prop1,
                    item.Prop2,
                   ....
      });
      l.Add(row);
}
OutlookGrid1.ResumeLayout();
OutlookGrid1.AssignRows(l);
OutlookGrid1.ForceRefreshGroupBox();
OutlookGrid1.Fill();
```