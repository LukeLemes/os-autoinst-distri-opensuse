# SUSE's openQA tests
#
# Copyright © 2019-2021 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved. This file is offered as-is,
# without any warranty.

# Summary: The class is a parent for all Pages of Network Card Setup Wizard.
# Introduces accessing methods to the elements that are common for all steps
# of the Wizard.

# Maintainer: QE YaST <qa-sle-yast@suse.de>

package YaST::NetworkSettings::NetworkCardSetup::NetworkCardSetupWizard;
use strict;
use warnings;
use testapi;

sub new {
    my ($class, $args) = @_;
    my $self = bless {}, $class;
}

sub press_next {
    my ($self, $page_needle) = @_;
    assert_screen($page_needle);
    send_key('alt-n');
}

1;
