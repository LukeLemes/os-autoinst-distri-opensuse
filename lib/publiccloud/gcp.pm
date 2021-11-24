# SUSE's openQA tests
#
# Copyright 2021 SUSE LLC
# SPDX-License-Identifier: FSFAP

# Summary: Helper class for Google Cloud Platform
#
# Maintainer: Clemens Famulla-Conrad <cfamullaconrad@suse.de>
#             Jose Lausuch <jalausuch@suse.de>
#             qa-c team <qa-c@suse.de>

package publiccloud::gcp;
use Mojo::Base 'publiccloud::provider';
use Mojo::Util qw(b64_decode);
use Mojo::JSON 'decode_json';
use mmapi 'get_current_job_id';
use testapi;
use utils;

use constant CREDENTIALS_FILE => '/root/google_credentials.json';

has account => undef;
has project_id => undef;
has private_key_id => undef;
has private_key => undef;
has service_acount_name => undef;
has client_id => undef;
has vault_gcp_role_index => undef;
has gcr_zone => undef;

sub vault_gcp_roles {
    return split(/\s*,\s*/,
        get_var('PUBLIC_CLOUD_VAULT_ROLES', 'openqa-role,openqa-role1,openqa-role2,openqa-role3'));
}


sub init {
    my ($self) = @_;
    $self->SUPER::init();
    $self->vault(publiccloud::vault->new());

    $self->gcr_zone(get_var('PUBLIC_CLOUD_GCR_ZONE', 'eu.gcr.io'));

    $self->create_credentials_file();
    assert_script_run('source ~/.bashrc');
    assert_script_run('ntpdate -s time.google.com');
    assert_script_run('gcloud config set account ' . $self->account);
    assert_script_run('gcloud auth activate-service-account --key-file=' . CREDENTIALS_FILE . ' --project=' . $self->project_id);
}

=head2
A service account in GCP can only have up to 10 keys assigned. With this we 
reach our paralel openqa jobs quite fast.
To have more keys available, we create 4 service accounts and select randomly
one. If this fails, the next call of C<get_next_vault_role()> will retrieve
the next.

=cut
sub get_next_vault_role {
    my ($self) = shift;
    my @known_roles = $self->vault_gcp_roles();
    if (defined($self->vault_gcp_role_index)) {
        $self->vault_gcp_role_index(($self->vault_gcp_role_index + 1) % scalar(@known_roles));
    } else {
        $self->vault_gcp_role_index(int(rand(scalar(@known_roles))));
    }
    return $known_roles[$self->vault_gcp_role_index];
}

sub create_credentials_file {
    my ($self) = @_;
    my $credentials_file;

    if ($self->private_key_id()) {
        $credentials_file = "{" . $/
          . '"type": "service_account", ' . $/
          . '"project_id": "' . $self->project_id . '", ' . $/
          . '"private_key_id": "' . $self->private_key_id . '", ' . $/
          . '"private_key": "' . $self->private_key . '", ' . $/
          . '"client_email": "' . $self->service_acount_name . '@' . $self->project_id . '.iam.gserviceaccount.com", ' . $/
          . '"client_id": "' . $self->client_id . '", ' . $/
          . '"auth_uri": "https://accounts.google.com/o/oauth2/auth", ' . $/
          . '"token_uri": "https://oauth2.googleapis.com/token", ' . $/
          . '"auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", ' . $/
          . '"client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/' . $self->service_acount_name . '%40' . $self->project_id . '.iam.gserviceaccount.com"' . $/
          . '}';
    } else {
        record_info('INFO', 'Get credentials from VAULT server.');

        my $data = $self->vault->retry(
            sub { $self->vault->get_secrets('/gcp/key/' . $self->get_next_vault_role(), max_tries => 1) },
            name => 'get_secrets(gcp)',
            max_tries => scalar($self->vault_gcp_roles()) * 2,
            sleep_duration => get_var('PUBLIC_CLOUD_VAULT_TIMEOUT', 5)
        );
        $credentials_file = b64_decode($data->{private_key_data});
        my $cf_json = decode_json($credentials_file);
        $self->account($cf_json->{client_email});
        $self->project_id($cf_json->{'project_id'});
    }

    save_tmp_file(CREDENTIALS_FILE, $credentials_file);
    assert_script_run('curl ' . autoinst_url . '/files/' . CREDENTIALS_FILE . ' -o ' . CREDENTIALS_FILE);
}

sub get_credentials_file_name {
    return CREDENTIALS_FILE;
}


=head2 get_container_registry_prefix
Get the full registry prefix URL for any containers image registry of ECR based on the account and region
=cut
sub get_container_registry_prefix {
    my ($self) = @_;
    return sprintf($self->gcr_zone . '/suse-sle-qa', $self->project_id);
}

=head2 get_container_image_full_name
Get the full name for a container image in ECR registry
=cut
sub get_container_image_full_name {
    my ($self, $tag) = @_;
    my $full_name_prefix = $self->get_container_registry_prefix();
    return "$full_name_prefix/$tag:latest";
}

=head2 get_default_tag
Returns a default tag for container images based of the current job id (required by GCR)
=cut
sub get_default_tag {
    my ($self) = @_;
    return join('-', $self->resource_name, get_current_job_id());
}

sub cleanup {
    my ($self) = @_;
    $self->SUPER::cleanup();
    $self->vault->revoke();
}

1;
