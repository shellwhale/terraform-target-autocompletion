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
