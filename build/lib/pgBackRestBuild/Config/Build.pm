####################################################################################################################################
# Auto-Generate Files Required for Config
####################################################################################################################################
package pgBackRestBuild::Config::Build;

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
use pgBackRestBuild::Config::Rule;

####################################################################################################################################
# Constants
####################################################################################################################################
use constant BLDLCL_FILE_CONFIG                                     => 'config';

use constant BLDLCL_DATA_COMMAND                                    => '01-command';
use constant BLDLCL_DATA_OPTION                                     => '02-option';

use constant BLDLCL_ENUM_COMMAND                                    => '01-enumCommand';
use constant BLDLCL_ENUM_OPTION                                     => '02-enumOption';

####################################################################################################################################
# Definitions for constants and data to build
####################################################################################################################################
my $rhBuild =
{
    &BLD_FILE =>
    {
        #---------------------------------------------------------------------------------------------------------------------------
        &BLDLCL_FILE_CONFIG =>
        {
            &BLD_SUMMARY => 'Command and Option Configuration',

            &BLD_ENUM =>
            {
                &BLDLCL_ENUM_COMMAND =>
                {
                    &BLD_SUMMARY => 'Command',
                    &BLD_NAME => 'ConfigCommand',
                    &BLD_LIST => [],
                },

                &BLDLCL_ENUM_OPTION =>
                {
                    &BLD_SUMMARY => 'Option',
                    &BLD_NAME => 'ConfigOption',
                    &BLD_LIST => [],
                },
            },

            &BLD_DATA =>
            {
                &BLDLCL_DATA_COMMAND =>
                {
                    &BLD_SUMMARY => 'Command data',
                },

                &BLDLCL_DATA_OPTION =>
                {
                    &BLD_SUMMARY => 'Option data',
                },
            },
        },
    },
};

####################################################################################################################################
# Build constants and data
####################################################################################################################################
sub buildConfig
{
    # Build command constants and data
    #-------------------------------------------------------------------------------------------------------------------------------
    my $rhEnum = $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_CONFIG}{&BLD_ENUM}{&BLDLCL_ENUM_COMMAND};

    my $strBuildSource =
        "ConfigCommandData configCommandData[] = CONFIG_COMMAND_LIST\n" .
        "(";

    foreach my $strCommand (sort(keys(%{cfgbldCommandGet()})))
    {
        # Build C enum
        my $strCommandEnum = bldEnum('cfgCmd', $strCommand);
        push(@{$rhEnum->{&BLD_LIST}}, $strCommandEnum);

        # Build command data
        $strBuildSource .=
            "\n" .
            "    CONFIG_COMMAND\n" .
            "    (\n" .
            "        CONFIG_COMMAND_NAME(\"${strCommand}\")\n" .
            "    )\n";
    }

    $strBuildSource .=
        ")\n";

    $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_CONFIG}{&BLD_DATA}{&BLDLCL_DATA_COMMAND}{&BLD_SOURCE} = $strBuildSource;

    # Build option constants and data
    #-------------------------------------------------------------------------------------------------------------------------------
    my $rhOptionRule = cfgdefRule();
    $rhEnum = $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_CONFIG}{&BLD_ENUM}{&BLDLCL_ENUM_OPTION};
    my $iOptionTotal = 0;

    $strBuildSource =
        "ConfigOptionData configOptionData[] = CONFIG_OPTION_LIST\n" .
        "(";

    foreach my $strOption (sort(keys(%{$rhOptionRule})))
    {
        my $iOptionIndexTotal = $rhOptionRule->{$strOption}{&CFGBLDDEF_RULE_INDEX_TOTAL};
        my $strOptionPrefix = $rhOptionRule->{$strOption}{&CFGBLDDEF_RULE_PREFIX};

        # Build C enum
        my $strOptionEnum = bldEnum('cfgOption', $strOption);
        push(@{$rhEnum->{&BLD_LIST}}, $strOptionEnum);
        $rhEnum->{&BLD_VALUE}{$strOptionEnum} = $iOptionTotal;

        # Builds option data
        for (my $iOptionIndex = 1; $iOptionIndex <= $iOptionIndexTotal; $iOptionIndex++)
        {
            # Create the indexed version of the option name
            my $strOptionIndex = $iOptionIndexTotal > 1 ?
                "${strOptionPrefix}${iOptionIndex}-" . substr($strOption, length($strOptionPrefix) + 1) : $strOption;

            # Add option data
            $strBuildSource .=
                "\n" .
                "    //" . (qw{-} x 126) . "\n" .
                "    CONFIG_OPTION\n" .
                "    (\n" .
                "        CONFIG_OPTION_NAME(\"${strOptionIndex}\")\n" .
                "        CONFIG_OPTION_INDEX(" . ($iOptionIndex - 1) . ")\n" .
                "        CONFIG_OPTION_RULE_ID(" . buildConfigOptionRuleEnum($strOption) . ")\n" .
                "    )\n";
        }

        $iOptionTotal += $iOptionIndexTotal;
    }

    $strBuildSource .=
        ")\n";

    $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_CONFIG}{&BLD_DATA}{&BLDLCL_DATA_OPTION}{&BLD_SOURCE} = $strBuildSource;

    return $rhBuild;
}

push @EXPORT, qw(buildConfig);

1;
