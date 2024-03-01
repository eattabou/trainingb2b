#!/bin/bash

#set -x
ORG_ALIAS=$1

function create_buyer_group_member {
  local BUYER_ACCOUNT_NAME=$1
  local BUYER_GROUP_NAME=$2

  BUYER_GROUP_ID=`sfdx force:data:soql:query -q "SELECT Id FROM BuyerGroup WHERE Name = '${BUYER_GROUP_NAME}' ORDER BY CreatedDate Desc LIMIT 1" --json -u ${ORG_ALIAS}|jq -r .result.records[0].Id`
  ACCOUNT_ID=`sfdx force:data:soql:query -q "SELECT Id FROM Account WHERE Name = '${BUYER_ACCOUNT_NAME}' ORDER BY CreatedDate Desc LIMIT 1" --json -u ${ORG_ALIAS}|jq -r .result.records[0].Id`

  sfdx force:data:record:create -s BuyerAccount -v "BuyerId='${ACCOUNT_ID}' Name='Buyer ${BUYER_ACCOUNT_NAME}' isActive=true" -u ${ORG_ALIAS}
  sfdx force:data:record:create -s BuyerGroupMember -v "BuyerGroupId='${BUYER_GROUP_ID}' BuyerId='${ACCOUNT_ID}'" -u ${ORG_ALIAS}
}

create_buyer_group_member "PHARMACIE AMANDIERS" "Sample Buyer Group FR 1"
create_buyer_group_member "PHARMACIE CENTRALE" "Sample Buyer Group FR 1"
create_buyer_group_member "PHARMACIE SANTE SERVICE" "Sample Buyer Group FR 2"

