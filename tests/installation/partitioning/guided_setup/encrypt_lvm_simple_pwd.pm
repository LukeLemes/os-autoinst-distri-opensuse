# Copyright SUSE LLC
# SPDX-License-Identifier: FSFAP
#
# Summary: The test module enables LVM and configures partition encryption
# with too simple password on Partitioning Scheme Screen of Guided Setup.
# Maintainer: QE YaST <qa-sle-yast@suse.de>

use parent 'y2_installbase';
use strict;
use warnings;

sub run {
    my $partitioning_scheme = $testapi::distri->get_partitioning_scheme();
    $partitioning_scheme->enable_lvm();
    $partitioning_scheme->configure_encryption($testapi::password);
    $partitioning_scheme->go_forward();
    $partitioning_scheme->get_weak_password_warning->press_yes();
}

1;
