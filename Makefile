MAKEFLAGS=--no-builtin-rules --no-builtin-variables --always-make
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

set-env:
	./env.sh

extract-abi:
	cat ethereum/artifacts/contracts/NftWallet721.sol/NftWallet721.json | jq '.abi' > NftWallet/NftWallet721.abi.json
	cat ethereum/artifacts/contracts/NftWallet1155.sol/NftWallet1155.json | jq '.abi' > NftWallet/NftWallet1155.abi.json
