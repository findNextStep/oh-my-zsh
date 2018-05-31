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
__start=$'\u2605'
SEGMENT_SEPARATOR=$'\u2593\u2592\u2591'
SEGMENT_SEPARATOR_diff=$'\u2591\u2592\u2593'
# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  echo -n "%{$fg[$1]%}%{$bg[$2]%}$SEGMENT_SEPARATOR"
}
prompt_segment_diff() {
  echo -n "%{$fg[$2]%}%{$bg[$1]%}$SEGMENT_SEPARATOR_diff%{$bg[$2]%}"
}

#记录问题
#展示当前目录
doprompt() {
    print -P ${${$(pwd)}//\//%{$fg[red]%}➤ %{$fg[blue]%}}
}
#获取精确到ms的时间
function __getms {
    echo $(($(($(date +"%N")/1000000+$(date +"%S")*1000+$(date +"%M")*60000))))
}
# Grab the current date (%D) and time (%T) wrapped in {}: {%D %T}
DALLAS_CURRENT_TIME_="%{$fg[green]%}%D  %t%{$reset_color%}"
# Grab the current machine name: muscato
DALLAS_CURRENT_MACH_="%{$fg[green]%}%m:%{$reset_color%}"
# Grab the current username: dallas
DALLAS_CURRENT_USER_="%{$fg[red]%}%n>%{$reset_color%}"
# Use a % for normal users and a # for privelaged (root) users.
DALLAS_PROMPT_CHAR_="%{$fg[white]%}%(!.#.%%)%{$reset_color%}"

#两个参数 第一个参数为正确执行上一指令的字符,第二个参数为错误执行时的字符
#使用参考  $(get_prompt_indicator \> x)
function get_prompt_indicator {
    [[ $? -eq 0 ]] && echo " %{$fg_bold[green]%}$1%{$reset_color%}" || echo "%{$fg_bold[red]%}$? $2%{$reset_color%}"
}

function show_power {
    num="$(cat /sys/class/power_supply/BAT0/capacity)"
    [[ $num -lt 10 ]] && echo ">%{$fg_bold[red]%}$num%%%{$reset_color%}" || ([[ $num -gt 90 ]] && echo ">%{$fg_bold[green]%}$num%%%{$reset_color%}" || echo ">%{$fg_bold[yellow]%}$num%%%{$reset_color%}")
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
    local left_prompt="$fg_bold[blue]$DALLAS_CURRENT_USER_$DALLAS_CURRENT_MACH_$(prompt_segment_diff default green)%{$fg[red]%}$(doprompt)$(git_prompt_info)  "
    print -P "$left_prompt"
}
autoload -U add-zsh-hook
add-zsh-hook precmd print_prompt_head
setopt prompt_subst
setopt no_nomatch
# bindkey "^C" echo 233
# $(prompt_segment default blue green)
# $(prompt_segment blue red)
PROMPT='%{$bg[blue]%}%{$fg_bold[green]%}%t%{$reset_color%}%{$fg[blue]%}%{$bg[default]%}$SEGMENT_SEPARATOR%{$reset_color%}$(get_prompt_indicator \> x) '
RPROMPT='%{$fg[green]%}job:%j%{$reset_color%} $(show_power)'
print -P "$fg_bold[blue][ ${DALLAS_CURRENT_TIME_} $fg_bold[blue]]"
