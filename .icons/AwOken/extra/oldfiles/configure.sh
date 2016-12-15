#!/bin/bash

RCFILE=".AwOkenrc"
CONFIG_FILE="$HOME/$RCFILE"
VER="2.3"
ICNST="AwOken"

clear
echo "*************************************************************************"
echo "CONFIGURATION SCRIPT"
echo " "

if [ $1 ]; then
	ICONSDIR=$1
	echo "I'm using this path for iconset in configuration process: $ICONSDIR"
else
	cd ../
	ICONSDIR=`pwd`
	echo "I'm using this path for iconset in configuration process: $ICONSDIR"
fi

echo "*************************************************************************"

cp $ICONSDIR/$RCFILE $CONFIG_FILE
source $CONFIG_FILE
echo "Now I'll modify the configuration file located in $CONFIG_FILE."
echo "*************************************************************************"
echo "What kind of folder type do you prefer? (Type the number of your choice)" 
TARGET_KEY="folder_type"
PS3="$TARGET_KEY? "
select TIPO in "dark" "gray" "metal" "tlagdark" "tlaglight" "token" "violet" "white" "s11" "s11-original" "classy" "sonetto" "snowsabre" "leaf" "See icons before choosing them"
do
	if [ "$TIPO" = "" ]; then
		echo "Wrong choice!"
    elif [ "$TIPO" = "See icons before choosing them" ]; then
        CARTELLE="1) dark\t\t\t\t\t9) s11\n2) gray\t\t\t\t\t10) s11-original\n3) metal\t\t\t\t11) classy\n4) tlagdark\t\t\t\t12) sonetto\n5) tlaglight\t\t\t\t13) snowsabre\n6) token\t\t\t\t14) leaf\n7) violet\t\t\t\t15) See icons before choosing them\n8) white"
        echo -e $CARTELLE
        xdg-open $ICONSDIR/clear/128x128/places &
	else
		sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		TARGET_KEY="folder_sub_type"
		
	    if [ $TIPO = "classy" ] || [ $TIPO = "snowsabre" ] || [ $TIPO = "leaf" ] || [ $TIPO = "s11" ] || [ $TIPO = "s11-original" ] || [ $TIPO = "sonetto" ]; then
	    
          echo "Your choice was $TIPO. There are different folder types with this option. Choose the one from the list below:"
    	  PS3="Wich folder do you prefer? "	
    	  
	      case $TIPO in
	      classy)
        	select SOTTOTIPO in "aluminum" "black" "black-gray" "blue" "carboard" "ocean" "steel" "white" "yellow"; do
        	  if [ "$SOTTOTIPO" = "" ]; then
		        echo "Wrong choice! You have to type the number of your choice."
	          else
    		    echo "Your choice was: $SOTTOTIPO"
		        break
	          fi
            done
	      ;;
	      snowsabre)
        	select SOTTOTIPO in "black" "silver"; do
        	  if [ "$SOTTOTIPO" = "" ]; then
		        echo "Wrong choice! You have to type the number of your choice."
	          else
    		    echo "Your choice was: $SOTTOTIPO"
		        break
	          fi
            done
	      ;;
	      leaf)
        	select SOTTOTIPO in "blue"  "green"  "red"  "white"; do
        	  if [ "$SOTTOTIPO" = "" ]; then
		        echo "Wrong choice! You have to type the number of your choice."
	          else
    		    echo "Your choice was: $SOTTOTIPO"
		        break
	          fi
            done
	      ;;
	      s11*)
        	select SOTTOTIPO in "normal" "blue" "green" "gray" "orange" "purple" "red" "yellow"; do
        	  if [ "$SOTTOTIPO" = "" ]; then
		        echo "Wrong choice! You have to type the number of your choice."
	          else
    		    echo "Your choice was: $SOTTOTIPO"
		        break
	          fi
            done
	      ;;
	      sonetto)
        	select SOTTOTIPO in "normal" "sonetto01" "sonetto02" "sonetto03" "sonetto04" "sonetto05" "sonetto06" "sonetto07" "sonetto08" "sonetto09" "sonetto10"; do
        	  if [ "$SOTTOTIPO" = "" ]; then
		        echo "Wrong choice! You have to type the number of your choice."
	          else
    		    echo "Your choice was: $SOTTOTIPO"
		        break
	          fi
            done
	      ;;   
	      esac
	    
	    else
		  echo "Your choice was: $TIPO"
	      SOTTOTIPO="none"
		fi
		
    	sed -i "s/\($TARGET_KEY *=*\).*/\1'$SOTTOTIPO'/" $CONFIG_FILE
    	break
	fi
done

echo "*************************************************************************"
echo "What kind of start here icon do you prefer? I'll not show all 90 options, but if you want I'll open a window to see them (if xdg-open is supported). Do you want this (y/[n])?"
read RISP
if [ $RISP = "y" ]; then
	xdg-open $ICONSDIR/clear/128x128/start-here &
fi
TARGET_KEY="start_here"
PS3="$TARGET_KEY? "
echo "Now type the name of the icon of choice."
echo "WARNING: type only the last part of the icon before file extension!! For example, type 'gaia2' or 'centos' or 'arch4'"
read -p $PS3 TIPO
while [ ! -f "$ICONSDIR/clear/128x128/start-here/start-here-$TIPO.png" ]; do
	echo "$TIPO is not valid, I'm afraid. Type a correct option"
	read -p $PS3 TIPO
done		
echo "Your choice was $TIPO"
sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
echo "*************************************************************************"
echo "What kind of trash icon do you prefer? (Type the number of your choice)"
TARGET_KEY="trash_type"
PS3="$TARGET_KEY? "
select TIPO in "trash1" "trash2" "trash3" "trash4" "See icons before choosing them"
do
	if [ "$TIPO" = "" ]; then
		echo "Wrong choice!"
    elif [ "$TIPO" = "See icons before choosing them" ]; then
        PERCORSO=$ICONSDIR/clear/128x128/places
        `xdg-mime query default image/png | cut -d. -f1 ` $PERCORSO/user-trash1.png $PERCORSO/user-trash1-full.png $PERCORSO/user-trash2.png $PERCORSO/user-trash2-full.png $PERCORSO/user-trash3.png $PERCORSO/user-trash3-full.png $PERCORSO/user-trash4.png $PERCORSO/user-trash4-full.png &
	else
		echo "Your choice was: $TIPO"
		sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		break
	fi
done
echo "*************************************************************************"
echo "Do you want colored applications or greyish apps? (Type the number of your choice)"
TARGET_KEY="color_type"
PS3="$TARGET_KEY? "
select TIPO in "color" "no-color"
do
	if [ "$TIPO" = "" ]; then
		echo "Wrong choice!"
	else
		echo "Your choice was: $TIPO"
		sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		break
	fi
done
echo "*************************************************************************"
echo "Last three questions (I incorporate them in one question): change gedit icon, home icon and computer icon."
echo "For each option, type the number of your choice, as above. Name that ends with 1 is the colored version, name that ends with 2 is the grayish version."
TARGET_KEY="gedit_type"
PS3="$TARGET_KEY? "
select TIPO in "gedit1" "gedit2" "See icons before choosing them"
do
	if [ "$TIPO" = "" ]; then
		echo "Wrong choice!"
    elif [ "$TIPO" = "See icons before choosing them" ]; then
        PERCORSO=$ICONSDIR/clear/128x128/apps
        `xdg-mime query default image/png | cut -d. -f1 ` $PERCORSO/gedit1.png $PERCORSO/gedit2.png &
	else
		echo "Your choice was: $TIPO"
		sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		break
	fi
done
TARGET_KEY="computer_type"
PS3="$TARGET_KEY? "
select TIPO in "computer1" "computer2" "computer3" "computer4" "computer5" "See icons before choosing them"
do
	if [ "$TIPO" = "" ]; then
		echo "Wrong choice!"
    elif [ "$TIPO" = "See icons before choosing them" ]; then
        PERCORSO=$ICONSDIR/clear/128x128/places
        `xdg-mime query default image/png | cut -d. -f1 ` $PERCORSO/user-desktop1.png $PERCORSO/user-desktop2.png $PERCORSO/user-desktop3.png $PERCORSO/user-desktop4.png $PERCORSO/user-desktop5.png &
	else
		echo "Your choice was: $TIPO"
		sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		break
	fi
done
TARGET_KEY="home_type"
PS3="$TARGET_KEY? "
select TIPO in "home1" "home2" "home3" "home4" "home5" "See icons before choosing them"
do
	if [ "$TIPO" = "" ]; then
		echo "Wrong choice!"
    elif [ "$TIPO" = "See icons before choosing them" ]; then
        PERCORSO=$ICONSDIR/clear/128x128/places
        `xdg-mime query default image/png | cut -d. -f1 ` $PERCORSO/user-home1.png $PERCORSO/user-home2.png $PERCORSO/user-home3.png $PERCORSO/user-home4.png $PERCORSO/user-home5.png &
	else
		echo "Your choice was: $TIPO"
		sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		break
	fi
done
echo "*************************************************************************"
echo "Configuration process is finished. Notice that until now script has changed only main options. Do you want to run other options of the customize.sh file? (y/[n])"
read RISP
if [ $RISP = "y" ]; then
	#Firstly, I'll change fresh_install option in the configuration file, so recover.sh script called
	#below will know that he has to run also this part of the script (and after re-set the
	#fresh_install option to no, because running twice this part of the script will remove default
	#settings for icons).
	TARGET_KEY="fresh_install"
	TIPO="yes"
	sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
		
	echo "This is a new part of the script, to fully exploit all the customization options. It comes with 1.5 version of the set, and it's still under testing (and so it has dozens of bugs!)"
	echo "WARNING: if you run twice this part of those configurations, you may will lose default icons!"
	echo "Select an option from below, typing the number of your choice:" 
	PS3="Wich option do you prefer? "
	select OPTION in "MISC: change/restore some icons (CoverGloobus, Enroll, Screenlets)" "EMESENE: change/restore emesene icons" "CPUFREQ: change/restore cpu-frequency-applet icons" "LIFEREA: change/restore liferea icons" "CAFFEINE: change/restore caffeine icons" "PIDGIN: change/restore pidgin icons" "WICD: change/restore wicd icons" "Quit"
	do
		PINO="1) MISC:\tchange/restore some icons (CoverGloobus, Enroll, Screenlets)\n2) EMESENE:\tchange/restore emesene icons \n3) CPUFREQ:\tchange/restore cpu-frequency-applet icons\n4) LIFEREA:\tchange/restore liferea icons\n5) CAFFEINE:\tchange/restore caffeine icons\n6) PIDGIN:\tchange/restore pidgin icons\n7) WICD:\tchange/restore wicd icons\n8) Quit"
		
		#************************************************************************
		# If number of choice doesn't exist, the script will re-print the question
		if [ "$OPTION" = "" ]; then
			echo "Wrong choice!"
		else
			echo "Your choice was: $OPTION."
		fi
			
		#************************************************************************
		if [ "$OPTION" = "MISC: change/restore some icons (CoverGloobus, Enroll, Screenlets)" ]; then
			TARGET_KEY="misc"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "EMESENE: change/restore emesene icons" ]; then
			TARGET_KEY="emesene"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "CPUFREQ: change/restore cpu-frequency-applet icons" ]; then
			TARGET_KEY="cpufreq"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "LIFEREA: change/restore liferea icons" ]; then
			TARGET_KEY="liferea"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "CAFFEINE: change/restore caffeine icons" ]; then
			TARGET_KEY="caffeine"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "PIDGIN: change/restore pidgin icons" ]; then
			TARGET_KEY="pidgin"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "WICD: change/restore wicd icons" ]; then
			TARGET_KEY="wicd"
		fi
			
		#************************************************************************
		if [ "$OPTION" = "Quit" ]; then
			break
		fi

		echo "Do you want to change or restore $TARGET_KEY icons (or neither)? Type the correct number:"			
		PS3="What do you want to do? "
		select TIPO in "change" "restore" "nothing"
		do
			if [ "$TIPO" = "" ]; then
				echo "Wrong choice!"
			else
				echo "Your choice was: $TIPO."
				sed -i "s/\($TARGET_KEY *=*\).*/\1'$TIPO'/" $CONFIG_FILE
				echo -e $PINO
				PS3="Wich option do you prefer? "
				break
			fi
		done
	done
fi

echo "*************************************************************************"
echo "Now I'll start the recovery script. Type any key to continue."
read CONTINUE
bash $ICONSDIR/extra/recover.sh $ICONSDIR
