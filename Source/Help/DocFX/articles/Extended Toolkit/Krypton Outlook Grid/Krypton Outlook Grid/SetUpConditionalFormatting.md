# KryptonOutlookGrid - Set Up Conditional Formatting

## Conditional Formatting


There are three conditional formatting types :

* Bar : displays value as a bar (solid or gradient filling)
* 2-color scale : displays cells with background color varying between two colors.
* 3-color scale : displays cells with background color varying between three colors.

Conditional formatting by is done by adding:

```cs
ConditionalFormatting cond = new ConditionalFormatting(); 
cond.ColumnName = SandBoxGridColumn.ColumnPrice.ToString();
cond.FormatType = EnumConditionalFormatType.TwoColorsRange; 
cond.FormatParams = new TwoColorsParams(Color.White, Color.FromArgb(255, 255, 58, 61)); 
Grid.ConditionalFormatting.Add(cond);
```

The only requirement is that the column must be a *KryptonDataGridViewFormattingColumn*.

Conditional formatting comes with an integrated context menu in the grid. It contains predefined formatting and in case of not finding the exact look you want you can customize it by setting a custom rule.