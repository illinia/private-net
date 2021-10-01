#!/bin/sh
geth --datadir /var/share/ethereum --nodiscover --maxpeers 0 \
init /var/share/ethereum/genesis.json \
&& \
geth --datadir /var/share/ethereum --networkid 15 \
--nodiscover --maxpeers 0 --mine --miner.threads 1 \
--http --http.addr "127.0.0.1" --http.corsdomain "*" \
--http.vhosts "*" --http.api "eth,web3,personal,net,miner" \
--ipcpath /temp/geth.ipc --ws --ws.addr "localhost" \
--ws.api "eth,web3,personal,net,miner" --ws.origins "*" \
--allow-insecure-unlock --password /var/share/ethereum/password