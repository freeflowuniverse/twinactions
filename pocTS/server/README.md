# Servers

## flow1server.v

Allows initiliazing grid client from the browser (the user enters the mnemonics, network, .. etc)



## flow2server.v

Allows initilaizing the grid client from the V server backend (the server starts with the suitable environment of `NET` and `MNE` and it sends it to the web browser to initialize the grid client

```
      # Required Environment Variables
      NET= # it can be one of (dev, qa, test, main)
      MNE= # your mnemonics for your tfchain twin and used for kvstor secret
      
```
