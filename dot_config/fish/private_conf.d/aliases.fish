# ~/.config/fish/conf.d/aliases.fish
#
if test "$TERM" = linux
    alias l='ls'
    alias ll='ls -l'
    alias la='ls -la'
else
    alias ls='eza --ignore-glob="\$RECYCLE.BIN|System Volume Information"  --icons auto'
    alias ll='eza --ignore-glob="\$RECYCLE.BIN|System Volume Information"  --icons auto -l'
    alias la='eza --ignore-glob="\$RECYCLE.BIN|System Volume Information"  --icons auto -la'

end

alias grep='grep --color=auto'
alias cdir='cd ~/Workspace/c'
alias git_downloads='cd ~/Downloads/git'
alias workspace='cd ~/Workspace'
alias github='cd ~/Workspace/github'
alias profiles='cd ~/Workspace/profiles'
alias pydir='cd ~/Workspace/python'

# git aliases
alias gs='git switch'
alias gb='git branch'
alias ga='git add .'
alias gc='git commit -m'
alias gm='git merge'
alias gp='git push'

# chezmoi aliases
alias dotsadd='chezmoi add'
alias nvimdots='chezmoi edit'
alias dotsapply='chezmoi apply'
alias dotsdiff='chezmoi diff'
alias dotsdir='chezmoi cd'
