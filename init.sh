#!/bin/bash

set -eo pipefail

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Check if superset application is already configured, otherwise set it up
if [ ! -f $SUPERSET_HOME/superset_config.py ]; then
  echo "No Superset configuration detected. Initializing from defaults."
  envsubst < /etc/superset-defaults/superset.cfg > $SUPERSET_HOME/superset_config.py
else
  echo "Existing Superset configuration detected."
fi

# If no Superset backend found - set it up
if [ ! -f $SUPERSET_DB ]; then
  echo "Setup Superset database with default admin account."
  source /etc/superset-defaults/admin.cfg
  #/bin/sh -c '/usr/bin/fabmanager create-admin --app superset --username $USERNAME --firstname $FIRSTNAME --lastname $LASTNAME --email $EMAIL --password $PASSWORD'
  /usr/bin/fabmanager create-admin --app superset --username $USERNAME --firstname $FIRSTNAME --lastname $LASTNAME --email $EMAIL --password $PASSWORD
  sed -i '/PASSWORD=.*/d' /etc/superset-defaults/admin.cfg

  # Initialize the database
  superset db upgrade

  # Create default roles and permissions
  superset init

else
  echo "Existing Superset backend detected. Upgrading database."
  superset db upgrade
fi

echo "Starting up Superset"
superset runserver
