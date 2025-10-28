# KryptonOutlookGrid - Additional Columns

## KryptonDataGridViewFormattingColumn
This column enables the use of conditional formatting. Only one condition is allowed per column. Three types of formatting are available :

* Bar : displays value as a bar (solid or gradient filling)
* 2-color scale : displays cells with background color varying between two colors.
* 3-color scale : displays cells with background color varying between three colors.

*Figure 1 - An example of the KryptonDataGridViewFormattingColumn.*

Please see [here](SetUpConditionalFormatting.md) for more information.

## KryptonDataGridViewPercentageColumn

This column displays the percentage value with a bar. The color depends on the *Krypton* palette. If you want to make customizations, please take a look (for now) to the conditional formatting or hack the code ;).

*Figure 2 - An example of the KryptonDataGridViewPercentageColumn.*

## KryptonDataGridViewRatingColumn
This column displays rating cells in the *DataGridView*.

*Figure 3 - An example of the KryptonDataGridViewRatingColumn.*

## KryptonDataGridViewTextAndImageColumn
This type column does not exist in the standard *DataGridView*. It is here to fill that gap.

To use it you must add an *TextAndImage* object to the cell value :

```cs
public TextAndImage(string text, Image img)
```

*Figure 4 - An example of the KryptonDataGridViewTextAndImageColumn.*

## KryptonDataGridViewTokenColumn

This column allows to display data in a "token" format :

```cs
/// <summary>
/// Constructor
/// </summary>
/// <param name="text">Text of the token</param>
/// <param name="text">Text of the token</param>
/// <param name="bg">Background color</param>
/// <param name="fg">Foreground text color</param>
public Token(string text, Color bg, Color fg)
```

*Figure 5 - An example of the KryptonDataGridViewTokenColumn.*

There is a derived column called *KryptonDataGridViewTokenListColumn* which allows to have a list of *Tokens* displayed in the cell.

## KryptonDataGridViewTreeTextColumn

This column is the key to use the tree grid mode functionality. Please see here for more information.

*Figure 6 - An example of the KryptonDataGridViewTreeTextColumn.*