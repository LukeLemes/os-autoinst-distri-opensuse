# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Enable automatic login during user creation
#
# Maintainer: QE YaST and Migration (QE Yam) <qe-yam at suse de>

use base 'y2_installbase';
use strict;
use warnings;
use Test::Assert ':all';

sub run {
    my $local_user = $testapi::distri->get_local_user();

    $local_user->enable_automatic_login();
    assert_true($local_user->is_autologin());
}

1;
