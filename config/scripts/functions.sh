nopad(){
    pad_id=$(xinput list | grep -Eio 'pad.*id=([1-9]+)' | cut -d"=" -f2)
    xdotool mousemove 1920 1080
    xinput set-prop $pad_id 'Device Enabled' 0
}

pad(){
    pad_id=$(xinput list | grep -Eio 'pad.*id=([1-9]+)' | cut -d"=" -f2)
    xinput set-prop $pad_id 'Device Enabled' 1
    xdotool mousemove 960 540
}

debug() {
    export core_name="$(/bin/ls -r $core_dir| head -n 1)"
    export core_path="$core_dir/$core_name"
    gdb $bin "$core_path"
}

fj() {
    path=$(fzf)
    if [[ $(file $path 2>/dev/null | awk  '{print $2}') == 'directory' ]];then
        joshuto $path
    elif [[ $path == '' ]];then
        echo -e $bold$fg_red$bg_white"didn't find path"$origin
    else
        joshuto $( echo $path | awk -F / -v OFS=/ '{$NF="";print}' ) 
    fi
}

jo() {
    if [[ $(file $1 2>/dev/null | awk  '{print $2}') == 'directory' ]];then
        echo 1
        joshuto $1
    elif [[ -z $1 ]];then
        joshuto ./
    else
        echo 3
        joshuto $( echo $1 | awk -F / -v OFS=/ '{$NF="";print}' )
    fi
}

rn() {
    if [[ $# -eq 0 ]]; then
        python3 -c "a=list(range(10));print(a)"
    elif [[ $# -eq 1 ]]; then
        python3 -c "a=list(range($1));print(a)"
    elif [[ $# -eq 2 ]]; then
        python3 -c "a=list(range($1, $2));print(a)"
    elif [[ $# -eq 3 ]]; then
        python3 -c "a=list(range($1, $2, $3));print(a)"
    elif [[ $# -eq 4 ]]; then
        python3 -c "a=set(list(range($1, $2, $3)));print(a)"
    fi
}

vman() {
#     export MANPAGER="col -b" # for FreeBSD/MacOS

    # Make it read-only
    [[ -n "$(man $@ 2>/dev/null)" ]]  &&  man $@ 2>/dev/null | vim -MR +"set filetype=man" -
}

