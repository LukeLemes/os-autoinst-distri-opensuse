# SUSE's openQA tests
#
# Copyright 2009-2013 Bernhard M. Wiedemann
# Copyright 2012-2018 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: splited wait_encrypt_prompt being a single step; harmonized once wait_encrypt_prompt obsoleted
# Maintainer: Max Lin <mlin@suse.com>

use base 'y2_installbase';
use strict;
use warnings;
use testapi;
use utils;

sub run {
    # Eject the DVD
    send_key "ctrl-alt-f3";
    my $tty = get_root_console_tty;
    assert_screen "tty$tty-selected";
    send_key "ctrl-alt-delete";

    # Bug in 13.1?
    power('reset');

    # eject_cd;

    unlock_if_encrypted;
}

1;

