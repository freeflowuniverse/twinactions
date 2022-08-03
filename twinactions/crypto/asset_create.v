module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub struct AssetCreateArgs {
pub:
	account string
	name    string
	// TODO specify
	multisig MultiSig // optional
}

pub fn asset_create(args AssetCreateArgs) {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.asset.create')) // the first argument is the command
	// TODO
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not create asset. Error:\n#$result.get_string()') // get following string should be the error message
}

pub struct AssetDeleteArgs {
pub:
	account string
	name    string
}

// deletes the asset, checks the multisignature approach
pub fn asset_delete(args AssetDeleteArgs) {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.asset.delete')) // the first argument is the command
	// TODO
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not delete asset. Error:\n#$result.get_string()') // get following string should be the error message
}
