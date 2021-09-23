geth --datadir ~/private-net --networkid 88 \
--nodiscover --maxpeers 0 --mine --miner.threads 1 \
--http --http.addr "127.0.0.1" --http.corsdomain "*" \
--http.api "eth,web3,personal,net,miner" \
--ipcpath ~/private-net/geth.ipc --ws --ws.addr "localhost" \
--ws.api "eth,web3,personal,net,miner" --ws.origins "*" \
--allow-insecure-unlock --password ~/private-net/password