#!/bin/bash

DEVHUB_ALIAS=$1
ORG_ALIAS=$2

if [ "$#" -ne 2 ];
then
  echo "Usage: load-sample-data.sh <Devhub user or alias> <alias to assign> "
  exit 1
fi

if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    echo "Installing jq"
    curl -sS https://webinstall.dev/jq | bash
    export PATH="$HOME/.local/bin:$PATH"
    echo "Path exported"
fi

echo "Checking Devhub connection..."

# check connectivity
sfdx force:org:display -u ${DEVHUB_ALIAS}

if [ $? -ne 0 ];
then
  echo "Unable to connect to Org ${DEVHUB_ALIAS}"
  exit 1
fi

echo "Devhub connection OK"
echo "Creating scratch Org"

sfdx force:org:create -t scratch -v ${DEVHUB_ALIAS} -f config/project-scratch-def.json -d 30 -a ${ORG_ALIAS} -w 10

STORE_NAME="Store"
STORE_DESCRIPTION="B2B Store"
B2B_TEMPLATE="B2B Commerce"

# TODO maybe make a function here
sfdx force:org:display -u ${ORG_ALIAS}

if [ $? -ne 0 ];
then
  echo "Unable to connect to Org ${ORG_ALIAS}"
  exit 1
fi

echo "Org connection OK"
echo "Creating community"

sfdx force:community:create -n "${STORE_NAME}" -t "${B2B_TEMPLATE}" -p "" -d "B2B Store Test" -u ${ORG_ALIAS}

echo "Waiting 2 minutes for community creation..."

sleep 120

echo "Pushing source"

sfdx force:source:push -f -u ${ORG_ALIAS}

echo "Loading sample data"

# create EUR currency
sfdx force:data:record:create -s CurrencyType -v "IsoCode='EUR' ConversionRate=1.0 DecimalPlaces=2 IsActive=true" -u ${ORG_ALIAS}
# create translations
sfdx force:data:record:create -s Translation -v "Language='fr' IsActive=true" -u ${ORG_ALIAS}
sfdx force:data:record:create -s Translation -v "Language='en_US' IsActive=true" -u ${ORG_ALIAS}

sfdx sfdmu:run -p sample-data/b2b -s csvfile -u ${ORG_ALIAS}
scripts/shell/import-buyer-group-members.sh ${ORG_ALIAS}

echo "Publishing site"

sfdx force:community:publish --name "${STORE_NAME}" -u ${ORG_ALIAS}

echo "Site published"

scripts/shell/setup-media.sh ${ORG_ALIAS}