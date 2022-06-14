MAKEFLAGS=--no-builtin-rules --no-builtin-variables --always-make
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

MORARIS_URL := ""
MORARIS_APP_ID := ""
MORARIS_MASTER_KEY := ""

deploy-functions:
	firebase deploy --only functions

deploy-functions-env:
	firebase functions:config:set \
		moralis.server_url=$(MORARIS_URL) \
		moralis.app_id=$(MORARIS_APP_ID) \
		moralis.master_key=$(MORARIS_MASTER_KEY)
