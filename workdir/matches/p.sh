T=4      # nombre de terrains
P=26     # nombre d'inscrits
M=5      # nombre de matches

if [ "$1" != "" ]
then
	T=$1
fi 

if [ "$2" != "" ]
then
	P=$2
fi 

if [ "$3" != "" ]
then
	M=$3
fi 

pick_player() {
	if [ $nbp -ge $P ]
	then
		nbp=0
		unset alreadypicked
		echo "test1 ${alreadypicked[*]}" >> val
	fi
	while true
	do
		nextplayer=$((RANDOM%P))
		if [ "${alreadypicked[$nextplayer]}" != "" ]
		then
			continue
		fi
		break;
	done
	return $nextplayer
}

m=0
nbp=0
#unset alreadypicked
while [ $m -lt $M ]
do
	echo "Match : $((m+1)) ================"
	t=0
	k=0
	while [ $t -lt $T ]
	do
		# 2 paires de joueurs par terrain
		j=0
		while [ $j -lt 4 ]
		do
			while true
			do
				pick_player
				joueur=$?
				ok=1
				i=0
				while [ $i -lt $k ]
				do
					if [ ${jou[$i]} -eq $joueur ]
					then
						ok=0
						break
					else
						i=$((i+1))
					fi
				done
				if [ $ok -eq 1 ]
				then
					jou[$k]=$joueur
					if [ "${nbj[${jou[$k]}]}" == "" ]
					then
						nbj[${jou[$k]}]=1
					else
						nbj[${jou[$k]}]=$((nbj[jou[k]]+1))
					fi
					alreadypicked[$joueur]=1
					nbp=$((nbp+1))
					break
				fi
			done
			j=$((j+1))
			k=$((k+1))
		done
		echo "Terrain $t : J${jou[$t*4]}-J${jou[$t*4+1]} vs J${jou[$t*4+2]}-J${jou[$t*4+3]}"
		t=$((t+1))
	done
	m=$((m+1))
done
echo <<!

	# Nombre de matches par joueur

!

j=0
while [ $j -lt $P ]
do
	echo "J$j : ${nbj[$j]}"
	j=$((j+1))
done
