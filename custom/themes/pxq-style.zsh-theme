# vim:ft=zsh ts=2 sw=2 sts=2
# agnoster's Theme - https://gist.github.com/3712874

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

case ${SOLARIZED_THEME:-dark} in
    light) CURRENT_FG='white';;
    *)     CURRENT_FG='black';;
esac

# Special Powerline characters

# test () {
  LC_ALL="" LC_CTYPE="zh_CN.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0'
  SEGMENT_SEPARATOR_DIFF=$'\ue0b2'
  # SEGMENT_SEPARATOR=$'\uf0da '
  # SEGMENT_SEPARATOR_DIFF=$'\ue0be '
# }

set_terminal_fg(){
  case $1 in
    "reset")
      echo -n "%{\e[49m%}"
      ;;
    "black")
      set_terminal_fg 0
      ;;
    "maroon")
      set_terminal_fg 1
      ;;
    "green")
      set_terminal_fg 2
      ;;
    "olive")
      set_terminal_fg 3
      ;;
    "navy")
      set_terminal_fg 4
      ;;
    "purple")
      set_terminal_fg 5
      ;;
    "teal")
      set_terminal_fg 6
      ;;
    "silver")
      set_terminal_fg 7
      ;;
    "grey")
      set_terminal_fg 8
      ;;
    "red")
      set_terminal_fg 9
      ;;
    "lime")
      set_terminal_fg 10
      ;;
    "yellow")
      set_terminal_fg 11
      ;;
    "blue")
      set_terminal_fg 12
      ;;
    "fuchisa")
      set_terminal_fg 13
      ;;
    "aqua")
      set_terminal_fg 14
      ;;
    "white")
      set_terminal_fg 15
      ;;
    "")
      ;;
    *)
      color="%{\e[38;5;$1m%}"
      echo -n "$color"
      ;;
  esac

}
set_terminal_bg(){
  case $1 in
    "reset")
    echo -n "%{\e[39m%}"
      ;;
    "black")
      set_terminal_bg 0
      ;;
    "maroon")
      set_terminal_bg 1
      ;;
    "green")
      set_terminal_bg 2
      ;;
    "olive")
      set_terminal_bg 3
      ;;
    "navy")
      set_terminal_bg 4
      ;;
    "purple")
      set_terminal_bg 5
      ;;
    "teal")
      set_terminal_bg 6
      ;;
    "silver")
      set_terminal_bg 7
      ;;
    "grey")
      set_terminal_bg 8
      ;;
    "red")
      set_terminal_bg 9
      ;;
    "lime")
      set_terminal_bg 10
      ;;
    "yellow")
      set_terminal_bg 11
      ;;
    "blue")
      set_terminal_bg 12
      ;;
    "fuchisa")
      set_terminal_bg 13
      ;;
    "aqua")
      set_terminal_bg 14
      ;;
    "white")
      set_terminal_bg 15
      ;;
    "")
      ;;
    *)
      color=%{"\e[48;5;$1m%}"
      echo -n $color
      ;;
  esac
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  echo -n "%{\e[0m%}"
  local bg fg
  [[ -n $1 ]] && bg="$1" || bg=""
  [[ -n $2 ]] && fg="$2" || fg=""
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n "$(set_terminal_bg $bg)$(set_terminal_fg $CURRENT_BG)$SEGMENT_SEPARATOR$(set_terminal_fg $fg)"
  else
    echo -n "$(set_terminal_fg $fg)$(set_terminal_bg $bg)"
  fi
  CURRENT_BG=$1
  echo -n "%{\e[1m%}"
  [[ -n $3 ]] && echo -n $3
}
prompt_segment_diff() {
  echo -n "%b"
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  # if [[ $CURRENT_BG == 'NONE' ]; then
    # CURRENT_BG="default"
  # fi
  echo -n "%{%K{$CURRENT_BG}%}%{%F{$1}%}$SEGMENT_SEPARATOR_DIFF%{$bg$fg%}"
  CURRENT_BG=$1
  echo -n "%B"
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  echo -n "%b"
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG='NONE'
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
    if [[ $USER == "root" ]];then
        prompt_segment red white "%n"
    else
        prompt_segment blue white "%n"
    fi
    prompt_segment black white "%m"
}

# Git: branch/detached head, dirty status
prompt_git() {
  precmd_update_git_vars
  if [ -n "$__CURRENT_GIT_STATUS" ]; then
    if [ "$GIT_BRANCH" = "master" ];then
      STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH%{$fg[red]%}$GIT_BRANCH"
    else
      STATUS="$ZSH_THEME_GIT_PROMPT_PREFIX$ZSH_THEME_GIT_PROMPT_BRANCH%{$fg[white]%}$GIT_BRANCH"
    fi
    if [ "$GIT_BEHIND" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND$GIT_BEHIND"
    fi
    if [ "$GIT_AHEAD" -ne "0" ]; then
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD$GIT_AHEAD"
    fi
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SEPARATOR"
    local clean="0"
    if [ "$GIT_STAGED" -ne "0" ]; then
      clean="1"
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED"
    fi
    if [ "$GIT_CONFLICTS" -ne "0" ]; then
      clean="1"
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CONFLICTS$GIT_CONFLICTS"
    fi
    if [ "$GIT_CHANGED" -ne "0" ]; then
      clean="1"
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED$GIT_CHANGED"
    fi
    if [ "$GIT_UNTRACKED" -ne "0" ]; then
      clean="1"
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    fi
    if [ "$GIT_CHANGED" -eq "0" ] && [ "$GIT_CONFLICTS" -eq "0" ] && [ "$GIT_STAGED" -eq "0" ] && [ "$GIT_UNTRACKED" -eq "0" ]; then
      clean="0"
      STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CLEAN"
    fi
    STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX%{${reset_color}%}"
    if [ $clean -eq "0" ]; then
      prompt_segment green white ""
    else
      prompt_segment yellow white
    fi
    echo -n "$STATUS"
    fi
  }

# Dir: current working directory
prompt_dir() {
  prompt_segment blue white
  echo -n ${${$(expr substr $(pwd) 2 999999)}//\//%{$fg_bold[black]%} "\ue0b1" %{$fg_bold[white]%}}
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment blue black "(`basename $virtualenv_path`)"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_background_jobs() {
  local -a symbols
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙ $(jobs -l | wc -l)" && prompt_segment_diff white cyan "$symbols"
}

prompt_last_command_status(){
  if [[ $RETVAL -ne 0 ]] ;then
    prompt_segment red white "菜$RETVAL"
  fi
}
prompt_show_now_time(){
  prompt_segment blue white "%t"
}
prompt_bettery(){
  if [ -d /sys/class/power_supply/BAT0 ];then
    num="$(cat /sys/class/power_supply/BAT0/capacity)"
    STATUS=$num
    if [ $( cat /sys/class/power_supply/AC/online) -eq "1" ];then
      if [[ $num -ne "100" ]];then
        STATUS=" $STATUS"
      fi
    else
      STATUS="%{$fg[red]%} %{$fg[white]%}$STATUS"
    fi
    if [[ $num -lt 10 ]];then
      prompt_segment_diff red white "$STATUS"
    else
      if [[ $num -gt 90 ]];then
        prompt_segment_diff green white "$STATUS"
      else
        prompt_segment_diff yellow white "$STATUS"
      fi
    fi
  fi
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
  echo -n "\n"
  prompt_show_now_time
  prompt_last_command_status
  prompt_end
}

build_prompt_diff(){
  prompt_bettery
  prompt_background_jobs
}

PROMPT='%{%f%b%k%}$(build_prompt) > '
RPROMPT='%{%f%b%k%}$(build_prompt_diff)'
echo "$fg_bold[blue][$fg_bold[green]$(date -u +"%F") $fg[blue]: $fg_bold[green]$(date -u +"%T")$fg_bold[blue]]"
