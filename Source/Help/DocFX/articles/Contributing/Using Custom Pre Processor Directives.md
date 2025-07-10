# Using Custom Pre Processor Directives

In version 100, a number of custom [preprocessor directives](https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/preprocessor-directives) have been implemented. The rationale behind such a decision is to allow contributors to test code and features in specific configurations without affecting public builds.

Here are the custom defined preprocessor directives:-

1. `#ALPHA`
2. `#CANARY`
3. `#NIGHTLY`
4. `#RELEASE`
5. `#LTS`
6. `#PREVIEW_BUILD`
7. `#STABLE_BUILD`
8. `#INTERNAL_BUILD`
