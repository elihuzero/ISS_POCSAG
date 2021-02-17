#!/bin/bash

#
# Version : 1.2
#
#
# Modification : 15/09/2018
# Date et heure FR
# Variables déplacées en haut du script
# Ajout variable dist_km
# Ajout variable Votre_Mail : Il faut avoir configurer les mails sur votre Linux: defaut = zero
# Ajout variable ID_DMR
#
# Variables a modifier

##############################

CALLSIGN=XE1REB
ID_DMR=3340235
MyLat=21.135792
MyLong=-101.6569
Dist_Km="1000"
Votre_Mail=zero

##############################

# Recuperation des informations Latitude et Longitude ISS

#========================================================

issLat='curl -s -H "Content-Type: application/json" -X GET http://api.open-notify.org/iss-now.json | jq -r [.iss_position] | sed -n -e 's/^.*"latitude": //p' | sed "s/\"//g" | sed "s/\,//g"`
issLong='curl -s -H "Content-Type: application/json" -X GET http://api.open-notify.org/iss-now.json | jq -r [.iss_position] | sed -n -e 's/^.*"longitude": //p' | sed "s/\"//g" | sed "s/\,//g"`

# Informations station radio

#===========================

echo "Mi Localizacion : $MyLat, $MyLong"
echo "Localizacion de ISS : $issLat, $issLong"
now=`date +"%d-%m-%Y %R"`

# Logs ISS

#=========

iss_log="/var/log/iss_distance.log"

# Calcule de la distance en KM entre vous et ISS

#===============================================

distance='/usr/local/bin/distance $issLat $issLong $MyLat $MyLong '

# Affichage et publication des informations

#==========================================

if [ ${distance%.*} -lt ${Dist_Km} ]; then

echo "${now} : ISS acercandose ${distance}KM" >> ${iss_log}

if [ ${Votre_Mail} = "zero" ] ; then

echo "Ningun Mensaje"

else

echo "${now} : ISS acercandose ${distance}KM" | mail -s "ISS-Approche" ${Votre_Mail}

fi

/usr/local/sbin/pistar-dapnetapi ${CALLSIGN} "${distance}KM ISS acercandose" debug

else

echo "${now} : ISS esta a ${distance}KM de tu posicion (${CALLSIGN})" >> ${iss_log}

fi