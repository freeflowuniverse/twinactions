module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub struct SendArgs {
	account  string // the account we are sending info from
	to       string
	amount   f64
	currency string
	memo     string // per type blockchain we need to check that memo field is not too long
}

// send money to a user on the chosen blockchain network
// the account used is the one who is selected
//```
// SendArgs {
//		account string
// 		to string
// 		amount f64
// 		memo string
// 		currency string
//}
//```
// multisig is supported, if account is multisig, the the needed needs to be done
pub fn send(args SendArgs) ? {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.account.send'))
	b.add(resp.r_string(args.account))
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
