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
        "Select DB") selectDB;;
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
    list=$(ls -l ./DBMS/ | grep ^d | wc -l);
    if [[ $list == 0 ]]
    then
        zenity --info --title="Info Message" --text="No Databases To Be Listed";
    else
        zenity --list --title="List of Databases" --column="Database" $(ls -l ./DBMS/ | cut -d" " -f9);
    fi
    mainMenu;
}
function dropDB {
    dbName=$(zenity --list --title="List of Databases" --column="Database" $(ls -l ./DBMS/ | cut -d" " -f9));
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
function selectDB {
    dbName=$(zenity --list --title="List of Databases" --column="Database" $(ls -l ./DBMS/ | cut -d" " -f9));
    if [[ $dbName != "" ]]
    then
        cd ./DBMS/$dbName 2>> /dev/null;
        if [[ $? == 0 ]]; then
            zenity --info --title="Info Message" --text="Database $dbName was Successfully Selected";
            tableMenu;
        else
            zenity --error --title="Error Message" --text="Database $dbName wasn't found";
            mainMenu;
        fi
    fi
}
function tableMenu {
    ch=$(zenity --list \
    --title="Table Menu" \
    --column="Operations" \
    "Create Table" \
    "List Tables" \
    "Drop Table" \
    "Insert Into Table" \
    "Select From Table" \
    "Delete From Table" \
    "Update Table" \
    "Back To Main Menu" \
    "Exit");
    case $ch in
        "Create Table") echo "Create Table";;
        "List Tables") listTables;;
        "Drop Table") dropTable;;
        "Insert Into Table") echo "Insert Into Table";;
        "Select From Table") echo "Select From Table";;
        "Delete From Table") echo "Delete From Table";;
        "Update Table") echo "Update Table";;
        "Back To Main Menu") cd ../.. 2>> /dev/null; mainMenu;;
        "Exit") exit;;
        *) zenity --error --title="Error Message" --text="Please Choose Again"; tableMenu;;
    esac
}
function listTables {
    list=$(ls -l | grep ^- | wc -l);
    if [[ $list == 0 ]]
    then
        zenity --info --title="Info Message" --text="No Tables To Be Listed";
    else
        zenity --list --title="List of Tables" --column="Tables" $(ls -l | cut -d" " -f9);
    fi
    tableMenu;
}
function dropTable {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        rm $tableName .$tableName 2>> /dev/null;
        if [[ $? == 0 ]]; then
            zenity --info --title="Info Message" --text="Table Dropped Successfully";
        else
            zenity --error --title="Error Message" --text="Table Not found";
        fi
    fi
    tableMenu;
}