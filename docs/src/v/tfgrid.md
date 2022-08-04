# module tfgrid


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



## Contents
- [vm_info](#vm_info)
- [account_init](#account_init)
- [account_delete](#account_delete)
- [zdb_info](#zdb_info)
- [zdb_delete](#zdb_delete)
- [vm_create](#vm_create)
- [vm_delete](#vm_delete)
- [zdb_create](#zdb_create)
- [ZDBMode](#ZDBMode)
- [AccountArgs](#AccountArgs)
- [VMInfo](#VMInfo)
- [VMNet](#VMNet)
- [VMArgs](#VMArgs)
- [MultiSig](#MultiSig)
- [IPRange](#IPRange)
- [ZDBArgs](#ZDBArgs)
- [ZDBInfo](#ZDBInfo)
- [VMDisk](#VMDisk)

## vm_info
```v
fn vm_info(name string) ?VMInfo
```

get object info from a deployed ZDB namespace

[[Return to contents]](#Contents)

## account_init
```v
fn account_init(args AccountArgs)
```

init the account on the action handler for TFGrid will give error if it already exists and mneomonic or type different will also give error if an error to create it e.g. wrong mnemonic the account will be selected, which means all actions done after are done on this account

[[Return to contents]](#Contents)

## account_delete
```v
fn account_delete(name string) ?
```

delete account on the handler in case it was already initialized, does not give error if not active yet if multisignature more than one will have to do

[[Return to contents]](#Contents)

## zdb_info
```v
fn zdb_info(name string) ?ZDBInfo
```

get object info from a deployed ZDB namespace

[[Return to contents]](#Contents)

## zdb_delete
```v
fn zdb_delete(name string) ?
```


[[Return to contents]](#Contents)

## vm_create
```v
fn vm_create(args VMArgs) ?
```

init the account on the action handler for TFGrid will give error if it already exists and mneomonic or type different will also give error if an error to create it e.g. wrong mnemonic the account will be selected, which means all actions done after are done on this account

[[Return to contents]](#Contents)

## vm_delete
```v
fn vm_delete(name string) ?
```


[[Return to contents]](#Contents)

## zdb_create
```v
fn zdb_create(args ZDBArgs) ?
```

init the account on the action handler for TFGrid will give error if it already exists and mneomonic or type different will also give error if an error to create it e.g. wrong mnemonic the account will be selected, which means all actions done after are done on this account

[[Return to contents]](#Contents)

## ZDBMode
```v
enum ZDBMode {
	user
	seq
}
```


[[Return to contents]](#Contents)

## AccountArgs
```v
struct AccountArgs {
pub:
	name       string
	mnemonic   string // private key in mnemonic form to be able to work on the right TFGrid net (TFChain)
	nettype    TFGridNet
	expiration int = 300 // will expire default 5 min
	multisig   MultiSig // optional, not implemented yet in TFGrid
}
```


[[Return to contents]](#Contents)

## VMInfo
```v
struct VMInfo {
pub:
	name        string
	disks       []VMDisk
	network     VMNet
	node_id     u32  // id of the node where this VM needs to be deployed
	public_ip   bool // connect virtual machine to public internet, this VM will receive an IP address
	planetary   bool // connect the virtual machine to the planetary network
	cpu         u8   // nr of cpu cores 1...16
	memory      u16  // MB of ram e.g. 1024*2 would be 2 GB
	rootfs_size u16    = 1 // GB of root filesystem
	flist       string = 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
	entrypoint  string = '/sbin/zinit init'
	env         map[string]string // environment variables as passed to VM
	ssh_key     string // default ssh_key is alias to SSH_KEY in env
}
```

TODO what info comes back?

[[Return to contents]](#Contents)

## VMNet
```v
struct VMNet {
pub:
	name  string
	range IPRange
}
```

network needs to correspond to network created on nodes, otherwise this will not work

[[Return to contents]](#Contents)

## VMArgs
```v
struct VMArgs {
pub:
	name        string
	disks       []VMDisk
	network     VMNet
	node_id     u32  // id of the node where this VM needs to be deployed
	public_ip   bool // connect virtual machine to public internet, this VM will receive an IP address
	planetary   bool // connect the virtual machine to the planetary network
	cpu         u8   // nr of cpu cores 1...16
	memory      u16  // MB of ram e.g. 1024*2 would be 2 GB
	rootfs_size u16    = 1 // GB of root filesystem
	flist       string = 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
	entrypoint  string = '/sbin/zinit init'
	env         map[string]string // environment variables as passed to VM
	ssh_key     string // default ssh_key is alias to SSH_KEY in env
}
```


[[Return to contents]](#Contents)

## MultiSig
```v
struct MultiSig {
pub:
	pubkeys       []string // the pubkeys of who needs to sign
	min_signature i16      // how many need minimally to sign
}
```

used for when we do smart contract for IT with multiple people

[[Return to contents]](#Contents)

## IPRange
```v
struct IPRange {
pub:
	range string = '10.10.0.0'
	mask  i16    = 16
}
```


[[Return to contents]](#Contents)

## ZDBArgs
```v
struct ZDBArgs {
pub:
	name      string
	node_id   u32 // id of the node where this ZDB namespace needs to be deployed
	mode      ZDBMode
	disk_size u16 = 9
	public    bool   // a public namespace can be read-only if a password is set
	password  string // password as set on the namespace
}
```


[[Return to contents]](#Contents)

## ZDBInfo
```v
struct ZDBInfo {
pub:
	name      string
	node_id   u32 // id of the node where this ZDB namespace needs to be deployed
	mode      ZDBMode
	disk_size u16 = 9
	public    bool   // a public namespace can be read-only if a password is set
	password  string // password as set on the namespace
}
```

TODO what info comes back?

[[Return to contents]](#Contents)

## VMDisk
```v
struct VMDisk {
pub:
	name       string = 'default'
	size       i16    = 8 // GB size of disk
	mountpoint string = '/testdisk'
}
```


[[Return to contents]](#Contents)

#### Powered by vdoc.
