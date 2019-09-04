setopt PROMPT_SUBST

# Setup git prompt.
prompt_git() {
    local s='';
    local branchName='';

    # Check if the current directory is in a git repository.
    if [[ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]]; then

        # Check if the current directory is in .git before running git checks.
        if [[ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]]; then

            # Ensure index is up to date.
            git update-index --really-refresh -q &>/dev/null;

            # Check index for uncommitted changes.
            if ! $(git diff --quiet --ignore-submodules --cached); then
                s+='+';
            fi;

            # Check for unstaged changes.
            if ! $(git diff-files --quiet --ignore-submodules); then
                s+='!';
            fi;

            # Check for untracked files.
            if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
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

        [[ -n "${s}" ]] && s=" [${s}]";

        echo -e "${1}${branchName}${2}${s}";
    else
        return;
    fi;
}

# Setup PS1 prompt.
prompt_ps1() {

    # Construct prompt.
    PS1="%B";
    PS1+="%F{cyan}%n%f"; # Username.
    PS1+="%F{white} at %f";
    PS1+="%F{yellow}%m%f";  # Hostname up to the first '.'.
    PS1+="%F{white} in %f";
    PS1+="%F{green}%~%f"; # Current directory relative to $HOME.
    PS1+="\$(prompt_git \"%F{white} on %f%F{magenta}\" \"%f\")"; # Git details.
    PS1+="\n";
    PS1+="%F{white}$ %f%b"; # Reset.

    echo -e $PS1;

}
export PS1=$(prompt_ps1)

# Setup general development workspace.
export DEVWORKSPACE="$HOME/Developer"
mkdir -p $DEVWORKSPACE

# Setup Go workspace.
export GOPATH=$DEVWORKSPACE/go
mkdir -p $GOPATH $GOPATH/bin $GOPATH/src $GOPATH/pkg

# Modify default ls behavior.
platform=$(uname)
if [[ "$platform" == 'Linux' ]]; then
    alias ls="ls -lhpF --color=auto"
elif [[ "$platform" == 'Darwin' ]]; then
    alias ls="ls -lhpFG"
fi
unset platform

# Modify default grep behavior.
alias grep="grep --color=auto"
