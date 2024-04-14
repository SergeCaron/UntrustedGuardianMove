# Reformatting PowerShell scripts and data files

This script implements a fixed set of coding standards for PowerShell scripts.

The formatting rules are defined in the data file *FormattingRules.psd1* and must be placed in the root directory of this project. The rules are documented *[here](https://github.com/PowerShell/PSScriptAnalyzer/tree/master/docs/Rules)*.

This is a Windows-oriented script:
- the input file is presumed coded UTF-8 and the output file is explicitly coded UTF-8 without a Byte Order Marker (BOM). On input, your editor of choice may not automatically change the file encoding to UTF-8 : see this *[UTF-8 Debugging Chart](https://www.i18nqa.com/debug/utf8-debug.html)* for tell-tale signs of corruption.
- by default, line delimiters are changed to LF. When the script is invoked from the terminal command line, there is a -UseCRLF switch to enable CFLF as th line delimiter. Note that Git may revert LF to CRLF.

## Outside VScode
You may not want to install VSCode just for the purpose of reformatting PowerShell scripts or your VSCode workspace may have implemented a different coding standard than what is expected in this project.

This *[PSReformat](https://github.com/SergeCaron/PSReformat)* script relies on the PSScriptAnalyzer utility module *[PS-ScriptAnalyzer](https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/overview?view=ps-modules)* to validate and reformat PowerShell scripts.

The utility module is installed in your environment using (you may have to also install the *Nuget* provider):
```
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name PSScriptAnalyzer -Force
```
On entry, the script validates the formatting rules and open a file browser to select what will be reformatted. The output file (if any) is placed in the same directory, implying write access and file creation privileges. The prefix "Reformatted" is added to the original file name.

The script performs a simple diff between the source and output files and shows the first and last lines of any difference: when there are no differences, this serves as a validation that the source script conforms to the formatting rules.

## Inside VSCode


The default PowerShell extension in VSCode allows reformatting a document using the Shift+Alt+F command or the *Format Document* context menu. This extension contains a hidden implementation of the PSScriptAnalyzer module which cannot be invoked outside VSCode.

The *[PSReformat](https://github.com/SergeCaron/PSReformat)* script can also run from a VSCode terminal window under the same conditions as outlined in [Outside VSCode](#outside-vscode).

The following VSCode settings for this extension are the equivalen of the formatting rules defined in the data file *FormattingRules.psd1* supplied with this script:

```
{
    "powershell.codeFormatting.autoCorrectAliases": true,
    "powershell.codeFormatting.avoidSemicolonsAsLineTerminators": true,
    "powershell.codeFormatting.pipelineIndentationStyle": "IncreaseIndentationForFirstPipeline",
    "powershell.codeFormatting.preset": "Stroustrup",
    "powershell.codeFormatting.trimWhitespaceAroundPipe": true,
    "powershell.codeFormatting.useCorrectCasing": true,
}
```
VSCode implements a *Compare Selected* in the context menu of the Explorer view. This implies that you save the reformatted text in the same tree just for the purpose of checking code conformity. This condition is the same when using the *[PSReformat](https://github.com/SergeCaron/PSReformat)* script.

## GitHub actions

The Readme.MD in *[PSReformat](https://github.com/SergeCaron/PSReformat)* documents the GitHub actions used to validate the PowerShell script(s) in this project.
