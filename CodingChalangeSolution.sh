#!/bin/bash

## IMPORTANT: This Script assumes that you have "mail" utility installed and configured. 

##Location of the Config files with variables
source /etc/CodingChalangeSolution.conf

## Error handling ##
# set exit-on-error mode:
set -e
#trap the exit signal instead of the error
trap 'catch $? $LINENO' EXIT
#make sure we ended up in catch based on an error
catch() {
  echo "Catching the error:"
  if [ "$1" != "0" ]; then
    # error handling goes here
    echo "Error $1 occurred on $2"
  fi
}

##Continue execution until forcibly interrupted (with kill or Ctrl+C)
while true; do
 
    ###CHECK SERVICE####
    `pgrep $X >/dev/null 2>&1`
    STATS=$(echo $?)
    
    ###IF SERVICE IS NOT RUNNING####
    if [[  $STATS == 1  ]]

        then
            ##send email that service is down##
            mail -s 'Service '$SERVICE' is Down.' $EMAIL

            ##append to the log file##
            echo "Service $SERVICE is down" >> /var/log/watchdog.log

            ##Set the counter to 0##
            n=0
            until [ $n -ge $REPEAT_M ]
            do
                ##TRY TO RESTART THE SERVICE###
                service $X start && break  
                n=$[$n+1]
                sleep $SLEEP_N
            done

            ##Set the restart counter Y##
            Y=$[$n+1]

            ##CHECK IF RESTART WORKED###
            `pgrep $X >/dev/null 2>&1`
            RESTART=$(echo $?)
        
        if [[  $RESTART == 0  ]]
        ##IF SERVICE HAS BEEN RESTARTED###
        then
        
            ##REMOVE THE TMP FILE IF EXISTS###
            if [ -f "/tmp/$X" ]; 
            then
                rm /tmp/$X
            fi
        
            ##SEND AN EMAIL###
            mail -s "Service​ ​$X ​has​ ​been​ ​started​ ​after​ $Y ​attempts" "$EMAIL"

            ##APPEND TO THE LOG##
            echo "Service $SERVICE has been sucessfully started after $Y start attempts" >> /var/log/watchdog.log
        else
            ##IF RESTART DID NOT WORK###
        
            ##CHECK IF THERE IS NOT A TMP FILE###
            if [ ! -f "/tmp/$X" ]; then
        
                ##CREATE A TMP FILE###
                touch /tmp/$X
            
                ##SEND A DIFFERENT EMAIL###
                mail -s "Service​ ​$X can't be ​started​ ​after​ $Y ​attempts" "$EMAIL"

                ##APPEND TO THE LOG##
                echo "Service $SERVICE could not be started after $Y start attempts" >> /var/log/watchdog.log
            fi
        fi
    fi

sleep $SLEEP_X
done


exit