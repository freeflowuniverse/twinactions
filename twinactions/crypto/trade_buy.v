module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub struct BuyActionArg {
	account            string
	asset_buy          string // the asset you want to buy
	max_price_usd      f64    // maximum price your want to buy for
	expirationtime_min u16    // max time in minutes, the trade stays open
	memo               string // per type blockchain we need to check that memo field
	// is not too long, is not everywhere used
}

// set of actions to buy an asset
// everything is re-calculated to USD
// pricing of USD comes from the blockchain (only stellar/algorand)
// the action server will execute in the background and return a uid4 identifier, which can be used to check
// sometimes the blockchain supports a deadline, sometimes the action handler will have to do it
//
//```
// pub struct BuyActionArg {
// 	asset_buy string 		// the asset you want to buy
// 	max_price_usd	f64		//maximum price your want to  biy for
// 	expirationtime_min	u16 //max time in minutes, the trade stays open
// 	memo       string 		// per type blockchain we need to check that memo
//							field is not too long, is not everywhere used
// }
//```
//
pub fn buy(args BuyActionArg) ?string {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.pool.buy'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() or { panic(err) } == 'OK' {
		return
	}
	return error('Could not deposit money to ... to ... . Error:\n#$result.get_string()') // get following string should be the error message
}
