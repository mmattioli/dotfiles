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

# Set colors.
base03=$(tput setaf 234)
base02=$(tput setaf 235)
base01=$(tput setaf 240)
base00=$(tput setaf 241)
base0=$(tput setaf 244)
base1=$(tput setaf 245)
base2=$(tput setaf 254)
base3=$(tput setaf 230)
yellow=$(tput setaf 136)
orange=$(tput setaf 166)
red=$(tput setaf 160)
magenta=$(tput setaf 125)
violet=$(tput setaf 61)
blue=$(tput setaf 33)
cyan=$(tput setaf 37)
green=$(tput setaf 64)

# Set title and prompt.
PS1="\[$(tput bold)\]";
PS1+="\[${orange}\]\u"; # User
PS1+="\[${base2}\] at ";
PS1+="\[${yellow}\]\h"; # Host
PS1+="\[${base2}\] in ";
PS1+="\[${green}\]\w"; # Working directory full path.
PS1+="\$(prompt_git \"\[${base2}\] on \[${violet}\]\" \"\[${blue}\]\")"; # Git details.
PS1+="\n";
PS1+="\[${base2}\]\$ \[$(tput sgr0)\]"; # Show '$' and reset colors.
export PS1;

# Cleanup.
unset base03
unset base02
unset base01
unset base00
unset base0
unset base1
unset base2
unset base3
unset yellow
unset orange
unset red
unset magenta
unset vioelt
unset blue
unset cyan
unset green

# Set Atom as the default editor.
export EDITOR="atom --wait"

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
    alias ls="ls -lFp --color=auto"
elif [[ "$platform" == 'Darwin' ]]; then
    alias ls="ls -lFGp"
fi
unset platform # Cleanup.

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
