####################################################################################################################################
# Auto-Generate Files Required for Config Rules
####################################################################################################################################
package pgBackRestLibC::Config::BuildRule;

use strict;
use warnings FATAL => qw(all);
use Carp qw(confess);
use English '-no_match_vars';

use Cwd qw(abs_path);
use Exporter qw(import);
    our @EXPORT = qw();
use File::Basename qw(dirname);
use Storable qw(dclone);

use pgBackRest::Common::Log;
use pgBackRest::Common::String;
use pgBackRest::Config::Data;
use pgBackRest::Config::Rule;
use pgBackRest::Version;

use pgBackRestBuild::Build::Common;
use pgBackRestBuild::Config::BuildRule;

####################################################################################################################################
# Constants
####################################################################################################################################
use constant BLDLCL_FILE_RULE                                       => 'rule';

use constant BLDLCL_CONSTANT_OPTION_TYPE                            => '01-constantOptionType';

####################################################################################################################################
# Definitions for constants and data to build
####################################################################################################################################
my $strSummary = 'Command and Option Rules';

my $rhBuild =
{
    &BLD_FILE =>
    {
        &BLDLCL_FILE_RULE =>
        {
            &BLD_SUMMARY => $strSummary,

            &BLD_CONSTANT_GROUP =>
            {
                &BLDLCL_CONSTANT_OPTION_TYPE =>
                {
                    &BLD_SUMMARY => 'Option type',
                    &BLD_CONSTANT => {},
                },
            },
        },
    },
};

####################################################################################################################################
# Build configuration constants and data
####################################################################################################################################
sub buildXsConfigRule
{
    # Build option type constants
    #-------------------------------------------------------------------------------------------------------------------------------
    my $rhOptionRule = cfgdefRule();
    my $rhOptionTypeMap;

    # Get unique list of types
    foreach my $strOption (sort(keys(%{$rhOptionRule})))
    {
        my $strOptionType = $rhOptionRule->{$strOption}{&CFGBLDDEF_RULE_TYPE};

        if (!defined($rhOptionTypeMap->{$strOptionType}))
        {
            $rhOptionTypeMap->{$strOptionType} = true;
        }
    };

    my $rhConstant = $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_RULE}{&BLD_CONSTANT_GROUP}{&BLDLCL_CONSTANT_OPTION_TYPE}{&BLD_CONSTANT};

    foreach my $strOptionType (sort(keys(%{$rhOptionTypeMap})))
    {
        # Build Perl constant
        my $strOptionTypeConstant = "CFGOPTDEF_TYPE_" . uc($strOptionType);
        $strOptionTypeConstant =~ s/\-/\_/g;

        $rhConstant->{$strOptionTypeConstant}{&BLD_CONSTANT_VALUE} = bldEnum('cfgRuleOptDefType', $strOptionType);
        $rhConstant->{$strOptionTypeConstant}{&BLD_CONSTANT_EXPORT} = true;
    };

    return $rhBuild;
}

push @EXPORT, qw(buildXsConfigRule);

1;
