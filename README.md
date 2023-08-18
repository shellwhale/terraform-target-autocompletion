# terraform-target-autocompletion 🎯💨
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://img.shields.io/badge/PowerShell-blue)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://img.shields.io/badge/Bash-blue)

Press <kbd>tab</kbd> after `--target` and get autocomplete suggestions for your resources and modules.

![Demo GIF](./docs/assets/demo.gif)

## Requirements
`terraform-target-autocompletion` is a Go program that rely on [terraform-config-inspect](https://github.com/hashicorp/terraform-config-inspect) for the heavy lifting.
So it should work with any Terraform version. You don't need anything else than the binary and the completion scripts provided. But currently you'll need Go 1.21.0 installed to build it yourself.

## Installation
### PowerShell
First you have to install the binary
```pwsh
go install github.com/shellwhale/terraform-target-autocompletion@latest
```

Then you need to setup add the following to your PowerShell $PROFILE
```powershell
$__terraformTargetCompleterBlock = {
    param($supposedToBeDashDashTarget, $commandAst, $cursorPosition);
    $cmdElements = $commandAst.CommandElements;

    $currentLength = $cmdElements[0].Value.Length + $cmdElements[1].Value.Length + $cmdElements[2].Value.Length + 2
    $lengthAfterSearchString = $currentLength + $cmdElements[3].Value.Length + 2
    $targetWordLocation = $cmdElements[2].Value;

    if ($targetWordLocation -EQ '--target' -OR $targetWordLocation -EQ '-target' -AND $cursorPosition -GT $currentLength -AND $cursorPosition -LE $lengthAfterSearchString) {
        $filter = $cmdElements[3].Value;
        if ($filter -EQ "") {
            $filter = "*";
        }
        else {
            $filter += "*";
        }

        $completionResults = @();
        terraform-target-autocompletion | Where-Object { $_ -like $filter } | Sort-Object | ForEach-Object {
            $completionResults += [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        };
        
        # If no completion items were found, return $null to prevent the trigger of the default filesystem completion.
        if (-not $completionResults) {
            $null;
        } else {
            $completionResults;
        }
    }
}

Register-ArgumentCompleter -Native -CommandName 'terraform' -ScriptBlock $__terraformTargetCompleterBlock;
```
### Bash
First you have to install the binary
```bash
# This will install the binary in your $GOBIN
# Make sure it's in your $PATH
# You can set it with export PATH=$PATH:$(go env GOPATH)/bin
go install github.com/shellwhale/terraform-target-autocompletion@latest
```

Then you need to setup add the following to your bashrc
This will currently overwrite the `terraform -install-autocomplete bash` command so only completion for --target will work. I'm working on a fix for this so you can use both.
```bash
#!/bin/bash

terraform_target_autocompletion() {
    if [[ ${COMP_CWORD} -eq 2 || ${COMP_CWORD} -eq 3 ]]; then
        if [[ ${COMP_WORDS[2]} == "--target" || ${COMP_WORDS[2]} == "-target" ]]; then
            if [[ -z ${COMP_WORDS[3]} ]]; then
                filter=".*"
            else
                filter="^${COMP_WORDS[3]}"
            fi
            COMPREPLY=($(terraform-target-autocompletion | grep "$filter" | sort))
        fi
    fi
}

complete -F terraform_target_autocompletion terraform
```
