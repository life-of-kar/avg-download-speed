#!/bin/bash
# Script to check avg download speed which are listed in mylist.txt
# One link per line with location and host.
# link<space>location<space>host

#Declaring mysql DB connection

MASTER_DB_USER='USER'
MASTER_DB_PASSWD='PASSWORD'
#MASTER_DB_PORT=3160
MASTER_DB_HOST='localhost'
MASTER_DB_NAME='speedtest'

#Start of speedtest logs
#logs in root dir, bench.log

printf "*************************************\n" | tee -a $HOME/bench.log

date | tee -a $HOME/bench.log

printf "*************************************\n" | tee -a $HOME/bench.log

infile=$1
i=1
while read -r line
do
    printf "Line %3d: %s" $i "$line" | tee -a $HOME/bench.log
    arr=($line)
        node_server=$( wget -4 -O /dev/null ${arr[0]} 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
        printf "\n Avg speed: $node_server" | tee -a $HOME/bench.log
        echo "" | tee -a $HOME/bench.log

        #Split speed and type

        speed=$(echo $node_server | grep -o '[0-9.]*')
        type=$(echo $node_server | grep -o '[^0-9.]*')

        if [[ $type == "KB/s" ]]
        then
                #speed=`expr $speed / 1000`
                speed=$(bc <<< "scale=3; $speed / 1000")
                type="MB/s"
        fi

        #GET date

        YEAR=`date +%Y`
        MONTH=`date +%m`
        DATE=`date +%d`

        #Prepare sql query

        (echo "INSERT INTO speedtab (link, location, host, speed, type, year, month, date) VALUES (\"${arr[0]}\", \"${arr[1]}\", \"${arr[2]}\", \"$speed\",\"$type\", \"$YEAR\", \"$MONTH\", \"$DATE\")" | mysql speedtest -u $MASTER_DB_USER -p$MASTER_DB_PASSWD)

        #SQL_Query='INSERT INTO `speedtab` (`link`, `speed`, `type`) VALUES (\"${arr[0]}\", \"$node_server\", \"0\")'
        #SQL_Query='UPDATE `speedtab` SET `link` = ${arr[0]}, `speed` = $node_server'

        #mysql command to connect to database

        #mysql -u $MASTER_DB_USER -p$MASTER_DB_PASSWD -D $MASTER_DB_NAME -e $SQL_Query

    let i=i+1
done<$infile

echo "End of script"
