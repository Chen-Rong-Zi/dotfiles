bookmark=''


marco(){
    bookmark=$(pwd)
    echo "saved $bookmark to bookmark!" | lolcat
    echo $bookmark >| /tmp/bookmark
}


polo(){
    bookmark=$(cat /tmp/bookmark)
    now=$(pwd)
    if [[ $bookmark == '' ]]; then
        echo "no bookmark !!!" | lolcat
        return 1
    fi
    echo "from:$now --> now:$bookmark" | lolcat
    cd $bookmark
}
