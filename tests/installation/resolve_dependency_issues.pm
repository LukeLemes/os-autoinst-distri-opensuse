# SUSE's openQA tests
#
# Copyright © 2019-2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Unified dependency issues resolver
# - If manual intervention is needed during software selection on installation:
#   - If WORKAROUND_DEPS is set, try to use first suggestion to fix dependency issue
#   - If BREAK_DEPS is set, choose option to break dependencies
# - Handle license, automatic changes, unsupported packages, errors with
# patterns.
# Maintainer: QE YaST <qa-sle-yast@suse.de>

use base "y2_installbase";
use strict;
use warnings;
use testapi;

sub run {
    my ($self) = @_;
    assert_screen('installation-settings-overview-loaded', 420);

    if (check_screen('manual-intervention', 0)) {
        $self->deal_with_dependency_issues;
    } elsif (check_screen('installation-settings-overview-loaded-scrollbar')) {
        # We still need further check if we find scrollbar
        assert_and_click "installation-settings-overview-loaded-scrollbar-down";
        if (check_screen('manual-intervention', 0)) {
            $self->deal_with_dependency_issues;
        }
    }
}

sub post_fail_hook {
    my $self = shift;
    select_console 'root-console';
    $self->upload_solvertestcase_logs();
    $self->SUPER::post_fail_hook;
}

1;
