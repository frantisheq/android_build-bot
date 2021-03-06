#!/bin/bash

# BuildBot script for android builds
# Severely modified by:
# daavvis
# Find me on XDA Developers
# Originally written by:
# Shane Faulkner
# http://shanefaulkner.com
# You are free to modify and distribute this code,
# So long as you keep our names and URL in it.
# Lots of thanks go out to TeamBAMF

#-------------------ROMS To Be Built------------------#
# Instructions and examples below:

PRODUCT[0]="m7vzw"			# phone model name (product folder name)
LUNCHCMD[0]="m7vzw"			# lunch command used for ROM


PRODUCT[1]="p3110"
LUNCHCMD[1]="p3110"

#PRODUCT[2]="p3100"
#LUNCHCMD[2]="p3100"


#PRODUCT[3]="m7spr"
#LUNCHCMD[3]="m7spr"

#PRODUCT[4]="m7att"
#LUNCHCMD[4]="m7att"

#PRODUCT[5]="p5110"
#LUNCHCMD[5]="p5110"


#PRODUCT[6]="p5100"
#LUNCHCMD[6]="p5100"




#---------------------Build Settings------------------#

# select "y" or "n"... Or fill in the blanks...



#use ccache

CCACHE=y

#what dir for ccache?

CCSTORAGE=~/.ccache

# should they be moved out of the output folder?
# like a dropbox or other cloud storage folder?
# or any other folder you want?
# also required for FTP upload!!

MOVE=y

# Do you want to move the MD5 after build is completed also?
MD5=y

# Do you want to move the Recovery.img after build is completed also?
recov=y

# Please fill in below the folder they should be moved to.
# The "//" means root. if you are moving to an external HDD you should start with //media/your PC username/name of the storage device An example is below.
# If you are using an external storage device as seen in the example below, be sure to mount it via your file manager (open the drive in a file manager window) or thought the command prompt before you build, or the script will not find your drive.
# If the storage location is on the same drive as your build folder, use a "~/" to begin. It should look like this usually: ~/your storage folder... assuming your storage folder is in your "home" directory.

STORAGE=//media/daavvis/storage/1foronlyme

# Do you want to make a folder for the version of android you are building? 

AVF=y

# What version of android? (no".")(you only need to fill this out if you answered "y" to the question above)

VER=4.4.2

# The first few letters of your ROM name... this is needed to move the completed zip to your storage folder. 

ROM=MK44

# Your build source code directory path. In the example below the build source code directory path is in the "home" folder. If your source code directory is on an external HDD it should look like: //media/your PC username/the name of your storage device/path/to/your/source/code/folder
SAUCE=~/mkkk

# REMOVE BUILD PROP (recomended for every build, otherwise the date of the build may not be changed, as well as other variables)

BP=y


# Number for the -j parameter (choose a smaller number for slower internet conection... default is usually 4... this only controls how many threads are running during repo sync)

J=16

# Sync repositories before build

SYNC=n

# run mka installclean first (quick clean build)
QCLEAN=y

# Run make clean first (Slow clean build. Will delete entire contents of out folder...)

CLEAN=n

# leave alone
DATE=`eval date +%y``eval date +%m``eval date +%d`

#----------------------FTP Settings--------------------#

# Set "FTP=y" if you want to enable FTP uploading
# You must have moving to storage folder enabled first

FTP=n

# FTP server settings... to move to more than one ftp server, uncoment, and if necessary add more to FTP blah blah below...

FTPHOST[0]="ftp2.file1.info"	# ftp hostname
FTPUSER[0]="Your-Username"	# ftp username 
FTPPASS[0]="password"	# ftp password
FTPDIR[0]="/"	# ftp upload directory

#FTPHOST[1]="host"
#FTPUSER[1]="user"
#FTPPASS[1]="password"
#FTPDIR[1]="directory"

#---------------------Build Bot Code-------------------#
# Very much not a good idea to change this unless you know what you are doing....



echo -n "Moving to source directory..."
cd $SAUCE
echo "done!"

#d710 branch stuff remove or hash out if not needed
#echo -n "switching to the right branch cause of the d710..."
#cd frameworks/base
#git checkout "remotes/mokee/jb-mr2_mkt"
#cd $SAUCE
#echo -n "done!"

if [ $CLEAN = "y" ]; then
	echo -n "Running make clean..."
	make clean
	echo "done!"
fi


if [ $SYNC = "y" ]; then
	echo -n "Running repo sync..."
	repo sync -j$J
	echo "done!"
fi

if [ $CCACHE = "y" ]; then
			export USE_CCACHE=1
			export CCACHE_DIR=$CCSTORAGE
			# set ccache due to your disk space,set it at your own risk
			prebuilts/misc/linux-x86/ccache/ccache -M 15G
		fi



for VAL in "${!PRODUCT[@]}"
do

echo -n "Starting build..."
. build/envsetup.sh
croot
lunch mk_${LUNCHCMD[$VAL]}-userdebug



		if [ $BP = "y" ]; then
		echo "Removing build.prop..."
		rm $SAUCE/out/target/product/${PRODUCT[$VAL]}/system/build.prop
		echo "done!"
		fi

		
		
		if [ $QCLEAN = "y" ]; then
		echo -n "Running make install clean..."
		mka installclean
		echo "done!"
		fi

		




# get time of startup
res1=$(date +%s.%N)

# start compilation
mka bacon

echo "done!"

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
	
		if  [ $MOVE = "y" ]; then
		echo -n "Moving to cloud or storage directory..."
		echo -n "checking for directory, and creating as needed..."
			mkdir -p $STORAGE
				if [ $AVF = "y" ]; then
					mkdir -p $STORAGE/$VER
					mkdir -p $STORAGE/$VER/${PRODUCT[$VAL]}
				fi
				if [ $AVF = "n" ]; then
					mkdir -p $STORAGE/${PRODUCT[$VAL]}
				fi
		echo "Done."
		echo "Moving flashable zip..."
				if [ $AVF = "y" ]; then
					mv $SAUCE/out/target/product/${PRODUCT[$VAL]}/$ROM*".zip" $STORAGE/$VER/${PRODUCT[$VAL]}/
				fi
				if [ $AVF = "n" ]; then
					mv $SAUCE/out/target/product/${PRODUCT[$VAL]}/$ROM*".zip" $STORAGE/${PRODUCT[$VAL]}/
				fi
		echo "Done."
		fi
		
		if [ $MD5 = "y" ]; then
		echo -n "Moving md5..."
				if [ $AVF = "y" ]; then
					mv $SAUCE/out/target/product/${PRODUCT[$VAL]}/*".md5sum" $STORAGE/$VER/${PRODUCT[$VAL]}/
				fi
				if [ $AVF = "n" ]; then
					mv $SAUCE/out/target/product/${PRODUCT[$VAL]}/*".md5sum" $STORAGE/${PRODUCT[$VAL]}/
				fi
		echo "done."
		fi

		if [ $recov = "y" ]; then
		echo -n "Moving recovery.img..."
				if [ $AVF = "y" ]; then
					mv $SAUCE/out/target/product/${PRODUCT[$VAL]}/"recovery.img" $STORAGE/$VER/${PRODUCT[$VAL]}/
				fi
				if [ $AVF = "n" ]; then
					mv $SAUCE/out/target/product/${PRODUCT[$VAL]}/"recovery.img" $STORAGE/${PRODUCT[$VAL]}/
				fi
		echo "done."
		fi
done

#----------------------FTP Upload Code--------------------#

if  [ $FTP = "y" ]; then
	echo "Initiating FTP connection..."

	cd $STORAGE/ ${PRODUCT[$VAL]}
	ATTACHROM=`for file in ${OUTPUTNME[$VAL]}$DATE".zip"; do echo -n -e "put ${file}\n"; done`
	if [ $MD5 = "y" ]; then
		ATTACHMD5=`for file in *"-"$DATE".md5sum.txt"; do echo -n -e "put ${file}\n"; done`
		ATTACH=$ATTACHROM"/n"$ATTACHMD5
	else
		ATTACH=$ATTACHROM
	fi

for VAL in "${!FTPHOST[@]}"
do
	echo -e "\nConnecting to ${FTPHOST[$VAL]} with user ${FTPUSER[$VAL]}..."
	ftp -nv <<EOF
	open ${FTPHOST[$VAL]}
	user ${FTPUSER[$VAL]} ${FTPPASS[$VAL]}
	tick
	cd ${FTPDIR[$VAL]}
	$ATTACH
	quit
EOF
done

	echo -e  "FTP transfer complete! \n"
fi

echo "All done!"
