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
function createDB {
    dbName=$(zenity --entry --title="Dtabase Name" --text="Enter Database Name");
    if [[ $dbName != "" ]]
    then
        mkdir ./DBMS/$dbName 2>> /dev/null;
        if [[ $? == 0 ]]
        then
            zenity --info --title="Info Message" --text="Database Created Successfully";
        else
            zenity --error --title="Error Message" --text="Error Creating Database $dbName";
        fi
    fi
    mainMenu;
}
function listDBs {
    list=$(ls -l ./DBMS/ | grep ^d | wc -l);
    if [[ $list != 0 ]]
    then
        zenity --list --title="List of Databases" --column="Database" $(ls -l ./DBMS/ | cut -d" " -f9);
    else
        zenity --info --title="Info Message" --text="No Databases To Be Listed";
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
        fi
    fi
    mainMenu;
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
        "Select From Table") selectMenu;;
        "Delete From Table") deleteFromTable;;
        "Update Table") updateTable;;
        "Back To Main Menu") cd ../..; mainMenu;;
        "Exit") exit;;
        *) zenity --error --title="Error Message" --text="Wrong Choice"; tableMenu;;
    esac
}
function createTable {
    tableName=$(zenity --entry --title="Table Name" --text="Enter Table Name");
    if [[ -f $tableName ]]
    then
        zenity --error --title="Error Message" --text="Table Already Existed, Choose Another Name";
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
            *) tableMenu;;
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
    else
        zenity --error --title="Error Message" --text="Error Creating Table $tableName";
    fi
    tableMenu;
}
function listTables {
    list=$(ls -l | grep ^- | wc -l);
    if [[ $list != 0 ]]
    then
        zenity --list --title="List of Tables" --column="Tables" $(ls -l | cut -d" " -f9);
    else
        zenity --info --title="Info Message" --text="No Tables To Be Listed";
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
            colName=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $1}' .$tableName);
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
                    if [[ $data =~ ^[$(awk 'BEGIN{FS=":"; ORS=" "}{if(NR!=1) print $(('$i'-1))}' $tableName 2>> /dev/null)]$ ]]
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
        for (( i = 2; i <= $colsNum; i++ ))
        do
            colName=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $1}' .$tableName);
            colKey=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $3}' .$tableName);
            ((fID=$i-1));
            if [[ $colKey == "PK" ]]
            then
                break;
            fi
        done
        pkValue=$(zenity --entry --title="PK $colName" --text="Enter Value");
        if [[ $pkValue != "" ]]
        then
            res=$(awk 'BEGIN{FS=":"}{if($'$fID'=="'$pkValue'") print $'$fID'}' $tableName);
            if [[ $res != "" ]]
            then
                NR=$(awk 'BEGIN{FS=":"}{if($'$fID'=="'$pkValue'") print NR}' $tableName);
                sed -i ''$NR'd' $tableName 2>> /dev/null;
                if [[ $? == 0 ]]
                then
                    zenity --info --title="Info Message" --text="Row Deleted Successfully";
                else
                    zenity --error --title="Error Message" --text="Error Deleting Data From Table $tableName";
                fi
            else
                zenity --error --title="Error Message" --text="Value not Found";
            fi
        fi
    fi
    tableMenu;
}
function updateTable {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        colsNum=$(awk 'END{print NR}' .$tableName);
        for (( i = 2; i <= $colsNum; i++ ))
        do
            colName=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $1}' .$tableName);
            colKey=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $3}' .$tableName);
            ((fID=$i-1));
            if [[ $colKey == "PK" ]]
            then
                break;
            fi
        done
        pkValue=$(zenity --entry --title="PK $colName" --text="Enter Value");
        if [[ $pkValue != "" ]]
        then
            res=$(awk 'BEGIN{FS=":"}{if($'$fID'=="'$pkValue'") print $'$fID'}' $tableName);
            if [[ $res != "" ]]
            then
                setField=$(zenity --list --title="Tables Fields" --column="Filed" $(awk 'BEGIN{FS=":"; ORS=" "}{if(NR!=1) print $1}' .$tableName));
                if [[ $setField != "" ]]
                then
                    setFid=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1; i<=NF; i++){if($i=="'$setField'") print i}}}' $tableName);
                    newValue=$(zenity --entry --title="$setField New Value" --text="Enter $setField New Value");
                    NR=$(awk 'BEGIN{FS=":"}{if($'$fID'=="'$pkValue'") print NR}' $tableName);
                    oldValue=$(awk 'BEGIN{FS=":"}{if(NR=='$NR'){for(i=1; i<=NF; i++){if(i=='$setFid') print $i}}}' $tableName);
                    sed -i ''$NR's/'$oldValue'/'$newValue'/g' $tableName 2>> /dev/null;
                    if [[ $? == 0 ]]
                    then
                        zenity --info --title="Info Message" --text="Row Updated Successfully";
                    else
                        zenity --error --title="Error Message" --text="Error Updating Data From Table $tableName";
                    fi
                fi
            else
                zenity --error --title="Error Message" --text="Value not Found";
            fi
        fi
    fi
    tableMenu;
}
function selectMenu {
    ch=$(zenity --list \
    --title="Select Menu" \
    --column="Operations" \
    "Select All" \
    "Select a Column" \
    "Select a Record" \
    "Back To Table Menu" \
    "Back To Main Menu" \
    "Exit");
    case $ch in
        "Select All") selectAll;;
        "Select a Column") selectColumn;;
        "Select a Record") selectRecord;;
        "Back To Table Menu") tableMenu;;
        "Back To Main Menu") cd ../..; mainMenu;;
        "Exit") exit;;
        *) zenity --error --title="Error Message" --text="Wrong Choice"; selectMenu;;
    esac
}
function selectAll {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        allRecords=$(awk 'BEGIN{FS=":"}{if(NR!=1){for(i=1; i<=NF; i++){print $i}}}' $tableName);
        if [[ $allRecords != "" ]]
        then
            zenity --list --title="List of Records" $(awk 'BEGIN{FS=":"; ORS=" "}{if(NR!=1) print "--column="$1}' .$tableName) $(awk 'BEGIN{FS=":"}{if(NR!=1){for(i=1; i<=NF; i++){print $i}}}' $tableName);
        else
            zenity --info --title="Info Message" --text="Table is Empty";
        fi
    fi
    selectMenu;
}
function selectColumn {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        setField=$(zenity --list --title="Tables Fields" --column="Filed" $(awk 'BEGIN{FS=":"; ORS=" "}{if(NR!=1) print $1}' .$tableName));
        if [[ $setField != "" ]]
        then
            setFid=$(awk 'BEGIN{FS=":"}{if(NR==1){for(i=1; i<=NF; i++){if($i=="'$setField'") print i}}}' $tableName);
            columnRecords=$(awk 'BEGIN{FS=":"}{if(NR!=1) print $'$setFid'}' $tableName);
            if [[ $columnRecords != "" ]]
            then
                zenity --list --title="List of Column Records" --column=$setField $(awk 'BEGIN{FS=":"}{if(NR!=1) print $'$setFid'}' $tableName);
            else
                zenity --info --title="Info Message" --text="Table is Empty";
            fi
        fi
    fi
    selectMenu;
}
function selectRecord {
    tableName=$(zenity --list --title="List of Tables" --column="Table" $(ls -l | cut -d" " -f9));
    if [[ $tableName != "" ]]
    then
        colsNum=$(awk 'END{print NR}' .$tableName);
        for (( i = 2; i <= $colsNum; i++ ))
        do
            colName=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $1}' .$tableName);
            colKey=$(awk 'BEGIN{FS=":"}{if(NR=='$i') print $3}' .$tableName);
            ((fID=$i-1));
            if [[ $colKey == "PK" ]]
            then
                break;
            fi
        done
        pkValue=$(zenity --entry --title="PK $colName" --text="Enter Value");
        if [[ $pkValue != "" ]]
        then
            res=$(awk 'BEGIN{FS=":"}{if($'$fID'=="'$pkValue'") print $'$fID'}' $tableName);
            if [[ $res != "" ]]
            then
                zenity --list --title="The Record" $(awk 'BEGIN{FS=":"; ORS=" "}{if(NR!=1) print "--column="$1}' .$tableName) $(awk 'BEGIN{FS=":"}{if(NR!=1 && $'$fID'=='$pkValue'){for(i=1; i<=NF; i++){print $i}}}' $tableName);
            else
                zenity --error --title="Error Message" --text="Value not Found";
            fi
        fi
    fi
    selectMenu;
}
mainMenu;