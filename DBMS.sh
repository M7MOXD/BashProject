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
        *) zenity --error --title="Error Message" --text="Wrong Choice"; mainMenu;;
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
        if [[ $? == 0 ]]
        then
            zenity --info --title="Info Message" --text="Database Dropped Successfully";
        fi
    fi
    mainMenu;
}
function selectDB {
    dbName=$(zenity --list --title="List of Databases" --column="Database" $(ls -l ./DBMS/ | cut -d" " -f9));
    if [[ $dbName != "" ]]
    then
        cd ./DBMS/$dbName 2>> /dev/null;
        if [[ $? == 0 ]]
        then
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
        "Create Table") createTable;;
        "List Tables") listTables;;
        "Drop Table") dropTable;;
        "Insert Into Table") insert;;
        "Select From Table") echo "Select From Table";;
        "Delete From Table") deleteFromTable;;
        "Update Table") echo "Update Table";;
        "Back To Main Menu") cd ../.. 2>> /dev/null; mainMenu;;
        "Exit") exit;;
        *) zenity --error --title="Error Message" --text="Wrong Choice"; tableMenu;;
    esac
}
function createTable {
    tableName=$(zenity --entry --title="Table Name" --text="Enter Table Name");
    if [[ -f $tableName ]]
    then
        zenity --error --title="Error Message" --text="table already existed ,choose another name";
        tableMenu;
    fi
    colsNum=$(zenity --entry --title="Number of Columns" --text="Enter Number of Columns");
    counter=1;
    sep=":";
    rSep="\n";
    pKey="";
    metaData="Field"$sep"Type"$sep"key";
    while [[ $counter -le $colsNum ]]
    do
        colName=$(zenity --entry --title="Name of Column No.$counter" --text="Enter Name of Column No.$counter");
        chType=$(zenity --list \
        --title="Column Type" \
        --column="Type" \
        "int" \
        "str");
        case $chType in
            "int") colType="int";;
            "str") colType="str";;
            *) zenity --error --title="Error Message" --text="Wrong Choice"; tableMenu;;
        esac
        if [[ $pKey == "" ]]
        then
            chPK=$(zenity --list \
            --title="Make PK" \
            --column="Answer" \
            "Yes" \
            "No");
            case $chPK in
                "Yes") pKey="PK"; metaData+=$rSep$colName$sep$colType$sep$pKey;;
                "No") metaData+=$rSep$colName$sep$colType$sep"";;
                *) metaData+=$rSep$colName$sep$colType$sep"";;
            esac
        else
            metaData+=$rSep$colName$sep$colType$sep"";
        fi
        if [[ $counter == $colsNum ]]
        then
            temp=$temp$colName;
        else
            temp=$temp$colName$sep;
        fi
        ((counter++));
    done
    touch $tableName .$tableName;
    echo -e $metaData  >> .$tableName;
    echo -e $temp >> $tableName;
    if [[ $? == 0 ]]
    then
        zenity --info --title="Info Message" --text="Table Created Successfully";
        tableMenu;
    else
        zenity --error --title="Error Message" --text="Error Creating Table $tableName";
        tableMenu;
    fi
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
        fi
    fi
    tableMenu;
}
function insert {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        colsNum=$(awk 'END{print NR}' .$tableName);
        sep=":";
        rSep="\n";
        for (( i = 2; i <= $colsNum; i++ ))
        do
            colName=$(awk 'BEGIN{FS=":"}{ if(NR=='$i') print $1}' .$tableName);
            colType=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $2}' .$tableName);
            colKey=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $3}' .$tableName);
            data=$(zenity --entry --title="Column: $colName" --text="Enter Value of Type $colType");
            if [[ $colType == "int" ]]
            then
                while ! [[ $data =~ ^[0-9]*$ ]]
                do
                    zenity --error --title="Error Message" --text="Invalid Data Type";
                    data=$(zenity --entry --title="Column: $colName" --text="Enter Value of Type $colType");
                done
            fi
            if [[ $colKey == "PK" ]]
            then
                while [[ true ]]
                do
                    if [[ $data =~ ^[$(awk 'BEGIN{FS=":"; ORS=" "}{if (NR != 1) print $(('$i'-1))}' $tableName 2>> /dev/null)]$ ]]
                    then
                        zenity --error --title="Error Message" --text="Invalid Input for PK";
                        data=$(zenity --entry --title="Column: $colName" --text="Enter Value of Type $colType");
                    else
                        break;
                    fi
                done
            fi
            if [[ $i == $colsNum ]]
            then
                row=$row$data$rSep;
            else
                row=$row$data$sep;
            fi
        done
        echo -e $row"\c" >> $tableName;
        if [[ $? == 0 ]]
        then
            zenity --info --title="Info Message" --text="Data Inserted Successfully";
        else
            zenity --error --title="Error Message" --text="Error Inserting Data into Table $tableName";
        fi
        row="";
    fi
    tableMenu;
}
function deleteFromTable {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        colsNum=$(awk 'END{print NR}' .$tableName);
        sep=":";
        rSep="\n";
        for (( i = 2; i <= $colsNum; i++ ))
        do
            colName=$(awk 'BEGIN{FS=":"}{ if(NR=='$i') print $1}' .$tableName);
            colType=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $2}' .$tableName);
            colKey=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $3}' .$tableName);
            ((fID=$i-1))
            if [[ $colKey == "PK" ]]
            then
                break;
            fi
        done
        val=$(zenity --entry --title="PK $colName" --text="Enter Value");
        if [[ $val != "" ]]
        then
            res=$(awk 'BEGIN{FS=":"}{if ($'$fID'=="'$val'") print $'$fID'}' $tableName)
            if [[ $res != "" ]]
            then
                NR=$(awk 'BEGIN{FS=":"}{if ($'$fID'=="'$val'") print NR}' $tableName)
                sed -i ''$NR'd' $tableName 2>> /dev/null
                if [[ $? == 0 ]]
                then
                    zenity --info --title="Info Message" --text="Row Deleted Successfully";
                else
                    zenity --error --title="Error Message" --text="Error Deleting Data From Table $tableName";
                fi
            else
                zenity --error --title="Error Message" --text="Value not Found"
            fi
            tableMenu;
        fi
    fi
    tableMenu;
}