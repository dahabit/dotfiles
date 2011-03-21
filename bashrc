# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s checkwinsize
shopt -s cmdhist
shopt -s cdspell

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

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

function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

if [ `id -u` = 0 ]; then
	COLOUR="04;01;31m"
	PATH_COLOUR="04;01;31m"
	TIME_COLOUR="0;31m"
else
	COLOUR="01;32m"
	PATH_COLOUR="01;34m"
	TIME_COLOUR="0;33m"
fi

PS1='\[\033[$TIME_COLOUR\]$(date +%H:%M)\[\033[00m\] ${debian_chroot:+($debian_chroot)}\[\033[$COLOUR\]\u@\h\[\033[00m\]:\[\033[01;$PATH_COLOUR\]\w\[\033[00m\]\[\033[01;35m\] $(parse_git_branch)\[\033[00m\]\$ '
unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
alias workoff='deactivate'
source /usr/local/bin/virtualenvwrapper.sh
. /etc/bash_completion.d/django_bash_completion
