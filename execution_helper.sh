[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

function car { 
    echo $* | awk '{ print $1 }' 
}

function cdr { 
    echo $* | awk '{ for (i = NR + 1; i <= NF; i++) print $i }' 
}

function sep {
    in_red "-----------------------------------------------------------------"
    echo
}

function in_red {
    tput sgr0
    tput setaf 1; 
    tput setab 7; 
    echo -n $1; 
    tput sgr0
}

function show_running_with {
    echo -e "\n"
    sep
    in_red "|"
    echo -n " "
    tput setaf 4
    echo -n "Running tests with: "
    tput bold; 
    tput setaf 0
    ruby --version
    sep
    echo 
}

function run_command_with {
    rvm use `car $*`
    show_running_with
    `cdr $*`
}

