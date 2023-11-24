#!/bin/bash

# Enable extended globbing
shopt -s extglob

SOURCE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
#echo $SOURCE;
while true; do
	read -p "
	-------------------------| About |--------------------------------
	This is a combinated install/update/uninstall -script.

	* If this is the first time it will copy Ambient Light Fix to
	/usr/bin and then add it to systemd so it will be started
	automatically after each reboot.

	* If you already have Ambient Light Fix this script will find it
	and either help you uninstall or update it.
	------------------------------------------------------------------

	Continue? (y/n) " yn
	case $yn in
		[Yy]* ) echo; echo "
		Great, let's do it!"; echo; break;;
		[Nn]* ) echo; echo "
		... ok, you were supposed to hit Y :-/"; echo; exit;;
		* ) echo; echo "
		! You must answer something I understand...  - Y or N"; echo;;
	esac

done


if [ -f "/sys/bus/iio/devices/iio:device0/in_illuminance_raw" ];
	then
		echo "
		--------------------------------------------
		*** Things are looking up - Found sensor ***
		--------------------------------------------";
		sleep 1; echo;
	else
		echo "
		-------------------------------------------------
		| No sensors here... AmbientLightFix won't be	|
		| able to run on your machine :-(		|
		-------------------------------------------------";
		exit
fi

if compgen -G "/sys/class/backlight/@(intel_backlight|amdgpu_bl0|radeon_bl0|gmux_backlight)/brightness" > /dev/null;
	then

		# Letar efter existerande lightfix och erbjuder avinstallation eller uppdatering
		if compgen -G "/usr/bin/ambientLightFix*" > /dev/null;
			then
				while true; do
					read -p "
		-------| Found existing Ambient Light Fix! |-------
		Do you want to Uninstall [1] Ambient Light Fix...
		... or do you want to Update [2] to a newer version?
		---------------------------------------------------
					" radeon
					case $radeon in
						[1]* ) echo;
						systemctl stop ambientLightFix.service;
						sudo sh -c "rm /usr/bin/ambientLightFix";
						systemctl disable ambientLightFix.service;
						sudo sh -c "rm /etc/systemd/system/ambientLightFix.service";
						echo "
		---------------| Uninstalled! |----------------";
						echo; break;;
						[2]* ) echo;
						systemctl stop ambientLightFix.service;
						sudo sh -c "rm /usr/bin/ambientLightFix";
						sudo sh -c "cp '$SOURCE'/ambientLightFix /usr/bin/ambientLightFix";
						systemctl start ambientLightFix.service;
						echo "
		-----------------| Updated! |------------------";
						echo; break;;
						* ) echo; echo "
		-------------
		! type 1 or 2
		-------------"; echo;;
					esac
				done
			else

				echo "
		--------------------------------
		*** found brightness control ***
		--------------------------------
				";
				echo "
		-> Sensor Path: "
				control=$(ls /sys/class/backlight/@(intel_backlight|amdgpu_bl0|radeon_bl0|gmux_backlight)/brightness)
				echo $control
				echo "
		-> Will test changing brightness before installation...
				"; echo; sleep 1
				echo "
		-> Current brightness: "
				cat $control; sleep 1;
				echo "
		-> Setting brightness to 50, then step up to 500...
				";
				sleep 3;
				
				sudo bash -c "echo 50 > $control";
				sleep 1;
				sudo bash -c "echo 100 > $control";
				sleep 1;
				sudo bash -c "echo 150 > $control";
				sleep 1;
				sudo bash -c "echo 200 > $control";
				sleep 1;
				sudo bash -c "echo 250 > $control";
				sleep 1;
				sudo bash -c "echo 300 > $control";
				sleep 1;
				sudo bash -c "echo 350 > $control";
				sleep 1;
				sudo bash -c "echo 400 > $control";
				sleep 1;
				sudo bash -c "echo 450 > $control";
				sleep 1;
				sudo bash -c "echo 500 > $control";
				echo "
				->Current brightness: ";
				cat $control; sleep 1; echo "
		---------------------------------
		... Everything good so far!
		Let's start setting things up :-)
		---------------------------------
				";
				echo; echo;
				echo "
		---------------------
		*** Copying files ***
		---------------------
				";
				sudo sh -c "cp '$SOURCE'/ambientLightFix /usr/bin/ambientLightFix";
				sudo sh -c "cp '$SOURCE'/ambientLightFix.service /etc/systemd/system/ambientLightFix.service";
				echo;
				sleep 1;
				echo "
		------------------
		*** Setting up ***
		------------------
				";
				systemctl enable ambientLightFix.service;
				echo;
				echo "
		------------
		*** Done ***
		------------
				";
				echo;
				while true; do
					read -p "
		-----------------| All set! |---------------
		You wanna start Ambient Light Fix now? (y/n)
		--------------------------------------------
					" radeon_start
					case $radeon_start in
						[Yy]* ) echo; echo "
		--------------| Congratulations! |---------------
		You're all done! You can close this terminal now.
		-------------------------------------------------
						"; systemctl start ambientLightFix.service; break;;
						[Nn]* ) echo; echo "
		---------------------| OK |----------------------
		Ambient Light Fix will start next time you reboot
		-------------------------------------------------
						"; echo; exit;;
					esac
				done
				echo "Done :-)";
			fi


	else echo "
		----------| Something didn't go as expected|--------
		... Ok, this is weird. Didn't find any intel either.
		Report this to hackan!
		----------------------------------------------------
		";
fi
