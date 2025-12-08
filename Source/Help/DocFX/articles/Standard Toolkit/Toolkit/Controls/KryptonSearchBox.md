# KryptonSearchBox

## Overview

`KryptonSearchBox` is a modern, feature-rich search input control that extends `KryptonTextBox` to provide a comprehensive search experience with built-in suggestions, search history, and customizable display options. It is designed for Windows Forms applications using the Krypton Toolkit.

## Key Features

- **Search and Clear Buttons**: Integrated search and clear buttons with customizable visibility
- **Auto-complete Suggestions**: Real-time suggestions as the user types
- **Rich Suggestions**: Support for `IContentValues` objects with icons, descriptions, and custom formatting
- **Search History**: Optional search history tracking with configurable maximum count
- **Multiple Display Types**: Support for ListBox or DataGridView suggestion displays
- **Custom Filtering**: Extensible filtering system with support for custom filter functions
- **Keyboard Navigation**: Full keyboard support for navigating and selecting suggestions
- **Placeholder Text**: Watermark text support when the control is empty
- **Theme Integration**: Full integration with Krypton palette system

## Class Hierarchy

```
System.Object
  └─ System.MarshalByRefObject
      └─ System.ComponentModel.Component
          └─ System.Windows.Forms.Control
              └─ System.Windows.Forms.TextBoxBase
                  └─ System.Windows.Forms.TextBox
                      └─ Krypton.Toolkit.KryptonTextBox
                          └─ Krypton.Toolkit.KryptonSearchBox
```

## API Reference

### Properties

#### SearchBoxValues

```csharp
public KryptonSearchBoxValues SearchBoxValues { get; }
```

Gets access to the search box configuration values. This property provides access to all configurable aspects of the search box including button visibility, suggestion settings, history settings, and behavior options.

**Category**: Visuals  
**Type**: `KryptonSearchBoxValues`

#### Suggestions

```csharp
public List<string> Suggestions { get; }
```

Gets the collection of suggestion strings. This collection is used to provide auto-complete suggestions when the user types. Suggestions are filtered based on the current text input.

**Category**: Data  
**Type**: `List<string>`

#### SearchHistory

```csharp
public IReadOnlyList<string> SearchHistory { get; }
```

Gets the collection of search history items. This is a read-only collection that contains previously searched terms (when search history is enabled). Items are automatically added when a search is performed.

**Category**: Hidden (Browsable: false)  
**Type**: `IReadOnlyList<string>`

#### CustomFilter

```csharp
public Func<string, IEnumerable<object>, IEnumerable<object>>? CustomFilter { get; set; }
```

**Note**: This property exists but is currently not used by the filtering logic. Use `SearchBoxValues.CustomFilter` instead, which is the property that actually controls custom filtering behavior.

**Category**: Hidden (Browsable: false)  
**Type**: `Func<string, IEnumerable<object>, IEnumerable<object>>?`

#### DataGridViewColumns

```csharp
public List<SearchSuggestionColumnDefinition> DataGridViewColumns { get; }
```

Gets the collection of column definitions for DataGridView suggestion display. This property is only used when `SearchBoxValues.SuggestionDisplayType` is set to `SearchSuggestionDisplayType.DataGridView`.

**Note**: By default, a single column named "Suggestion" is automatically added to this collection during initialization. You can replace it by calling `SetDataGridViewColumns()` or modify the existing collection.

**Category**: Data  
**Type**: `List<SearchSuggestionColumnDefinition>`

#### SearchButton

```csharp
public ButtonSpecAny? SearchButton { get; }
```

Gets access to the search button specification. This allows customization of the search button's appearance, tooltip, and behavior.

**Category**: Hidden (Browsable: false)  
**Type**: `ButtonSpecAny?`

#### ClearButton

```csharp
public ButtonSpecAny? ClearButton { get; }
```

Gets access to the clear button specification. This allows customization of the clear button's appearance, tooltip, and behavior.

**Category**: Hidden (Browsable: false)  
**Type**: `ButtonSpecAny?`

### Methods

#### Clear()

```csharp
public new void Clear()
```

Clears the search text, hides suggestions, and raises the `SearchCleared` event. This method also maintains focus on the control after clearing.

**Overrides**: `KryptonTextBox.Clear()`

#### PerformSearch()

```csharp
public void PerformSearch()
```

Triggers the search event programmatically. If the text is not empty, it will:
- Add the search term to history (if history is enabled)
- Hide the suggestion popup
- Raise the `Search` event with the current text

**Usage**: Call this method when you want to programmatically trigger a search without user interaction.

#### SetSearchSuggestions(IEnumerable<string>)

```csharp
public void SetSearchSuggestions(IEnumerable<string> suggestions)
```

Sets the search suggestions from a collection of strings. This replaces all existing string suggestions.

**Parameters**:
- `suggestions`: The collection of suggestion strings. Cannot be null.

**Exceptions**:
- `ArgumentNullException`: Thrown when `suggestions` is null.

#### AddToSearchHistory(string)

```csharp
public void AddToSearchHistory(string searchText)
```

Adds a search term to the search history. If the term already exists, it is moved to the top. The history is automatically trimmed to the maximum count specified in `SearchBoxValues.SearchHistoryMaxCount`.

**Parameters**:
- `searchText`: The search text to add. If null or whitespace, the method returns without adding.

**Note**: This method respects the `SearchHistoryMaxCount` setting and will remove the oldest items if the limit is exceeded.

#### ClearSearchHistory()

```csharp
public void ClearSearchHistory()
```

Clears all search history items.

#### SetRichSuggestions(IEnumerable<object>)

```csharp
public void SetRichSuggestions(IEnumerable<object> suggestions)
```

Sets rich suggestions that support `IContentValues` (icons, descriptions, etc.). This replaces all existing rich suggestions. Rich suggestions can be:
- Strings (converted to text)
- Objects implementing `IContentValues` (for icons, descriptions, etc.)
- Any object (converted via `ToString()`)

**Parameters**:
- `suggestions`: Collection of suggestion objects. Cannot be null.

**Exceptions**:
- `ArgumentNullException`: Thrown when `suggestions` is null.

#### AddRichSuggestion(object)

```csharp
public void AddRichSuggestion(object suggestion)
```

Adds a single rich suggestion item to the collection.

**Parameters**:
- `suggestion`: The suggestion object (string or `IContentValues`). If null, the method returns without adding.

#### ClearRichSuggestions()

```csharp
public void ClearRichSuggestions()
```

Clears all rich suggestions.

#### SetDataGridViewColumns(IEnumerable<SearchSuggestionColumnDefinition>)

```csharp
public void SetDataGridViewColumns(IEnumerable<SearchSuggestionColumnDefinition> columns)
```

Sets the column definitions for DataGridView suggestion display. This method clears existing columns (including the default "Suggestion" column) and replaces them with the provided definitions. If the suggestion popup already exists, it will be recreated to apply the new columns.

**Parameters**:
- `columns`: The column definitions. Cannot be null.

**Exceptions**:
- `ArgumentNullException`: Thrown when `columns` is null.

### Events

#### Search

```csharp
public event EventHandler<SearchEventArgs>? Search;
```

Occurs when the search is triggered. This event is raised when:
- The user presses Enter (and no suggestion is selected)
- The user clicks the search button
- `PerformSearch()` is called programmatically

**Event Data**: `SearchEventArgs` containing the search text.

**Category**: Action

#### SearchCleared

```csharp
public event EventHandler? SearchCleared;
```

Occurs when the search text is cleared. This event is raised when:
- The user clicks the clear button
- The user presses Escape (if `ClearOnEscape` is enabled and suggestions are not visible)
- `Clear()` is called programmatically

**Event Data**: `EventArgs`

**Category**: Action

#### SuggestionSelected

```csharp
public event EventHandler<SuggestionSelectedEventArgs>? SuggestionSelected;
```

Occurs when a suggestion is selected from the suggestion list. This event is raised when:
- The user clicks on a suggestion
- The user presses Enter while a suggestion is highlighted
- A suggestion is selected programmatically

**Event Data**: `SuggestionSelectedEventArgs` containing the selected suggestion index, text, and object.

**Category**: Action

## KryptonSearchBoxValues Configuration

The `SearchBoxValues` property provides access to all configuration options:

### Button Properties

#### ShowSearchButton

```csharp
public bool ShowSearchButton { get; set; }
```

Gets or sets a value indicating whether the search button is displayed.

**Default**: `true`  
**Category**: Buttons

#### ShowClearButton

```csharp
public bool ShowClearButton { get; set; }
```

Gets or sets a value indicating whether the clear button is displayed when text is entered.

**Default**: `true`  
**Category**: Buttons

### Suggestion Properties

#### EnableSuggestions

```csharp
public bool EnableSuggestions { get; set; }
```

Gets or sets a value indicating whether custom suggestions are enabled.

**Default**: `true`  
**Category**: Suggestions

#### SuggestionMaxCount

```csharp
public int SuggestionMaxCount { get; set; }
```

Gets or sets the maximum number of suggestions to display. The value must be at least 1.

**Default**: `10`  
**Category**: Suggestions  
**Validation**: Minimum value is 1

#### SuggestionDisplayType

```csharp
public SearchSuggestionDisplayType SuggestionDisplayType { get; set; }
```

Gets or sets the type of control used to display suggestions.

**Default**: `SearchSuggestionDisplayType.ListBox`  
**Category**: Suggestions  
**Values**:
- `ListBox`: Display suggestions using a `KryptonListBox`
- `DataGridView`: Display suggestions using a `KryptonDataGridView`

#### MinimumSearchLength

```csharp
public int MinimumSearchLength { get; set; }
```

Gets or sets the minimum number of characters required before showing suggestions. The value must be at least 0.

**Default**: `0`  
**Category**: Suggestions  
**Validation**: Minimum value is 0

### History Properties

#### EnableSearchHistory

```csharp
public bool EnableSearchHistory { get; set; }
```

Gets or sets a value indicating whether search history is enabled. When enabled, search terms are automatically added to the history when `PerformSearch()` is called.

**Default**: `false`  
**Category**: History

#### SearchHistoryMaxCount

```csharp
public int SearchHistoryMaxCount { get; set; }
```

Gets or sets the maximum number of search history items to remember. The value must be at least 1.

**Default**: `10`  
**Category**: History  
**Validation**: Minimum value is 1

### Behavior Properties

#### ClearOnEscape

```csharp
public bool ClearOnEscape { get; set; }
```

Gets or sets a value indicating whether pressing Escape clears the text. If suggestions are visible, Escape will hide them first before clearing (if enabled).

**Default**: `true`  
**Category**: Behavior

#### PlaceholderText

```csharp
public string PlaceholderText { get; set; }
```

Gets or sets the placeholder text (watermark) displayed when the text box is empty.

**Default**: `""` (empty string)  
**Category**: Appearance  
**Localizable**: Yes

#### CustomFilter

```csharp
public Func<string, IEnumerable<object>, IEnumerable<object>>? CustomFilter { get; set; }
```

Gets or sets a custom filter function for suggestions. If set, this function will be used instead of the default filtering logic. **This is the property that actually controls custom filtering** - use this instead of the class-level `CustomFilter` property.

**Parameters**:
- `string`: The search text (already converted to lowercase)
- `IEnumerable<object>`: The collection of all suggestions (strings and rich suggestions combined)

**Returns**: `IEnumerable<object>`: The filtered collection of suggestions

**Category**: Hidden (Browsable: false)

## Event Arguments

### SearchEventArgs

Provides data for the `Search` event.

**Properties**:
- `SearchText` (string): Gets the search text that triggered the search.

**Example**:
```csharp
private void searchBox_Search(object sender, SearchEventArgs e)
{
    string searchTerm = e.SearchText;
    // Perform search operation
}
```

### SuggestionSelectedEventArgs

Provides data for the `SuggestionSelected` event.

**Properties**:
- `Index` (int): Gets the index of the selected suggestion.
- `Suggestion` (string?): Gets the selected suggestion text (for backward compatibility).
- `SuggestionObject` (object?): Gets the selected suggestion object (can be string or `IContentValues`).

**Example**:
```csharp
private void searchBox_SuggestionSelected(object sender, SuggestionSelectedEventArgs e)
{
    if (e.SuggestionObject is IContentValues contentValues)
    {
        // Handle rich suggestion with icon/description
        string text = contentValues.GetShortText();
        Image? icon = contentValues.GetImage(PaletteState.Normal);
    }
    else
    {
        // Handle simple string suggestion
        string text = e.Suggestion ?? string.Empty;
    }
}
```

## SearchSuggestionColumnDefinition

Represents a column definition for DataGridView suggestion display. Used when `SuggestionDisplayType` is set to `DataGridView`.

**Properties**:
- `Name` (string): Gets or sets the column name.
- `DataPropertyName` (string): Gets or sets the data property name (for binding).
- `HeaderText` (string): Gets or sets the header text.
- `Width` (int): Gets or sets the column width (0 = auto-size).
- `AutoSizeMode` (DataGridViewAutoSizeColumnMode): Gets or sets the auto-size mode. Default: `Fill`.
- `ValueExtractor` (Func<object, object?>?): Gets or sets a function to extract the column value from a suggestion object.

**Constructors**:
- `SearchSuggestionColumnDefinition()`: Initializes a new instance with default values.
- `SearchSuggestionColumnDefinition(string name, string headerText, Func<object, object?>? valueExtractor = null)`: Initializes a new instance with specified values.

## Usage Examples

### Basic Usage

```csharp
// Create and configure a basic search box
var searchBox = new KryptonSearchBox
{
    Width = 300,
    Height = 30
};

// Set placeholder text
searchBox.SearchBoxValues.PlaceholderText = "Search...";

// Add suggestions
searchBox.SetSearchSuggestions(new[]
{
    "Apple", "Banana", "Cherry", "Date", "Elderberry"
});

// Handle search event
searchBox.Search += (sender, e) =>
{
    MessageBox.Show($"Searching for: {e.SearchText}");
};

// Add to form
form.Controls.Add(searchBox);
```

### Rich Suggestions with IContentValues

```csharp
// Create a class implementing IContentValues
public class ProductSuggestion : IContentValues
{
    public string Name { get; set; }
    public string Description { get; set; }
    public Image? Icon { get; set; }

    public string GetShortText() => Name;
    public string GetLongText() => Description;
    public Image? GetImage(PaletteState state) => Icon;
    public Color GetImageTransparentColor(PaletteState state) => Color.Empty;
}

// Create suggestions
var suggestions = new List<object>
{
    new ProductSuggestion { Name = "Laptop", Description = "High-performance laptop", Icon = laptopIcon },
    new ProductSuggestion { Name = "Mouse", Description = "Wireless mouse", Icon = mouseIcon },
    new ProductSuggestion { Name = "Keyboard", Description = "Mechanical keyboard", Icon = keyboardIcon }
};

searchBox.SetRichSuggestions(suggestions);
```

### DataGridView Display Type

```csharp
// Configure for DataGridView display
searchBox.SearchBoxValues.SuggestionDisplayType = SearchSuggestionDisplayType.DataGridView;

// Define columns (replaces the default "Suggestion" column)
var columns = new List<SearchSuggestionColumnDefinition>
{
    new SearchSuggestionColumnDefinition("Name", "Product Name", 
        obj => obj is ProductSuggestion p ? p.Name : obj.ToString()),
    new SearchSuggestionColumnDefinition("Description", "Description", 
        obj => obj is ProductSuggestion p ? p.Description : string.Empty)
};

searchBox.SetDataGridViewColumns(columns);
```

### Custom Filtering

```csharp
// Implement custom filter function using SearchBoxValues.CustomFilter
searchBox.SearchBoxValues.CustomFilter = (searchText, suggestions) =>
{
    // Custom filtering logic
    return suggestions
        .Where(s => 
        {
            string text = s is IContentValues cv ? cv.GetShortText() : s.ToString() ?? string.Empty;
            return text.Contains(searchText, StringComparison.OrdinalIgnoreCase);
        })
        .OrderBy(s => 
        {
            string text = s is IContentValues cv ? cv.GetShortText() : s.ToString() ?? string.Empty;
            return text.StartsWith(searchText, StringComparison.OrdinalIgnoreCase) ? 0 : 1;
        });
};
```

### Search History

```csharp
// Enable search history
searchBox.SearchBoxValues.EnableSearchHistory = true;
searchBox.SearchBoxValues.SearchHistoryMaxCount = 20;

// Access history
var history = searchBox.SearchHistory;
foreach (string term in history)
{
    Console.WriteLine($"Previous search: {term}");
}

// Clear history
searchBox.ClearSearchHistory();
```

### Keyboard Navigation

The control supports full keyboard navigation:

- **Enter**: Performs search (if no suggestion is highlighted) or selects the highlighted suggestion
- **Escape**: Hides suggestions (if visible) or clears text (if `ClearOnEscape` is enabled)
- **Up Arrow**: Navigates to previous suggestion
- **Down Arrow**: Navigates to next suggestion

### Customizing Buttons

```csharp
// Access button specifications
var searchButton = searchBox.SearchButton;
if (searchButton != null)
{
    // Customize search button
    searchButton.Image = customSearchIcon;
    searchButton.ToolTipTitle = "Perform Search";
    searchButton.ToolTipBody = "Click to search for the entered text";
}

var clearButton = searchBox.ClearButton;
if (clearButton != null)
{
    // Customize clear button
    clearButton.Image = customClearIcon;
}
```

## Filtering Behavior

### Default Filtering

By default, the control filters suggestions using case-insensitive substring matching:

1. **String Suggestions**: Filters using `IndexOf` (case-insensitive) on the suggestion text
2. **Rich Suggestions**: Filters using `GetShortText()` and `GetLongText()` from `IContentValues` (searches both short and long text)
3. **Search History**: Included when no other suggestions match and history is enabled

The filtering combines string suggestions and rich suggestions, with string suggestions taking priority up to `SuggestionMaxCount`, then rich suggestions filling the remaining slots.

### Custom Filtering

When `SearchBoxValues.CustomFilter` is set, the default filtering logic is bypassed. The custom function receives:
- The search text (already converted to lowercase)
- All suggestions (strings and rich suggestions combined)

The function should return a filtered and optionally sorted collection. The control will then apply `SuggestionMaxCount` to limit the results.

**Important**: Use `SearchBoxValues.CustomFilter`, not the class-level `CustomFilter` property, as only the former is actually used by the filtering logic.

## Suggestion Display

### ListBox Display

When `SuggestionDisplayType` is `ListBox`:
- Suggestions are displayed in a `KryptonListBox`
- Supports `IContentValues` for rich display (icons, descriptions)
- Maximum 8 items visible at once (with scrolling)
- Single-click or double-click to select

### DataGridView Display

When `SuggestionDisplayType` is `DataGridView`:
- Suggestions are displayed in a `KryptonDataGridView`
- Requires column definitions via `DataGridViewColumns` (a default "Suggestion" column is automatically added)
- Supports multi-column display
- Column headers shown only when multiple columns are defined
- Single-click or double-click to select
- Maximum 8 rows visible at once (with scrolling)

## Best Practices

1. **Performance**: For large suggestion lists, use `MinimumSearchLength` to delay filtering until the user has typed a few characters.

2. **Memory**: Clear suggestions when they're no longer needed, especially for dynamic data sources.

3. **User Experience**: 
   - Set appropriate `SuggestionMaxCount` to avoid overwhelming users
   - Use placeholder text to guide users
   - Enable search history for frequently used applications

4. **Rich Suggestions**: Use `IContentValues` for suggestions that benefit from icons or descriptions, but keep the implementation lightweight.

5. **Custom Filtering**: Implement custom filters for complex matching logic (fuzzy matching, weighted results, etc.), but ensure the function is performant. Remember to use `SearchBoxValues.CustomFilter`, not the class-level property.

6. **Threading**: All operations should be performed on the UI thread. If loading suggestions from a background operation, use `Invoke` or `BeginInvoke`.

7. **DataGridView Columns**: When using DataGridView display, you can either modify the default column or replace all columns using `SetDataGridViewColumns()`. Column definitions should be set before suggestions are shown for best results.

## Integration with Krypton Themes

The `KryptonSearchBox` fully integrates with the Krypton palette system:

- Inherits theme from parent control or form
- Suggestion popup inherits theme from the search box
- Buttons respect theme colors and styles
- Supports all Krypton palette modes

## Limitations and Considerations

1. **Focus Management**: The suggestion popup is designed not to steal focus from the search box. This ensures smooth keyboard navigation.

2. **Screen Boundaries**: The popup positions itself below the search box. If there's insufficient space, it may appear off-screen (this could be enhanced in future versions).

3. **DataGridView Columns**: When using DataGridView display, a default "Suggestion" column is automatically created. You can replace it by calling `SetDataGridViewColumns()` or modify the existing collection. Changing columns after the popup is created requires the popup to be recreated.

4. **Thread Safety**: The control is not thread-safe. All operations must be performed on the UI thread.

5. **CustomFilter Property**: The class-level `CustomFilter` property exists but is not currently used. Always use `SearchBoxValues.CustomFilter` for custom filtering functionality.

## Related Types

- `KryptonTextBox`: Base class providing text input functionality
- `KryptonSearchBoxValues`: Configuration values container
- `SearchEventArgs`: Event arguments for Search event
- `SuggestionSelectedEventArgs`: Event arguments for SuggestionSelected event
- `SearchSuggestionColumnDefinition`: Column definition for DataGridView display
- `SearchSuggestionDisplayType`: Enumeration for display type selection
- `IContentValues`: Interface for rich suggestion content
- `ButtonSpecAny`: Button specification for search and clear buttons