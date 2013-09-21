# This is the *target* final state of RA::ChinookDemo, after the
# macro demo script has finished all of its steps. Note that this
# is for human consumption/brainstorming and may not match exactly
# the real/final lib/RA/ChinookDemo.pm file...
package RA::ChinookDemo;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

use RapidApp;

use Catalyst qw/
    -Debug
    RapidApp::RapidDbic
    RapidApp::AuthCore
    RapidApp::CoreSchemaAdmin
    RapidApp::NavCore
/;

extends 'Catalyst';

our $VERSION = '0.01';


__PACKAGE__->config(
    name => 'RA::ChinookDemo',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,

    'Plugin::RapidApp::RapidDbic' => {
      # Only required option:
      dbic_models => ['DB'],
      configs => { # Model Configs
         DB => { # Configs for the model 'DB'
            grid_params => {
               '*defaults' => { # Defaults for all Sources
                  updatable_colspec => ['*'],
                  creatable_colspec => ['*'],
                  destroyable_relspec => ['*']
               }, # ('*defaults')
               Album => {
                  include_colspec => ['*','artistid.name'] 
               },
               InvoiceLine => {
                  # join all columns of all relationships (first-level):
                  include_colspec => ['*','*.*'],
                  updatable_colspec => [
                     'unitprice','quantity',
                     'invoiceid.billing*'
                  ],
               },
               Track => {
                  include_colspec => ['*','albumid.artistid.*'] 
               },
            }, # (grid_params)
            virtual_columns => {
               Employee => {
                  full_name => {
                     data_type => "varchar",
                     is_nullable => 0,
                     size => 255,
                     sql => 'SELECT self.firstname || " " || self.lastname',
                     set_function => sub {
                        my ($row, $value) = @_;
                        my ($fn, $ln) = split(/\s+/,$value,2);
                        $row->update({ firstname=>$fn, lastname=>$ln });
                     },
                  },
               },
            }, # (virtual_columns)
            TableSpecs => {
               Album => {
                  display_column => 'title'
               },
               Artist => {
                  display_column => 'name'
               },
               Employee => {
                  display_column => 'full_name'
               },
               Genre => {
                  display_column => 'name',
                  auto_editor_type => 'combo'
               },
               MediaType => {
                  display_column => 'name'
               },
            }, # (TableSpecs)
         }, # (DB)
      }, # (configs)
    }, # ('Plugin::RapidApp::RapidDbic')
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

RA::ChinookDemo - Catalyst based application

=head1 SYNOPSIS

    script/ra_chinookdemo_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<RA::ChinookDemo::Controller::Root>, L<Catalyst>

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
