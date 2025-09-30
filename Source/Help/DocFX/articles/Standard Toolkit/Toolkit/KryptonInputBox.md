# KryptonInputBox

## Overview

The `KryptonInputBox` class provides a static utility for displaying input dialogs with Krypton theming. It offers a centralized way to show input dialogs with customizable data and layout options, enabling users to enter text input through a themed dialog interface.

## Class Hierarchy

```
System.Object
└── Krypton.Toolkit.KryptonInputBox
```

## Key Methods

### Show Method

```csharp
public static string Show(KryptonInputBoxData inputBoxData)
```

- **Purpose**: Displays an input box dialog with the specified data and returns the user's input
- **Parameters**:
  - `inputBoxData`: Configuration data for the input box dialog
- **Returns**: String containing the user's input, or empty string if cancelled
- **Usage**: Main entry point for showing input dialogs

### InternalShow Method

```csharp
internal static string InternalShow(KryptonInputBoxData inputBoxData)
```

- **Purpose**: Internal implementation that routes to the appropriate form based on RTL layout
- **Parameters**:
  - `inputBoxData`: Configuration data for the input box dialog
- **Returns**: String containing the user's input
- **Implementation**: Automatically selects between `VisualInputBoxForm` and `VisualInputBoxRtlAwareForm` based on RTL layout setting

## Advanced Usage Patterns

### Basic Input Box

```csharp
public void ShowBasicInputBox()
{
    var inputData = new KryptonInputBoxData
    {
        Prompt = "Enter your name:",
        Caption = "User Input",
        DefaultResponse = "John Doe"
    };

    string result = KryptonInputBox.Show(inputData);
    
    if (!string.IsNullOrEmpty(result))
    {
        MessageBox.Show($"Hello, {result}!", "Greeting");
    }
}
```

### Advanced Input Box with Validation

```csharp
public class InputValidator
{
    public string GetValidatedInput(string prompt, string caption, string defaultValue = "")
    {
        string input;
        bool isValid = false;

        do
        {
            var inputData = new KryptonInputBoxData
            {
                Prompt = prompt,
                Caption = caption,
                DefaultResponse = defaultValue
            };

            input = KryptonInputBox.Show(inputData);

            if (string.IsNullOrEmpty(input))
            {
                return string.Empty; // User cancelled
            }

            isValid = ValidateInput(input);
            if (!isValid)
            {
                MessageBox.Show("Invalid input. Please try again.", "Validation Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        } while (!isValid);

        return input;
    }

    private bool ValidateInput(string input)
    {
        // Add your validation logic here
        return !string.IsNullOrWhiteSpace(input) && input.Length >= 3;
    }
}
```

### Multi-Step Input Collection

```csharp
public class MultiStepInputCollector
{
    public Dictionary<string, string> CollectUserInformation()
    {
        var userInfo = new Dictionary<string, string>();

        // Collect name
        var nameData = new KryptonInputBoxData
        {
            Prompt = "Please enter your full name:",
            Caption = "User Information - Step 1 of 3",
            DefaultResponse = ""
        };
        string name = KryptonInputBox.Show(nameData);
        if (string.IsNullOrEmpty(name)) return userInfo;
        userInfo["Name"] = name;

        // Collect email
        var emailData = new KryptonInputBoxData
        {
            Prompt = "Please enter your email address:",
            Caption = "User Information - Step 2 of 3",
            DefaultResponse = ""
        };
        string email = KryptonInputBox.Show(emailData);
        if (string.IsNullOrEmpty(email)) return userInfo;
        userInfo["Email"] = email;

        // Collect phone
        var phoneData = new KryptonInputBoxData
        {
            Prompt = "Please enter your phone number:",
            Caption = "User Information - Step 3 of 3",
            DefaultResponse = ""
        };
        string phone = KryptonInputBox.Show(phoneData);
        if (string.IsNullOrEmpty(phone)) return userInfo;
        userInfo["Phone"] = phone;

        return userInfo;
    }
}
```

### Configuration Input Dialog

```csharp
public class ConfigurationManager
{
    public void ShowConfigurationInput()
    {
        // Server configuration
        var serverData = new KryptonInputBoxData
        {
            Prompt = "Enter server address:",
            Caption = "Server Configuration",
            DefaultResponse = "localhost"
        };
        string serverAddress = KryptonInputBox.Show(serverData);

        if (!string.IsNullOrEmpty(serverAddress))
        {
            // Port configuration
            var portData = new KryptonInputBoxData
            {
                Prompt = "Enter port number:",
                Caption = "Server Configuration",
                DefaultResponse = "8080"
            };
            string portString = KryptonInputBox.Show(portData);

            if (!string.IsNullOrEmpty(portString) && int.TryParse(portString, out int port))
            {
                SaveConfiguration(serverAddress, port);
            }
        }
    }

    private void SaveConfiguration(string server, int port)
    {
        // Save configuration logic
        Console.WriteLine($"Server: {server}, Port: {port}");
    }
}
```

### RTL Layout Support

```csharp
public class LocalizedInputManager
{
    public void ShowLocalizedInput()
    {
        var inputData = new KryptonInputBoxData
        {
            Prompt = GetLocalizedString("InputPrompt"),
            Caption = GetLocalizedString("InputCaption"),
            DefaultResponse = GetLocalizedString("DefaultInput"),
            UseRTLLayout = IsRightToLeftLanguage() ? KryptonUseRTLLayout.Yes : KryptonUseRTLLayout.No
        };

        string result = KryptonInputBox.Show(inputData);
        ProcessInput(result);
    }

    private string GetLocalizedString(string key)
    {
        // Implementation to get localized strings
        return key; // Placeholder
    }

    private bool IsRightToLeftLanguage()
    {
        var culture = CultureInfo.CurrentUICulture;
        return culture.TextInfo.IsRightToLeft;
    }

    private void ProcessInput(string input)
    {
        if (!string.IsNullOrEmpty(input))
        {
            // Process the input
            Console.WriteLine($"User input: {input}");
        }
    }
}
```

## Integration Patterns

### Settings Dialog Integration

```csharp
public class SettingsDialog : Form
{
    private KryptonButton configureButton;

    public SettingsDialog()
    {
        InitializeComponent();
        SetupConfigureButton();
    }

    private void SetupConfigureButton()
    {
        configureButton = new KryptonButton
        {
            Text = "Configure Settings",
            Dock = DockStyle.Fill
        };

        configureButton.Click += ConfigureButton_Click;
    }

    private void ConfigureButton_Click(object? sender, EventArgs e)
    {
        ShowConfigurationInput();
    }

    private void ShowConfigurationInput()
    {
        var inputData = new KryptonInputBoxData
        {
            Prompt = "Enter configuration value:",
            Caption = "Settings Configuration",
            DefaultResponse = GetCurrentSetting()
        };

        string newValue = KryptonInputBox.Show(inputData);
        if (!string.IsNullOrEmpty(newValue))
        {
            SaveSetting(newValue);
        }
    }

    private string GetCurrentSetting()
    {
        // Implementation to get current setting
        return "Current Value";
    }

    private void SaveSetting(string value)
    {
        // Implementation to save setting
        Console.WriteLine($"Setting saved: {value}");
    }
}
```

### User Registration Flow

```csharp
public class UserRegistration
{
    public bool RegisterNewUser()
    {
        // Username input
        var usernameData = new KryptonInputBoxData
        {
            Prompt = "Enter your desired username:",
            Caption = "User Registration",
            DefaultResponse = ""
        };
        string username = KryptonInputBox.Show(usernameData);
        if (string.IsNullOrEmpty(username)) return false;

        // Email input
        var emailData = new KryptonInputBoxData
        {
            Prompt = "Enter your email address:",
            Caption = "User Registration",
            DefaultResponse = ""
        };
        string email = KryptonInputBox.Show(emailData);
        if (string.IsNullOrEmpty(email)) return false;

        // Display confirmation
        string confirmation = $"Username: {username}\nEmail: {email}\n\nIs this information correct?";
        var result = MessageBox.Show(confirmation, "Confirm Registration", 
            MessageBoxButtons.YesNo, MessageBoxIcon.Question);

        if (result == DialogResult.Yes)
        {
            return CreateUserAccount(username, email);
        }

        return false;
    }

    private bool CreateUserAccount(string username, string email)
    {
        // Implementation to create user account
        Console.WriteLine($"Creating account for {username} ({email})");
        return true;
    }
}
```

### Dynamic Configuration Input

```csharp
public class DynamicConfigurator
{
    public void ConfigureApplication()
    {
        var configItems = new[]
        {
            new ConfigItem("Database Connection String", "Server=localhost;Database=MyApp;"),
            new ConfigItem("API Endpoint", "https://api.example.com/"),
            new ConfigItem("Log Level", "Information"),
            new ConfigItem("Cache Timeout", "300")
        };

        foreach (var item in configItems)
        {
            ConfigureItem(item);
        }
    }

    private void ConfigureItem(ConfigItem item)
    {
        var inputData = new KryptonInputBoxData
        {
            Prompt = $"Enter {item.Name}:",
            Caption = "Application Configuration",
            DefaultResponse = item.DefaultValue
        };

        string newValue = KryptonInputBox.Show(inputData);
        if (!string.IsNullOrEmpty(newValue))
        {
            item.Value = newValue;
            SaveConfigurationItem(item);
        }
    }

    private void SaveConfigurationItem(ConfigItem item)
    {
        // Implementation to save configuration item
        Console.WriteLine($"{item.Name}: {item.Value}");
    }
}

public class ConfigItem
{
    public string Name { get; set; }
    public string DefaultValue { get; set; }
    public string Value { get; set; }

    public ConfigItem(string name, string defaultValue)
    {
        Name = name;
        DefaultValue = defaultValue;
        Value = defaultValue;
    }
}
```

## Performance Considerations

- **Static Methods**: Efficient static method calls without instance creation
- **Memory Management**: Minimal memory footprint for utility class
- **Dialog Lifecycle**: Proper dialog creation and disposal
- **RTL Support**: Automatic RTL layout detection and form selection

## Common Issues and Solutions

### Input Box Not Showing

**Issue**: Input box dialog not appearing  
**Solution**: Ensure proper input data configuration:

```csharp
var inputData = new KryptonInputBoxData
{
    Prompt = "Enter your input:",
    Caption = "Input Required",
    DefaultResponse = ""
    // Ensure all required properties are set
};

string result = KryptonInputBox.Show(inputData);
```

### RTL Layout Issues

**Issue**: Right-to-left layout not working correctly  
**Solution**: Properly configure RTL layout:

```csharp
var inputData = new KryptonInputBoxData
{
    Prompt = "Enter your input:",
    Caption = "Input Required",
    DefaultResponse = "",
    UseRTLLayout = CultureInfo.CurrentUICulture.TextInfo.IsRightToLeft 
        ? KryptonUseRTLLayout.Yes 
        : KryptonUseRTLLayout.No
};

string result = KryptonInputBox.Show(inputData);
```

### Input Validation

**Issue**: No built-in input validation  
**Solution**: Implement custom validation:

```csharp
public string GetValidatedInput(string prompt, string caption, Func<string, bool> validator)
{
    string input;
    do
    {
        var inputData = new KryptonInputBoxData
        {
            Prompt = prompt,
            Caption = caption,
            DefaultResponse = ""
        };

        input = KryptonInputBox.Show(inputData);
        
        if (string.IsNullOrEmpty(input))
        {
            return string.Empty; // User cancelled
        }

        if (!validator(input))
        {
            MessageBox.Show("Invalid input. Please try again.", "Validation Error");
        }
    } while (!validator(input));

    return input;
}
```

## Design-Time Integration

### Visual Studio Designer

- **Static Class**: Not available in toolbox (static utility class)
- **Method Access**: Accessible through code only
- **Configuration**: Input data configuration through code

### Usage Patterns

- **User Input**: Simple text input collection
- **Configuration**: Application settings input
- **Registration**: User registration flows
- **Localization**: Multi-language input dialogs

## Migration and Compatibility

### From Standard InputBox

```csharp
// Old way (if using custom input box)
// string result = CustomInputBox.Show("Enter your name:", "Input", "Default");

// New way
var inputData = new KryptonInputBoxData
{
    Prompt = "Enter your name:",
    Caption = "Input",
    DefaultResponse = "Default"
};
string result = KryptonInputBox.Show(inputData);
```

### From MessageBox Input

```csharp
// Old way (if using MessageBox for input)
// string result = Microsoft.VisualBasic.Interaction.InputBox("Prompt", "Title", "Default");

// New way
var inputData = new KryptonInputBoxData
{
    Prompt = "Prompt",
    Caption = "Title",
    DefaultResponse = "Default"
};
string result = KryptonInputBox.Show(inputData);
```

## Real-World Integration Examples

### Application Settings Manager

```csharp
public class ApplicationSettingsManager
{
    public void ShowSettingsConfiguration()
    {
        var settings = new Dictionary<string, string>
        {
            ["DatabaseServer"] = "localhost",
            ["DatabasePort"] = "1433",
            ["DatabaseName"] = "MyApplication",
            ["ApiEndpoint"] = "https://api.myapp.com",
            ["LogLevel"] = "Information"
        };

        foreach (var setting in settings)
        {
            ConfigureSetting(setting.Key, setting.Value);
        }
    }

    private void ConfigureSetting(string key, string currentValue)
    {
        var inputData = new KryptonInputBoxData
        {
            Prompt = $"Enter {key}:",
            Caption = "Application Settings",
            DefaultResponse = currentValue
        };

        string newValue = KryptonInputBox.Show(inputData);
        if (!string.IsNullOrEmpty(newValue) && newValue != currentValue)
        {
            SaveSetting(key, newValue);
        }
    }

    private void SaveSetting(string key, string value)
    {
        // Implementation to save setting
        Console.WriteLine($"Setting {key} updated to: {value}");
    }
}
```

### User Profile Setup

```csharp
public class UserProfileSetup
{
    public UserProfile CreateUserProfile()
    {
        var profile = new UserProfile();

        // Collect basic information
        profile.FirstName = GetInput("Enter your first name:", "Profile Setup");
        if (string.IsNullOrEmpty(profile.FirstName)) return null;

        profile.LastName = GetInput("Enter your last name:", "Profile Setup");
        if (string.IsNullOrEmpty(profile.LastName)) return null;

        profile.Email = GetInput("Enter your email address:", "Profile Setup");
        if (string.IsNullOrEmpty(profile.Email)) return null;

        profile.Phone = GetInput("Enter your phone number:", "Profile Setup", "");

        // Collect preferences
        profile.Theme = GetInput("Enter your preferred theme:", "Profile Setup", "Default");
        profile.Language = GetInput("Enter your preferred language:", "Profile Setup", "English");

        return profile;
    }

    private string GetInput(string prompt, string caption, string defaultValue = "")
    {
        var inputData = new KryptonInputBoxData
        {
            Prompt = prompt,
            Caption = caption,
            DefaultResponse = defaultValue
        };

        return KryptonInputBox.Show(inputData);
    }
}

public class UserProfile
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;
    public string Theme { get; set; } = string.Empty;
    public string Language { get; set; } = string.Empty;
}
```

### Dynamic Form Builder

```csharp
public class DynamicFormBuilder
{
    public Dictionary<string, string> BuildForm(string[] fieldNames)
    {
        var formData = new Dictionary<string, string>();

        foreach (string fieldName in fieldNames)
        {
            var inputData = new KryptonInputBoxData
            {
                Prompt = $"Enter {fieldName}:",
                Caption = "Dynamic Form",
                DefaultResponse = ""
            };

            string value = KryptonInputBox.Show(inputData);
            if (!string.IsNullOrEmpty(value))
            {
                formData[fieldName] = value;
            }
            else
            {
                // User cancelled, return partial data
                break;
            }
        }

        return formData;
    }

    public void ShowDynamicForm()
    {
        string[] fields = { "Name", "Age", "City", "Country", "Occupation" };
        var data = BuildForm(fields);

        if (data.Count > 0)
        {
            string summary = "Form Data:\n";
            foreach (var item in data)
            {
                summary += $"{item.Key}: {item.Value}\n";
            }

            MessageBox.Show(summary, "Form Summary", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}
```

## License and Attribution

This class is part of the Krypton Toolkit Suite under the BSD 3-Clause License. It provides a centralized input dialog utility with support for RTL layouts and customizable input data, enabling consistent user input collection across Krypton applications.
