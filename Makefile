-include .env

init-install:
	forge install Openzeppelin/openzeppelin-contracts foundry-rs/forge-std smartcontractkit/chainlink smartcontractkit/chainlink

install:
	forge install

deploy-token:
	forge script script/Token.s.sol:TokenScript --rpc-url ${RPC_URL} --etherscan-api-key ${EXPLORER_KEY} --broadcast -vvvv --ffi --verify

deploy-subscription:
	forge script script/Subscriptions.s.sol:SubscriptionsScript --rpc-url ${RPC_URL} --etherscan-api-key ${EXPLORER_KEY} --broadcast -vvvv --ffi --verify