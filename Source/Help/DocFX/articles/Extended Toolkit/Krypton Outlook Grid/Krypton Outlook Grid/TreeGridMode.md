# KryptonOutlookGrid - TreeGridMode

## Tree-grid mode

*Figure 1 - An example of an expanded node*

As treegrid mode requires algorithm with recursive parts, the code is a bit slower. You may want maximum performance if you do not need a tree mode and that's why there is a *FillMode* property which is set to *GroupsOnly* by default. To active the tree mode you need to set it to *GroupsAndNodes*. Even with tree mode enabled there is no need to have sublevels rows, allowing flexibility for your application.

The tree mode is symbolized by the the +/- symbol located on cells in one column of the grid. This must column must be a *KryptonDataGridViewTreeTextColumn*.

You can also choose to display or not lines between nodes *OutlookGrid1.ShowLines = true;*

To fill the grid with sublevels there are extra steps :

```cs
OutlookGridRow row2 = new OutlookGridRow(); 
row2.CreateCells(OutlookGrid1, new object[] { ... }
```

Then add the newly created row to its parent one by using :

```cs
row.Nodes.Add(row2); ((KryptonDataGridViewTreeTextCell)row2.Cells[1]).UpdateStyle(); //Important : after adding to the parent node, do the same for the parent row
listOfRows.Add(row); ((KryptonDataGridViewTreeTextCell)row.Cells[1]).UpdateStyle(); //Important : after adding to the rows list. Those steps are here to get a proper indentation (padding) of the text in the TreeTextCells
```