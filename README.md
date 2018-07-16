# Turtle-to-Turtle (T2T) Protocol 1.0

## Objective

To facilitiate the exchange of peer information, blockchain records, and other necessary data to advance the TurtleCoin blockchain.

## Protocol & Port Assignments

|Protocol|Port|Description|
|---|---|---|
|TCP|11897|Turtle-to-Turtle Communication Channel|
|TCP|11898|Node-to-Wallet Communication Channel|

## Seed Node(s)

Functions of a seed node is as follows. This list is all inclusive.

1. Provide an entry point for the interconnection of turtle-to-turtle swarm of nodes.
2. Provide an archival (historical) copy of the blockchain for synchronization to other nodes.

***Note: Seed nodes will not accept the submission of new blocks from miners nor produce new blocks.***

## Turtle-to-Turtle Bootstrap

1. At first launch, the new node will generate a new peer ID that that is the result of the generation of [UUID Version 5](https://tools.ietf.org/html/rfc4122).
2. The node then attempts to establish a TCP socket to a randomly selected seed node (peer) as defined in it's provided configuration.
 a. If the connection fails, it will try connecting to another randomly selected seed node. This process continues until the list of seed nodes is exhausted.
 b. In the event the full list of seed nodes is exhausted, the node will continue to retry connections to the seed(s) until a connection is made.
 
    **Note:** It is recommended that a backoff timer of ```log(n) * 60``` where ```n``` is the connection attempt number is used to prevent unnecessary connection attempts.

3. The peer will add the node's information to its internal state database.
4. Upon successful connect, the new node will send a [T2T-CandidateListRequest](#T2T---candidatelistrequest) to the peer node.
5. The peer will then send a maximum of 511 randomly selected and weighted peer candidates from its internal peer database to the node using a [T2T-CandidateList](#T2T---candidatelist) message. See [Peer Candidate Selection](#peer-candidate-selection) for information the weighting system used.
6. The node will insert the provided peer candidates in to its peer state database.
7. The node will add the seed node's connection information into its peer state database.
8. The node will attempt connection(s) to the target number of peers as defined in its compiled time configuration following the candidate election process as described in [Peer Election Process](#peer--election--process).
 a. If a connection fails, it will try connecting to another peer candidate using the same selection algorithm. This process continues util the list of nodes is exhausted.
 b. In the event the full list of peer candidates is exhausted, the node will reach back out to the seed for an additional list of peer candidates via [T2T-CandidateListRequest](#T2T---candidatelistrequest) and resume connection attempts are describted in #9.
9. Once the node has connected to the target number of peers, standard operation then begins.

## Turtle-to-Turtle Connection (Post Bootstrap)

1. The node will open it's internal peer database.
2. The node will attempt connection(s) to the target number of peers as defined in its provided configuration following the candidate election process as described in [Peer Election Process](#peer--election--process).
 a. If a connection fails, it will try connecting to another peer candidate using the same selection algorithm. This process continues util the list of nodes is exhausted.
 b. In the event the full list of peer candidates is exhausted, the node will perform the [Turtle-to-Turtle Bootstrap](#turtle---to---turtlebootstrap) process.
3. Upon successful connect, the new node will send a [T2T-CandidateListRequest](#T2T---candidatelistrequest) to the peer node.
4. Once connected, the peer will then send a maximum of 511 randomly selected and weighted peer candidates from its internal peer database to the node using a [T2T-CandidateList](#T2T---candidatelist) message. See [Peer Candidate Selection](#peer-candidate-selection) for information the weighting system used.
5. The node will insert the provided peer candidates in to its peer state database.
6. Once the node has connected to the target number of peers, standard operation then begins.

## Peer List Management

1. Each failed connection attempt to a particular peer candidate will result in the node increasing the effective  ```ttl``` value of the peer candidate in the node's internal state database by ```10```.
2. A successful connection will set the peer candidate ```ttl``` to a value of ```1``` in the node's internal state database.
3. Once a peer candidate's ```ttl``` reaches a value larger than ```255``` the peer candidate is removed from the internal state database.

## Peer Candidate Distribution

A node will select the peer candidates to send to peers by following the process below.

1. The node will calculate the median of the ```ttl``` values for the peer candidates in it's internal state database.
2. Using that median, the node will compute a [Normal Distribution Curve](https://en.wikipedia.org/wiki/Normal_distribution) of the peer candidates based on their ```ttl```.
3. A random selection following the distribution below is used to select the pool of up to 1,023 candidates sent during the peer exchange process.

|Percentile|Weight|
|---|---|
|< 25th|10%|
|>= 25th && < 37.5th|20%|
|>= 37.5th && < 50th|20%|
|>= 50th && < 62.5th|20%|
|>= 62.5th && < 75th|20%|
|>= 75th|10%|
|***Total***|100%|

Selecting the peer candidates to announce in this manner helps to provide a meaningful mixture of peer canidates to avoid centralization of the swarm.

## Peer Election Process

Each implementor of the protocol may locally elect candidate peers in any manner they see fit to connect to the Turtle-to-Turtle swarm. The steps below are **recommendations** for how that election can take place.

1. Each peer is sent an ICMP Echo Request as defined in [RFC792](https://tools.ietf.org/html/rfc792).
2. The result of the ICMP Echo Request (success/failure) is saved as variable ```success``` in the form of a boolean variable.
3. The observed latency of the ICMP Echo Request is saved as the variable ```latency``` in the form of a ```uint32```. The base units of milliseconds (ms) are simply dropped.
4. The TTL of the ICMP Echo Request is recorded as ```ICMPEchoRequestTTL```.
5. The following formula computes the ```cost``` of the peer used later to locally elect peer candidates for local use. 

**Note:** ```ttl``` in this context is the ```ttl``` as defined within the swarm.

```
networkHops = [(255 - ICMPEchoRequestTTL) + 1]
cost = ceil({1 / [(success + 1) * (1 / latency) * (1 / ttl) * (1 / networkTTL)]})
```
5. The peer candidates with the lowest cost are then used in the first round of connection attempts.

### Example Values

![Example Values](https://i.imgur.com/uimwSKZ.png)

## Turtle-to-Turtle Messages

All Turtle-to-Turtle messages are exchanged using [Protocol Buffers](https://developers.google.com/protocol-buffers/) that follow the below structures. The tables below are provided for reference purposes.

### T2T-Datagram

All messages between peers are encapsulated into the standard T2T-Datagram before being sent over the wire. Additional payloads are then easily defined and added at the core of the protocol by extending the payload structure to support the additional message types.

|Field|Type|Description|
|---|---|---|
|p2pNetworkId|uint32|A unique ID assigned to the peer-to-peer network|
|version|uint32|The turtle-to-turtle protocol version supported|
|peerId|string|The ID of the node|
|agent|string|The node agent string|
|nodeVersion|string|The node version|
|dataPayload|Object|The Protobuf payload of any of the types below|

#### Protobuf Structure

```
message T2TDatagram {
  uint32 p2pNetworkId = 1;
  uint32 version = 2;
  string peerId = 3;
  string agent = 4;
  string nodeVersion = 5;
  oneof dataPayload {
    T2TCandidateList t2tCandidateList = 6;
    T2TCandidateListRequest t2tCandidateListRequest = 7;
    BlockChainPayload blockChainPayload = 8;
  }
}
```

## Turtle-to-Turtle Data Payload Definitions

### Peer Information

#### T2T-CandidateList

|Field|Type|Description|
|---|---|---|
|candidate|[T2TCandidate](#t2t---candidate)[]|An array of candidate peers|

##### Protobuf Structure

```
message T2TCandidateList {
  repeated T2TCandidate candidate = 1;
}
```

#### T2T-CandidateListRequest

|Field|Type|Description|
|---|---|---|
|blockChainId|uint32[]|The blockchain IDs for which you want peers|

##### Protobuf Structure

```
message T2TCandidateListRequest {
  repeated uint32 blockChainId = 1;
}
```

#### T2T-Candidate

|Field|Type|Description|
|---|---|---|
|peerId|string|[UUID Version 5](https://tools.ietf.org/html/rfc4122) node identifier of peer candidate|
|version|uint32|The turtle-to-turtle protocol version supported|
|ipV4Address|uint32|IP version 4 address of peer candidate|
|ipV6Address|string|IP version 6 address of peer candidate|
|port|uint32|Port number of peer candidate|
|ttl|uint32|The number of degrees of separation from the peer|

##### Protobuf Structure

```
message T2TCandidate {
  string peerId = 1;
  uint32 version = 2;
  optional uint32 ipV4Address = 3;
  optional string ipV6Address = 4;
  uint32 port = 5;
  uint32 ttl = 6;
  T2TNodeCapability capability = 7;
}
```

#### T2T-NodeCapability

This message is designed to provide information on current and future capabilities of a particule node to the rest of the swarm.

|Field|Type|Description|
|---|---|---|
|archival|boolean|Defines if the node has the full blockchain|
|blockChainId|uint32[]|Defines the blockchain networks that this node supports|

##### Protobuf Structure

```
message T2TNodeCapability {
  bool archival = 1;
  repeated uint32 blockChainId = 2;
}
```

### BlockChain Payloads

#### BlockChain Data

|Field|Type|Description|
|---|---|---|
|blockChainId|uint32|The unique ID of the blockchain network|
|data|Object|The Protobuf payload of any of the types below|

##### Protobuf Structure

```
message BlockChainPayload {
  uint32 blockChainId = 1;
  oneof data {
    TurtleBlock block = 2;
    TurtleTransaction transaction = 3;
  }
}
```

### Turtle Block Payloads

#### TurtleBlock

|Field|Type|Description|
|---|---|---|
|header|TurtleBlockHeader|The block header|
|baseTransaction|TurtleBaseTransaction|The transaction prefix of the transaction containing the TransactionInputGen|
|transactions|TurtleTransaction[]|Array of Transaction objects contained in the block|

##### Protobuf Structure

```
message TurtleBlock {
  TurtleBlockHeader header = 1;
  TurtleBaseTransaction baseTransaction = 2;
  repeated TurtleTransaction transactions = 3;
}
```

#### Turtle Block Header

|Field|Type|Description|
|---|---|---|
|majorVersion|uint32|The Major version of the block|
|minorVersion|uint32|The Minor version of the block|
|timestamp|uint64|The timestamp of the block|
|previousBlockHash|string|The hex representation of the previous block hash|
|nonce|uint32|The nonce of the block|

##### Protobuf Structure

```
message TurtleBlockHeader {
  uint32 majorVersion = 1;
  uint32 minorVersion = 2;
  uint64 timestamp = 3;
  string previousBlockHash = 4;
  uint32 nonce = 5;
}
```

### Turtle Transaction Payloads

#### Base Transaction

|Field|Type|Description|
|---|---|---|
|transaction|TurtleTransactionPrefix|The transaction data|

##### Protobuf Structure

```
message TurtleBaseTransaction {
  TurtleTransactionPrefix transaction = 1;
}
```

#### Turtle Transaction

|Field|Type|Description|
|---|---|---|
|transaction|TurtleTransactionPrefix|The transaction data|
|signatures|TurtleTransactionSignature[]|Array of TransactionSignature objects|

##### Protobuf Structure

```
message TurtleTransaction {
  TurtleTransactionPrefix transaction = 1;
  repeated TurtleTransactionSignature signature = 2;
}
```

#### Turtle Transaction Prefix

|Field|Type|Description|
|---|---|---|
|version|uint32|Transaction format version|
|unlockTime|uint64|UNIX timestamp or Blockchain Height if < CRYPTONOTE_MAX_BLOCK_NUMBER(500000000)|
|inputs|TurtleTransactionInput[]|Array of TransactionInput objects|
|outputs|TurtleTransactionOutput[]|Array of TransactionOutput objects|
|paymentId|string|Hex representation of 64-bit Payment Id|
|extra|uint32|Additional data associated with the transaction|

##### Protobuf Structure

```
message TurtleTransactionPrefix {
  uint32 version = 1;
  uint64 unlockTime = 2;
  repeated TurtleTransactionInput inputs = 3;
  repeated TurtleTransactionOutput outputs = 4;
  string paymentId = 5;
  repeated uint32 extra = 6;
}
```

#### Turtle Transaction Signature

|Field|Type|Description|
|---|---|---|
|signature|string|Hex representation of 512-bit value of the signature|

##### Protobuf Structure

```
TurtleTransactionSignature {
  string signature = 1;
}
```

#### Turtle Transaction Inputs

##### Turtle Transaction Input

|Field|Type|Description|
|---|---|---|
|input|TurtleTransactionInputGen *or* TurtleTransactionInputKey|The transaction input|

###### Protobuf Structure

```
message TurtleTransactionInput {
  oneof input {
    TurtleTransactionInputGen gen = 1;
    TurtleTransactionInputKey key = 2;
  }
}
```

##### Turtle Transaction Input Gen

|Field|Type|Description|
|---|---|---|
|type|int32|Input type - 0xff. Created by peer who found the block|
|height|uint64|Height of the block which contains the transaction|

###### Protobuf Structure

```
message TurtleTransactionInputGen {
  int32 type = 1;
  uint64 height = 2;
}
```

##### Turtle Transaction Input Key

|Field|Type|Description|
|---|---|---|
|type|int32|Input type - 0x2|
|amount|uint64|Input Amount|
|offsets|uint32[]|Offsets corresponding to the outputs referenced by the input|
|keyImage|string|Hex representation of the 256-bit value of the output spent by the input, used to prevent double spending|

###### Protobuf Structure

```
message TurtleTransactionInputKey {
  int32 type = 1;
  uint64 amount = 2;
  repeated uint32 offsets = 3;
  string keyImage = 4;
}
```

#### Turtle Transaction Outputs

##### Turtle Transaction Output Target

|Field|Type|Description|
|---|---|---|
|type|uint32|Output Type. 0x2 = out to key|
|key|string|Output one time public key|

###### Protobuf Structure

```
message TurtleTransactionOutputTarget {
  uint32 type = 1;
  string key = 2;
}
```

##### Turtle Transaction Output

|Field|Type|Description|
|---|---|---|
|amount|uint64|Output Amount|
|target|TurtleTransactionOutputTarget|Output destination. Destinations may be of different types|

###### Protobuf Structure

```
message TurtleTransactionOutput {
  uint64 amount = 1;
  TurtleTransactionOutputTarget target = 2;
}
```

## License

Copyright (C) 2018 The TurtleCoin Developers

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.