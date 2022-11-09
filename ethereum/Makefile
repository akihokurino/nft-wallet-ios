vendor:
	npm install

compile:
	npx hardhat compile

.PHONY: test
test:
	npx hardhat test

node:
	npx hardhat node

deploy-local:
	npx hardhat run scripts/deploy.ts --network hardhat

deploy-goerli:
	npx hardhat run scripts/deploy.ts --network goerli