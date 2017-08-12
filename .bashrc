# Setup git prompt.
prompt_git() {
    local s='';
    local branchName='';

    # Check if the current directory is in a git repository.
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

        # Check if the current directory is in .git before running git checks.
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

            # Ensure index is up to date.
            git update-index --really-refresh -q &>/dev/null;

            # Check index for uncommitted changes.
            if ! $(git diff --quiet --ignore-submodules --cached); then
                s+='+';
            fi;

            # Check for unstaged changes.
            if ! $(git diff-files --quiet --ignore-submodules --); then
                s+='!';
            fi;

            # Check for untracked files.
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                s+='?';
            fi;

            # Check for stashed files.
            if $(git rev-parse --verify refs/stash &>/dev/null); then
                s+='$';
            fi;

        fi;

        # Use short symbolic ref as branch name, if HEAD isn't a symbolic ref,
        # use shortened SHA for latest commit, otherwise give up.
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
            git rev-parse --short HEAD 2> /dev/null || \
            echo '(unknown)')";

        [ -n "${s}" ] && s=" [${s}]";

        echo -e "${1}${branchName}${2}${s}";
    else
        return;
    fi;
}

# Display 256 colors.
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM='xterm-256color';
fi;

# Set colors.
if tput setaf 1 &> /dev/null; then
    tput sgr0; # Reset
    bold=$(tput bold);
    reset=$(tput sgr0);
    black=$(tput setaf 0);
    blue=$(tput setaf 33);
    cyan=$(tput setaf 37);
    green=$(tput setaf 64);
    orange=$(tput setaf 166);
    purple=$(tput setaf 125);
    red=$(tput setaf 124);
    violet=$(tput setaf 61);
    white=$(tput setaf 15);
    yellow=$(tput setaf 136);
else
    bold='';
    reset="\e[0m";
    black="\e[1;30m";
    blue="\e[1;34m";
    cyan="\e[1;36m";
    green="\e[1;32m";
    orange="\e[1;33m";
    purple="\e[1;35m";
    red="\e[1;31m";
    violet="\e[1;35m";
    white="\e[1;37m";
    yellow="\e[1;33m";
fi;

# Highlight user when logged in as root.
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}";
else
    userStyle="${orange}";
fi;

# Hightlight host when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}";
else
    hostStyle="${yellow}";
fi;

# Set title and prompt.
PS1="\[\033]0;\W\007\]"; # Working directory base name
PS1+="\[${bold}\]\n"; # Line break
PS1+="\[${userStyle}\]\u"; # User
PS1+="\[${white}\] at ";
PS1+="\[${hostStyle}\]\h"; # Host
PS1+="\[${white}\] in ";
PS1+="\[${green}\]\w"; # Working directory full path
PS1+="\$(prompt_git \"\[${white}\] on \[${violet}\]\" \"\[${blue}\]\")"; # Git details
PS1+="\n";
PS1+="\[${white}\]\$ \[${reset}\]"; # '$' (and reset color)
export PS1;

# Set Vim as the default editor.
export EDITOR="vim"

# Setup general development workspace.
export DEVWORKSPACE="$HOME/Developer"
mkdir -p $DEVWORKSPACE

# Setup Go workspace.
export GOPATH=$DEVWORKSPACE/go
mkdir -p $GOPATH $GOPATH/bin $GOPATH/src/github.com/mmattioli $GOPATH/pkg
export PATH=$PATH:$GOPATH/bin

# Modify default ls behavior.
platform=$(uname)
if [[ "$platform" == 'Linux' ]]; then
    alias ls="ls -lF --color=auto"
elif [[ "$platform" == 'Darwin' ]]; then
    alias ls="ls -lFG"
fi
unset platform

# Extract most known archives with one command.
extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)  tar xjf $1      ;;
            *.tar.gz)   tar xzf $1      ;;
            *.bz2)      bunzip2 $1      ;;
            *.rar)      unrar e $1      ;;
            *.gz)       gunzip $1       ;;
            *.tar)      tar xf $1       ;;
            *.tbz2)     tar xjf $1      ;;
            *.tgz)      tar xzf $1      ;;
            *.zip)      unzip $1        ;;
            *.Z)        uncompress $1   ;;
            *)  echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
