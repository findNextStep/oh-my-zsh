#https://github.com/skylerlee/zeta-zsh-theme/blob/master/zeta.zsh-theme
#zeta-zsh-theme/zeta.zsh-theme
# Zeta theme for oh-my-zsh
# Tested on Linux, Unix and Windows under ANSI colors.
# Copyright: Radmon, 2015
# $HOST==%m
# %#=='%' (if pxq)
# %#=='#' (if root)
# %/==绝对路径(没有~)
# %~==相对路径
# %h==当前语句在历史中的序号
# %t==当前时间 格式xx:xx a/pm(上/下午)
# %w==星期 格式 日/*星期*/ 18/*日期*/
# %l=='pts/28' ...
# 这些可以用 print -P 打印

# Colors: black|red|blue|green|yellow|magenta|cyan|white
local black=$fg[black]
local red=$fg[red]
local blue=$fg[blue]
local green=$fg[green]
local yellow=$fg[yellow]
local magenta=$fg[magenta]
local cyan=$fg[cyan]
local white=$fg[white]

local black_bold=$fg_bold[black]
local red_bold=$fg_bold[red]
local blue_bold=$fg_bold[blue]
local green_bold=$fg_bold[green]
local yellow_bold=$fg_bold[yellow]
local magenta_bold=$fg_bold[magenta]
local cyan_bold=$fg_bold[cyan]
local white_bold=$fg_bold[white]
local highlight_bg=$bg[red]

local zeta='ζ'

# Machine name.
function get_box_name {
    if [ -f ~/.box-name ]; then
        cat ~/.box-name
    else
        echo $HOST
    fi
}

# User name.
function get_usr_name {
    local name="%n"
    if [[ "$USER" == 'root' ]]; then
        name="%{$highlight_bg%}%{$white_bold%}$name%{$reset_color%}"
    fi
    echo $name
}

# Directory info.
function get_current_dir {
    echo "${PWD/#$HOME/~}"
}


# git theming
# Add 1 cyan ✗s if this branch is diiirrrty! Dirty branch!
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗{$reset_color%} "
# For the git prompt, use a blue  and red text for the branch name
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}@%{$reset_color%} "
# Close it all off by resetting the color and styles.
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}%{$fg[yellow]%} %{$reset_color%} "
# Do nothing if the branch is clean (no changes).
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}%{$fg[green]%} ✔ %{$reset_color%} "
ZSH_THEME_GIT_PROMPT_ADDED="%{$FG[082]%}✚%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$FG[166]%}✹%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DELETED="%{$FG[160]%}✖%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$FG[220]%}➜%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$FG[082]%}═%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$FG[190]%}✭%{$reset_color%} " 

# Git sha.
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="[%{$yellow%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%}]"

function get_git_prompt {
    if [[ -n $(git rev-parse --is-inside-work-tree 2>/dev/null) ]]; then
        local git_status="$(git_prompt_status)"
        if [[ -n $git_status ]]; then
            git_status="[$git_status%{$reset_color%}]"
        fi
        local git_prompt=" <$(git_prompt_info)$git_status>"
        echo $git_prompt
    fi
}

function get_time_stamp {
    echo "%*"
}

function get_space {
    local str=$1$2
    local zero='%([BSUbfksu]|([FB]|){*})'
    local len=${#${(S%%)str//$~zero/}}
    local size=$(( $COLUMNS - $len - 1 ))
    local space=""
    while [[ $size -gt 0 ]]; do
        space="$space "
        let size=$size-1
    done
    echo $space
}

# Prompt: # USER@MACHINE: DIRECTORY <BRANCH [STATUS]> --- (TIME_STAMP)
# > command
function print_prompt_head {
    local left_prompt="\
%{$blue%}# \
%{$green_bold%}$(get_usr_name)\
%{$blue%}@\
%{$cyan_bold%}$(get_box_name): \
%{$yellow_bold%}$(get_current_dir)%{$reset_color%}\
$(get_git_prompt) "
    local right_prompt="%{$blue%}($(get_time_stamp))%{$reset_color%} "
    print -rP "$left_prompt$(get_space $left_prompt $right_prompt)$right_prompt"
}

function get_prompt_indicator {
    if [[ $? -eq 0 ]]; then
        echo "%{$magenta_bold%}$1 %{$reset_color%}"
    else
        echo "%{$red_bold%}$2 %{$reset_color%}"
    fi
}

#漂亮又实用的命令高亮界面
setopt extended_glob  
TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')  
   
recolor-cmd() {  
    region_highlight=()  
    colorize=true  
    start_pos=0  
    for arg in ${(z)BUFFER}; do  
        ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))  
        ((end_pos=$start_pos+${#arg}))  
        if $colorize; then  
            colorize=false  
            res=$(LC_ALL=C builtin type $arg 2>/dev/null)  
            case $res in  
                *'reserved word'*)   style="fg=magenta,bold";;  
                *'alias for'*)       style="fg=cyan,bold";;  
                *'shell builtin'*)   style="fg=yellow,bold";;  
                *'shell function'*)  style='fg=green,bold';;  
                *"$arg is"*)  
                    [[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=blue,bold";;  
                *)                   style='none,bold';;  
            esac  
            region_highlight+=("$start_pos $end_pos $style")  
        fi  
        [[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true  
        start_pos=$end_pos  
    done  
}  
check-cmd-self-insert() { zle .self-insert && recolor-cmd }  
check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }  
zle -N self-insert check-cmd-self-insert  
zle -N backward-delete-char check-cmd-backward-delete-char 
#彩色补全菜单  
eval $(dircolors -b)  
export ZLSCOLORS="${LS_COLORS}"  
zmodload zsh/complist  
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'  

autoload -U add-zsh-hook
add-zsh-hook precmd print_prompt_head   
setopt prompt_subst

PROMPT='$(get_prompt_indicator \> x)'
#PROMPT='$bg[red]%S $reset_color 234%% '
POSTEDIT=`echotc se`
RPROMPT='$(git_prompt_short_sha) '
















#$HOST==%m
# %#=='%' (if pxq)
# %#=='#' (if root)
# %/==绝对路径(没有~)
# %~==相对路径
# %h==当前语句在历史中的序号
# %t==当前时间 格式xx:xx a/pm(上/下午)
# %w==星期 格式 日/*星期*/ 18/*日期*/
# %l=='pts/28' ...
# %.==%c==%C==当前文件夹名
# 这些可以用 print -P 打印
# git theming
# Add 1 cyan ✗s if this branch is diiirrrty! Dirty branch!
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}✗{$reset_color%} "
# For the git prompt, use a blue  and red text for the branch name
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}@%{$reset_color%} "
# Close it all off by resetting the color and styles.
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}%{$fg[yellow]%} %{$reset_color%} "
# Do nothing if the branch is clean (no changes).
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}%{$fg[green]%} ✔ %{$reset_color%} "
ZSH_THEME_GIT_PROMPT_ADDED="%{$FG[082]%}✚%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$FG[166]%}✹%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DELETED="%{$FG[160]%}✖%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_RENAMED="%{$FG[220]%}➜%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$FG[082]%}═%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$FG[190]%}✭%{$reset_color%} " 

# Colors: black|red|blue|green|yellow|magenta|cyan|white
# 建立局部变量,记录颜色
# black=$fg[black]
# red=$fg[red]
# blue=$fg[blue]
# green=$fg[green]
# yellow=$fg[yellow]
# magenta=$fg[magenta]
# cyan=$fg[cyan]
# white=$fg[white]
# default=$fg[default]

# black_bold=$fg_bold[black]
# red_bold=$fg_bold[red]
# blue_bold=$fg_bold[blue]
# green_bold=$fg_bold[green]
# yellow_bold=$fg_bold[yellow]
# magenta_bold=$fg_bold[magenta]
# cyan_bold=$fg_bold[cyan]
# white_bold=$fg_bold[white]

# highlight_bg=$bg[red]
#记录问题
__NOW_ERROR=0
#展示当前目录
doprompt() {
    echo "${PWD/#$HOME/~}"
}

# Grab the current date (%D) and time (%T) wrapped in {}: {%D %T}
DALLAS_CURRENT_TIME_="%{$fg[green]%}%D  %t%{$reset_color%}"
# Grab the current machine name: muscato
DALLAS_CURRENT_MACH_="%{$fg[green]%}%m://%{$reset_color%}"
# Grab the current filepath, use shortcuts: ~/Desktop
# Append the current git branch, if in a git repository: ~aw@master
DALLAS_CURRENT_LOCA_="%{$fg[cyan]%} %{$(doprompt)%} $(git_prompt_info)%{$reset_color%}"
# Grab the current username: dallas
DALLAS_CURRENT_USER_="%{$fg[red]%}%n>%{$reset_color%}"
# Use a % for normal users and a # for privelaged (root) users.
DALLAS_PROMPT_CHAR_="%{$fg[white]%}%(!.#.%%)%{$reset_color%}"

#两个参数 第一个参数为正确执行上一指令的字符,第二个参数为错误执行时的字符
#使用参考  $(get_prompt_indicator \> x)
function get_prompt_indicator {
    [[ $? -eq 0 ]] && echo " %{$fg_bold[green]%}$1%{$reset_color%}" || echo "%{$fg_bold[red]%}$? $2%{$reset_color%}"
}

#漂亮又实用的命令高亮界面
setopt extended_glob  
TOKENS_FOLLOWED_BY_COMMANDS=('|' '||' ';' '&' '&&' 'sudo' 'do' 'time' 'strace')  
   
recolor-cmd() {  
    region_highlight=()  
    colorize=true  
    start_pos=0  
    for arg in ${(z)BUFFER}; do  
        ((start_pos+=${#BUFFER[$start_pos+1,-1]}-${#${BUFFER[$start_pos+1,-1]## #}}))  
        ((end_pos=$start_pos+${#arg}))  
        if $colorize; then  
            colorize=false  
            res=$(LC_ALL=C builtin type $arg 2>/dev/null)  
            case $res in  
                *'reserved word'*)   style="fg=magenta,bold";;  
                *'alias for'*)       style="fg=cyan,bold";;  
                *'shell builtin'*)   style="fg=yellow,bold";;  
                *'shell function'*)  style='fg=green,bold';;  
                *"$arg is"*)  
                    [[ $arg = 'sudo' ]] && style="fg=red,bold" || style="fg=blue,bold";;  
                *)                   style='none,bold';;  
            esac  
            region_highlight+=("$start_pos $end_pos $style")  
        fi  
        [[ ${${TOKENS_FOLLOWED_BY_COMMANDS[(r)${arg//|/\|}]}:+yes} = 'yes' ]] && colorize=true  
        start_pos=$end_pos  
    done  
}  
check-cmd-self-insert() { zle .self-insert && recolor-cmd }  
check-cmd-backward-delete-char() { zle .backward-delete-char && recolor-cmd }  
zle -N self-insert check-cmd-self-insert  
zle -N backward-delete-char check-cmd-backward-delete-char 
#彩色补全菜单  
eval $(dircolors -b)  
export ZLSCOLORS="${LS_COLORS}"  
zmodload zsh/complist  
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'  

function print_prompt_head {
    local left_prompt="$fg_bold[blue][ $DALLAS_CURRENT_USER_$DALLAS_CURRENT_MACH_ %{$bg[green]%} %{$fg[red]%} ${${$(pwd)}//\//%{$fg[red]%}/%{$fg[blue]%}}%{$reset_color%}$fg[yellow]$fg_bold[blue] ]$reset_color"
    print -rP "$left_prompt"
}
autoload -U add-zsh-hook
add-zsh-hook precmd print_prompt_head   
setopt prompt_subst


PROMPT='%t $(get_prompt_indicator \> x)  $(git_prompt_info)'
RPROMPT=' %{$fg[green]%}job:%j%{$reset_color%}'
print -P "$fg_bold[blue][ ${DALLAS_CURRENT_TIME_} $fg_bold[blue]]"
