# File checksum dialogs

## Overview

`KryptonComputeFileCheckSum` and `KryptonVerifyFileCheckSum` are static APIs that show Krypton-themed modal dialogs for computing and verifying file hashes.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Type:** Static classes (`ToolboxItem(false)`)

| API | Purpose |
| --- | --- |
| `KryptonComputeFileCheckSum` | Select a file, choose algorithm, compute and display hash |
| `KryptonVerifyFileCheckSum` | Compare a file's hash against an expected value |

## Supported algorithms

| Enum | Algorithms | Notes |
| --- | --- | --- |
| `SupportedHashAlgorithims` | MD5, SHA1, SHA256, SHA384, SHA512, RIPEMD160 | Compute dialog |
| `SafeNETAndNewerSupportedHashAlgorithms` | MD5, SHA1, SHA256, SHA384, SHA512 | Verify dialog / .NET built-in set |

Prefer **SHA256** or stronger for integrity checks. MD5 and SHA1 are included for legacy compatibility.

`CheckSumStatus` reports in-dialog progress (`Computing`, `Verifying`, `Valid`, `Invalid`, etc.).

## KryptonComputeFileCheckSum

### Show overloads

```csharp
using Krypton.Toolkit.Utilities;

// File picker + algorithm selection
DialogResult result = KryptonComputeFileCheckSum.Show(this);

// Pre-fill file path
KryptonComputeFileCheckSum.Show(this, @"C:\Downloads\setup.msi");

// Pre-select algorithm
KryptonComputeFileCheckSum.Show(this, filePath, SupportedHashAlgorithims.SHA256);
```

The dialog lets the user browse for a file, pick an algorithm, compute the hash, and copy or save the result.

## KryptonVerifyFileCheckSum

### Show overloads

```csharp
// Empty verify dialog
KryptonVerifyFileCheckSum.Show(this);

// Pre-fill file path
KryptonVerifyFileCheckSum.Show(this, @"C:\Downloads\setup.msi");

// Pre-fill file and expected hash
KryptonVerifyFileCheckSum.Show(
    this,
    @"C:\Downloads\setup.msi",
    expectedHash: "A1B2C3...");
```

The dialog computes the selected algorithm's hash and compares it to the user-supplied expected value, reporting match or mismatch.

## Typical workflows

### After download

```csharp
KryptonVerifyFileCheckSum.Show(
    owner: this,
    filePath: downloadedPath,
    expectedHash: publishedSha256);
```

### Generate hash for distribution

```csharp
KryptonComputeFileCheckSum.Show(
    owner: this,
    filePath: releasePackagePath,
    algorithim: SupportedHashAlgorithims.SHA256);
```

## See also

- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
- `HashingHelpers` / `HelperMethods` in source for programmatic hashing without dialogs
