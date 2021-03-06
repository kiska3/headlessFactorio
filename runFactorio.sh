#!/bin/bash

set -euo pipefail

if [ -w factorioSave ]; then
	latest=""
	for file in factorioSave/*.zip; do
	  [[ $file -nt $latest ]] && latest=$file
	done

fi
if [ "$#" -ne 1 ]; then
	if [ -z $latest ]; then	
        echo -e "./runFactorio.sh <ZipFileSave> \n or make sure that factorioSave/ is populated"
        exit 1
    else
    	save=$latest
    fi  
else
	save=$1

fi


if [ "$(file -ib $save)" != "application/zip; charset=binary" ]; then
        echo "$save is not a valid zip file."
        exit 1
fi

echo "*********** Your game password is in the quotes *********"
grep "game_password" /opt/factorio/config/settings.json
echo "*********************************************************"

numthreads=$(grep -P "processor\t" /proc/cpuinfo | wc -l)
sed -i -e 's/max_threads=.*/max_threads='"$numthreads/" /opt/factorio/config/config.ini

/opt/factorio/bin/x64/factorio --config /opt/factorio/config/config.ini --start-server $save \
                 --autosave-interval 10 --afk-autokick-interval 5 --allow-commands restrict \
                 --server-settings /opt/factorio/config/settings.json 

