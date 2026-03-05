# OAuth2 with PKCE

**Namespace:** `Krypton.Utilities`  
**Assembly:** `Krypton.Utilities`

This document provides comprehensive developer documentation for the OAuth2 with PKCE (Proof Key for Code Exchange) authentication feature in Krypton Utilities.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [API Reference](#api-reference)
5. [Provider Presets](#provider-presets)
6. [Extensibility](#extensibility)
7. [Advanced Usage](#advanced-usage)
8. [Error Handling](#error-handling)
9. [Architecture & File Layout](#architecture--file-layout)

---

## Overview

The OAuth2 PKCE feature supports the **authorization code flow with PKCE** as defined in [RFC 7636](https://tools.ietf.org/html/rfc7636). It is designed for:

- **Desktop and mobile applications** that cannot securely store a client secret (public clients)
- **Single sign-on** with Azure AD / Entra ID, Google, GitHub, or custom OAuth2/OIDC providers
- **Flexible UI** via embedded WebView2 or system browser with HTTP callback

### Key Features

- **PKCE (S256)** – Secure authorization without client secret
- **Provider presets** – Azure AD, Google, GitHub
- **Custom providers** – Implement `IOAuth2Provider` for any OIDC provider
- **Multiple browser hosts** – WebView2 form (Krypton-styled) or system browser + HttpListener
- **Flow hooks** – Before authorize, after code received, after tokens, after refresh
- **HTTP interceptors** – Add headers, log traffic, transform requests
- **Token refresh** – Refresh access tokens using refresh tokens
- **Static API** – `KryptonOAuth2Login.ShowAsync()` for simple sign-in dialogs

---

## Prerequisites

### WebView2 (for embedded sign-in)

To use the default embedded sign-in form (`KryptonOAuth2Login` / `OAuth2WebView2BrowserHost`), the **WebView2 Runtime** must be available:

- Bundled DLLs: Place `Microsoft.Web.WebView2.Core.dll` and `Microsoft.Web.WebView2.WinForms.dll` in `Krypton.Utilities/Lib/WebView2/`
- Or run: `Scripts\WebView2\Populate-BundledWebView2.cmd`

If WebView2 is not available, you can:

1. Use `OAuth2SystemBrowserHost` with `OAuth2HttpListenerRedirectHandler` for system-browser-based auth
2. Implement a custom `IOAuth2BrowserHost`

### Redirect URI

The redirect URI must be registered with your OAuth2 provider and match exactly:

- **Custom scheme** (recommended for WebView2): `myapp://callback` or `com.myapp://auth`
- **Localhost** (for system browser): `http://localhost:8400/callback` or `http://127.0.0.1:8400/`

---

## Quick Start

### 1. Simple sign-in dialog (WebView2)

```csharp
using Krypton.Utilities;

// Use provider preset
var options = OAuth2ProviderPresets.AzureAd(
    clientId: "your-client-id",
    redirectUri: "myapp://callback",
    tenantId: "common",
    scopes: "openid profile User.Read"
);

var client = new OAuth2PkceClient(options);
var tokens = await client.AuthorizeWithBrowserAsync(this, "Sign in to My App");

// Use tokens.AccessToken for API calls
// tokens.RefreshToken to refresh when expired
```

### 2. Manual flow (custom UI)

If you provide your own sign-in UI, build the authorization URL, obtain the code, then exchange it. You must generate a PKCE code verifier (RFC 7636: 43–128 chars, base64url-safe) and keep it for the token exchange:

```csharp
var client = new OAuth2PkceClient(options);
var codeVerifier = /* generate per RFC 7636 */;
var authUrl = client.BuildAuthorizationUrl(codeVerifier, state: "optional-state");

// Show authUrl in your UI; after user completes sign-in and you receive the code:
var tokens = await client.ExchangeCodeAsync(authorizationCode, codeVerifier);
```

**Recommended:** Use `AuthorizeWithBrowserAsync` when possible; it handles PKCE internally.

### 3. Static dialog (like KryptonMessageBox)

Use `KryptonOAuth2Login` when you want the Krypton sign-in dialog but need custom flow logic. You must use the same `codeVerifier` for both `BuildAuthorizationUrl` and `ExchangeCodeAsync`:

```csharp
var codeVerifier = /* generate per RFC 7636 */;
var authUrl = client.BuildAuthorizationUrl(codeVerifier, state);
var result = await KryptonOAuth2Login.ShowAsync(this, authUrl, redirectUri, "Sign in");

if (result.Success && !string.IsNullOrEmpty(result.Code))
    tokens = await client.ExchangeCodeAsync(result.Code, codeVerifier);
else
    MessageBox.Show(result.ErrorMessage ?? "Sign-in failed.");
```

**Tip:** `AuthorizeWithBrowserAsync` uses this dialog internally and handles PKCE automatically.

### 4. Refresh tokens

```csharp
var newTokens = await client.RefreshTokenAsync(tokens.RefreshToken!);
```

---

## API Reference

### `KryptonOAuth2Login` (static)

Displays an OAuth2 sign-in dialog similar to `KryptonMessageBox`.

| Method | Description |
|--------|-------------|
| `ShowAsync(authUrl, redirectUri)` | Show dialog, no owner, default title "Sign in" |
| `ShowAsync(authUrl, redirectUri, title)` | Show dialog with custom title |
| `ShowAsync(owner, authUrl, redirectUri)` | Show modal in front of owner window |
| `ShowAsync(owner, authUrl, redirectUri, title)` | Full overload |

**Returns:** `Task<OAuth2AuthorizationResult>`

**WebView2:** When WebView2 is not available, returns a failed result with error message instead of throwing.

---

### `OAuth2PkceClient`

Main client for OAuth2 PKCE flows.

#### Constructors

| Constructor | Description |
|-------------|-------------|
| `OAuth2PkceClient(OAuth2PkceOptions options, IOAuth2BrowserHost? browserHost = null)` | From options; optional custom browser host |
| `OAuth2PkceClient(IOAuth2Provider provider, clientId, redirectUri, scopes = "openid", IOAuth2BrowserHost? browserHost = null)` | From provider preset |

#### Methods

| Method | Description |
|--------|-------------|
| `BuildAuthorizationUrl(codeVerifier, state?)` | Builds authorization URL with PKCE parameters |
| `GetTokenEndpoint()` | Returns the token endpoint URL |
| `ExchangeCodeAsync(code, codeVerifier, cancellationToken?)` | Exchanges authorization code for tokens |
| `AuthorizeWithBrowserAsync(owner?, title?, cancellationToken?)` | Full flow: open browser, intercept redirect, exchange code, return tokens |
| `RefreshTokenAsync(refreshToken, cancellationToken?)` | Refreshes access token using refresh token |

---

### `OAuth2PkceOptions`

Configuration for the OAuth2 PKCE flow.

| Property | Type | Description |
|----------|------|-------------|
| `Authority` | string | Base URL of identity provider |
| `ClientId` | string | Application/client ID |
| `RedirectUri` | string | Registered redirect URI |
| `Scopes` | string | Space-separated scopes (default: `"openid"`) |
| `AuthorizationEndpoint` | string? | Override; otherwise derived from Authority |
| `TokenEndpoint` | string? | Override; otherwise derived from Authority |
| `ExtraParameters` | `IDictionary<string, string>?` | Extra query params for auth URL |
| `Prompt` | string? | `login`, `consent`, `select_account`, etc. |
| `LoginHint` | string? | Pre-fill username |
| `HttpInterceptors` | `IList<IOAuth2HttpInterceptor>?` | Interceptors for token requests |
| `FlowHooks` | `OAuth2FlowHooks?` | Hooks at key flow points |

---

### `OAuth2TokenResponse`

Result of token exchange or refresh.

| Property | Type | Description |
|----------|------|-------------|
| `AccessToken` | string? | Access token for API calls |
| `RefreshToken` | string? | Refresh token (if issued) |
| `TokenType` | string? | Typically `"Bearer"` |
| `ExpiresIn` | int | Seconds until access token expires |
| `IdToken` | string? | OpenID Connect ID token (JWT) |
| `Scope` | string? | Granted scopes |
| `HasRefreshToken` | bool | True when refresh token is present |

---

### `OAuth2AuthorizationResult`

Result of the authorization step (before token exchange).

| Property | Type | Description |
|----------|------|-------------|
| `Success` | bool | User completed sign-in successfully |
| `Code` | string? | Authorization code when Success |
| `State` | string? | State parameter returned |
| `ErrorMessage` | string? | Error message when !Success |

---

### `OAuth2Exception`

Thrown on OAuth2 failures.

| Property | Type | Description |
|----------|------|-------------|
| `Error` | string? | OAuth2 error code (e.g. `invalid_grant`, `access_denied`) |
| `ErrorDescription` | string? | Provider error description |

---

## Provider Presets

### `OAuth2ProviderPresets`

| Method | Description |
|--------|-------------|
| `AzureAd(clientId, redirectUri, tenantId?, scopes?)` | Microsoft Azure AD / Entra ID |
| `Google(clientId, redirectUri, scopes?)` | Google OAuth2 |
| `GitHub(clientId, redirectUri, scopes?)` | GitHub OAuth2 |
| `Custom(provider, clientId, redirectUri, scopes?)` | Custom `IOAuth2Provider` |

### Built-in providers

| Class | Authority / Endpoints |
|-------|------------------------|
| `AzureAdOAuth2Provider` | `login.microsoftonline.com/{tenant}/v2.0` |
| `GoogleOAuth2Provider` | `accounts.google.com`, `oauth2.googleapis.com` |
| `GitHubOAuth2Provider` | `github.com/login/oauth` |

### Example: Azure AD with Microsoft Graph

```csharp
var options = OAuth2ProviderPresets.AzureAd(
    "your-app-client-id",
    "myapp://callback",
    tenantId: "common",
    scopes: "openid profile https://graph.microsoft.com/User.Read"
);
```

---

## Extensibility

### `IOAuth2Provider`

Implement to add support for a custom OAuth2/OIDC provider.

```csharp
public interface IOAuth2Provider
{
    string Name { get; }
    void ApplyTo(OAuth2PkceOptions options);
}
```

Example:

```csharp
public class MyOAuth2Provider : IOAuth2Provider
{
    public string Name => "My Provider";
    public void ApplyTo(OAuth2PkceOptions options)
    {
        options.Authority = "https://auth.example.com";
        options.AuthorizationEndpoint = "https://auth.example.com/authorize";
        options.TokenEndpoint = "https://auth.example.com/token";
    }
}

var options = OAuth2ProviderPresets.Custom(new MyOAuth2Provider(), clientId, redirectUri);
```

---

### `IOAuth2BrowserHost`

Controls how the sign-in UI is shown (embedded vs system browser).

```csharp
public interface IOAuth2BrowserHost
{
    Task<OAuth2AuthorizationResult> LaunchAsync(
        string authorizationUrl,
        string redirectUri,
        string title,
        IWin32Window? owner,
        CancellationToken cancellationToken);
}
```

**Built-in implementations:**

- `OAuth2WebView2BrowserHost` – Krypton form with WebView2 (default when WebView2 available)
- `OAuth2SystemBrowserHost` – Opens system browser; requires `IOAuth2RedirectHandler`

---

### `IOAuth2RedirectHandler`

Handles receiving the OAuth2 callback.

```csharp
public interface IOAuth2RedirectHandler
{
    Task<OAuth2AuthorizationResult> WaitForRedirectAsync(string redirectUri, CancellationToken cancellationToken);
}
```

**Built-in implementations:**

- `OAuth2WebView2RedirectHandler` – Intercepts WebView2 navigations
- `OAuth2HttpListenerRedirectHandler` – Listens on `http://localhost:port` for redirect

---

### `IOAuth2HttpInterceptor`

Intercepts token HTTP requests and responses.

```csharp
public interface IOAuth2HttpInterceptor
{
    void OnBeforeTokenRequest(HttpRequestMessage request, OAuth2TokenRequestContext context);
    void OnAfterTokenResponse(HttpResponseMessage response, string jsonBody, OAuth2TokenRequestContext context);
}
```

Use for: adding headers, logging, transforming requests.

---

### `OAuth2FlowHooks`

Hooks invoked at key points in the flow.

| Property | Signature | When invoked |
|----------|-----------|--------------|
| `BeforeAuthorize` | `(authUrl, state, ct) => Task` | Before opening sign-in UI |
| `AfterAuthorizationCodeReceived` | `(code, state, ct) => Task` | After redirect, before token exchange |
| `AfterTokensReceived` | `(tokens, ct) => Task` | After successful token exchange/refresh |
| `AfterRefresh` | `(tokens, ct) => Task` | After successful token refresh only |

Example:

```csharp
options.FlowHooks = new OAuth2FlowHooks
{
    BeforeAuthorize = async (url, state, ct) => { /* log, metrics */ },
    AfterTokensReceived = async (tokens, ct) => { /* persist tokens */ }
};
```

---

## Advanced Usage

### System browser with HttpListener

```csharp
var redirectHandler = new OAuth2HttpListenerRedirectHandler();
var browserHost = new OAuth2SystemBrowserHost(redirectHandler);

var options = OAuth2ProviderPresets.AzureAd(clientId, "http://localhost:8400/callback");
var client = new OAuth2PkceClient(options, browserHost);

var tokens = await client.AuthorizeWithBrowserAsync(this, "Sign in");
```

**Note:** Redirect URI must be `http://localhost` or `http://127.0.0.1`.

---

### Custom HTTP interceptor (add header)

```csharp
options.HttpInterceptors = new List<IOAuth2HttpInterceptor>
{
    new CustomHeaderInterceptor()
};

public class CustomHeaderInterceptor : IOAuth2HttpInterceptor
{
    public void OnBeforeTokenRequest(HttpRequestMessage request, OAuth2TokenRequestContext context)
    {
        request.Headers.Add("X-Custom-Header", "value");
    }
    public void OnAfterTokenResponse(HttpResponseMessage response, string jsonBody, OAuth2TokenRequestContext context) { }
}
```

---

### Login hint and prompt

```csharp
options.LoginHint = "user@example.com";  // Pre-fill username
options.Prompt = "select_account";       // Force account picker
```

---

## Error Handling

1. **`OAuth2Exception`** – Thrown on token exchange/refresh failure.
   - Check `Error` and `ErrorDescription` for provider details.

2. **`OAuth2AuthorizationResult`** – Returned by `KryptonOAuth2Login` and `IOAuth2BrowserHost`.
   - When `!Success`, use `ErrorMessage`.

3. **WebView2 not available** – `KryptonOAuth2Login` returns failed result with explanatory message; does not throw.

4. **Cancellation** – User closes sign-in window; `OAuth2AuthorizationResult.Success` is false, `ErrorMessage` indicates cancellation.

---

## Architecture & File Layout

```
Components/Krypton OAuth2/
├── Controls Toolkit/
│   ├── KryptonOAuth2Login.cs      # Static API (ShowAsync)
│   ├── OAuth2PkceClient.cs        # Main client
│   └── OAuth2ProviderPresets.cs   # AzureAd, Google, GitHub, Custom
├── Controls Visuals/
│   ├── VisualOAuth2LoginForm.cs       # Krypton form with WebView2
│   └── VisualOAuth2LoginForm.Designer.cs
└── General/
    ├── OAuth2PkceOptions.cs
    ├── OAuth2TokenResponse.cs
    ├── OAuth2AuthorizationResult.cs
    ├── OAuth2Exception.cs
    ├── OAuth2FlowHooks.cs
    ├── PkceHelper.cs (internal)
    ├── IOAuth2Provider.cs
    ├── IOAuth2BrowserHost.cs
    ├── IOAuth2RedirectHandler.cs
    ├── IOAuth2HttpInterceptor.cs
    ├── OAuth2TokenRequestContext.cs
    ├── AzureAdOAuth2Provider.cs
    ├── GoogleOAuth2Provider.cs
    ├── GitHubOAuth2Provider.cs
    ├── OAuth2WebView2RedirectHandler.cs  (#if WEBVIEW2_AVAILABLE)
    ├── OAuth2HttpListenerRedirectHandler.cs
    ├── OAuth2SystemBrowserHost.cs
    └── OAuth2WebView2BrowserHost.cs      (#if WEBVIEW2_AVAILABLE)
```

---

## Target Frameworks

The OAuth2 feature targets all frameworks supported by `Krypton.Utilities`:

- .NET Framework 4.7.2, 4.8, 4.8.1  
- .NET 8.0, 9.0, 10.0, 11.0 (Windows)

---

## References

- [RFC 6749 – OAuth 2.0](https://tools.ietf.org/html/rfc6749)
- [RFC 7636 – PKCE](https://tools.ietf.org/html/rfc7636)
- [Microsoft identity platform (Azure AD)](https://learn.microsoft.com/en-us/azure/active-directory/develop/)
- [Google OAuth 2.0](https://developers.google.com/identity/protocols/oauth2)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
