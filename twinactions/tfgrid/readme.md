# TFGrid workload deployment

> inspired by: https://library.threefold.me/info/manual/#/manual3_iac/grid3_javascript

this client allows deployment of all kinds of workloads on TFGrid

- kubernetes
- vm
- zdb
- networks
- qsfs (quantum safe filesystem)
- kvs (key value stor)
- gateways
- ...

>TODO: 

## Principles

The metadata we need to remember is stored in the KVS on TFChain (encrypted by the private key of the account).
This metadata is important it has all info in relation to workloads we have deployed, where are they deployed, ...

## TODO

- key value stor on tfchain
- most of primitives
- how to do capacity planning using the TFGrid Proxy

