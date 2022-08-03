module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub struct AssetBurnArgs {
pub:
	account    string
	name       string
	burnamount f64
}

// destroy some of the tokens of the asset
// multisignature is used when asset was multisignature
pub fn asset_burn(args AssetBurnArgs) {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.asset.burn'))
	// TODO
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not create asset. Error:\n#$result.get_string()') // get following string should be the error message
}

pub struct AssetMintArgs {
pub:
	account    string
	name       string
	mintamount f64
}

// mint amount of tokens of the asset
// multisignature is used when asset was multisignature
pub fn asset_mint(args AssetMintArgs) {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.asset.burn'))
	// TODO
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not create asset. Error:\n#$result.get_string()') // get following string should be the error message
}
