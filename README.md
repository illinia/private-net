프라이빗 네트워크 초기화

geth --datadir ~/private-net --nodiscover --maxpeers 0 init ~/private-net/genesis.json

geth 프라이빗 네트워크 실행

private-net 폴더에 [geth-start.sh](http://geth-start.sh) 저장 실행시 sh geth-start.sh

geth --datadir ~/private-net --networkid 88 \
--nodiscover --maxpeers 0 --mine --miner.threads 1 \
--http --http.addr "127.0.0.1" --http.corsdomain "\*" \
--http.vhosts "\*" --http.api "eth,web3,personal,net,miner" \
--ipcpath ~/private-net/geth.ipc --ws --ws.addr "localhost" \
--ws.api "eth,web3,personal,net,miner" --ws.origins "\*" \
--allow-insecure-unlock --password ~/private-net/password

geth 콘솔 접속

geth attach http://127.0.0.1:8545

mkdir truffle-metacoin && cd truffle-metacoin

truffle unbox metacoin

계정 언락(총 5개)

web3.personal.unlockAccount(eth.accounts[0])

truffle console --network development

메타코인 계약정보 / 5개 계정 정보

let instance = await MetaCoin.deployed()

let accounts = await web3.eth.getAccounts()

밸런스 확인

instance.getBalance(accounts[0])

트랜잭션 실행(채굴중일때 적용)

instance.sendCoin(accounts[1], 10, {from: accounts[0]})

구글 쿠버네티스 엔진 api 사용 설정하고

구글 클라우드 sdk 설치

brew install --cask google-cloud-sdk

echo "source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'" >> ~/.zprofile

m1 맥은 gcloud m1 검색해서 다운받고

echo "source '/Users/gimtaemin/google-cloud-sdk/path.zsh.inc'" >> ~/.zprofile

source ~/.zprofile

gcloud --version

gcloud auth login

구글 클라우드 플랫폼 프로젝트 하나 새로만들고

```
gcloud compute project-info add-metadata \
   --metadata google-compute-default-region=asia-northeast1,google-compute-default-zone=asia-northeast1-a
```

gcloud init

쿠버네티스 설치

gcloud components install kubectl

kubectl version

private-net용 Geth의 Dockerfile

```docker
FROM ethereum/client-go:v1.10.8

COPY genesis.json /var/share/ethereum/
COPY keystore /var/share/ethereum/keystore/
COPY password /var/share/ethereum/
COPY entrypoint.sh /
RUN chmod 744 /entrypoint.sh

EXPOSE 8545 8546 30303 30303/udp

ENTRYPOINT ["/entrypoint.sh"]
```

private-net 안에 entrypoint.sh

```bash
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
```

```
docker build -t private-net .
```

```
docker run -it private-net
```

cloud build api 사용 설정

gcloud components install cloud-build-local

private-net 폴더안에 cloudbuild.yaml

```
steps:
  - name: "gcr.io/cloud-builders/docker"
    args:
      [
        "build",
        "--file",
        "./Dockerfile",
        "-t",
        "gcr.io/$PROJECT_ID/private-net:1.0",
        ".",
      ]

images:
  - "gcr.io/$PROJECT_ID/private-net:1.0"
```

```
cloud-build-local --dryrun=false .
```

```
cloud-build-local --dryrun=false --push=true .
```

구글 컨테이너 레지스트리 확인

컨테이너 배포 private-net.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: private-net
  namespace: default
  labels:
    app: private-net
spec:
  replicas: 1
  selector:
    matchLabels:
      app: private-net
  template:
    metadata:
      labels:
        app: private-net
    spec:
      containers:
        - name: private-net
          image: gcr.io/smart-contract-327601/private-net:1.0
          imagePullPolicy: Always
          ports:
            - name: rpc
              containerPort: 8545
            - name: ws
              containerPort: 8546
---
apiVersion: v1
kind: Service
metadata:
  name: private-net
  namespace: default
  labels:
    app: private-net
spec:
  type: NodePort
  ports:
    - name: rpc
      port: 8545
      nodePort: 30045
    - name: ws
      port: 8546
      nodePort: 30046
  selector:
    app: private-net
```

```
kubectl apply -f private-net.yaml
```

```
kubectl get pods,deployments,service -l app=private-net
```

방화벽 해제

```
gcloud compute firewall-rules create private-net-rpc --allow=tcp:30045 \
&& \
gcloud compute firewall-rules create private-net-ws --allow=tcp:30046
```

jq설치

```
brew install jq
```

쿠버네티스 노드 ip 주소 확인

```
kubectl get nodes -o json \
| jq ".items[]|{name: .metadata.name, externalIP: .status.addresses[1].address}"
```
