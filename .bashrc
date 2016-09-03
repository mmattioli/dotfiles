# ensure vim base16-solarized-dark color scheme is installed
vim_color_name="base16-solarized-dark.vim"
vim_color_url="https://raw.githubusercontent.com/chriskempson/base16-vim/master/colors/base16-solarized-dark.vim"
if ! [ -e ~/.vim/colors/$vim_color_name ]; then
    echo "Installing Solarized color scheme..."
    if ! [ -d ~/.vim/colors ]; then
        echo "Creating Vim colors directory..."
        mkdir -p ~/.vim/colors
    fi
    curl -o ~/.vim/colors/$vim_color_name $vim_color_url
fi
unset vim_color_name
unset vim_color_url

# determine whether or not the current git branch is dirty or clean
function parse_git_dirty {
    [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working directory clean" ]] && echo "*"
}

# get the current checked out git branch
function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}

# set prompt
export PS1='\u@\h \[\033[1;33m\]\w\[\033[0m\]$(parse_git_branch)$ '

# set vim as the default editor
export EDITOR="vim"

# set Go workspace
export GOPATH=~/Git/Go

# modify default ls behavior
platform=$(uname)
if [[ "$platform" == 'Linux' ]]; then
    alias ls="ls -lF --color=auto"
elif [[ "$platform" == 'Darwin' ]]; then
    alias ls="ls -lFG"
fi
unset platform

# extract most known archives with one command
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
