# Advanced Localization Topics for Krypton Toolkit

## Overview

This document covers advanced localization topics, implementation strategies, and comprehensive examples for the Krypton Toolkit localization system. It is intended for developers who need deep integration of localization features in their applications.

## Table of Contents

1. [Architecture Deep Dive](#architecture-deep-dive)
2. [Complete Language Implementations](#complete-language-implementations)
3. [Resource File Integration](#resource-file-integration)
4. [Dynamic Language Switching](#dynamic-language-switching)
5. [Custom String Categories](#custom-string-categories)
6. [Localization Testing Framework](#localization-testing-framework)
7. [Performance Optimization](#performance-optimization)
8. [Deployment Strategies](#deployment-strategies)

---

## Architecture Deep Dive

### String Management System Components

```
Application Layer
    └── KryptonManager (Entry Point)
        └── KryptonGlobalToolkitStrings (Container)
            ├── GeneralToolkitStrings (Button strings)
            ├── CustomToolkitStrings (Custom actions)
            ├── GeneralRibbonStrings (Ribbon UI)
            ├── Component-Specific Strings
            └── Style/Converter Strings

Designer Layer
    └── TypeConverter Support
        └── ExpandableObjectConverter
            ├── Property Grid Integration
            ├── Serialization Support
            └── .resx Resource Generation
```

### Internal Implementation

#### String Category Base Pattern

All string categories inherit from `GlobalId` and implement a consistent pattern:

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class StringCategoryExample : GlobalId
{
    #region Static Fields (Constants)
    // Private constants define default values
    private const string DEFAULT_PROPERTY = "Default Value";
    #endregion
    
    #region Identity
    // Constructor initializes to defaults
    public StringCategoryExample() => Reset();
    
    // ToString for designer support
    public override string ToString() => !IsDefault ? "Modified" : string.Empty;
    #endregion
    
    #region Public Properties
    [Localizable(true)]
    [Category("Visuals")]
    [Description("Property description")]
    [DefaultValue(DEFAULT_PROPERTY)]
    [RefreshProperties(RefreshProperties.All)]
    public string Property { get; set; }
    #endregion
    
    #region Implementation
    [Browsable(false)]
    public bool IsDefault => Property.Equals(DEFAULT_PROPERTY);
    
    public void Reset() => Property = DEFAULT_PROPERTY;
    #endregion
}
```

#### Static vs Instance Access

The system supports both access patterns:

```csharp
// Static access - direct to category
string value1 = KryptonGlobalToolkitStrings.GeneralToolkitStrings.OK;

// Instance access - through KryptonManager
string value2 = KryptonManager.Strings.GeneralStrings.OK;

// Both refer to the same singleton instance
Debug.Assert(value1 == value2); // True
```

### Memory and Performance Characteristics

**Memory Footprint:**
- Base overhead: ~50 KB for all string categories
- Each modified string: ~50-200 bytes depending on length
- Total application impact: < 1 MB for fully localized application

**Performance:**
- String access: O(1) - direct property access
- Reset operation: O(n) where n = number of properties
- No caching overhead
- No dictionary lookups

**Thread Safety:**
- Read operations: Thread-safe
- Write operations: Not thread-safe (require UI thread)
- Recommendation: Configure strings during application startup

---

## Complete Language Implementations

### Spanish (Español) - Complete Implementation

```csharp
public class SpanishLocalization
{
    public static void Apply()
    {
        ApplyGeneral();
        ApplyCustom();
        ApplyRibbon();
        ApplyAboutBox();
        ApplyToastNotification();
    }
    
    private static void ApplyGeneral()
    {
        var s = KryptonManager.Strings.GeneralStrings;
        
        // Message Box Buttons
        s.OK = "&Aceptar";              // Alt+A
        s.Cancel = "&Cancelar";         // Alt+C
        s.Yes = "&Sí";                  // Alt+S
        s.No = "&No";                   // Alt+N
        s.Abort = "Abo&rtar";           // Alt+R
        s.Retry = "Rei&ntentar";        // Alt+N
        s.Ignore = "&Ignorar";          // Alt+I
        s.Close = "C&errar";            // Alt+E
        s.Help = "A&yuda";              // Alt+Y
        s.Continue = "Co&ntinuar";      // Alt+N
        s.TryAgain = "Volver a &intentar"; // Alt+I
        
        // Other UI Elements
        s.Today = "&Hoy";               // Alt+H (for calendars)
    }
    
    private static void ApplyCustom()
    {
        var s = KryptonManager.Strings.CustomStrings;
        
        // Navigation
        s.Apply = "A&plicar";           // Alt+P
        s.Back = "&Atrás";              // Alt+A
        s.Next = "&Siguiente";          // Alt+S
        s.Previous = "A&nterior";       // Alt+N
        s.Finish = "&Finalizar";        // Alt+F
        s.Exit = "&Salir";              // Alt+S
        
        // Panels
        s.Collapse = "&Contraer";       // Alt+C
        s.Expand = "E&xpander";         // Alt+X
        
        // Clipboard
        s.Cut = "Cor&tar";              // Alt+T
        s.Copy = "&Copiar";             // Alt+C
        s.Paste = "&Pegar";             // Alt+P
        s.SelectAll = "Seleccionar &todo"; // Alt+T
        s.ClearClipboard = "&Limpiar portapapeles"; // Alt+L
        
        // Batch Operations
        s.YesToAll = "Sí a &todo";      // Alt+T
        s.NoToAll = "No a t&odo";       // Alt+O
        s.OkToAll = "Aceptar &todo";    // Alt+T
        
        // Other
        s.Reset = "&Restablecer";       // Alt+R
        s.SystemInformation = "&Información del sistema"; // Alt+I
        s.CurrentTheme = "Tema actual";
        s.DoNotShowAgain = "&No volver a mostrar"; // Alt+N
    }
    
    private static void ApplyRibbon()
    {
        var s = KryptonManager.Strings.RibbonStrings;
        
        s.AppButtonText = "Archivo";
        s.AppButtonKeyTip = "A";
        s.CustomizeQuickAccessToolbar = "Personalizar barra de herramientas de acceso rápido";
        s.Minimize = "&Minimizar la cinta";
        s.MoreColors = "&Más colores...";
        s.NoColor = "&Sin color";
        s.RecentDocuments = "Documentos recientes";
        s.RecentColors = "Colores recientes";
        s.ShowAboveRibbon = "&Mostrar encima de la cinta";
        s.ShowBelowRibbon = "Mostrar &debajo de la cinta";
        s.ShowQATAboveRibbon = "Mostrar barra de acceso rápido &encima de la cinta";
        s.ShowQATBelowRibbon = "Mostrar barra de acceso rápido &debajo de la cinta";
        s.StandardColors = "Colores estándar";
        s.ThemeColors = "Colores del tema";
    }
    
    private static void ApplyAboutBox()
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
        s.ImageRuntimeVersion = "Versión de tiempo de ejecución";
        s.LoadedFromGlobalAssemblyCache = "Cargado desde GAC";
    }
    
    private static void ApplyToastNotification()
    {
        var s = KryptonManager.Strings.ToastNotificationStrings;
        
        s.Dismiss = "&Cerrar";
        s.DoNotShowAgain = "&No volver a mostrar";
    }
}
```

### French (Français) - Complete Implementation

```csharp
public class FrenchLocalization
{
    public static void Apply()
    {
        ApplyGeneral();
        ApplyCustom();
        ApplyRibbon();
        ApplyAboutBox();
        ApplyToastNotification();
    }
    
    private static void ApplyGeneral()
    {
        var s = KryptonManager.Strings.GeneralStrings;
        
        s.OK = "&OK";
        s.Cancel = "&Annuler";
        s.Yes = "&Oui";
        s.No = "&Non";
        s.Abort = "A&bandonner";
        s.Retry = "&Réessayer";
        s.Ignore = "&Ignorer";
        s.Close = "&Fermer";
        s.Help = "&Aide";
        s.Continue = "&Continuer";
        s.TryAgain = "Réessayer";
        s.Today = "Aujourd'&hui";
    }
    
    private static void ApplyCustom()
    {
        var s = KryptonManager.Strings.CustomStrings;
        
        s.Apply = "&Appliquer";
        s.Back = "&Retour";
        s.Next = "&Suivant";
        s.Previous = "&Précédent";
        s.Finish = "&Terminer";
        s.Exit = "&Quitter";
        s.Collapse = "&Réduire";
        s.Expand = "&Développer";
        s.Cut = "Co&uper";
        s.Copy = "&Copier";
        s.Paste = "C&oller";
        s.SelectAll = "&Tout sélectionner";
        s.ClearClipboard = "&Vider le presse-papiers";
        s.YesToAll = "Oui à &tout";
        s.NoToAll = "Non à t&out";
        s.OkToAll = "OK à &tout";
        s.Reset = "&Réinitialiser";
        s.SystemInformation = "&Informations système";
        s.CurrentTheme = "Thème actuel";
        s.DoNotShowAgain = "&Ne plus afficher ce message";
    }
    
    private static void ApplyRibbon()
    {
        var s = KryptonManager.Strings.RibbonStrings;
        
        s.AppButtonText = "Fichier";
        s.AppButtonKeyTip = "F";
        s.CustomizeQuickAccessToolbar = "Personnaliser la barre d'outils Accès rapide";
        s.Minimize = "&Réduire le ruban";
        s.MoreColors = "&Autres couleurs...";
        s.NoColor = "&Aucune couleur";
        s.RecentDocuments = "Documents récents";
        s.RecentColors = "Couleurs récentes";
        s.ShowAboveRibbon = "Afficher au-&dessus du ruban";
        s.ShowBelowRibbon = "Afficher en dessous du ruban";
        s.ShowQATAboveRibbon = "Afficher la barre d'accès rapide au-dessus du ruban";
        s.ShowQATBelowRibbon = "Afficher la barre d'accès rapide en dessous du ruban";
        s.StandardColors = "Couleurs standard";
        s.ThemeColors = "Couleurs du thème";
    }
    
    private static void ApplyAboutBox()
    {
        var s = KryptonManager.Strings.AboutBoxStrings;
        
        s.About = "À propos";
        s.Title = "Titre";
        s.Copyright = "Copyright";
        s.Description = "Description";
        s.Company = "Société";
        s.Product = "Produit";
        s.Trademark = "Marque déposée";
        s.Version = "Version";
        s.BuildDate = "Date de compilation";
        s.ImageRuntimeVersion = "Version du runtime";
        s.LoadedFromGlobalAssemblyCache = "Chargé depuis le GAC";
    }
    
    private static void ApplyToastNotification()
    {
        var s = KryptonManager.Strings.ToastNotificationStrings;
        
        s.Dismiss = "&Fermer";
        s.DoNotShowAgain = "&Ne plus afficher";
    }
}
```

### German (Deutsch) - Complete Implementation

```csharp
public class GermanLocalization
{
    public static void Apply()
    {
        ApplyGeneral();
        ApplyCustom();
        ApplyRibbon();
        ApplyAboutBox();
        ApplyToastNotification();
    }
    
    private static void ApplyGeneral()
    {
        var s = KryptonManager.Strings.GeneralStrings;
        
        s.OK = "&OK";
        s.Cancel = "A&bbrechen";
        s.Yes = "&Ja";
        s.No = "&Nein";
        s.Abort = "Abbr&echen";
        s.Retry = "&Wiederholen";
        s.Ignore = "&Ignorieren";
        s.Close = "&Schließen";
        s.Help = "&Hilfe";
        s.Continue = "&Fortsetzen";
        s.TryAgain = "Erneut versuchen";
        s.Today = "&Heute";
    }
    
    private static void ApplyCustom()
    {
        var s = KryptonManager.Strings.CustomStrings;
        
        s.Apply = "&Anwenden";
        s.Back = "&Zurück";
        s.Next = "&Weiter";
        s.Previous = "Z&urück";
        s.Finish = "&Fertig stellen";
        s.Exit = "&Beenden";
        s.Collapse = "&Reduzieren";
        s.Expand = "&Erweitern";
        s.Cut = "&Ausschneiden";
        s.Copy = "&Kopieren";
        s.Paste = "E&infügen";
        s.SelectAll = "&Alles auswählen";
        s.ClearClipboard = "Zwischenablage &löschen";
        s.YesToAll = "Ja für &alle";
        s.NoToAll = "Nein für a&lle";
        s.OkToAll = "OK für &alle";
        s.Reset = "Zur&ücksetzen";
        s.SystemInformation = "&Systeminformationen";
        s.CurrentTheme = "Aktuelles Design";
        s.DoNotShowAgain = "&Diese Meldung nicht mehr anzeigen";
    }
    
    private static void ApplyRibbon()
    {
        var s = KryptonManager.Strings.RibbonStrings;
        
        s.AppButtonText = "Datei";
        s.AppButtonKeyTip = "D";
        s.CustomizeQuickAccessToolbar = "Symbolleiste für den Schnellzugriff anpassen";
        s.Minimize = "&Menüband minimieren";
        s.MoreColors = "&Weitere Farben...";
        s.NoColor = "&Keine Farbe";
        s.RecentDocuments = "Zuletzt verwendete Dokumente";
        s.RecentColors = "Zuletzt verwendete Farben";
        s.ShowAboveRibbon = "&Über dem Menüband anzeigen";
        s.ShowBelowRibbon = "&Unter dem Menüband anzeigen";
        s.ShowQATAboveRibbon = "Symbolleiste für Schnellzugriff über dem Menüband anzeigen";
        s.ShowQATBelowRibbon = "Symbolleiste für Schnellzugriff unter dem Menüband anzeigen";
        s.StandardColors = "Standardfarben";
        s.ThemeColors = "Designfarben";
    }
    
    private static void ApplyAboutBox()
    {
        var s = KryptonManager.Strings.AboutBoxStrings;
        
        s.About = "Über";
        s.Title = "Titel";
        s.Copyright = "Copyright";
        s.Description = "Beschreibung";
        s.Company = "Firma";
        s.Product = "Produkt";
        s.Trademark = "Marke";
        s.Version = "Version";
        s.BuildDate = "Erstellungsdatum";
        s.ImageRuntimeVersion = "Laufzeitversion";
        s.LoadedFromGlobalAssemblyCache = "Aus GAC geladen";
    }
    
    private static void ApplyToastNotification()
    {
        var s = KryptonManager.Strings.ToastNotificationStrings;
        
        s.Dismiss = "&Schließen";
        s.DoNotShowAgain = "&Nicht erneut anzeigen";
    }
}
```

### Japanese (日本語) - Complete Implementation

```csharp
public class JapaneseLocalization
{
    public static void Apply()
    {
        ApplyGeneral();
        ApplyCustom();
        ApplyRibbon();
        ApplyAboutBox();
        ApplyToastNotification();
    }
    
    private static void ApplyGeneral()
    {
        var s = KryptonManager.Strings.GeneralStrings;
        
        // Note: Japanese typically doesn't use accelerator keys
        s.OK = "OK";
        s.Cancel = "キャンセル";
        s.Yes = "はい";
        s.No = "いいえ";
        s.Abort = "中止";
        s.Retry = "再試行";
        s.Ignore = "無視";
        s.Close = "閉じる";
        s.Help = "ヘルプ";
        s.Continue = "続行";
        s.TryAgain = "再試行";
        s.Today = "今日";
    }
    
    private static void ApplyCustom()
    {
        var s = KryptonManager.Strings.CustomStrings;
        
        s.Apply = "適用";
        s.Back = "戻る";
        s.Next = "次へ";
        s.Previous = "前へ";
        s.Finish = "完了";
        s.Exit = "終了";
        s.Collapse = "折りたたむ";
        s.Expand = "展開";
        s.Cut = "切り取り";
        s.Copy = "コピー";
        s.Paste = "貼り付け";
        s.SelectAll = "すべて選択";
        s.ClearClipboard = "クリップボードをクリア";
        s.YesToAll = "すべてはい";
        s.NoToAll = "すべていいえ";
        s.OkToAll = "すべてOK";
        s.Reset = "リセット";
        s.SystemInformation = "システム情報";
        s.CurrentTheme = "現在のテーマ";
        s.DoNotShowAgain = "今後表示しない";
    }
    
    private static void ApplyRibbon()
    {
        var s = KryptonManager.Strings.RibbonStrings;
        
        s.AppButtonText = "ファイル";
        s.AppButtonKeyTip = "F";
        s.CustomizeQuickAccessToolbar = "クイックアクセスツールバーのカスタマイズ";
        s.Minimize = "リボンを最小化";
        s.MoreColors = "その他の色...";
        s.NoColor = "色なし";
        s.RecentDocuments = "最近使用したドキュメント";
        s.RecentColors = "最近使用した色";
        s.ShowAboveRibbon = "リボンの上に表示";
        s.ShowBelowRibbon = "リボンの下に表示";
        s.ShowQATAboveRibbon = "クイックアクセスツールバーをリボンの上に表示";
        s.ShowQATBelowRibbon = "クイックアクセスツールバーをリボンの下に表示";
        s.StandardColors = "標準の色";
        s.ThemeColors = "テーマの色";
    }
    
    private static void ApplyAboutBox()
    {
        var s = KryptonManager.Strings.AboutBoxStrings;
        
        s.About = "バージョン情報";
        s.Title = "タイトル";
        s.Copyright = "著作権";
        s.Description = "説明";
        s.Company = "会社";
        s.Product = "製品";
        s.Trademark = "商標";
        s.Version = "バージョン";
        s.BuildDate = "ビルド日";
        s.ImageRuntimeVersion = "イメージランタイムバージョン";
        s.LoadedFromGlobalAssemblyCache = "GACから読み込み";
    }
    
    private static void ApplyToastNotification()
    {
        var s = KryptonManager.Strings.ToastNotificationStrings;
        
        s.Dismiss = "閉じる";
        s.DoNotShowAgain = "今後表示しない";
    }
}
```

---

## Resource File Integration

### Creating Resource-Based Localization

#### Step 1: Create Resource Files

Create `.resx` files for each language in your project:

```
Resources/
    Strings.resx         (default/English)
    Strings.es.resx      (Spanish)
    Strings.fr.resx      (French)
    Strings.de.resx      (German)
    Strings.ja.resx      (Japanese)
```

#### Step 2: Resource File Structure

**Strings.resx** (English - Default):
```xml
<?xml version="1.0" encoding="utf-8"?>
<root>
  <data name="OK" xml:space="preserve">
    <value>O&amp;K</value>
  </data>
  <data name="Cancel" xml:space="preserve">
    <value>Cance&amp;l</value>
  </data>
  <data name="Yes" xml:space="preserve">
    <value>&amp;Yes</value>
  </data>
  <!-- More strings -->
</root>
```

**Strings.es.resx** (Spanish):
```xml
<?xml version="1.0" encoding="utf-8"?>
<root>
  <data name="OK" xml:space="preserve">
    <value>&amp;Aceptar</value>
  </data>
  <data name="Cancel" xml:space="preserve">
    <value>&amp;Cancelar</value>
  </data>
  <data name="Yes" xml:space="preserve">
    <value>&amp;Sí</value>
  </data>
  <!-- More strings -->
</root>
```

#### Step 3: Resource Manager Implementation

```csharp
using System.Resources;
using System.Globalization;

public class ResourceBasedLocalization
{
    private static ResourceManager _resourceManager;
    private static CultureInfo _currentCulture;
    
    static ResourceBasedLocalization()
    {
        // Initialize resource manager
        _resourceManager = new ResourceManager(
            "YourNamespace.Resources.Strings",
            typeof(ResourceBasedLocalization).Assembly
        );
    }
    
    public static void ApplyLocalization(CultureInfo culture)
    {
        _currentCulture = culture;
        
        ApplyGeneralStrings();
        ApplyCustomStrings();
        ApplyRibbonStrings();
        ApplyAboutBoxStrings();
        ApplyToastNotificationStrings();
    }
    
    private static void ApplyGeneralStrings()
    {
        var s = KryptonManager.Strings.GeneralStrings;
        
        s.OK = GetString("OK");
        s.Cancel = GetString("Cancel");
        s.Yes = GetString("Yes");
        s.No = GetString("No");
        s.Abort = GetString("Abort");
        s.Retry = GetString("Retry");
        s.Ignore = GetString("Ignore");
        s.Close = GetString("Close");
        s.Help = GetString("Help");
        s.Continue = GetString("Continue");
        s.TryAgain = GetString("TryAgain");
        s.Today = GetString("Today");
    }
    
    private static void ApplyCustomStrings()
    {
        var s = KryptonManager.Strings.CustomStrings;
        
        s.Apply = GetString("Apply");
        s.Back = GetString("Back");
        s.Next = GetString("Next");
        s.Previous = GetString("Previous");
        s.Finish = GetString("Finish");
        s.Exit = GetString("Exit");
        s.Collapse = GetString("Collapse");
        s.Expand = GetString("Expand");
        s.Cut = GetString("Cut");
        s.Copy = GetString("Copy");
        s.Paste = GetString("Paste");
        s.SelectAll = GetString("SelectAll");
        s.ClearClipboard = GetString("ClearClipboard");
        s.YesToAll = GetString("YesToAll");
        s.NoToAll = GetString("NoToAll");
        s.OkToAll = GetString("OkToAll");
        s.Reset = GetString("Reset");
        s.SystemInformation = GetString("SystemInformation");
        s.CurrentTheme = GetString("CurrentTheme");
        s.DoNotShowAgain = GetString("DoNotShowAgain");
    }
    
    private static void ApplyRibbonStrings()
    {
        var s = KryptonManager.Strings.RibbonStrings;
        
        s.AppButtonText = GetString("Ribbon_AppButtonText");
        s.AppButtonKeyTip = GetString("Ribbon_AppButtonKeyTip");
        s.CustomizeQuickAccessToolbar = GetString("Ribbon_CustomizeQAT");
        s.Minimize = GetString("Ribbon_Minimize");
        s.MoreColors = GetString("Ribbon_MoreColors");
        s.NoColor = GetString("Ribbon_NoColor");
        s.RecentDocuments = GetString("Ribbon_RecentDocuments");
        s.RecentColors = GetString("Ribbon_RecentColors");
        s.ShowAboveRibbon = GetString("Ribbon_ShowAbove");
        s.ShowBelowRibbon = GetString("Ribbon_ShowBelow");
        s.ShowQATAboveRibbon = GetString("Ribbon_QATAbove");
        s.ShowQATBelowRibbon = GetString("Ribbon_QATBelow");
        s.StandardColors = GetString("Ribbon_StandardColors");
        s.ThemeColors = GetString("Ribbon_ThemeColors");
    }
    
    private static void ApplyAboutBoxStrings()
    {
        var s = KryptonManager.Strings.AboutBoxStrings;
        
        s.About = GetString("AboutBox_About");
        s.Title = GetString("AboutBox_Title");
        s.Copyright = GetString("AboutBox_Copyright");
        s.Description = GetString("AboutBox_Description");
        s.Company = GetString("AboutBox_Company");
        s.Product = GetString("AboutBox_Product");
        s.Trademark = GetString("AboutBox_Trademark");
        s.Version = GetString("AboutBox_Version");
        s.BuildDate = GetString("AboutBox_BuildDate");
        s.ImageRuntimeVersion = GetString("AboutBox_RuntimeVersion");
        s.LoadedFromGlobalAssemblyCache = GetString("AboutBox_GAC");
    }
    
    private static void ApplyToastNotificationStrings()
    {
        var s = KryptonManager.Strings.ToastNotificationStrings;
        
        s.Dismiss = GetString("Toast_Dismiss");
        s.DoNotShowAgain = GetString("Toast_DoNotShowAgain");
    }
    
    private static string GetString(string key)
    {
        try
        {
            string value = _resourceManager.GetString(key, _currentCulture);
            
            if (string.IsNullOrEmpty(value))
            {
                // Fallback to invariant culture (English)
                value = _resourceManager.GetString(key, CultureInfo.InvariantCulture);
            }
            
            return value ?? key; // Return key if still not found
        }
        catch (Exception ex)
        {
            // Log error
            System.Diagnostics.Debug.WriteLine(
                $"Error loading resource '{key}': {ex.Message}"
            );
            return key;
        }
    }
    
    // Helper method to get all supported cultures
    public static CultureInfo[] GetSupportedCultures()
    {
        return new[]
        {
            new CultureInfo("en"),    // English
            new CultureInfo("es"),    // Spanish
            new CultureInfo("fr"),    // French
            new CultureInfo("de"),    // German
            new CultureInfo("ja")     // Japanese
        };
    }
}
```

#### Step 4: Application Integration

```csharp
// In Program.cs or App.xaml.cs
static class Program
{
    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        
        // Load user's preferred language or system default
        CultureInfo userCulture = LoadUserPreferredCulture();
        
        // Apply localization
        ResourceBasedLocalization.ApplyLocalization(userCulture);
        
        // Set thread culture for dates, numbers, etc.
        Thread.CurrentThread.CurrentCulture = userCulture;
        Thread.CurrentThread.CurrentUICulture = userCulture;
        
        Application.Run(new MainForm());
    }
    
    private static CultureInfo LoadUserPreferredCulture()
    {
        // Try to load from user settings
        string savedLanguage = Properties.Settings.Default.Language;
        
        if (!string.IsNullOrEmpty(savedLanguage))
        {
            try
            {
                return new CultureInfo(savedLanguage);
            }
            catch
            {
                // Invalid culture, fall through to default
            }
        }
        
        // Use system default
        return CultureInfo.CurrentUICulture;
    }
}
```

---

## Dynamic Language Switching

### Complete Language Switcher Implementation

```csharp
using System;
using System.Globalization;
using System.Windows.Forms;

public class LanguageSwitcher
{
    #region Events
    
    /// <summary>
    /// Raised when the language is changed
    /// </summary>
    public event EventHandler<LanguageChangedEventArgs> LanguageChanged;
    
    /// <summary>
    /// Raised before the language is changed (can be cancelled)
    /// </summary>
    public event EventHandler<LanguageChangingEventArgs> LanguageChanging;
    
    #endregion
    
    #region Properties
    
    public CultureInfo CurrentCulture { get; private set; }
    
    public CultureInfo[] SupportedCultures { get; }
    
    #endregion
    
    #region Constructor
    
    public LanguageSwitcher()
    {
        SupportedCultures = new[]
        {
            new CultureInfo("en"),
            new CultureInfo("es"),
            new CultureInfo("fr"),
            new CultureInfo("de"),
            new CultureInfo("ja")
        };
        
        CurrentCulture = CultureInfo.CurrentUICulture;
    }
    
    #endregion
    
    #region Public Methods
    
    public bool SetLanguage(string cultureName)
    {
        try
        {
            CultureInfo newCulture = new CultureInfo(cultureName);
            return SetLanguage(newCulture);
        }
        catch (CultureNotFoundException ex)
        {
            System.Diagnostics.Debug.WriteLine(
                $"Culture '{cultureName}' not found: {ex.Message}"
            );
            return false;
        }
    }
    
    public bool SetLanguage(CultureInfo culture)
    {
        if (culture == null)
            throw new ArgumentNullException(nameof(culture));
        
        // Check if language is already set
        if (CurrentCulture.Equals(culture))
            return true;
        
        // Raise LanguageChanging event
        var changingArgs = new LanguageChangingEventArgs(CurrentCulture, culture);
        OnLanguageChanging(changingArgs);
        
        if (changingArgs.Cancel)
            return false;
        
        // Store old culture
        CultureInfo oldCulture = CurrentCulture;
        
        try
        {
            // Apply new language
            ApplyLanguage(culture);
            
            // Update current culture
            CurrentCulture = culture;
            
            // Update thread cultures
            System.Threading.Thread.CurrentThread.CurrentCulture = culture;
            System.Threading.Thread.CurrentThread.CurrentUICulture = culture;
            
            // Raise LanguageChanged event
            OnLanguageChanged(new LanguageChangedEventArgs(oldCulture, culture));
            
            return true;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine(
                $"Error changing language: {ex.Message}"
            );
            return false;
        }
    }
    
    public void ResetToDefault()
    {
        KryptonManager.Strings.Reset();
        CurrentCulture = new CultureInfo("en");
    }
    
    #endregion
    
    #region Private Methods
    
    private void ApplyLanguage(CultureInfo culture)
    {
        switch (culture.TwoLetterISOLanguageName)
        {
            case "es":
                SpanishLocalization.Apply();
                break;
            case "fr":
                FrenchLocalization.Apply();
                break;
            case "de":
                GermanLocalization.Apply();
                break;
            case "ja":
                JapaneseLocalization.Apply();
                break;
            default:
                // English or unsupported - reset to defaults
                KryptonManager.Strings.Reset();
                break;
        }
    }
    
    protected virtual void OnLanguageChanging(LanguageChangingEventArgs e)
    {
        LanguageChanging?.Invoke(this, e);
    }
    
    protected virtual void OnLanguageChanged(LanguageChangedEventArgs e)
    {
        LanguageChanged?.Invoke(this, e);
    }
    
    #endregion
}

#region Event Args Classes

public class LanguageChangingEventArgs : EventArgs
{
    public CultureInfo OldCulture { get; }
    public CultureInfo NewCulture { get; }
    public bool Cancel { get; set; }
    
    public LanguageChangingEventArgs(CultureInfo oldCulture, CultureInfo newCulture)
    {
        OldCulture = oldCulture;
        NewCulture = newCulture;
        Cancel = false;
    }
}

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
```

### UI Integration for Language Switching

```csharp
public partial class SettingsForm : KryptonForm
{
    private LanguageSwitcher _languageSwitcher;
    
    public SettingsForm()
    {
        InitializeComponent();
        
        _languageSwitcher = new LanguageSwitcher();
        _languageSwitcher.LanguageChanging += OnLanguageChanging;
        _languageSwitcher.LanguageChanged += OnLanguageChanged;
        
        InitializeLanguageComboBox();
    }
    
    private void InitializeLanguageComboBox()
    {
        // Clear existing items
        languageComboBox.Items.Clear();
        
        // Add supported languages
        foreach (var culture in _languageSwitcher.SupportedCultures)
        {
            languageComboBox.Items.Add(new LanguageItem(culture));
        }
        
        // Select current language
        for (int i = 0; i < languageComboBox.Items.Count; i++)
        {
            var item = (LanguageItem)languageComboBox.Items[i];
            if (item.Culture.Equals(_languageSwitcher.CurrentCulture))
            {
                languageComboBox.SelectedIndex = i;
                break;
            }
        }
    }
    
    private void languageComboBox_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (languageComboBox.SelectedItem is LanguageItem selectedItem)
        {
            _languageSwitcher.SetLanguage(selectedItem.Culture);
        }
    }
    
    private void OnLanguageChanging(object sender, LanguageChangingEventArgs e)
    {
        // Ask for confirmation if user has unsaved changes
        if (HasUnsavedChanges())
        {
            var result = KryptonMessageBox.Show(
                "Changing the language will require reloading the form. Continue?",
                "Confirm Language Change",
                KryptonMessageBoxButtons.YesNo,
                KryptonMessageBoxIcon.Question
            );
            
            e.Cancel = (result != DialogResult.Yes);
        }
    }
    
    private void OnLanguageChanged(object sender, LanguageChangedEventArgs e)
    {
        // Save language preference
        Properties.Settings.Default.Language = e.NewCulture.Name;
        Properties.Settings.Default.Save();
        
        // Reload form to reflect new language
        ReloadForm();
    }
    
    private bool HasUnsavedChanges()
    {
        // Check if form has unsaved changes
        return false; // Implement your logic
    }
    
    private void ReloadForm()
    {
        // Close and reopen the form
        var newForm = new SettingsForm();
        newForm.Show();
        this.Close();
    }
    
    // Helper class for combo box items
    private class LanguageItem
    {
        public CultureInfo Culture { get; }
        
        public LanguageItem(CultureInfo culture)
        {
            Culture = culture;
        }
        
        public override string ToString()
        {
            // Display native language name
            return Culture.NativeName;
        }
    }
}
```

---

## Custom String Categories

### Creating Your Own String Category

If the built-in categories don't cover your specific needs, you can create custom string categories:

```csharp
using System.ComponentModel;
using Krypton.Toolkit;

/// <summary>
/// Custom string category for a business application
/// </summary>
[TypeConverter(typeof(ExpandableObjectConverter))]
public class BusinessApplicationStrings : GlobalId
{
    #region Static Fields (Defaults)
    
    private const string DEFAULT_CUSTOMER = "Customer";
    private const string DEFAULT_ORDER = "Order";
    private const string DEFAULT_INVOICE = "Invoice";
    private const string DEFAULT_PRODUCT = "Product";
    private const string DEFAULT_PRICE = "Price";
    private const string DEFAULT_QUANTITY = "Quantity";
    private const string DEFAULT_TOTAL = "Total";
    private const string DEFAULT_TAX = "Tax";
    private const string DEFAULT_DISCOUNT = "Discount";
    private const string DEFAULT_SHIPPING = "Shipping";
    
    #endregion
    
    #region Constructor
    
    public BusinessApplicationStrings()
    {
        Reset();
    }
    
    #endregion
    
    #region Public Properties
    
    [Localizable(true)]
    [Category("Business Terms")]
    [Description("Label for customer")]
    [DefaultValue(DEFAULT_CUSTOMER)]
    public string Customer { get; set; }
    
    [Localizable(true)]
    [Category("Business Terms")]
    [Description("Label for order")]
    [DefaultValue(DEFAULT_ORDER)]
    public string Order { get; set; }
    
    [Localizable(true)]
    [Category("Business Terms")]
    [Description("Label for invoice")]
    [DefaultValue(DEFAULT_INVOICE)]
    public string Invoice { get; set; }
    
    [Localizable(true)]
    [Category("Business Terms")]
    [Description("Label for product")]
    [DefaultValue(DEFAULT_PRODUCT)]
    public string Product { get; set; }
    
    [Localizable(true)]
    [Category("Financial Terms")]
    [Description("Label for price")]
    [DefaultValue(DEFAULT_PRICE)]
    public string Price { get; set; }
    
    [Localizable(true)]
    [Category("Financial Terms")]
    [Description("Label for quantity")]
    [DefaultValue(DEFAULT_QUANTITY)]
    public string Quantity { get; set; }
    
    [Localizable(true)]
    [Category("Financial Terms")]
    [Description("Label for total")]
    [DefaultValue(DEFAULT_TOTAL)]
    public string Total { get; set; }
    
    [Localizable(true)]
    [Category("Financial Terms")]
    [Description("Label for tax")]
    [DefaultValue(DEFAULT_TAX)]
    public string Tax { get; set; }
    
    [Localizable(true)]
    [Category("Financial Terms")]
    [Description("Label for discount")]
    [DefaultValue(DEFAULT_DISCOUNT)]
    public string Discount { get; set; }
    
    [Localizable(true)]
    [Category("Financial Terms")]
    [Description("Label for shipping")]
    [DefaultValue(DEFAULT_SHIPPING)]
    public string Shipping { get; set; }
    
    #endregion
    
    #region Implementation
    
    [Browsable(false)]
    public bool IsDefault =>
        Customer.Equals(DEFAULT_CUSTOMER) &&
        Order.Equals(DEFAULT_ORDER) &&
        Invoice.Equals(DEFAULT_INVOICE) &&
        Product.Equals(DEFAULT_PRODUCT) &&
        Price.Equals(DEFAULT_PRICE) &&
        Quantity.Equals(DEFAULT_QUANTITY) &&
        Total.Equals(DEFAULT_TOTAL) &&
        Tax.Equals(DEFAULT_TAX) &&
        Discount.Equals(DEFAULT_DISCOUNT) &&
        Shipping.Equals(DEFAULT_SHIPPING);
    
    public void Reset()
    {
        Customer = DEFAULT_CUSTOMER;
        Order = DEFAULT_ORDER;
        Invoice = DEFAULT_INVOICE;
        Product = DEFAULT_PRODUCT;
        Price = DEFAULT_PRICE;
        Quantity = DEFAULT_QUANTITY;
        Total = DEFAULT_TOTAL;
        Tax = DEFAULT_TAX;
        Discount = DEFAULT_DISCOUNT;
        Shipping = DEFAULT_SHIPPING;
    }
    
    public override string ToString() => !IsDefault ? "Modified" : string.Empty;
    
    #endregion
}

/// <summary>
/// Global access point for business application strings
/// </summary>
public static class BusinessStrings
{
    public static BusinessApplicationStrings Instance { get; } 
        = new BusinessApplicationStrings();
}
```

### Using Custom String Categories

```csharp
// Spanish localization for business strings
public class SpanishBusinessLocalization
{
    public static void Apply()
    {
        var s = BusinessStrings.Instance;
        
        s.Customer = "Cliente";
        s.Order = "Pedido";
        s.Invoice = "Factura";
        s.Product = "Producto";
        s.Price = "Precio";
        s.Quantity = "Cantidad";
        s.Total = "Total";
        s.Tax = "Impuesto";
        s.Discount = "Descuento";
        s.Shipping = "Envío";
    }
}

// Usage in application
public class OrderForm : KryptonForm
{
    public OrderForm()
    {
        InitializeComponent();
        
        // Use business strings
        customerLabel.Text = BusinessStrings.Instance.Customer + ":";
        orderLabel.Text = BusinessStrings.Instance.Order + ":";
        totalLabel.Text = BusinessStrings.Instance.Total + ":";
    }
}
```

---

## Localization Testing Framework

### Automated Testing for Localization

```csharp
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Globalization;
using Krypton.Toolkit;

[TestClass]
public class LocalizationTests
{
    [TestInitialize]
    public void Setup()
    {
        // Reset to English before each test
        KryptonManager.Strings.Reset();
    }
    
    [TestCleanup]
    public void Cleanup()
    {
        // Reset after each test
        KryptonManager.Strings.Reset();
    }
    
    #region Spanish Localization Tests
    
    [TestMethod]
    public void TestSpanishGeneralStrings()
    {
        // Arrange
        SpanishLocalization.Apply();
        var strings = KryptonManager.Strings.GeneralStrings;
        
        // Assert - All strings should be in Spanish
        Assert.AreEqual("&Aceptar", strings.OK);
        Assert.AreEqual("&Cancelar", strings.Cancel);
        Assert.AreEqual("&Sí", strings.Yes);
        Assert.AreEqual("&No", strings.No);
        Assert.AreEqual("Abo&rtar", strings.Abort);
        Assert.AreEqual("Rei&ntentar", strings.Retry);
        Assert.AreEqual("&Ignorar", strings.Ignore);
        Assert.AreEqual("C&errar", strings.Close);
        Assert.AreEqual("A&yuda", strings.Help);
    }
    
    [TestMethod]
    public void TestSpanishCustomStrings()
    {
        // Arrange
        SpanishLocalization.Apply();
        var strings = KryptonManager.Strings.CustomStrings;
        
        // Assert
        Assert.AreEqual("A&plicar", strings.Apply);
        Assert.AreEqual("&Atrás", strings.Back);
        Assert.AreEqual("&Siguiente", strings.Next);
        Assert.AreEqual("A&nterior", strings.Previous);
        Assert.AreEqual("Cor&tar", strings.Cut);
        Assert.AreEqual("&Copiar", strings.Copy);
        Assert.AreEqual("&Pegar", strings.Paste);
    }
    
    #endregion
    
    #region French Localization Tests
    
    [TestMethod]
    public void TestFrenchGeneralStrings()
    {
        // Arrange
        FrenchLocalization.Apply();
        var strings = KryptonManager.Strings.GeneralStrings;
        
        // Assert
        Assert.AreEqual("&OK", strings.OK);
        Assert.AreEqual("&Annuler", strings.Cancel);
        Assert.AreEqual("&Oui", strings.Yes);
        Assert.AreEqual("&Non", strings.No);
    }
    
    #endregion
    
    #region Accelerator Key Tests
    
    [TestMethod]
    public void TestAcceleratorKeysAreUnique_English()
    {
        // Arrange
        KryptonManager.Strings.Reset(); // English defaults
        var strings = KryptonManager.Strings.GeneralStrings;
        
        // Act - Extract accelerator keys
        var keys = new Dictionary<char, string>();
        AddAcceleratorKey(keys, strings.OK, nameof(strings.OK));
        AddAcceleratorKey(keys, strings.Cancel, nameof(strings.Cancel));
        AddAcceleratorKey(keys, strings.Yes, nameof(strings.Yes));
        AddAcceleratorKey(keys, strings.No, nameof(strings.No));
        AddAcceleratorKey(keys, strings.Abort, nameof(strings.Abort));
        AddAcceleratorKey(keys, strings.Retry, nameof(strings.Retry));
        AddAcceleratorKey(keys, strings.Ignore, nameof(strings.Ignore));
        AddAcceleratorKey(keys, strings.Close, nameof(strings.Close));
        
        // Assert - All accelerators should be unique
        // (Test passes if no exceptions thrown in AddAcceleratorKey)
    }
    
    [TestMethod]
    public void TestAcceleratorKeysAreUnique_Spanish()
    {
        // Arrange
        SpanishLocalization.Apply();
        var strings = KryptonManager.Strings.GeneralStrings;
        
        // Act & Assert
        var keys = new Dictionary<char, string>();
        AddAcceleratorKey(keys, strings.OK, nameof(strings.OK));
        AddAcceleratorKey(keys, strings.Cancel, nameof(strings.Cancel));
        AddAcceleratorKey(keys, strings.Yes, nameof(strings.Yes));
        AddAcceleratorKey(keys, strings.No, nameof(strings.No));
    }
    
    private void AddAcceleratorKey(Dictionary<char, string> keys, 
                                   string text, string propertyName)
    {
        int ampIndex = text.IndexOf('&');
        if (ampIndex >= 0 && ampIndex < text.Length - 1)
        {
            char key = char.ToUpper(text[ampIndex + 1]);
            
            if (keys.ContainsKey(key))
            {
                Assert.Fail($"Duplicate accelerator key '{key}' in {propertyName} " +
                          $"(already used in {keys[key]})");
            }
            
            keys[key] = propertyName;
        }
    }
    
    #endregion
    
    #region Reset Tests
    
    [TestMethod]
    public void TestReset_RestoresDefaults()
    {
        // Arrange
        SpanishLocalization.Apply();
        
        // Act
        KryptonManager.Strings.Reset();
        
        // Assert - Should be back to English
        var strings = KryptonManager.Strings.GeneralStrings;
        Assert.AreEqual("O&K", strings.OK);
        Assert.AreEqual("Cance&l", strings.Cancel);
        Assert.AreEqual("&Yes", strings.Yes);
        Assert.AreEqual("N&o", strings.No);
    }
    
    [TestMethod]
    public void TestIsDefault_ReturnsTrueForDefaultStrings()
    {
        // Arrange - Fresh reset
        KryptonManager.Strings.Reset();
        
        // Assert
        Assert.IsTrue(KryptonManager.Strings.IsDefault);
        Assert.IsTrue(KryptonManager.Strings.GeneralStrings.IsDefault);
        Assert.IsTrue(KryptonManager.Strings.CustomStrings.IsDefault);
    }
    
    [TestMethod]
    public void TestIsDefault_ReturnsFalseForModifiedStrings()
    {
        // Arrange
        KryptonManager.Strings.GeneralStrings.OK = "Modified";
        
        // Assert
        Assert.IsFalse(KryptonManager.Strings.IsDefault);
        Assert.IsFalse(KryptonManager.Strings.GeneralStrings.IsDefault);
    }
    
    #endregion
    
    #region Null/Empty String Tests
    
    [TestMethod]
    public void TestNoNullStrings_AfterSpanishLocalization()
    {
        // Arrange
        SpanishLocalization.Apply();
        
        // Assert
        AssertNoNullOrEmptyStrings(KryptonManager.Strings.GeneralStrings);
        AssertNoNullOrEmptyStrings(KryptonManager.Strings.CustomStrings);
    }
    
    private void AssertNoNullOrEmptyStrings(object stringCategory)
    {
        var type = stringCategory.GetType();
        var properties = type.GetProperties()
            .Where(p => p.PropertyType == typeof(string) &&
                       p.CanRead &&
                       p.GetCustomAttributes(typeof(LocalizableAttribute), false).Any());
        
        foreach (var prop in properties)
        {
            var value = (string)prop.GetValue(stringCategory);
            Assert.IsFalse(string.IsNullOrWhiteSpace(value),
                $"Property {prop.Name} is null or empty");
        }
    }
    
    #endregion
    
    #region Completeness Tests
    
    [TestMethod]
    public void TestAllLanguages_HaveCompleteTranslations()
    {
        var languages = new (string Name, Action Apply)[]
        {
            ("Spanish", SpanishLocalization.Apply),
            ("French", FrenchLocalization.Apply),
            ("German", GermanLocalization.Apply),
            ("Japanese", JapaneseLocalization.Apply)
        };
        
        foreach (var (name, apply) in languages)
        {
            // Reset and apply language
            KryptonManager.Strings.Reset();
            apply();
            
            // Verify no English defaults remain
            AssertNoEnglishDefaults(name);
            
            // Verify no null/empty strings
            AssertNoNullOrEmptyStrings(KryptonManager.Strings.GeneralStrings);
        }
    }
    
    private void AssertNoEnglishDefaults(string languageName)
    {
        var strings = KryptonManager.Strings.GeneralStrings;
        
        // These should not be the English defaults
        Assert.AreNotEqual("O&K", strings.OK, 
            $"{languageName}: OK not translated");
        Assert.AreNotEqual("Cance&l", strings.Cancel, 
            $"{languageName}: Cancel not translated");
        Assert.AreNotEqual("&Yes", strings.Yes, 
            $"{languageName}: Yes not translated");
        Assert.AreNotEqual("N&o", strings.No, 
            $"{languageName}: No not translated");
    }
    
    #endregion
}
```

---

## Performance Optimization

### Lazy Loading for Large Applications

```csharp
public class OptimizedLocalizationManager
{
    private bool _generalStringsLoaded = false;
    private bool _customStringsLoaded = false;
    private bool _ribbonStringsLoaded = false;
    
    public void ApplyLocalization(CultureInfo culture, 
                                 LocalizationCategory categories)
    {
        if (categories.HasFlag(LocalizationCategory.General))
        {
            if (!_generalStringsLoaded)
            {
                ApplyGeneralStrings(culture);
                _generalStringsLoaded = true;
            }
        }
        
        if (categories.HasFlag(LocalizationCategory.Custom))
        {
            if (!_customStringsLoaded)
            {
                ApplyCustomStrings(culture);
                _customStringsLoaded = true;
            }
        }
        
        if (categories.HasFlag(LocalizationCategory.Ribbon))
        {
            if (!_ribbonStringsLoaded)
            {
                ApplyRibbonStrings(culture);
                _ribbonStringsLoaded = true;
            }
        }
    }
    
    // Implementation methods...
}

[Flags]
public enum LocalizationCategory
{
    None = 0,
    General = 1,
    Custom = 2,
    Ribbon = 4,
    AboutBox = 8,
    ToastNotification = 16,
    All = General | Custom | Ribbon | AboutBox | ToastNotification
}
```

### Caching Translated Strings

```csharp
public class CachedLocalizationManager
{
    private readonly Dictionary<CultureInfo, CachedStrings> _cache 
        = new Dictionary<CultureInfo, CachedStrings>();
    
    public void ApplyLocalization(CultureInfo culture)
    {
        if (_cache.TryGetValue(culture, out CachedStrings cached))
        {
            // Use cached strings
            ApplyCachedStrings(cached);
        }
        else
        {
            // Load and cache strings
            var newCache = LoadAndCacheStrings(culture);
            _cache[culture] = newCache;
            ApplyCachedStrings(newCache);
        }
    }
    
    private CachedStrings LoadAndCacheStrings(CultureInfo culture)
    {
        // Load from resources or other source
        return new CachedStrings
        {
            // ... populate from resources
        };
    }
    
    private void ApplyCachedStrings(CachedStrings cached)
    {
        var general = KryptonManager.Strings.GeneralStrings;
        general.OK = cached.OK;
        general.Cancel = cached.Cancel;
        // ... apply all cached strings
    }
    
    private class CachedStrings
    {
        public string OK { get; set; }
        public string Cancel { get; set; }
        // ... all string properties
    }
}
```

---

## Deployment Strategies

### Satellite Assembly Deployment

For large applications, consider using satellite assemblies for each language:

```
YourApp.exe
YourApp.resources.dll (English resources)
es/
    YourApp.resources.dll (Spanish resources)
fr/
    YourApp.resources.dll (French resources)
de/
    YourApp.resources.dll (German resources)
ja/
    YourApp.resources.dll (Japanese resources)
```

The .NET runtime automatically loads the appropriate satellite assembly based on the current UI culture.

### Configuration File Approach

Create language configuration files (JSON/XML):

**localization.es.json**:
```json
{
  "General": {
    "OK": "&Aceptar",
    "Cancel": "&Cancelar",
    "Yes": "&Sí",
    "No": "&No"
  },
  "Custom": {
    "Apply": "A&plicar",
    "Copy": "&Copiar",
    "Paste": "&Pegar"
  }
}
```

Load and apply at runtime:
```csharp
public class JsonLocalizationLoader
{
    public void LoadFromFile(string filePath)
    {
        string json = File.ReadAllText(filePath);
        var data = JsonSerializer.Deserialize<LocalizationData>(json);
        
        ApplyLocalization(data);
    }
}
```

---

## See Also

- [Localization and String Management Guide](LocalizationGuide.md)
- [KryptonManager.Strings API Reference](../Components/KryptonManagerStringsAPIReference.md)
- [ExceptionHandler API Documentation](ExceptionHandlerAPIDocumentation.md)

