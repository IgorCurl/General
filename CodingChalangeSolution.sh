#!/bin/bash
 
##set the path ##this works for Ubuntu 14.04 and 16.04
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

##Path to the Config file with variables
. /usr/bin/watchdog.config 

##TO BE USED IF CONFIG FILE IS NOT AVAILABLE
##set your email address 
#EMAIL="email@yourdomain.com"
##service that you want to check?
#X=
##pause time between service checks?
#SLEEP_X=60
##how many times should the restart be attempted? 
#REPEAT_M=4
##pause time between restart attempts?
#SLEEP_N=15


##LOOP THE SCRIPT
while :; do
 
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

            ##set restart counter to 0##
            n=0
            until [ $n -ge $REPEAT_M ]
            do
                ##TRY TO RESTART THAT SERVICE###
                service $X start && break  
                n=$[$n+1]
                sleep $SLEEP_N
            done

            ##set the restart counter Y##
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