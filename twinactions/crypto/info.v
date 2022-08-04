module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.twinactions.twinactions
import crypto.ed25519

pub struct AccountInfo {
	pubkey_bin     []u8 // binary form of key
	pubkey_ed25519 ed25519.PublicKey // can be empty, if not same type, but often it is
	assets         []Asset
}

pub struct AccountAsset {
	amount   f64
	currency string // always lowercase
}

// return info about your account, the name is the name of the account as used in .account_init()
// the info returned
//```v
// pub struct AccountInfo {
// 	pubkey_bin     []u8 // binary form of key
// 	pubkey_ed25519 ed25519.PublicKey // can be empty, if not same type, but often it is
// 	assets         []Asset
// }
// pub struct AccountAsset {
// 	amount   f64
// 	currency string // always lowercase
// }
//```
pub fn info(name string) ?AccountInfo {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.account.info'))
	b.add(resp.r_string(name))
	b.add(resp.r_string(args.from))
	b.add(resp.r_string(args.to))
	b.add(resp.r_float(args.amount))
	b.add(resp.r_string(args.currency.to_lower()))
	b.add(resp.r_string(args.memo))
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not send money from ... to ... . Error:\n#$result.get_string()') // get following string should be the error message
}
