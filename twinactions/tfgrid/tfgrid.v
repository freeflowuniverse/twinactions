module tfgrid

import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

enum TFGridNet {
	testnet
	devnet
	mainnet
}

pub struct AccountArgs {
pub:
	name       string
	mnemonic   string // private key in mnemonic form to be able to work on the right TFGrid net (TFChain)
	nettype    TFGridNet
	expiration int = 300 // will expire default 5 min
	multisig   MultiSig // optional, not implemented yet in TFGrid
}

// used for when we do smart contract for IT with multiple people
pub struct MultiSig {
pub:
	pubkeys       []string // the pubkeys of who needs to sign
	min_signature i16      // how many need minimally to sign
}

// init the account on the action handler for TFGrid
// will give error if it already exists and mneomonic or type different
// will also give error if an error to create it e.g. wrong mnemonic
// the account will be selected, which means all actions done after are done on this account
pub fn account_init(args AccountArgs) {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.account.init')) // the first argument is the command
	b.add(resp.r_string(args.name))
	b.add(resp.r_string(args.mnemonic))
	b.add(resp.r_int(args.expiration))
	// TODO add multisig... (maybe the reflection feature is already there)
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not init account. Error:\n#$result.get_string()') // get following string should be the error message
}

// delete account on the handler in case it was already initialized,
// does not give error if not active yet
// if multisignature more than one will have to do
pub fn account_delete(name string) ? {
	b.add(resp.r_string('tfgrid.account.delete')) // the first argument is the command
	b.add(resp.r_string(args.name))
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not delete account. Error:\n#$result.get_string()') // get following string should be the error message
}
