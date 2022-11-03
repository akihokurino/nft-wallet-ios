MAKEFLAGS=--no-builtin-rules --no-builtin-variables --always-make
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

MORARIS_URL := https://qcdgbkhha2hk.usemoralis.com:2053/server
MORARIS_APP_ID := UUhyyinuDIJQqa5tTeq7CMhlewLroKlLF397DmRc
MORARIS_MASTER_KEY := PQBwVVCE4DTJxjJSaaaEuiwczfAkgR7nn3ktdQhL

deploy-functions:
	firebase deploy --only functions

deploy-functions-env:
	firebase functions:config:set \
		moralis.server_url=$(MORARIS_URL) \
		moralis.app_id=$(MORARIS_APP_ID) \
		moralis.master_key=$(MORARIS_MASTER_KEY)

extract-abi:
	cat ethereum/artifacts/contracts/NftWallet721.sol/NftWallet721.json | jq '.abi' > NftWallet/NftWallet721.abi.json
	cat ethereum/artifacts/contracts/NftWallet1155.sol/NftWallet1155.json | jq '.abi' > NftWallet/NftWallet1155.abi.json
