$__terraformTargetCompleterBlock = {
    param($supposedToBeDashDashTarget, $commandAst, $cursorPosition);
    $cmdElements = $commandAst.CommandElements;

    
    $currentLength = $cmdElements[0].Value.Length + $cmdElements[1].Value.Length + $cmdElements[2].Value.Length + 2
    if ($cmdElements[2].Value -EQ '--target' -OR $cmdElements[2].Value -EQ '-target' -AND $cursorPosition -EQ $currentLength+1) {
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