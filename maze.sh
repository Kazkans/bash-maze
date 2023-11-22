#1/bin/bash

declare -A board
declare -a neigh
# n = (w-1)/2
cols=$(($(tput lines)/2*2-4))
rows=$(($(tput cols)/2*2-4))

echo $cols $rows
stty -echo
tput clear
tput civis

for i in $(seq 0 $cols);do
	for j in $(seq 0 $rows);do
		key="$i $j"
		board["$key"]='#'
	done
done

check() {
	local keyg="$1 $2" 
	if [[ "${board["$keyg"]}" == "#" ]] ; then
		neigh+=("$keyg")
	fi
}

to_visit() {
	neigh=()
	check $(($1+2)) $(($2))
	check $(($1)) $(($2+2))
	check $(($1-2)) $(($2))
	check $(($1)) $(($2-2))
}

gen_maze() {
	local keyg="$1 $2"
	board["$keyg"]=" "
	to_visit $1 $2
	while [ ${#neigh[@]} -ne 0 ]; do
		pick=${neigh[ $RANDOM % ${#neigh[@]} ]}
		p_i=$(echo $pick | cut -d " " -f 1)
		p_j=$(echo $pick | cut -d " " -f 2)
		a_i=$((($p_i+$1)/2))
		a_j=$((($p_j+$2)/2))
		keyg="$a_i $a_j" 
		board["$keyg"]=" "

		gen_maze $p_i $p_j
		to_visit $1 $2
	done
}

gen_maze 1 1
key="1 1"
for i in $(seq 0 $cols);do
	for j in $(seq 0 $rows);do
		key="$i $j"
		tput cup $i $j
		echo ${board["$key"]}
	done
done


change() {
	if [ "${board["$2 $1"]}" == " " ]; then
		tput cup $y $x
		echo " "
		tput cup $2 $1
		echo -e "\033[0;31mP\033[0m"
		x=$1
		y=$2
		if [ $x -eq $(($rows-1)) -a $y -eq $(($cols-1)) ]; then
			stty echo
			exit
		fi
	fi
}

x=1
y=1
tput cup $x $y
echo -e "\033[0;31mP\033[0m"
tput cup $(($cols-1)) $(($rows-1))
echo -e "\033[0;32mE\033[0m"

while true;do
	read -rsn1 dir
	case $dir in
		w) change $x $(($y-1)) ;;
		s) change $x $(($y+1)) ;;
		a) change $(($x-1)) $y ;;
		d) change $(($x+1)) $y ;;
	esac
done
