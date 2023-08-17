$ScriptBlock = {
    param($supposedToBeDashDashTarget, $commandAst, $wordToComplete);

    if ($commandAst.CommandElements[2].Value -eq '--target' || $commandAst.CommandElements[2].Value -eq '-target') {
        $filter = $commandAst.CommandElements[3].Value;
        if ($filter -eq "") {
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

Register-ArgumentCompleter -Native -CommandName 'terraform' -ScriptBlock $ScriptBlock;
