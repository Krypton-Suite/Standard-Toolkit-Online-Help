# KryptonOAuth2Login

## Overview

`KryptonOAuth2Login` displays a modal OAuth2 authorization dialog using WebView2 inside a Krypton-styled form. The API mirrors `KryptonMessageBox` patterns (`ShowAsync` overloads).

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Requires:** WebView2 runtime (`WEBVIEW2_AVAILABLE` build)

Related types: `OAuth2PkceClient`, `OAuth2ProviderPresets`, `OAuth2AuthorizationResult`.

## Basic usage

```csharp
using Krypton.Toolkit.Utilities;

OAuth2AuthorizationResult result = await KryptonOAuth2Login.ShowAsync(
    authorizationUrl,
    redirectUri,
  title: "Sign in with Contoso",
    owner: this);

if (result.Success)
{
    // Exchange result.Code using your token endpoint
}
else
{
    KryptonMessageBox.Show(result.ErrorMessage ?? "Sign-in cancelled");
}
```

## PKCE client

For full authorization-code + PKCE flow:

```csharp
var client = new OAuth2PkceClient(providerConfig);
string url = client.BuildAuthorizationUrl(state, codeChallenge);
OAuth2AuthorizationResult auth = await KryptonOAuth2Login.ShowAsync(url, redirectUri);
TokenResponse tokens = await client.ExchangeCodeAsync(auth.Code!, codeVerifier);
```

Use `OAuth2ProviderPresets` for common provider configuration templates where available.

## See also

- [KryptonWebView2](KryptonWebView2.md)
- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
