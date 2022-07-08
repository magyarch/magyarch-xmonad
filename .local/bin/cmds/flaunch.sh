#!/bin/bash
DIR1="/bin"
DIR2="$HOME/.local/bin"

Menu="$(ls -a $DIR1 $DIR2 | uniq -u | fzf --prompt="Which Program Would You Like To Run : " --border=rounded --margin=5% --color=dark --height 100% --reverse --header="                    PROGRAMS " --info=hidden --header-first)"

exec devour $Menu

