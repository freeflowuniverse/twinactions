module crypto

import freeflowuniverse.crystallib.resp
import freeflowuniverse.twinactions.twinactions

// set of arguments to create, or add to a DEFIPool
// this is for an AMM DEFI pool (Automatic Market Making DEFI Pool)
pub struct DefiPoolDepositArgs {
	poolasset1 string // a pool has 2 assets, this is the first one
	amount1    f64
	currency1  string
	poolasset2 string // a pool has 2 assets, this is the first one
	amount2    f64
	currency2  string
	memo       string // per type blockchain we need to check that memo field is not too long, is not everywhere used
}

// withdraw money from the pool
// need to specify which currency and amount per currency
pub struct DefiPoolWithDrawArgs {
	poolasset1 string // a pool has 2 assets, this is the first one
	amount1    f64
	currency1  string
	poolasset2 string // a pool has 2 assets, this is the first one
	amount2    f64
	currency2  string
	memo       string // per type blockchain we need to check that memo field is not too long, is not everywhere used
}

// identify a pool, is unique, the order of asset 1 or 2 does not matter
pub struct DefiPoolIdentity {
	poolasset1 string // a pool has 2 assets, this is the first one
	poolasset2 string
}

// set of arguments to create, or add to a DEFIPool
//
// pool can exist or it can be a new one
// if there is already money, you will just add to it
pub fn defi_pool_deposit(account string, args DefiPoolDepositArgs) ? {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.pool.deposit'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not deposit money to ... to ... . Error:\n#$result.get_string()') // get following string should be the error message
}

// withdraw money from the pool
// need to specify which currency and amount per currency
pub fn defi_pool_withdraw(account string, args DefiPoolWithDrawArgs) ? {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.pool.withdraw'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not withdraw money from ... to ... . Error:\n#$result.get_string()') // get following string should be the error message
}

// withdraw money from the pool, do the maximum
// the purpose is to get all your money out from the pool
// the handler need to implement the logic to take all out
pub fn defi_pool_withdraw_all(account string, args DefiPoolIdentity) ? {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.pool.withdrawall'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not withdraw all money from ... to ... . Error:\n#$result.get_string()') // get following string should be the error message
}

pub struct DefiPoolInfo {
	pairs []DefiPoolInfoPairInfo // is always 2, need to check this is correct
	// TODO what else is important here?
}

pub struct DefiPoolInfoPairInfo {
	currency string
	amount   f64
	// TODO what else is important here?
}

// get all info from defi pool
pub fn defi_pool_info(args DefiPoolIdentity) ?DefiPoolInfo {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('crypto.pool.info'))
	// TODO:...
	result := twinactions.action_send(b)?
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not get info from specified DEFI pool. Error:\n#$result.get_string()') // get following string should be the error message
}
