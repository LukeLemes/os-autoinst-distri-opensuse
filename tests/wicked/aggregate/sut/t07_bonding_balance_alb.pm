# SUSE's openQA tests
#
# Copyright 2019 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Package: wicked iproute2
# Summary: Bonding, Balance-alb
# Maintainer: Anton Smorodskyi <asmorodskyi@suse.com>
#             Jose Lausuch <jalausuch@suse.com>
#             Clemens Famulla-Conrad <cfamullaconrad@suse.de>

use Mojo::Base 'wickedbase';
use testapi;


sub run {
    my ($self, $ctx) = @_;
    record_info('INFO', 'Bonding, Balance-alb');
    $self->setup_bond('alb', $ctx->iface(), $ctx->iface2());
    $self->validate_interfaces('bond0', $ctx->iface(), $ctx->iface2());
}

sub test_flags {
    return {always_rollback => 1};
}

1;
