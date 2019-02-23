# check if any aliases exist
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# print dir when moving there
cd() { builtin cd "$@" && ls -lthrG; }

# keep the prompt clean
export PS1="\W $ "

# color terminal output
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
export GREP_OPTIONS="--color=always"

# Setting PATH for Python 3.3
PATH="/usr/local/bin:/Library/Frameworks/Python.framework/Versions/3.3/bin:${PATH}"
export PATH
export PATH="$PATH:/usr/local/mysql/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="$PATH:~/.npm-packages/bin"
export PATH="$PATH:/Users/alexander/Library/Python/2.7/bin"
export PATH="$PATH:/Users/alexander/Library/Python/3.6/bin"
# log all vi keystrokes
alias vi='vim -w ~/.vimlog '

# for being sneaky
alias pvi='/usr/local/bin/vim -c "set viminfo="'

# track bash history forever
shopt -s histappend
export PROMPT_COMMAND="history -a"
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "

# Change the file location because certain bash sessions truncate
# .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history

# Git shortcuts.
alias gs="git status"
alias gcp="git cherry-pick"
alias gc="git checkout"
alias gd="git diff"
alias gl="git log"
alias gg="git grep"
alias ga="git add"
alias gb='git checkout $(git branch | fzf)'

# clean up this garbage command
alias ll="ls -lG"

# pugs utilities
export PATH=/usr/local/pugs:$PATH

# shortcut for finding files by prefix
ff () {
    find . -name "$1*"
}

# find repo file with fuzzy search, then edit it
alias f='vi $(git ls-files | fzf)'

# `fd` - cd to selected directory
# from: https://github.com/junegunn/fzf/wiki/examples
fd() {
  local dir
  dir=$(find ${1:-*} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# Add directory marks.
alias j="jump"
alias m="mark"
export MARKPATH=$HOME/.marks
function jump {
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
function mark {
  mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
function unmark {
  rm -i "$MARKPATH/$1"
}
function marks {
    ls -l "$MARKPATH" | tail -n +2 | sed 's/  / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
}
_completemarks() {
  local curw=${COMP_WORDS[COMP_CWORD]}
  local wordlist=$(find $MARKPATH -type l -printf "%f\n")
  COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
  return 0
}
complete -F _completemarks jump unmark

# Add tab complete for Invoke commands.
_complete_invoke() {
    local candidates

    # COMP_WORDS contains the entire command string up til now (including
    # program name).
    # We hand it to Invoke so it can figure out the current context: spit back
    # core options, task names, the current task's options, or some combo.
    candidates=`invoke --complete -- ${COMP_WORDS[*]}`

    # `compgen -W` takes list of valid options & a partial word & spits back
    # possible matches. Necessary for any partial word completions (vs
    # completions performed when no partial words are present).
    #
    # $2 is the current word or token being tabbed on, either empty string or a
    # partial word, and thus wants to be compgen'd to arrive at some subset of
    # our candidate list which actually matches.
    #
    # COMPREPLY is the list of valid completions handed back to `complete`.
    COMPREPLY=( $(compgen -W "${candidates}" -- $2) )
}


# Tell shell builtin to use the above for completing 'inv'/'invoke':
# * -F: use given function name to generate completions.
# * -o default: when function generates no results, use filenames.
# * positional args: program names to complete for.
complete -F _complete_invoke -o default invoke inv

# Use emacs bindings to jump to beginning or end of line.
bind '\C-a:beginning-of-line'
bind '\C-e:end-of-line'

# print the date so you can orient yourself
echo "`date`" "(`tty`)"

# enable iTerm shell integration
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# for editing daily notes
alias today="pvi ~/tmp/brandonblogger/`date +'%m-%d'`.txt"

# relax with a weather report
arkansas() {
    curl "https://forecast.weather.gov/product.php?site=LZK&issuedby=LZK&product=RWS&format=CI&version=1&glossary=0" 2>>/dev/null | selector pre | re '\n' ' ' | re '.*2018' | re '  ' '\n\n' | re '((.){62} )' '\1\n' | trim
}
