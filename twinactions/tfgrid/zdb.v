module tfgrid

// inspiration from https://library.threefold.me/info/manual/#/manual3_iac/grid3_javascript/manual__grid3_javascript_zdb
import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub enum ZDBMode {
	user
	seq
}

pub struct ZDBArgs {
pub:
	name      string
	node_id   u32 // id of the node where this ZDB namespace needs to be deployed
	mode      ZDBMode
	disk_size u16 = 9
	public    bool   // a public namespace can be read-only if a password is set
	password  string // password as set on the namespace
}

// in typsecript examples we see zdbs.metadata = '{"test": "test"}';  WHAT IS THIS METADATA, WHERE DOES IT GET STORED

// check that the iprange is properly set
fn (o ZDBArgs) check() ? {
	// TODO
}

// init the account on the action handler for TFGrid
// will give error if it already exists and mneomonic or type different
// will also give error if an error to create it e.g. wrong mnemonic
// the account will be selected, which means all actions done after are done on this account
pub fn zdb_create(args ZDBArgs) ? {
	// TODO: check format of ip_range
	args.check()?
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.zdb.create')) // the first argument is the command
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not init account. Error:\n#$result.get_string()') // get following string should be the error message
}

pub fn zdb_delete(name string) ? {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.zdb.delete')) // the first argument is the command
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not init account. Error:\n#$result.get_string()') // get following string should be the error message
}

// TODO what info comes back?
pub struct ZDBInfo {
pub:
	name      string
	node_id   u32 // id of the node where this ZDB namespace needs to be deployed
	mode      ZDBMode
	disk_size u16 = 9
	public    bool   // a public namespace can be read-only if a password is set
	password  string // password as set on the namespace
}

// get object info from a deployed ZDB namespace
pub fn zdb_info(name string) ?ZDBInfo {
	// how does the client now where to ask the info from?
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.zdb.info')) // the first argument is the command
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not init account. Error:\n#$result.get_string()') // get following string should be the error message
}
