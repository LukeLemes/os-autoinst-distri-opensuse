# SUSE's openQA tests
#
# Copyright © 2017 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: HPC_Module: mrsh slave
#    This test is setting up a mrsh scenario according to the testcase
#    described in FATE
# Maintainer: soulofdestiny <mgriessmeier@suse.com>
# Tags: https://fate.suse.com/321722

use base "hpcbase";
use strict;
use testapi;
use lockapi;
use utils;

sub run {
    my $self = shift;

    # set proper hostname
    assert_script_run "hostnamectl set-hostname mrsh-slave";

    # install mrsh
    zypper_call('in mrsh mrsh-server');
    barrier_wait("MRSH_INSTALLATION_FINISHED");
    mutex_lock("MRSH_KEY_COPIED");

    # start munge
    $self->enable_and_start('munge');
    barrier_wait("MRSH_MUNGE_ENABLED");

    # Start the socket listener for mrlogind and mrsh
    $self->enable_and_start('mrlogind.socket mrshd.socket');
    barrier_wait("SLAVE_MRLOGIN_STARTED");
    barrier_wait("MRSH_MASTER_DONE");
}

sub test_flags {
    return {fatal => 1, milestone => 1};
}

1;
# vim: set sw=4 et:
