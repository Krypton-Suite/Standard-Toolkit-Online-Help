# Localization Implementation Examples

## Overview

This document provides complete, ready-to-use implementation examples for localizing Krypton Toolkit applications. Each example includes full source code that you can adapt to your specific needs.

## Table of Contents

1. [Complete Application Example](#complete-application-example)
2. [Multi-Form Application](#multi-form-application)
3. [Settings Dialog with Language Selector](#settings-dialog-with-language-selector)
4. [Localized Message Box Wrapper](#localized-message-box-wrapper)
5. [Plugin-Based Localization System](#plugin-based-localization-system)
6. [Database-Driven Localization](#database-driven-localization)

---

## Complete Application Example

### Project Structure

```
MyKryptonApp/
├── Program.cs
├── Localization/
│   ├── ILocalizationProvider.cs
│   ├── LocalizationManager.cs
│   ├── Languages/
│   │   ├── SpanishProvider.cs
│   │   ├── FrenchProvider.cs
│   │   ├── GermanProvider.cs
│   │   └── JapaneseProvider.cs
├── Forms/
│   ├── MainForm.cs
│   └── SettingsForm.cs
└── Properties/
    └── Settings.settings
```

### Program.cs

```csharp
using System;
using System.Globalization;
using System.Threading;
using System.Windows.Forms;
using Krypton.Toolkit;

namespace MyKryptonApp
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            // Configure application
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
            
            // Initialize localization
            InitializeLocalization();
            
            // Run application
            Application.Run(new MainForm());
        }
        
        private static void InitializeLocalization()
        {
            try
            {
                // Load user's preferred language from settings
                string languageCode = Properties.Settings.Default.Language;
                
                CultureInfo culture;
                if (string.IsNullOrEmpty(languageCode))
                {
                    // Use system default on first run
                    culture = CultureInfo.CurrentUICulture;
                    
                    // Save it for next time
                    Properties.Settings.Default.Language = culture.Name;
                    Properties.Settings.Default.Save();
                }
                else
                {
                    culture = new CultureInfo(languageCode);
                }
                
                // Apply localization
                LocalizationManager.Instance.SetLanguage(culture);
                
                // Set thread culture
                Thread.CurrentThread.CurrentCulture = culture;
                Thread.CurrentThread.CurrentUICulture = culture;
                
                Console.WriteLine($"Application localized to: {culture.DisplayName}");
            }
            catch (Exception ex)
            {
                // Log error and fall back to English
                Console.WriteLine($"Localization initialization error: {ex.Message}");
                KryptonManager.Strings.Reset();
            }
        }
    }
}
```

### ILocalizationProvider.cs

```csharp
using System.Globalization;

namespace MyKryptonApp.Localization
{
    /// <summary>
    /// Interface for localization providers
    /// </summary>
    public interface ILocalizationProvider
    {
        /// <summary>
        /// Gets the culture this provider supports
        /// </summary>
        CultureInfo Culture { get; }
        
        /// <summary>
        /// Gets the display name of the language
        /// </summary>
        string DisplayName { get; }
        
        /// <summary>
        /// Applies this localization to KryptonManager.Strings
        /// </summary>
        void ApplyLocalization();
    }
}
```

### LocalizationManager.cs

```csharp
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Krypton.Toolkit;
using MyKryptonApp.Localization.Languages;

namespace MyKryptonApp.Localization
{
    /// <summary>
    /// Manages application localization
    /// </summary>
    public sealed class LocalizationManager
    {
        #region Singleton
        
        private static readonly Lazy<LocalizationManager> _instance 
            = new Lazy<LocalizationManager>(() => new LocalizationManager());
        
        public static LocalizationManager Instance => _instance.Value;
        
        #endregion
        
        #region Fields
        
        private readonly Dictionary<string, ILocalizationProvider> _providers;
        private CultureInfo _currentCulture;
        
        #endregion
        
        #region Events
        
        public event EventHandler<LanguageChangedEventArgs> LanguageChanged;
        
        #endregion
        
        #region Constructor
        
        private LocalizationManager()
        {
            _providers = new Dictionary<string, ILocalizationProvider>();
            _currentCulture = CultureInfo.InvariantCulture;
            
            // Register built-in language providers
            RegisterProvider(new SpanishProvider());
            RegisterProvider(new FrenchProvider());
            RegisterProvider(new GermanProvider());
            RegisterProvider(new JapaneseProvider());
        }
        
        #endregion
        
        #region Public Properties
        
        public CultureInfo CurrentCulture => _currentCulture;
        
        public IEnumerable<ILocalizationProvider> SupportedLanguages => _providers.Values;
        
        #endregion
        
        #region Public Methods
        
        public void RegisterProvider(ILocalizationProvider provider)
        {
            if (provider == null)
                throw new ArgumentNullException(nameof(provider));
            
            string key = provider.Culture.TwoLetterISOLanguageName.ToLower();
            _providers[key] = provider;
        }
        
        public bool SetLanguage(CultureInfo culture)
        {
            if (culture == null)
                throw new ArgumentNullException(nameof(culture));
            
            string key = culture.TwoLetterISOLanguageName.ToLower();
            
            if (key == "en")
            {
                // English - reset to defaults
                KryptonManager.Strings.Reset();
                UpdateCurrentCulture(culture);
                return true;
            }
            
            if (_providers.TryGetValue(key, out ILocalizationProvider provider))
            {
                try
                {
                    provider.ApplyLocalization();
                    UpdateCurrentCulture(culture);
                    return true;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine(
                        $"Error applying localization: {ex.Message}"
                    );
                    return false;
                }
            }
            
            // Unsupported language - fall back to English
            KryptonManager.Strings.Reset();
            UpdateCurrentCulture(CultureInfo.InvariantCulture);
            return false;
        }
        
        public bool SetLanguage(string cultureName)
        {
            try
            {
                CultureInfo culture = new CultureInfo(cultureName);
                return SetLanguage(culture);
            }
            catch (CultureNotFoundException)
            {
                return false;
            }
        }
        
        public ILocalizationProvider GetProvider(CultureInfo culture)
        {
            string key = culture.TwoLetterISOLanguageName.ToLower();
            _providers.TryGetValue(key, out ILocalizationProvider provider);
            return provider;
        }
        
        #endregion
        
        #region Private Methods
        
        private void UpdateCurrentCulture(CultureInfo culture)
        {
            CultureInfo oldCulture = _currentCulture;
            _currentCulture = culture;
            
            OnLanguageChanged(new LanguageChangedEventArgs(oldCulture, culture));
        }
        
        private void OnLanguageChanged(LanguageChangedEventArgs e)
        {
            LanguageChanged?.Invoke(this, e);
        }
        
        #endregion
    }
    
    #region Event Args
    
    public class LanguageChangedEventArgs : EventArgs
    {
        public CultureInfo OldCulture { get; }
        public CultureInfo NewCulture { get; }
        
        public LanguageChangedEventArgs(CultureInfo oldCulture, CultureInfo newCulture)
        {
            OldCulture = oldCulture;
            NewCulture = newCulture;
        }
    }
    
    #endregion
}
```

### SpanishProvider.cs

```csharp
using System.Globalization;
using Krypton.Toolkit;

namespace MyKryptonApp.Localization.Languages
{
    public class SpanishProvider : ILocalizationProvider
    {
        public CultureInfo Culture => new CultureInfo("es");
        
        public string DisplayName => "Español";
        
        public void ApplyLocalization()
        {
            ApplyGeneralStrings();
            ApplyCustomStrings();
            ApplyRibbonStrings();
            ApplyAboutBoxStrings();
            ApplyToastNotificationStrings();
        }
        
        private void ApplyGeneralStrings()
        {
            var s = KryptonManager.Strings.GeneralStrings;
            
            s.OK = "&Aceptar";
            s.Cancel = "&Cancelar";
            s.Yes = "&Sí";
            s.No = "&No";
            s.Abort = "Abo&rtar";
            s.Retry = "Rei&ntentar";
            s.Ignore = "&Ignorar";
            s.Close = "C&errar";
            s.Help = "A&yuda";
            s.Continue = "Co&ntinuar";
            s.TryAgain = "Volver a &intentar";
            s.Today = "&Hoy";
        }
        
        private void ApplyCustomStrings()
        {
            var s = KryptonManager.Strings.CustomStrings;
            
            s.Apply = "A&plicar";
            s.Back = "&Atrás";
            s.Next = "&Siguiente";
            s.Previous = "A&nterior";
            s.Finish = "&Finalizar";
            s.Exit = "&Salir";
            s.Collapse = "&Contraer";
            s.Expand = "E&xpander";
            s.Cut = "Cor&tar";
            s.Copy = "&Copiar";
            s.Paste = "&Pegar";
            s.SelectAll = "Seleccionar &todo";
            s.ClearClipboard = "&Limpiar portapapeles";
            s.YesToAll = "Sí a &todo";
            s.NoToAll = "No a t&odo";
            s.OkToAll = "Aceptar &todo";
            s.Reset = "&Restablecer";
            s.SystemInformation = "&Información del sistema";
            s.CurrentTheme = "Tema actual";
            s.DoNotShowAgain = "&No volver a mostrar";
        }
        
        private void ApplyRibbonStrings()
        {
            var s = KryptonManager.Strings.RibbonStrings;
            
            s.AppButtonText = "Archivo";
            s.AppButtonKeyTip = "A";
            s.CustomizeQuickAccessToolbar = "Personalizar barra de herramientas";
            s.Minimize = "&Minimizar la cinta";
            s.MoreColors = "&Más colores...";
            s.NoColor = "&Sin color";
            s.RecentDocuments = "Documentos recientes";
            s.RecentColors = "Colores recientes";
            s.ShowAboveRibbon = "&Mostrar encima de la cinta";
            s.ShowBelowRibbon = "Mostrar &debajo de la cinta";
            s.ShowQATAboveRibbon = "Mostrar barra de acceso rápido &encima";
            s.ShowQATBelowRibbon = "Mostrar barra de acceso rápido &debajo";
            s.StandardColors = "Colores estándar";
            s.ThemeColors = "Colores del tema";
        }
        
        private void ApplyAboutBoxStrings()
        {
            var s = KryptonManager.Strings.AboutBoxStrings;
            
            s.About = "Acerca de";
            s.Title = "Título";
            s.Copyright = "Copyright";
            s.Description = "Descripción";
            s.Company = "Compañía";
            s.Product = "Producto";
            s.Trademark = "Marca comercial";
            s.Version = "Versión";
            s.BuildDate = "Fecha de compilación";
            s.ImageRuntimeVersion = "Versión de runtime";
            s.LoadedFromGlobalAssemblyCache = "Cargado desde GAC";
        }
        
        private void ApplyToastNotificationStrings()
        {
            var s = KryptonManager.Strings.ToastNotificationStrings;
            
            s.Dismiss = "&Cerrar";
            s.DoNotShowAgain = "&No volver a mostrar";
        }
    }
}
```

### MainForm.cs

```csharp
using System;
using System.Globalization;
using System.Windows.Forms;
using Krypton.Toolkit;
using MyKryptonApp.Localization;

namespace MyKryptonApp.Forms
{
    public partial class MainForm : KryptonForm
    {
        public MainForm()
        {
            InitializeComponent();
            
            // Subscribe to language changes
            LocalizationManager.Instance.LanguageChanged += OnLanguageChanged;
            
            // Initialize UI
            InitializeUI();
        }
        
        private void InitializeUI()
        {
            // Set form text based on current language
            UpdateUIText();
        }
        
        private void UpdateUIText()
        {
            // Update form title
            this.Text = GetLocalizedText("MainForm.Title", "My Application");
            
            // Update menu items
            fileToolStripMenuItem.Text = GetLocalizedText("Menu.File", "File");
            editToolStripMenuItem.Text = GetLocalizedText("Menu.Edit", "Edit");
            helpToolStripMenuItem.Text = GetLocalizedText("Menu.Help", "Help");
            
            // Update buttons
            saveButton.Text = KryptonManager.Strings.CustomStrings.Apply;
            cancelButton.Text = KryptonManager.Strings.GeneralStrings.Cancel;
        }
        
        private string GetLocalizedText(string key, string defaultValue)
        {
            // In a real application, you would load this from resources
            return defaultValue;
        }
        
        private void OnLanguageChanged(object sender, LanguageChangedEventArgs e)
        {
            // Update UI when language changes
            UpdateUIText();
            
            // Show notification
            KryptonMessageBox.Show(
                this,
                $"Language changed to: {e.NewCulture.DisplayName}",
                "Language Changed",
                KryptonMessageBoxButtons.OK,
                KryptonMessageBoxIcon.Information
            );
        }
        
        private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            using (var settingsForm = new SettingsForm())
            {
                settingsForm.ShowDialog(this);
            }
        }
        
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // Use localized message box
            var result = KryptonMessageBox.Show(
                this,
                "Are you sure you want to exit?",
                "Confirm Exit",
                KryptonMessageBoxButtons.YesNo,
                KryptonMessageBoxIcon.Question
            );
            
            if (result == DialogResult.Yes)
            {
                Application.Exit();
            }
        }
        
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            // Unsubscribe from events
            LocalizationManager.Instance.LanguageChanged -= OnLanguageChanged;
            
            base.OnFormClosing(e);
        }
    }
}
```

---

## Settings Dialog with Language Selector

### SettingsForm.cs

```csharp
using System;
using System.Globalization;
using System.Linq;
using System.Windows.Forms;
using Krypton.Toolkit;
using MyKryptonApp.Localization;

namespace MyKryptonApp.Forms
{
    public partial class SettingsForm : KryptonForm
    {
        private bool _languageChanged = false;
        
        public SettingsForm()
        {
            InitializeComponent();
            
            InitializeLanguageComboBox();
            LoadSettings();
        }
        
        private void InitializeLanguageComboBox()
        {
            // Add English (default)
            languageComboBox.Items.Add(new LanguageItem(
                new CultureInfo("en"), 
                "English"
            ));
            
            // Add supported languages
            foreach (var provider in LocalizationManager.Instance.SupportedLanguages.OrderBy(p => p.DisplayName))
            {
                languageComboBox.Items.Add(new LanguageItem(
                    provider.Culture,
                    provider.DisplayName
                ));
            }
            
            // Select current language
            CultureInfo current = LocalizationManager.Instance.CurrentCulture;
            for (int i = 0; i < languageComboBox.Items.Count; i++)
            {
                var item = (LanguageItem)languageComboBox.Items[i];
                if (item.Culture.TwoLetterISOLanguageName == 
                    current.TwoLetterISOLanguageName)
                {
                    languageComboBox.SelectedIndex = i;
                    break;
                }
            }
        }
        
        private void LoadSettings()
        {
            // Load other settings
            // ...
        }
        
        private void languageComboBox_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (languageComboBox.SelectedItem is LanguageItem selectedItem)
            {
                CultureInfo current = LocalizationManager.Instance.CurrentCulture;
                
                if (!selectedItem.Culture.TwoLetterISOLanguageName.Equals(
                    current.TwoLetterISOLanguageName, 
                    StringComparison.OrdinalIgnoreCase))
                {
                    _languageChanged = true;
                    
                    // Show preview of change
                    restartLabel.Visible = true;
                    restartLabel.Text = "Language will be changed when you click Apply";
                }
                else
                {
                    _languageChanged = false;
                    restartLabel.Visible = false;
                }
            }
        }
        
        private void applyButton_Click(object sender, EventArgs e)
        {
            if (_languageChanged && languageComboBox.SelectedItem is LanguageItem selectedItem)
            {
                // Confirm language change
                var result = KryptonMessageBox.Show(
                    this,
                    "Changing the language will require restarting the application. Continue?",
                    "Confirm Language Change",
                    KryptonMessageBoxButtons.YesNo,
                    KryptonMessageBoxIcon.Question
                );
                
                if (result == DialogResult.Yes)
                {
                    // Save language preference
                    Properties.Settings.Default.Language = selectedItem.Culture.Name;
                    Properties.Settings.Default.Save();
                    
                    // Apply immediately
                    LocalizationManager.Instance.SetLanguage(selectedItem.Culture);
                    
                    // Show message
                    KryptonMessageBox.Show(
                        this,
                        "Language changed successfully.",
                        "Success",
                        KryptonMessageBoxButtons.OK,
                        KryptonMessageBoxIcon.Information
                    );
                    
                    _languageChanged = false;
                    restartLabel.Visible = false;
                }
            }
            
            // Save other settings
            SaveSettings();
        }
        
        private void okButton_Click(object sender, EventArgs e)
        {
            applyButton_Click(sender, e);
            this.Close();
        }
        
        private void cancelButton_Click(object sender, EventArgs e)
        {
            if (_languageChanged)
            {
                var result = KryptonMessageBox.Show(
                    this,
                    "You have unsaved language changes. Are you sure you want to cancel?",
                    "Unsaved Changes",
                    KryptonMessageBoxButtons.YesNo,
                    KryptonMessageBoxIcon.Warning
                );
                
                if (result == DialogResult.No)
                    return;
            }
            
            this.Close();
        }
        
        private void SaveSettings()
        {
            // Save other settings
            Properties.Settings.Default.Save();
        }
        
        #region LanguageItem Helper Class
        
        private class LanguageItem
        {
            public CultureInfo Culture { get; }
            public string DisplayName { get; }
            
            public LanguageItem(CultureInfo culture, string displayName)
            {
                Culture = culture;
                DisplayName = displayName;
            }
            
            public override string ToString() => DisplayName;
        }
        
        #endregion
    }
}
```

### SettingsForm.Designer.cs (partial)

```csharp
partial class SettingsForm
{
    private KryptonLabel languageLabel;
    private KryptonComboBox languageComboBox;
    private KryptonLabel restartLabel;
    private KryptonButton applyButton;
    private KryptonButton okButton;
    private KryptonButton cancelButton;
    
    private void InitializeComponent()
    {
        this.languageLabel = new KryptonLabel();
        this.languageComboBox = new KryptonComboBox();
        this.restartLabel = new KryptonLabel();
        this.applyButton = new KryptonButton();
        this.okButton = new KryptonButton();
        this.cancelButton = new KryptonButton();
        
        // languageLabel
        this.languageLabel.Location = new System.Drawing.Point(12, 12);
        this.languageLabel.Text = "Language:";
        
        // languageComboBox
        this.languageComboBox.Location = new System.Drawing.Point(120, 10);
        this.languageComboBox.Width = 200;
        this.languageComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
        this.languageComboBox.SelectedIndexChanged += 
            new EventHandler(languageComboBox_SelectedIndexChanged);
        
        // restartLabel
        this.restartLabel.Location = new System.Drawing.Point(120, 35);
        this.restartLabel.ForeColor = System.Drawing.Color.Red;
        this.restartLabel.Visible = false;
        
        // applyButton
        this.applyButton.Location = new System.Drawing.Point(12, 100);
        this.applyButton.Text = KryptonManager.Strings.CustomStrings.Apply;
        this.applyButton.Click += new EventHandler(applyButton_Click);
        
        // okButton
        this.okButton.Location = new System.Drawing.Point(100, 100);
        this.okButton.Text = KryptonManager.Strings.GeneralStrings.OK;
        this.okButton.Click += new EventHandler(okButton_Click);
        
        // cancelButton
        this.cancelButton.Location = new System.Drawing.Point(188, 100);
        this.cancelButton.Text = KryptonManager.Strings.GeneralStrings.Cancel;
        this.cancelButton.Click += new EventHandler(cancelButton_Click);
        
        // SettingsForm
        this.ClientSize = new System.Drawing.Size(350, 150);
        this.Controls.Add(this.languageLabel);
        this.Controls.Add(this.languageComboBox);
        this.Controls.Add(this.restartLabel);
        this.Controls.Add(this.applyButton);
        this.Controls.Add(this.okButton);
        this.Controls.Add(this.cancelButton);
        this.FormBorderStyle = FormBorderStyle.FixedDialog;
        this.MaximizeBox = false;
        this.MinimizeBox = false;
        this.StartPosition = FormStartPosition.CenterParent;
        this.Text = "Settings";
    }
}
```

---

## Localized Message Box Wrapper

### LocalizedMessageBox.cs

```csharp
using System;
using System.Windows.Forms;
using Krypton.Toolkit;

namespace MyKryptonApp.Localization
{
    /// <summary>
    /// Wrapper for KryptonMessageBox with automatic localization
    /// </summary>
    public static class LocalizedMessageBox
    {
        /// <summary>
        /// Shows a localized confirmation dialog
        /// </summary>
        public static DialogResult ShowConfirmation(
            string message, 
            string title = null,
            IWin32Window owner = null)
        {
            title = title ?? GetLocalizedString("MessageBox.Confirmation", "Confirmation");
            
            return KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.YesNo,
                KryptonMessageBoxIcon.Question
            );
        }
        
        /// <summary>
        /// Shows a localized information dialog
        /// </summary>
        public static void ShowInformation(
            string message,
            string title = null,
            IWin32Window owner = null)
        {
            title = title ?? GetLocalizedString("MessageBox.Information", "Information");
            
            KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.OK,
                KryptonMessageBoxIcon.Information
            );
        }
        
        /// <summary>
        /// Shows a localized warning dialog
        /// </summary>
        public static void ShowWarning(
            string message,
            string title = null,
            IWin32Window owner = null)
        {
            title = title ?? GetLocalizedString("MessageBox.Warning", "Warning");
            
            KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.OK,
                KryptonMessageBoxIcon.Warning
            );
        }
        
        /// <summary>
        /// Shows a localized error dialog
        /// </summary>
        public static void ShowError(
            string message,
            string title = null,
            IWin32Window owner = null)
        {
            title = title ?? GetLocalizedString("MessageBox.Error", "Error");
            
            KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.OK,
                KryptonMessageBoxIcon.Error
            );
        }
        
        /// <summary>
        /// Shows a localized save confirmation dialog
        /// </summary>
        public static DialogResult ShowSaveConfirmation(
            string fileName,
            IWin32Window owner = null)
        {
            string message = string.Format(
                GetLocalizedString("MessageBox.SaveChanges", 
                    "Do you want to save changes to '{0}'?"),
                fileName
            );
            
            string title = GetLocalizedString("MessageBox.SaveTitle", "Save Changes");
            
            return KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.YesNoCancel,
                KryptonMessageBoxIcon.Question
            );
        }
        
        /// <summary>
        /// Shows a localized delete confirmation dialog
        /// </summary>
        public static DialogResult ShowDeleteConfirmation(
            string itemName,
            IWin32Window owner = null)
        {
            string message = string.Format(
                GetLocalizedString("MessageBox.DeleteConfirm",
                    "Are you sure you want to delete '{0}'? This action cannot be undone."),
                itemName
            );
            
            string title = GetLocalizedString("MessageBox.DeleteTitle", "Confirm Delete");
            
            return KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.YesNo,
                KryptonMessageBoxIcon.Warning
            );
        }
        
        /// <summary>
        /// Shows a localized overwrite confirmation dialog
        /// </summary>
        public static DialogResult ShowOverwriteConfirmation(
            string fileName,
            IWin32Window owner = null)
        {
            string message = string.Format(
                GetLocalizedString("MessageBox.OverwriteConfirm",
                    "The file '{0}' already exists. Do you want to replace it?"),
                fileName
            );
            
            string title = GetLocalizedString("MessageBox.OverwriteTitle", 
                "Confirm Overwrite");
            
            return KryptonMessageBox.Show(
                owner,
                message,
                title,
                KryptonMessageBoxButtons.YesNo,
                KryptonMessageBoxIcon.Warning
            );
        }
        
        private static string GetLocalizedString(string key, string defaultValue)
        {
            // In a real application, load from resources
            // For now, return default value
            return defaultValue;
        }
    }
}
```

### Usage Example

```csharp
// Instead of:
var result = KryptonMessageBox.Show("Are you sure?", "Confirm", 
    KryptonMessageBoxButtons.YesNo, KryptonMessageBoxIcon.Question);

// Use:
var result = LocalizedMessageBox.ShowConfirmation("Are you sure?", "Confirm");

// Other examples:
LocalizedMessageBox.ShowInformation("Operation completed successfully");
LocalizedMessageBox.ShowWarning("This action may take some time");
LocalizedMessageBox.ShowError("An error occurred while processing");

var saveResult = LocalizedMessageBox.ShowSaveConfirmation("document.txt");
var deleteResult = LocalizedMessageBox.ShowDeleteConfirmation("Old File.txt");
var overwriteResult = LocalizedMessageBox.ShowOverwriteConfirmation("file.txt");
```

---

## Database-Driven Localization

### Database Schema

```sql
CREATE TABLE Languages (
    LanguageID INT PRIMARY KEY IDENTITY(1,1),
    CultureCode NVARCHAR(10) NOT NULL UNIQUE,
    DisplayName NVARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

CREATE TABLE StringCategories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE LocalizedStrings (
    StringID INT PRIMARY KEY IDENTITY(1,1),
    CategoryID INT NOT NULL,
    StringKey NVARCHAR(100) NOT NULL,
    LanguageID INT NOT NULL,
    StringValue NVARCHAR(500) NOT NULL,
    LastModified DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (CategoryID) REFERENCES StringCategories(CategoryID),
    FOREIGN KEY (LanguageID) REFERENCES Languages(LanguageID),
    UNIQUE (CategoryID, StringKey, LanguageID)
);

-- Sample data
INSERT INTO Languages (CultureCode, DisplayName) VALUES 
    ('en', 'English'),
    ('es', 'Español'),
    ('fr', 'Français'),
    ('de', 'Deutsch'),
    ('ja', '日本語');

INSERT INTO StringCategories (CategoryName) VALUES 
    ('General'),
    ('Custom'),
    ('Ribbon'),
    ('AboutBox'),
    ('ToastNotification');

-- Sample strings
INSERT INTO LocalizedStrings (CategoryID, StringKey, LanguageID, StringValue) VALUES
    (1, 'OK', 1, 'O&K'),
    (1, 'OK', 2, '&Aceptar'),
    (1, 'Cancel', 1, 'Cance&l'),
    (1, 'Cancel', 2, '&Cancelar');
```

### DatabaseLocalizationProvider.cs

```csharp
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using Krypton.Toolkit;

namespace MyKryptonApp.Localization.Database
{
    public class DatabaseLocalizationProvider : ILocalizationProvider
    {
        private readonly string _connectionString;
        private readonly CultureInfo _culture;
        private readonly string _displayName;
        private Dictionary<string, Dictionary<string, string>> _cachedStrings;
        
        public DatabaseLocalizationProvider(
            string connectionString, 
            CultureInfo culture, 
            string displayName)
        {
            _connectionString = connectionString;
            _culture = culture;
            _displayName = displayName;
        }
        
        public CultureInfo Culture => _culture;
        public string DisplayName => _displayName;
        
        public void ApplyLocalization()
        {
            LoadStringsFromDatabase();
            ApplyToKryptonManager();
        }
        
        private void LoadStringsFromDatabase()
        {
            _cachedStrings = new Dictionary<string, Dictionary<string, string>>(
                StringComparer.OrdinalIgnoreCase
            );
            
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                
                string query = @"
                    SELECT 
                        c.CategoryName,
                        s.StringKey,
                        s.StringValue
                    FROM LocalizedStrings s
                    INNER JOIN StringCategories c ON s.CategoryID = c.CategoryID
                    INNER JOIN Languages l ON s.LanguageID = l.LanguageID
                    WHERE l.CultureCode = @CultureCode
                    ORDER BY c.CategoryName, s.StringKey";
                
                using (var command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@CultureCode", 
                        _culture.TwoLetterISOLanguageName);
                    
                    using (var reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string category = reader.GetString(0);
                            string key = reader.GetString(1);
                            string value = reader.GetString(2);
                            
                            if (!_cachedStrings.ContainsKey(category))
                            {
                                _cachedStrings[category] = 
                                    new Dictionary<string, string>(
                                        StringComparer.OrdinalIgnoreCase
                                    );
                            }
                            
                            _cachedStrings[category][key] = value;
                        }
                    }
                }
            }
        }
        
        private void ApplyToKryptonManager()
        {
            ApplyCategory("General", KryptonManager.Strings.GeneralStrings);
            ApplyCategory("Custom", KryptonManager.Strings.CustomStrings);
            ApplyCategory("Ribbon", KryptonManager.Strings.RibbonStrings);
            ApplyCategory("AboutBox", KryptonManager.Strings.AboutBoxStrings);
            ApplyCategory("ToastNotification", 
                KryptonManager.Strings.ToastNotificationStrings);
        }
        
        private void ApplyCategory(string categoryName, object target)
        {
            if (!_cachedStrings.TryGetValue(categoryName, out var strings))
                return;
            
            var type = target.GetType();
            foreach (var kvp in strings)
            {
                var property = type.GetProperty(kvp.Key);
                if (property != null && property.CanWrite && 
                    property.PropertyType == typeof(string))
                {
                    property.SetValue(target, kvp.Value);
                }
            }
        }
        
        public string GetString(string category, string key, string defaultValue = null)
        {
            if (_cachedStrings == null)
                LoadStringsFromDatabase();
            
            if (_cachedStrings.TryGetValue(category, out var categoryStrings) &&
                categoryStrings.TryGetValue(key, out var value))
            {
                return value;
            }
            
            return defaultValue ?? key;
        }
    }
}
```

### DatabaseLocalizationManager.cs

```csharp
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace MyKryptonApp.Localization.Database
{
    public class DatabaseLocalizationManager
    {
        private readonly string _connectionString;
        private List<DatabaseLocalizationProvider> _providers;
        
        public DatabaseLocalizationManager(string connectionString)
        {
            _connectionString = connectionString;
            LoadProviders();
        }
        
        private void LoadProviders()
        {
            _providers = new List<DatabaseLocalizationProvider>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                connection.Open();
                
                string query = @"
                    SELECT CultureCode, DisplayName 
                    FROM Languages 
                    WHERE IsActive = 1
                    ORDER BY DisplayName";
                
                using (var command = new SqlCommand(query, connection))
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string cultureCode = reader.GetString(0);
                        string displayName = reader.GetString(1);
                        
                        try
                        {
                            var culture = new CultureInfo(cultureCode);
                            var provider = new DatabaseLocalizationProvider(
                                _connectionString,
                                culture,
                                displayName
                            );
                            
                            _providers.Add(provider);
                        }
                        catch (CultureNotFoundException)
                        {
                            // Skip invalid cultures
                        }
                    }
                }
            }
        }
        
        public IEnumerable<ILocalizationProvider> GetProviders()
        {
            return _providers;
        }
        
        public void RegisterWithLocaliz ationManager()
        {
            foreach (var provider in _providers)
            {
                LocalizationManager.Instance.RegisterProvider(provider);
            }
        }
    }
}
```

---

## See Also

- [Localization and String Management Guide](LocalizationGuide.md)
- [KryptonManager.Strings API Reference](../Components/KryptonManagerStringsAPIReference.md)
- [Advanced Localization Topics](LocalizationAdvancedTopics.md)
- [ExceptionHandler API Documentation](ExceptionHandlerAPIDocumentation.md)

