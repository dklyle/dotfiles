# Ghostty shell integration for Bash. This should be at the top of your bashrc!
#if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
#    builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
#fi

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|*ghostty) color_prompt=yes;;
esac

title() {
    prefix=${PS1%%\\a*}
    search=${prefix##*;}
    esearch="${search//\\/\\\\}"
    PS1="${PS1/$esearch/$@}"
    printf "\033]0;$*\007";
}

k8s() {
    if [ -f /home/dlyle/.kube/config.$1 ]; then
        export KUBECONFIG=/home/dlyle/.kube/config.$1
        title "$(echo $KUBECONFIG | awk -F/ '{print $5}' | cut -c 8-)"
    else
        echo "No kubeconfig found for $1"
    fi
}

_k8s_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local options=$(ls /home/dlyle/.kube/config.* 2>/dev/null | xargs -n1 basename | sed 's/^config\.//')
    COMPREPLY=($(compgen -W "${options}" -- "${cur}"))
}
complete -F _k8s_completions k8s

lk8s() {
    # list prompt source is
    # https://github.com/timo-reymann/bash-tui-toolkit/releases/download/1.9.0/prompts.bash
    source ~/.prompts.bash
    local options=($(ls ${HOME}/.kube/config.* | awk -F/ '{print $5}' | cut -c 8-))
    local option=$(list "k8s" "${options[@]}")
    k8s ${options[$option]}
    k8s ${options[$option]}
}

lssh() {
    source ~/.prompts.bash
    local options=($(awk -F\# '/^Host [A-Za-z1-9]/{split($1,a," "); print a[2]}' ${HOME}/.ssh/config))
    local option=$(list "ssh" "${options[@]}")
    echo ""
    echo ""
    echo "\$ ssh ${options[$option]}"
    echo ""
    ssh ${options[$option]}
}

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#get_kube_prompt() {
#    if [ -z ${KUBECONFIG+x} ]; then
#        $(echo "")
#    else
#        echo "$(echo $KUBECONFIG | awk -F/ '{print $5}' | cut -c 8-):"
#    fi
#}

#PROMPT_COMMAND=PS1_CMD='$(get_kube_prompt)'
#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;33m\]$PS1_CMD\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:$PS1_CMD\w\$ '
#fi
#unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac



# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export GOROOT=/usr/local/go
export GOHOME=$HOME/go
export PATH=$GOROOT/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export VAGRANT_HOME=/workspace/vagrant.d
export EDITOR=vi
set -o vi

export VAGRANT_DEFAULT_PROVIDER=libvirt

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="src/ghostty/zig-out/bin:$PATH"
#export PATH="$HOME/src/zig/zig-x86_64-linux-0.14.1:$PATH" # ghostty build 1.2.*
export PATH="$HOME/src/zig/zig-x86_64-linux-0.15.2:$PATH"  # ghostty build tip

export WEBKIT_DISABLE_DMABUF_RENDERER=1

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# opencode
export PATH=/home/dlyle/.opencode/bin:$PATH
alias k="kubectl"
