# SUSE's openQA tests
#
# Copyright 2018 SUSE LLC
# SPDX-License-Identifier: FSFAP
#
# Summary: Actions required after upgrade
#       Such as:
#       1) Change the HDDVERSION to UPGRADE_TARGET_VERSION
# Maintainer: Wei Gao <wegao@suse.com>

use base "opensusebasetest";
use strict;
use warnings;
use testapi;
use utils 'get_x11_console_tty';

sub run {
    # Reset HDDVERSION after upgrade
    set_var('HDDVERSION', get_var('UPGRADE_TARGET_VERSION', get_var('VERSION')));
}

1;
