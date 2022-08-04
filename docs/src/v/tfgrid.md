# module tfgrid




## Contents
- [account_delete](#account_delete)
- [account_init](#account_init)
- [AccountArgs](#AccountArgs)
- [MultiSig](#MultiSig)

## account_delete
```v
fn account_delete(name string) ?
```

delete account on the handler in case it was already initialized, does not give error if not active yet if multisignature more than one will have to do

[[Return to contents]](#Contents)

## account_init
```v
fn account_init(args AccountArgs)
```

init the account on the action handler for TFGrud will give error if it already exists and mneomonic or type different will also give error if an error to create it e.g. wrong mnemonic the account will be selected, which means all actions done after are done on this account

[[Return to contents]](#Contents)

## AccountArgs
```v
struct AccountArgs {
pub:
	name       string
	mnemonic   string
	expiration int = 300 // will expire default 5 min
	multisig   MultiSig // optional, not implemented yet in TFGrid
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

#### Powered by vdoc.
