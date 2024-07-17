#!/bin/bash


blue() {
    echo -e "\e[34m$1\e[0m"
}

green() {
    echo -e "\e[32m$1\e[0m"
}

yellow() {
    echo -e "\e[33m$1\e[0m"
}

red() {
    echo -e "\e[31m$1\e[0m"
}

test() {
    blue "++ Command : $1"
    if [ -z "$2" ]; then
        # No redirection, capture the output directly
	commande=$(eval "$1") #2>&1)
        if [ $? -eq 0 ]; then
            green "$commande\n"
        else
            red "[ERROR] $commande\n"
        fi
    else
        # Redirect output to specified file
        eval "$1" >> "$2" 2>&1
        if [ $? -eq 0 ]; then
            green "Command output appended to $2\n"
        else
            red "[ERROR] Command failed, check $2 for details.\n"
        fi
    fi
}
echo

test "file $1"
test "binwalk -e $1"
yellow "Extract : binwalk --dd='.*' $1\n"
test "exiftool -a -s -sort -G $1"
test "strings -n 6 $1" "$2"
test "steghide info $1"
yellow "Extract : steghide extract -sf $1"

echo
echo "#######################################################"
echo "                      PNG"
echo "#######################################################"
echo

test "pngcheck $1"
