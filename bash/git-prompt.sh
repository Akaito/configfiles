# From https://gist.github.com/transat/6694554

# WEDISAGREE terminal prompt. By Clem.

# Change the 16 colours of your default terminal palette to the following Monokai-inspired colours. Do this in your terminal's profile preferences.

# 1st 8 colours: #1D1F21, #F92672, #A6E22E, #FD971F, #1E90FF, #9458FF, #66D9EF, #EDD400
# Next 8 colours: #B294BB, #CC6666, #F92672, #DE935F, #1E90FF, #74B933, #4277AD, #FFFFFF

# Make sure your background colour is the same as the first colour of your palette: #1D1F21
# And set your text colour to #B694D3 and your bold colour to #DA6234

# I use Droid Sans Mono @ 9pt and I also disable bold text in the preferences. You can do what you want.

####################
#### THE PROMPT ####
####################

# Variables for prompt clarity

LBLUE=$'\e[36;40m'
PURPLE=$'\e[35;40m'
GREEN=$'\e[32;40m'
ORANGE=$'\e[33;40m'
YELLOW=$'\e[37;40m'
PINK=$'\e[31;40m'

# This bit enables different colours for your command and output but for it to work you must add yourself to the tty group.
# To do so, enter the following command in your terminal: sudo gpasswd --add <username> tty
# Change <username> to your username of course! 

debug()
{
  echo -n $'\e[0m';
}
trap debug DEBUG

# This bit changes the prompt when you're in a Git repo.

function _git_prompt() {
    local git_status="`git status -unormal 2>&1`"
    if ! [[ "$git_status" =~ [Nn]ot\ a\ git\ repo ]]; then
        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
            local gitcolour="nothing to commit:$YELLOW"
        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
            local gitcolour="untracked:$PINK"
        else
            local gitcolour="branch:$LBLUE"
        fi
        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
            branch=${BASH_REMATCH[1]}
            test "$branch" != master || branch=' '
            #test "$branch" != main || branch=' '
            #[[ "$branch" -eq "master" || "$branch" -eq "main" ]] && branch=' '
        else
            # Detached HEAD.  (branch=HEAD is a faster alternative.)
            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null ||
                echo HEAD`)"
        fi
        echo -n "$gitcolour $branch"
    fi
}

# Colour your prompt

function _prompt_command() {
    PS1='\n\n\[$PINK\]\u \[$LBLUE\]on \[$PURPLE\]\d \[$LBLUE\]at \[$ORANGE\]\@ \[$LBLUE\]in \[$GREEN\]\w \[$ORANGE\]`_git_prompt` \n\[$GREEN\]>> \[$YELLOW\]'
    # Kept repeating existing prompt every time it appeared.  Oops!
    #PS1="\[$ORANGE\]($(_git_prompt)\[$ORANGE\]) $PS1"
}

export PROMPT_COMMAND=_prompt_command

###############################################################################
#### NEEDED BY MY RVM SETUP BUT YOU WILL NEED TO ENTER SOMETHING ELSE HERE ####
############################################################################### 

#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
