# from https://github.com/laurenkt/zsh-vimto
# Vim mode
bindkey -v

# Don't take 0.4s to change modes
export KEYTIMEOUT=1

# Save previous RPROMPT to restore when vim status not displayed
RPROMPT_PREVIOUS=$RPROMPT

# Default color settings
if [ -z "$VIMTO_COLOR_NORMAL_TEXT" ]; then VIMTO_COLOR_NORMAL_TEXT=black; fi
if [ -z "$VIMTO_COLOR_NORMAL_BACKGROUND" ]; then VIMTO_COLOR_NORMAL_BACKGROUND=white; fi
function zle-keymap-select zle-line-init {
	# If it's not tmux then can use normal sequences
	if [[ -z "${TMUX}" ]]; then
		local vicmd_seq="\e[2 q"
		local viins_seq="\e[0 q"
	else
		# In tmux, escape sequences to pass to terminal need to be
		# surrounded in a DSC sequence and double-escaped:
		# ESC P tmux; {text} ESC \
		# <http://linsam.homelinux.com/tmux/tmuxcodes.pdf>
		local vicmd_seq="\ePtmux;\e\e[2 q\e\\"
		local viins_seq="\ePtmux;\e\e[0 q\e\\"
	fi
	RPROMPT=$'$(prompt_segment_diff white black $KEYMAP&&build_prompt_diff)'
	# Command mode
	if [ $KEYMAP = vicmd ]; then
		local active=${REGION_ACTIVE:-0}
		RPROMPT=$'$(prompt_segment_diff white black "NORMAL"&&build_prompt_diff)'
		if [[ $active = 1 ]]; then
			RPROMPT=$'$(prompt_segment_diff white black "VISUAL"&&build_prompt_diff)'
        elif [[ $active = 2 ]]; then
			RPROMPT=$'$(prompt_segment_diff white black "V-LINE"&&build_prompt_diff)'
        fi
	# Insert mode
	else

		[[ $ZLE_STATE = *overwrite* ]] &&
			RPROMPT=$'$(prompt_segment_diff red white "REPLAC"&&build_prompt_diff)' ||
			RPROMPT=$'$(prompt_segment_diff blue white "INSERT"&&build_prompt_diff)'
	fi
	zle reset-prompt
}

function accept-line-clear-rprompt {
	export RPROMPT=$'$(prompt_segment_diff blue white "INSERT"&&build_prompt_diff)'
    zle reset-prompt
    zle accept-line
}

zle -N accept-line-clear-rprompt
# Hook enter being pressed whilst in cmd mode
bindkey -M vicmd "^M" accept-line-clear-rprompt

# Change appearance
zle -N zle-keymap-select  # When vi mode changes
zle -N zle-line-init      # When a new line starts

# Fix backspace not working after returning from cmd mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# Re-enable incremental search from emacs mode (it's useful)
bindkey '^r' history-incremental-search-backward

# Need to initially clear RPROMPT for it to work on first prompt
export RPROMPT=$RPROMPT_PREVIOUS


vim-mode-line-pre-redraw  () {  zle-keymap-select "line" }

autoload -Uz add-zle-hook-widget
() {
    local w; for w in "$@"; do add-zle-hook-widget $w vim-mode-$w; done
} line-pre-redraw