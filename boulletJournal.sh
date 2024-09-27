#!/bin/bash
now=$(date -d "last monday" +"%Y%m%d");
file=s.csv

WHITE='\033[0m';
RED='\033[00;31m'
GREEN='\033[00;32m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
STRICKETHROUGH='\e[9mstrikethrough\e[0m'

clear

if [ ! -e "$file" ]; then
    touch "$file"
fi

echo -e "\e[4mBoullet Journal\e[0m"

printEntry(){
	if [ ! -z $1 ]
	then
		echo "# $1"
	fi
	grep $1, $file | while IFS=',' read -r fecha tarea estado inicio fin histories; do
		case $estado in
  			A) color=$BLUE;;
  			B) color=$RED;;
			D) color=$STRICKETHROUGH;;
  			X) color=$GREEN;;
  			-) color=$YELOOW;;
			*) color=$WHITE;;
		esac
    	echo -e "$color [$estado] $tarea: $inicio - $fin"
		IFS='@'
		for history in $histories; do
			echo -e "\t $history" | tr '#' ' ' 
		done	done
	echo -e "$WHITE\n"
}

getActualWeek(){
	contador=0
	while [ $contador -le 5 ]; do
		printEntry $(date -d "$now +$contador days" +"%Y%m%d");
	    ((contador++)) 
	done
}

addEntry(){
	read -p "Entry task: " newTask
	newTask="${newTask^^}"
	exist=$(grep $newTask $file)
	if [ ! -z $exist ]
	then
		echo "Sorry, entry exist, please, search from the menu"
	else
		echo $now,$newTask,,, >> $file
	fi

	echo "Entry saved"
}

editEntry(){
	read -p "Select task: " editTask
	editTask="${editTask^^}"
	old=$(grep $editTask $file)
	linea=$(grep -n  $editTask $file | cut -d':' -f1)
	echo -e ">>> " $old "\n"
	read -p "Select replace (1. start date/2. finish date /3. status): " replace
 
	fechaRegistro=$(echo "$old" | cut -d',' -f1)
	task=$(echo "$old" | cut -d',' -f2)
	status=$(echo "$old" | cut -d',' -f3)
	start=$(echo "$old" | cut -d',' -f4)
	finish=$(echo "$old" | cut -d',' -f5)
	history=$(echo "$old" | cut -d',' -f6)

	if [ $replace == 3 ]
	then
		echo "Ask add finish value automatic"
	fi

	read -p "Select new $replace: " newValue
	newValue="${newValue^^}"

		case $replace in
  			1) start=$newValue;;
  			2) finish=$newValue;;
  			3) 
				status=$newValue
				finish=$now
				if [ ! -z $history ]
				then
					history+="@"
				fi
				history+="$now#$status"	;;
  			
			*) echo "Error";;
		esac


	newEntry=$fechaRegistro,$task,$status,$start,$finish,$history

	sed -i "${linea}s/.*/$newEntry/" $file
	echo "Entry edit: " $newEntry
}

search(){
 read -p "Search: " searchValue
 	searchValue="${searchValue^^}"
	printEntry $searchValue
}

menu=" \t0. Exit \n \t1. This date \n \t2. GetAll \n \t3. Search (ask, status, date) \n \t4. Add \n \t5. Edit \n \t8. Clear Windows \n \t9. Help";

while true; do
    echo -e $menu
    read -p "Select option: " op 
    case $op in
	[0]* ) 
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s
		break;; 
	[1]* ) 
		getActualWeek
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s;;
	[2]* ) 
		printEntry
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s;;
	[3]* ) 
		search
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s;;
	[4]* ) 
		addEntry
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s;;
	[5]* ) 
		editEntry
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s;;
	[8]* ) clear;;	
	[9]* ) 
		echo -e "File exist in path $file. \nStructure's file is: date create, task, status, start date, finish date, history change status (date#status)\nStatus List: \n empty \t No working (color white) \n B \t Block (color red)\n D \t DELETE (strikethrough)\n X \t Done (color green) \n - \t pospuesto (color yellow)"
		echo "Presiona cualquier tecla para continuar..."
		read -n 1 -s;;
        * ) echo "Seleccione una Opción de 1 a 5.";;
    esac
done

