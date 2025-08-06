#!/usr/bin/env bash

_add_completion() {
    local command="$1"
    local options="$2"
    
    eval "_${command}_completions() {
        local cur prev opts
        COMPREPLY=()
        cur=\"\${COMP_WORDS[\$COMP_CWORD]}\"
        prev=\"\${COMP_WORDS[\$COMP_CWORD-1]}\"
        
        opts=\"$options\"
        
        if [[ \${COMP_CWORD} -eq 1 ]]; then
            COMPREPLY=( \$(compgen -W \"\${opts}\" -- \"\${cur}\") )
            return 0
        fi
    }"
    complete -F "_${command}_completions" "$command"
}

# Usage examples:
_add_completion "hm" "test rollback"
