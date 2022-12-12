#!/bin/bash
mkdir DBMS 2>> /dev/null
function mainMenu {
    ch=$(zenity --list \
    --title="Main Menu" \
    --column="Operations" \
    "Create DB" \
    "List DBs" \
    "Select DB" \
    "Drop DB" \
    "Exit");
    case $ch in
        "Create DB") createDB;;
        "List DBs") listDBs;;
        "Select DB") echo "Select DB";;
        "Drop DB") dropDB;;
        "Exit") exit;;
        *) zenity --error --title="Error Message" --text="Please Choose Again"; mainMenu;;
    esac
}
mainMenu
function createDB {
    dbName=$(zenity --entry --title="Dtabase Name" --text="Enter Database Name");
    mkdir ./DBMS/$dbName 2>> /dev/null;
    if [[ $? == 0 ]]
    then
        zenity --info --title="Info Message" --text="Database Created Successfully";
    else
        zenity --error --title="Error Message" --text="Error Creating Database $dbName";
    fi
    mainMenu;
}
function listDBs {
    list=$(ls -Al ./DBMS/ | grep ^d | wc -l);
    if [[ $list == 0 ]]
    then
        zenity --info --title="Info Message" --text="No Databases To Be Listed";
    else
        zenity --list --title="List of Databases" --column="Database" $(ls -Al ./DBMS/ | cut -d" " -f9);
    fi
    mainMenu;
}
function dropDB {
    dbName=$(zenity --list --title="List of Databases" --column="Database" $(ls -Al ./DBMS/ | cut -d" " -f9));
    if [[ $dbName != "" ]]
    then
        rm -r ./DBMS/$dbName 2>> /dev/null;
        if [[ $? == 0 ]]; then
            zenity --info --title="Info Message" --text="Database Dropped Successfully";
        else
            zenity --error --title="Error Message" --text="Database Not found";
        fi
    fi
    mainMenu;
}