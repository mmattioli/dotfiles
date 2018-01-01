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

# Setup PS1 prompt.
prompt_ps1() {

    # Solarized colors.
    local base03=$(tput setaf 234)
    local base02=$(tput setaf 235)
    local base01=$(tput setaf 240)
    local base00=$(tput setaf 241)
    local base0=$(tput setaf 244)
    local base1=$(tput setaf 245)
    local base2=$(tput setaf 254)
    local base3=$(tput setaf 230)
    local yellow=$(tput setaf 136)
    local orange=$(tput setaf 166)
    local red=$(tput setaf 160)
    local magenta=$(tput setaf 125)
    local violet=$(tput setaf 61)
    local blue=$(tput setaf 33)
    local cyan=$(tput setaf 37)
    local green=$(tput setaf 64)

    local bold=$(tput bold)
    local reset=$(tput sgr0)

    # Construct prompt.
    PS1="\[${bold}\]";
    PS1+="\[${orange}\]\u";
    PS1+="\[${base2}\] at ";
    PS1+="\[${yellow}\]\h";
    PS1+="\[${base2}\] in ";
    PS1+="\[${green}\]\w";
    PS1+="\$(prompt_git \"\[${base2}\] on \[${violet}\]\" \"\[${blue}\]\")"; # Git details.
    PS1+="\n";
    PS1+="\[${base2}\]\$ \[${reset}\]";

    export PS1;

}
prompt_ps1

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
unset platform
