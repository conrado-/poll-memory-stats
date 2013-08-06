#!/bin/bash
#################################################################
# @author Miguel Rodriguez Fernandez                           	#
# @date June 1st, 2012                                         	#
# @version 1.0 First release                                   	#
# This script is intended to connect to msm device provided on 	#
# the first argument and poll memory stats of process given in 	#
# the second one.						#
#################################################################

if [ $# == 2 ]
then
	process=$2
	print_headers=true
	print_waiting=true
	last_mode_standby=false
	while :
	do
		PID=`ssh $1 ps|awk -v process="$process" '$0 ~ process {print $1}'`
		if [ -z $PID ]
       		then
			if $print_waiting;
       			then
				echo -ne "Waiting for process $2 to be started in $1" 1>&2;
				print_waiting=false
				print_headers=true
			else	
				echo -ne "." 1>&2;
			fi
			last_mode_standby=true
			continue
		else
			if $last_mode_standby;
       			then
				echo "" 1>&2;
				last_mode_standby=false
			fi
			if $print_headers ;
       			then
				echo -e "Timestamp\tVmSize\tVmRSS\tVmData" 1>&2;
				print_headers=false
				print_waiting=true
			fi
		fi
		ssh $1 cat /proc/$PID/status|awk 'BEGIN {OFS="\t"} /VmSize/ {t = $2} /VmRSS/ {rss = $2} /VmData/ {data = $2} END  {print strftime("%T"), t, rss, data}'
	done
else
    echo Usage $0 server process
fi
