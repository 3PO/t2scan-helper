#!/bin/bash


DVBT="dvbt_transmitters_de.csv"
DVBT2="dvbt2_transmitters_de.csv"

if [ ! "$(which t2scan)" ] ; then
  echo -e "\nt2scan ist nicht installiert\n"
  echo -e "Dieses Script benötigt t2scan"
  echo -e "Weitere Informationen unter:\n"
  echo -e "https://github.com/mighty-p/t2scan/ \n"
  exit
fi

PS3="Bitte Empfangsart auswählen : "
select i in DVB-T DVB-T2 Beenden
do
   case "$i" in
      Beenden)
        echo "Beenden"
        exit
        ;;

       "")  
        echo "Ungültige Auswahl"
        ;;

        *)
        echo -e "\n Sie haben $i gewählt \n"
        break
        ;;

   esac
done

if [ "$REPLY" == 1 ] ; then
  SCANFILE="$DVBT"
  TYPE="T"
  SCANTYPE="1"
elif [ "$REPLY" == 2 ] ; then
  SCANFILE="$DVBT2"
  TYPE="T2"
  SCANTYPE="2"
fi

SAVEIFS=$IFS
IFS=$(echo -en "\t") read -ra LAND <<<"$(cut -d ";" -f1 $SCANFILE |sort -u |tr '\n' '\t')"

PS3="Bitte Bundesland auswählen : "
select auswahl in "${LAND[@]}" Beenden
do
   case "$auswahl" in
      Beenden)
        echo "Beenden"
        exit
        ;;

       "")  
        echo "Ungültige Auswahl"
        ;;

        *)
        echo -e "\n Sie haben $auswahl gewählt \n"
        break
        ;;

   esac
done

IFS=$(echo -en "\t") read -ra STATION <<<"$(grep $auswahl $SCANFILE |cut -d ";" -f2 |sort -u |tr '\n' '\t')"

PS3="Bitte Senderstandort auswählen : "
select auswahl in "${STATION[@]}" Beenden
do
   case "$auswahl" in
      Beenden)
        echo "Beenden"
        exit
        ;;

       "")  
        echo "Ungültige Auswahl"
        ;;

        *)
        echo -e "\n Sie haben $auswahl gewählt \n"
        break
        ;;

   esac
done

IFS=$SAVEIFS

SCANLIST="$(grep "$auswahl" $SCANFILE |cut -d ";" -f4 |tr "\n" "," |sed 's/.$//')"

echo -e " Beim Sender $auswahl sind folgende DVB-$TYPE Kanäle verfügbar: $SCANLIST \n"

PARM=""
LOOP=0 
while [ $LOOP -eq 0 ] 
do 
  echo -en " Sollen auch verschlüsselte Kanäle angezeigt werden? [j/n]" 
  read CHOICE 
  echo -en "\n" 
 case $CHOICE in 

   [jJ]|[yY])
   echo -e "\n verschlüsselte Kanäle werden angezeigt.\n"  
   $CASE 
   LOOP=1
   ;; 
  
   [nN])
   echo -e "\n verschlüsselte Kanäle werden nicht angezeigt.\n"
   $CASE
   PARM="-E"
   LOOP=1 
   ;; 
 
   *) echo " Bitte \"j\" oder \"n\" eingeben." 
   LOOP=0
   ;; 

 esac 
done



echo -e " Starte t2scan ...\n"

t2scan -t "$SCANTYPE" "$PARM" -l "$SCANLIST"

