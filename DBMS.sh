#!/bin/bash
# mkdir DBMS 2>> /dev/null
function mainMenu {
    ch=$(zenity --list \
    --title="Main Menu:" \
    --column="Bug Number" \
    "Create DB" \
    "List DBs" \
    "Select DB" \
    "Drop DB" \
    "Exit")
    echo $ch
    case $ch in
        "Create DB") echo "Create DB";;
        "List DBs") echo "List DBs";;
        "Select DB") echo "Select DB";;
        "Drop DB") echo "Drop DB";;
        "Exit") exit;;
        *) zenity --error --title="Wrong Choice" --text="Please Choose Again"; mainMenu;
    esac
}
mainMenu
