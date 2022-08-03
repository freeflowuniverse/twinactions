module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub struct OrderBookInfoArgs {
pub mut:
	only_my_orders bool = true
}

pub struct OrderBookInfo {
pub mut:
	pairs []OrderBookInfoPair
}

pub struct OrderBookInfoPair {
pub mut:
	currency1 string
	// TODO specify	
}

// returns all relevant info from an orderbook
pub fn orderbook_info(account string, args OrderBookInfoArgs) ?string {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.orderbook.info'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could query the orderbook. Error:\n#$result.get_string()') // get following string should be the error message
}

enum TradeState {
	open
	closed
	error
}

pub struct TradeInfoPair {
pub mut:
	// TODO specify	
	state TradeState
}

// returns all relevant info from an orderbook
// uid is uid4, and as given by sales/buy order creation
pub fn trade_info(account string, uid string) ?TradeInfoPair {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.trade.info'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could query the orderbook. Error:\n#$result.get_string()') // get following string should be the error message
}

// dlete an open trade, the uid is unique
// uid is uid4, and as given by sales/buy order creation
pub fn trade_delete(account string, uid string) ?TradeInfoPair {
	mut b := resp.builder_new()
	b.add(resp.r_string('crypto.trade.delete'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could query the orderbook. Error:\n#$result.get_string()') // get following string should be the error message
}

// delete all you open trades
pub fn trade_delete_all(account string) ?TradeInfoPair {
	// todo
}
