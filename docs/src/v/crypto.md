# module crypto


# Blockchain Actions (crypto)



## Contents
- [account_delete](#account_delete)
- [asset_create](#asset_create)
- [asset_delete](#asset_delete)
- [buy](#buy)
- [info](#info)
- [asset_mint](#asset_mint)
- [orderbook_info](#orderbook_info)
- [defi_pool_deposit](#defi_pool_deposit)
- [defi_pool_info](#defi_pool_info)
- [defi_pool_withdraw](#defi_pool_withdraw)
- [sell](#sell)
- [defi_pool_withdraw_all](#defi_pool_withdraw_all)
- [send](#send)
- [account_init](#account_init)
- [trade_delete](#trade_delete)
- [trade_delete_all](#trade_delete_all)
- [trade_info](#trade_info)
- [asset_burn](#asset_burn)
- [SellActionArg](#SellActionArg)
- [SendArgs](#SendArgs)
- [TradeInfoPair](#TradeInfoPair)
- [AccountArgs](#AccountArgs)
- [AccountAsset](#AccountAsset)
- [AccountInfo](#AccountInfo)
- [AssetBurnArgs](#AssetBurnArgs)
- [AssetCreateArgs](#AssetCreateArgs)
- [AssetDeleteArgs](#AssetDeleteArgs)
- [AssetMintArgs](#AssetMintArgs)
- [BuyActionArg](#BuyActionArg)
- [DefiPoolDepositArgs](#DefiPoolDepositArgs)
- [DefiPoolIdentity](#DefiPoolIdentity)
- [DefiPoolInfo](#DefiPoolInfo)
- [DefiPoolInfoPairInfo](#DefiPoolInfoPairInfo)
- [DefiPoolWithDrawArgs](#DefiPoolWithDrawArgs)
- [MultiSig](#MultiSig)
- [OrderBookInfo](#OrderBookInfo)
- [OrderBookInfoArgs](#OrderBookInfoArgs)
- [OrderBookInfoPair](#OrderBookInfoPair)

## account_delete
```v
fn account_delete(name string) ?
```

delete account on the handler in case it was already initialized, does not give error if not active yet if multisignature more than one will have to do

[[Return to contents]](#Contents)

## asset_create
```v
fn asset_create(args AssetCreateArgs)
```


[[Return to contents]](#Contents)

## asset_delete
```v
fn asset_delete(args AssetDeleteArgs)
```

deletes the asset, checks the multisignature approach

[[Return to contents]](#Contents)

## buy
```v
fn buy(args BuyActionArg) ?string
```

set of actions to buy an asset everything is re-calculated to USD pricing of USD comes from the blockchain (only stellar/algorand) the action server will execute in the background and return a uid4 identifier, which can be used to check sometimes the blockchain supports a deadline, sometimes the action handler will have to do it

```
pub struct BuyActionArg {
	asset_buy string 		// the asset you want to buy
	max_price_usd	f64		//maximum price your want to  biy for
	expirationtime_min	u16 //max time in minutes, the trade stays open
	memo       string 		// per type blockchain we need to check that memo
							field is not too long, is not everywhere used
}
```


[[Return to contents]](#Contents)

## info
```v
fn info(name string) ?AccountInfo
```

return info about your account, the name is the name of the account as used in .account_init() the info returned
```v
pub struct AccountInfo {
	pubkey_bin     []u8 // binary form of key
	pubkey_ed25519 ed25519.PublicKey // can be empty, if not same type, but often it is
	assets         []Asset
}
pub struct AccountAsset {
	amount   f64
	currency string // always lowercase
}
```

[[Return to contents]](#Contents)

## asset_mint
```v
fn asset_mint(args AssetMintArgs)
```

mint amount of tokens of the asset multisignature is used when asset was multisignature

[[Return to contents]](#Contents)

## orderbook_info
```v
fn orderbook_info(account string, args OrderBookInfoArgs) ?string
```

returns all relevant info from an orderbook

[[Return to contents]](#Contents)

## defi_pool_deposit
```v
fn defi_pool_deposit(account string, args DefiPoolDepositArgs) ?
```

set of arguments to create, or add to a DEFIPool

pool can exist or it can be a new one if there is already money, you will just add to it

[[Return to contents]](#Contents)

## defi_pool_info
```v
fn defi_pool_info(args DefiPoolIdentity) ?DefiPoolInfo
```

get all info from defi pool

[[Return to contents]](#Contents)

## defi_pool_withdraw
```v
fn defi_pool_withdraw(account string, args DefiPoolWithDrawArgs) ?
```

withdraw money from the pool need to specify which currency and amount per currency

[[Return to contents]](#Contents)

## sell
```v
fn sell(args SellActionArg) ?string
```

set of actions to sell an asset everything is re-calculated to USD, the money you get back is in USDC pricing of USD comes from the blockchain (only stellar/algorand) the action server will execute in the background and return a uid4 identifier, which can be used to check sometimes the blockchain supports a deadline, sometimes the action handler will have to do it

```
pub struct SellActionArg {
	asset_sell string 			// the asset you want to sell
	min_price_usd      f64    	// min price your want to sell for always in USDC
	expirationtime_min	u16 	// max time in minutes, the trade stays open
	memo       string 			// per type blockchain we need to check that memo
								field is not too long, is not everywhere used
}
```


[[Return to contents]](#Contents)

## defi_pool_withdraw_all
```v
fn defi_pool_withdraw_all(account string, args DefiPoolIdentity) ?
```

withdraw money from the pool, do the maximum the purpose is to get all your money out from the pool the handler need to implement the logic to take all out

[[Return to contents]](#Contents)

## send
```v
fn send(args SendArgs) ?
```

send money to a user on the chosen blockchain network the account used is the one who is selected
```
SendArgs {
		account string
		to string
		amount f64
		memo string
		currency string
}
``` multisig is supported, if account is multisig, the the needed needs to be done

[[Return to contents]](#Contents)

## account_init
```v
fn account_init(args AccountArgs)
```

init the account on the action handler will give error if it already exists and mneomonic or type different will also give error if an error to create it e.g. wrong mnemonic the account will be selected, which means all actions done after are done on this account

[[Return to contents]](#Contents)

## trade_delete
```v
fn trade_delete(account string, uid string) ?TradeInfoPair
```

dlete an open trade, the uid is unique uid is uid4, and as given by sales/buy order creation

[[Return to contents]](#Contents)

## trade_delete_all
```v
fn trade_delete_all(account string) ?TradeInfoPair
```

delete all you open trades

[[Return to contents]](#Contents)

## trade_info
```v
fn trade_info(account string, uid string) ?TradeInfoPair
```

returns all relevant info from an orderbook uid is uid4, and as given by sales/buy order creation

[[Return to contents]](#Contents)

## asset_burn
```v
fn asset_burn(args AssetBurnArgs)
```

destroy some of the tokens of the asset multisignature is used when asset was multisignature

[[Return to contents]](#Contents)

## SellActionArg
```v
struct SellActionArg {
	account            string
	asset_sell         string // the asset you want to sell
	min_price_usd      f64    // min price your want to sell for always in USDC
	expirationtime_min u16    // max time in minutes, the trade stays open
	memo               string // per type blockchain we need to check that memo field is not too long, is not everywhere used
}
```


[[Return to contents]](#Contents)

## SendArgs
```v
struct SendArgs {
	account  string // the account we are sending info from
	to       string
	amount   f64
	currency string
	memo     string // per type blockchain we need to check that memo field is not too long
}
```


[[Return to contents]](#Contents)

## TradeInfoPair
```v
struct TradeInfoPair {
pub mut:
	// TODO specify	
	state TradeState
}
```


[[Return to contents]](#Contents)

## AccountArgs
```v
struct AccountArgs {
pub:
	name           string
	mnemonic       string
	blockchaintype BlockchainType
	expiration     int = 300 // will expire default 5 min
	multisig       MultiSig // optional
}
```


[[Return to contents]](#Contents)

## AccountAsset
```v
struct AccountAsset {
	amount   f64
	currency string // always lowercase
}
```


[[Return to contents]](#Contents)

## AccountInfo
```v
struct AccountInfo {
	pubkey_bin     []u8 // binary form of key
	pubkey_ed25519 ed25519.PublicKey // can be empty, if not same type, but often it is
	assets         []Asset
}
```


[[Return to contents]](#Contents)

## AssetBurnArgs
```v
struct AssetBurnArgs {
pub:
	account    string
	name       string
	burnamount f64
}
```


[[Return to contents]](#Contents)

## AssetCreateArgs
```v
struct AssetCreateArgs {
pub:
	account string
	name    string
	// TODO specify
	multisig MultiSig // optional
}
```


[[Return to contents]](#Contents)

## AssetDeleteArgs
```v
struct AssetDeleteArgs {
pub:
	account string
	name    string
}
```


[[Return to contents]](#Contents)

## AssetMintArgs
```v
struct AssetMintArgs {
pub:
	account    string
	name       string
	mintamount f64
}
```


[[Return to contents]](#Contents)

## BuyActionArg
```v
struct BuyActionArg {
	account            string
	asset_buy          string // the asset you want to buy
	max_price_usd      f64    // maximum price your want to buy for
	expirationtime_min u16    // max time in minutes, the trade stays open
	memo               string // per type blockchain we need to check that memo field
	// is not too long, is not everywhere used
}
```


[[Return to contents]](#Contents)

## DefiPoolDepositArgs
```v
struct DefiPoolDepositArgs {
	poolasset1 string // a pool has 2 assets, this is the first one
	amount1    f64
	currency1  string
	poolasset2 string // a pool has 2 assets, this is the first one
	amount2    f64
	currency2  string
	memo       string // per type blockchain we need to check that memo field is not too long, is not everywhere used
}
```

set of arguments to create, or add to a DEFIPool this is for an AMM DEFI pool (Automatic Market Making DEFI Pool)

[[Return to contents]](#Contents)

## DefiPoolIdentity
```v
struct DefiPoolIdentity {
	poolasset1 string // a pool has 2 assets, this is the first one
	poolasset2 string
}
```

identify a pool, is unique, the order of asset 1 or 2 does not matter

[[Return to contents]](#Contents)

## DefiPoolInfo
```v
struct DefiPoolInfo {
	pairs []DefiPoolInfoPairInfo // is always 2, need to check this is correct
	// TODO what else is important here?
}
```


[[Return to contents]](#Contents)

## DefiPoolInfoPairInfo
```v
struct DefiPoolInfoPairInfo {
	currency string
	amount   f64
	// TODO what else is important here?
}
```


[[Return to contents]](#Contents)

## DefiPoolWithDrawArgs
```v
struct DefiPoolWithDrawArgs {
	poolasset1 string // a pool has 2 assets, this is the first one
	amount1    f64
	currency1  string
	poolasset2 string // a pool has 2 assets, this is the first one
	amount2    f64
	currency2  string
	memo       string // per type blockchain we need to check that memo field is not too long, is not everywhere used
}
```

withdraw money from the pool need to specify which currency and amount per currency

[[Return to contents]](#Contents)

## MultiSig
```v
struct MultiSig {
pub:
	pubkeys       []string // the pubkeys of who needs to sign
	min_signature i16      // how many need minimally to sign
}
```


[[Return to contents]](#Contents)

## OrderBookInfo
```v
struct OrderBookInfo {
pub mut:
	pairs []OrderBookInfoPair
}
```


[[Return to contents]](#Contents)

## OrderBookInfoArgs
```v
struct OrderBookInfoArgs {
pub mut:
	only_my_orders bool = true
}
```


[[Return to contents]](#Contents)

## OrderBookInfoPair
```v
struct OrderBookInfoPair {
pub mut:
	currency1 string
	// TODO specify	
}
```


[[Return to contents]](#Contents)

#### Powered by vdoc.
