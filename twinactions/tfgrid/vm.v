module tfgrid

// inspiration from https://library.threefold.me/info/manual/#/manual3_iac/grid3_javascript/manual__grid3_javascript_vm
import freeflowuniverse.crystallib.resp
import freeflowuniverse.crystallib.twinactions

pub struct VMArgs {
pub:
	name        string
	disks       []VMDisk
	network     VMNet
	node_id     u32  // id of the node where this VM needs to be deployed
	public_ip   bool // connect virtual machine to public internet, this VM will receive an IP address
	planetary   bool // connect the virtual machine to the planetary network
	cpu         u8   // nr of cpu cores 1...16
	memory      u16  // MB of ram e.g. 1024*2 would be 2 GB
	rootfs_size u16    = 1 // GB of root filesystem
	flist       string = 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
	entrypoint  string = '/sbin/zinit init'
	env         map[string]string // environment variables as passed to VM
	ssh_key     string // default ssh_key is alias to SSH_KEY in env
}

pub struct VMDisk {
pub:
	name       string = 'default'
	size       i16    = 8 // GB size of disk
	mountpoint string = '/testdisk'
}

// network needs to correspond to network created on nodes, otherwise this will not work
pub struct VMNet {
pub:
	name  string
	range IPRange
}

pub struct IPRange {
pub:
	range string = '10.10.0.0'
	mask  i16    = 16
}

// check that the iprange is properly set
fn (iprange IPRange) check() ? {
	// TODO
}

// check that the iprange is properly set
fn (disks VMDisk) check() ? {
	// TODO: check it starts with / on mountpoint & sizes are reasonale
}

// init the account on the action handler for TFGrid
// will give error if it already exists and mneomonic or type different
// will also give error if an error to create it e.g. wrong mnemonic
// the account will be selected, which means all actions done after are done on this account
pub fn vm_create(args VMArgs) ? {
	// TODO: check format of ip_range
	args.network.range.check()?
	for disk in args.disks {
		disk.check()?
	}
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.vm.create')) // the first argument is the command
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not .... Error:\n#$result.get_string()') // get following string should be the error message
}

pub fn vm_delete(name string) ? {
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.vm.delete')) // the first argument is the command
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not .... Error:\n#$result.get_string()') // get following string should be the error message
}

// TODO what info comes back?
pub struct VMInfo {
pub:
	name        string
	disks       []VMDisk
	network     VMNet
	node_id     u32  // id of the node where this VM needs to be deployed
	public_ip   bool // connect virtual machine to public internet, this VM will receive an IP address
	planetary   bool // connect the virtual machine to the planetary network
	cpu         u8   // nr of cpu cores 1...16
	memory      u16  // MB of ram e.g. 1024*2 would be 2 GB
	rootfs_size u16    = 1 // GB of root filesystem
	flist       string = 'https://hub.grid.tf/tf-official-apps/base:latest.flist'
	entrypoint  string = '/sbin/zinit init'
	env         map[string]string // environment variables as passed to VM
	ssh_key     string // default ssh_key is alias to SSH_KEY in env
}

// get object info from a deployed ZDB namespace
pub fn vm_info(name string) ?VMInfo {
	// how does the client now where to ask the info from?
	mut b := resp.builder_new()
	// in future this will go automacally by means of resp encoder, now we create it manual
	b.add(resp.r_string('tfgrid.vm.info')) // the first argument is the command
	result := twinactions.action_send(b)?
	// thjere is no return only error in case the account cannot be created e.g. exists already and different mnemonic or type
	if result.get_string() == 'OK' {
		return
	}
	return error('Could not get info from VM. Error:\n#$result.get_string()') // get following string should be the error message
}
