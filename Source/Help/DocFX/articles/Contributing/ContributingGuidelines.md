# Contributing Guidelines for Krypton Development

BEFORE CONTRIBUTING please read _all_ of the rules below are guidelines, which means that they should be followed when possible. You can contribute to these projects by opening new bug reports, feature requests, discussions and pull requests. New pull requests **will** be reviewed and merged at the maintainers discretion. Above all, have fun coding and learning about the intricacies of the toolkits! :slightly_smiling_face:

## Discussions

If you wish to discuss about the development of the toolkit, please use the areas as provided in either in the [Standard Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit/discussions) or the [Extended Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit/discussions).

## Rules

The developers **respects** diversity. Any user who posts offensive or disrespectful content regarding race, gender, religion, height or culture **will be immediately banned from this repository and Discord by extension**. No exception will be made.

## Reporting issues, bugs and making requests

#### Bugs

- Please use the provided `Bug` template
- Please be clear when describing issues.
- Please fill out the form and DO NOT send empty bugs with the information on the title.
- Please make sure to check for duplicates as said in the `Bug` template.
- Please make sure to precede titles with the `[Bug]:` string, so they can be easily identified.

#### Feature Requests

- Please use the `Feature Request` template
- Please detail how the feature should work. Please be as specific as possible.
- Some features are difficult and might take some time to get implemented. This project is made in the contributor's free time, so please do not post messages asking for ETAs or similar. Every feature request will be considered.
- Please make sure to check for duplicates as said in the `Feature Request` template.
- Please make sure to precede titles with the `[Feature Request]:` string, so they can be easily identified.

 _**Note:**_ _When a fix or further information is requested, the_ _**awaiting feedback**_ _label will be appended to the entry. If no response is submitted within_ _**90**_ _days, the entry will be closed._

## Making Pull Requests

 To make a new pull request, follow these [instructions](HowtoCreateaPullRequest.md) for guidance.

## Coding Style

 These repositories use the C# 10 or newer specification. **If** a new class is added, please be sure to append a license header. The `Standard Toolkit` is governed by the BSD-3-Clause license, whereas the `Extended Toolkit` is governed by the MIT license.

#### Handling `using` statements

 Please follow [this](HowtoManageUsingStatements.md) guide to learn more.

#### Variables, Constructors, Methods, Properties etc

 Each class has a standard layout of `regions`. These `regions` are as described:-

 1. `Static Fields` - Any fields that are _constant_ or _static_ belong here.
 2. `Instance Fields` - Any fields belong here
 3. `Identity` - The constructor(s) belong here
 4. `Protected Overrides` - Any protected override methods belong here
 5. `Public Overrides` - Any public override methods or properties belong here
 6. `Implementation` - Any methods or event handlers belong here

 **Note:** You can define your own regions within the prescribed region definitions.

##### Fields

 **Any** new fields _must_ be in the following format `_myNewField`, for example:

 ```cs
 private bool _myNewField;
 ```

##### Methods and Arguments

 **Any** new methods and arguments _must_ be in the following format `MyNewMethod(bool myNewField)`, for example:

 ```cs
 private void MyNewMethod(bool myNewField)
 {
     // ToDo: Do some stuff here...
 }
 ```

#### Usage of `this.`

 The toolkit does not use the `this.` citation _except_ in the 'designer' files, to follow the C# 10 and newer specifications.

#### Usage of ReSharper

 These toolkits use [ReSharper](https://www.jetbrains.com/resharper/) to do a multitude of tasks on the code-base such as refactoring. It is not essential to have it to work on the code, but it is a bonus to have it installed.

#### Breaking Changes

 If you make a breaking change within the code, ensure that the maintainers are aware of these changes, and that they are recorded **both** in the `README` and `Changelog` of that particular repository. The changelog is located in `Documents\Changelog`. Please ensure that in the `Changelog`, you precede the change with the following:

 ```md
 **[Breaking Change]:**
 ```
