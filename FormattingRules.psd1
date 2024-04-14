# These rules are equivlent to the following settings in the VSCode PowerShell Extension:
#	{
#		"powershell.codeFormatting.autoCorrectAliases": true,
#		"powershell.codeFormatting.avoidSemicolonsAsLineTerminators": true,
#		"powershell.codeFormatting.pipelineIndentationStyle": "IncreaseIndentationForFirstPipeline",
#		"powershell.codeFormatting.preset": "Stroustrup",
#		"powershell.codeFormatting.trimWhitespaceAroundPipe": true,
#		"powershell.codeFormatting.useCorrectCasing": true,
#	}
#
# Inspired by https://eslint.org/docs/rules/brace-style#stroustrup
# Note: CheckPipeForRedundantWhitespace is $false in "Settings\CodeFormattingStroustrup.psd1"
# Note: UseConsistentIndentation Kind is 'space' in "Settings\CodeFormattingStroustrup.psd1"
@{
    IncludeRules = @(
        'PSPlaceOpenBrace',
        'PSPlaceCloseBrace',
        'PSUseConsistentWhitespace',
        'PSUseConsistentIndentation',
        'PSAlignAssignmentStatement',
        'PSUseCorrectCasing',
		'PSAvoidUsingCmdletAliases',
		'PSAvoidSemicolonsAsLineTerminators'
    )

    Rules = @{
        PSPlaceOpenBrace = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable          = $true
            Kind            = 'tab'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable                          = $true
            CheckInnerBrace                 = $true
            CheckOpenBrace                  = $true
            CheckOpenParen                  = $true
            CheckOperator                   = $true
            CheckPipe                       = $true
            CheckPipeForRedundantWhitespace = $true
            CheckSeparator                  = $true
            CheckParameter                  = $false
            IgnoreAssignmentOperatorInsideHashTable = $true
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }

        PSUseCorrectCasing     = @{
            Enable             = $true
        }

# Additionnal rules: see https://github.com/PowerShell/PSScriptAnalyzer/tree/master/docs/Rules

        'PSAvoidUsingCmdletAliases' = @{
            Enable             = $true
		}

		'PSAvoidSemicolonsAsLineTerminators' = @{
            Enable             = $true
		}
	}
}

