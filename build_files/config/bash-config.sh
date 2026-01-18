alias ls='eza --color=always --group-directories-first --icons'
alias ll='eza -la --icons --octal-permissions --group-directories-first'
alias l='eza -bGF --header --git --color=always --group-directories-first --icons'
alias lt='eza -T --git-ignore --level=2 --color=always --group-directories-first --icons'
alias tree='eza -T --git-ignore --color=always --group-directories-first --icons'

eval "$(direnv hook bash)"
eval "$(zoxide init bash)"
