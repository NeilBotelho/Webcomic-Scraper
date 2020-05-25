#!/bin/sh

rootDir="/home/neil/.cache/comic/xkcd"
#path to a tempfile
tempFile=$rootDir"/temp_page_dump"
#Get the last post number that i downloaded from prevComic file
lastNum=`cat $rootDir/prevComic`

#Incase prevComic file is missing
if [ -z "$lastNum" ];then
	lastNum=2300
fi

waitForConnection(){
	numTries=20
	for i in $(seq 1 $numTries);do 
	ssid=`iwgetid|awk 'BEGIN{ FS="\""; }{print $2}'`
	if [ -z "$ssid" ];then
		sleep 2
	else
		break 
	fi
	done 
	if [ $numTries -eq $i ];then 
		echo "No network"
		exit
	fi
}

killOtherInstances(){
	procName=`echo $0|rev|cut -d/ -f1|rev`
	processes=`pgrep $procName`
	for i in $processes;do
		if [ "$i" != $$  ];then
			kill -9 $i
		fi
	done
}

getNext(){
	nextNum=`expr $lastNum + 1` #Add 1 to lastNum
	#Download the corresponging post
	curl  --silent  --show-error --output $tempFile "https://xkcd.com/$nextNum/"
	chmod +666 $tempFile
	err=`cat $tempFile |grep "404 Not Found"` #This acts as an error flag if a new post hasnt been created
	if [ -z "$err" ];then
	## Here I take the html dump od the page and search for the exact iamge i want
	## xkcd has 3 image tags so i use  inverse greps to get rid of the other two
		url=`cat $tempFile |grep "img src="|grep -v "usemap"|grep -v "xkcd.com logo"| cut -d\" -f2`
		rm $tempFile #Delete temp file
		url="https:"$url  #Add https to url
		curl --silent --show-error  --output $rootDir/archive/$nextNum.png "$url" #Dowload image
		#Screen sixe i s x=1360 y=740
		sxiv -g 850x600+255+70  $rootDir/archive/$nextNum.png   #Display image
		echo $nextNum > $rootDir/prevComic
	else
		rm $tempFile

	fi
}

getN(){
	if [ $1 -gt $lastNum ];then
		echo "Not available"
	else
		search=`ls $rootDir/archive|grep -w $1`
		if [ -z "$seach" ];then
			# echo "here"
			#Download that post
			curl --silent --show-error --output $tempFile "https://xkcd.com/$1/"

			err=`cat $tempFile |grep "404 Not Found"` #This acts as an error flag if a new post hasnt been created

			if [ -z "$err" ];then
			## Here I take the html dump of the page and search for the exact iamge i want
			## xkcd has 3 image tags so i use  inverse greps to get rid of the other two
				url=`cat $tempFile |grep "img src="|grep -v "usemap"|grep -v "xkcd.com logo"| cut -d\" -f2`
				rm $tempFile #Delete temp file
				url="https:"$url  #Add https to url
				
				curl --silent --show-error --output $rootDir/archive/$1.png "$url" #Dowload image
				sxiv -g 850x600+255+70 $rootDir/archive/$1.png   #Display image
			else
				rm $tempFile
				echo "Error curling webpage"
			fi
		fi

				ps u > /home/neil/psu
	fi
}

killOtherInstances
waitForConnection
case "$1" in
	#If the n flag is given that means the user is supplying comic numbers
	-n) for i in $@
		do
			if [ "$i" != "-n" ]
			then
				getN $i
			fi
		done
		;;

	 *)getNext
		;;
esac
