####################################################################################################################################
# Auto-Generate Files Required for Config Rules
####################################################################################################################################
package pgBackRestBuild::Config::BuildRule;

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
use pgBackRestBuild::Config::Rule qw(cfgbldCommandGet);

# !!! MAYBE CFGDEFOPT, cfgDefOpt would be better that cfgRule

####################################################################################################################################
# Constants
####################################################################################################################################
use constant BLDLCL_FILE_RULE                                       => 'rule';

use constant BLDLCL_DATA_COMMAND                                    => '01-dataCommand';
use constant BLDLCL_DATA_OPTION                                     => '02-dataOption';

use constant BLDLCL_ENUM_COMMAND                                    => '01-enumCommand';
use constant BLDLCL_ENUM_OPTION_TYPE                                => '02-enumOptionType';
use constant BLDLCL_ENUM_OPTION                                     => '03-enumOption';

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

            &BLD_ENUM =>
            {
                &BLDLCL_ENUM_COMMAND =>
                {
                    &BLD_SUMMARY => 'Command rule',
                    &BLD_NAME => 'ConfigRuleCommand',
                },

                &BLDLCL_ENUM_OPTION_TYPE =>
                {
                    &BLD_SUMMARY => 'Option type rule',
                    &BLD_NAME => 'ConfigRuleOptionType',
                },

                &BLDLCL_ENUM_OPTION =>
                {
                    &BLD_SUMMARY => 'Option rule',
                    &BLD_NAME => 'ConfigRuleOption',
                },
            },

            &BLD_DATA =>
            {
                &BLDLCL_DATA_COMMAND =>
                {
                    &BLD_SUMMARY => 'Command rule data',
                },

                &BLDLCL_DATA_OPTION =>
                {
                    &BLD_SUMMARY => 'Option rule data',
                },
            },
        },
    },
};

####################################################################################################################################
# Generate enum names
####################################################################################################################################
sub buildConfigCommandRuleEnum
{
    return bldEnum('cfgRuleCmd', shift)
}

push @EXPORT, qw(buildConfigCommandRuleEnum);

sub buildConfigOptionTypeRuleEnum
{
    return bldEnum('cfgRuleOptDefType', shift);
}

push @EXPORT, qw(buildConfigOptionTypeRuleEnum);

sub buildConfigOptionRuleEnum
{
    return bldEnum('cfgRuleOpt', shift);
}

push @EXPORT, qw(buildConfigOptionRuleEnum);

####################################################################################################################################
# Helper functions for building optional option data
####################################################################################################################################
sub renderAllowList
{
    my $ryAllowList = shift;
    my $bCommandIndent = shift;

    my $strIndent = $bCommandIndent ? '    ' : '';

    return
        "${strIndent}            CONFIG_OPTION_ALLOW_LIST\n" .
        "${strIndent}            (\n" .
        "${strIndent}                " . join(",\n${strIndent}                ", bldQuoteList($ryAllowList)) .
        "\n" .
        "${strIndent}            )\n";
}

sub renderDepend
{
    my $rhDepend = shift;
    my $bCommandIndent = shift;

    my $strIndent = $bCommandIndent ? '    ' : '';

    my $strDependOption = $rhDepend->{&CFGBLDDEF_RULE_DEPEND_OPTION};
    my $ryDependList = $rhDepend->{&CFGBLDDEF_RULE_DEPEND_LIST};

    if (defined($ryDependList))
    {
        my @stryQuoteList;

        foreach my $strItem (@{$ryDependList})
        {
            push(@stryQuoteList, "\"${strItem}\"");
        }

        return
            "${strIndent}            CONFIG_OPTION_DEPEND_LIST\n" .
            "${strIndent}            (\n" .
            "${strIndent}                " . buildConfigOptionRuleEnum($strDependOption) . ",\n" .
            "${strIndent}                " . join(",\n${strIndent}                ", bldQuoteList($ryDependList)) .
            "\n" .
            "${strIndent}            )\n";
    }

    return
        "${strIndent}            CONFIG_OPTION_DEPEND(" . buildConfigOptionRuleEnum($strDependOption) . ")\n";
}

sub renderOptional
{
    my $rhOptional = shift;
    my $bCommand = shift;

    my $strIndent = $bCommand ? '    ' : '';
    my $strBuildSourceOptional;
    my $bSingleLine = false;

    if (defined($rhOptional->{&CFGBLDDEF_RULE_ALLOW_LIST}))
    {
        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            renderAllowList($rhOptional->{&CFGBLDDEF_RULE_ALLOW_LIST}, $bCommand);

        $bSingleLine = false;
    }

    if (defined($rhOptional->{&CFGBLDDEF_RULE_ALLOW_RANGE}))
    {
        my @fyRange = @{$rhOptional->{&CFGBLDDEF_RULE_ALLOW_RANGE}};

        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            "${strIndent}            CONFIG_OPTION_ALLOW_RANGE(" . $fyRange[0] . ', ' . $fyRange[1] . ")\n";

        $bSingleLine = true;
    }
    if (defined($rhOptional->{&CFGBLDDEF_RULE_DEPEND}))
    {
        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            renderDepend($rhOptional->{&CFGBLDDEF_RULE_DEPEND}, $bCommand);

        $bSingleLine = defined($rhOptional->{&CFGBLDDEF_RULE_DEPEND}{&CFGBLDDEF_RULE_DEPEND_LIST}) ? false : true;
    }

    if (defined($rhOptional->{&CFGBLDDEF_RULE_DEFAULT}))
    {
        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            "${strIndent}            CONFIG_OPTION_DEFAULT(\"" . $rhOptional->{&CFGBLDDEF_RULE_DEFAULT} . "\")\n";

        $bSingleLine = true;
    }

    if (defined($rhOptional->{&CFGBLDDEF_RULE_ALT_NAME}))
    {
        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            "${strIndent}            CONFIG_OPTION_NAME_ALT(\"" . $rhOptional->{&CFGBLDDEF_RULE_ALT_NAME} . "\")\n";

        $bSingleLine = true;
    }

    if (defined($rhOptional->{&CFGBLDDEF_RULE_PREFIX}))
    {
        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            "${strIndent}            CONFIG_OPTION_PREFIX(\"" . $rhOptional->{&CFGBLDDEF_RULE_PREFIX} . "\")\n";

        $bSingleLine = true;
    }

    if ($bCommand && defined($rhOptional->{&CFGBLDDEF_RULE_REQUIRED}))
    {
        $strBuildSourceOptional .=
            (defined($strBuildSourceOptional) && !$bSingleLine ? "\n" : '') .
            "${strIndent}            CONFIG_OPTION_COMMAND_REQUIRED(" .
                ($rhOptional->{&CFGBLDDEF_RULE_REQUIRED} ? 'true' : 'false') . ")\n";

        $bSingleLine = true;
    }

    return $strBuildSourceOptional;
}

####################################################################################################################################
# Build configuration constants and data
####################################################################################################################################
sub buildConfigRule
{
    # Build command constants and data
    #-------------------------------------------------------------------------------------------------------------------------------
    my $rhEnum = $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_RULE}{&BLD_ENUM}{&BLDLCL_ENUM_COMMAND};

    my $strBuildSource =
        "CommandRule commandRule[] = CONFIGURATION_DEFINITION_COMMAND_LIST\n" .
        "(";

    foreach my $strCommand (sort(keys(%{cfgbldCommandGet()})))
    {
        # Build C enum
        my $strCommandEnum = bldEnum('cfgRuleCmd', $strCommand);
        push(@{$rhEnum->{&BLD_LIST}}, $strCommandEnum);

        # Build command data
        $strBuildSource .=
            "\n" .
            "    CONFIGURATION_DEFINITION_COMMAND\n" .
            "    (\n" .
            "        CONFIGURATION_DEFINITION_COMMAND_NAME(\"${strCommand}\")\n" .
            "    )\n";
    };

    $strBuildSource .=
        ")\n";

    $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_RULE}{&BLD_DATA}{&BLDLCL_DATA_COMMAND}{&BLD_SOURCE} = $strBuildSource;

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

    $rhEnum = $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_RULE}{&BLD_ENUM}{&BLDLCL_ENUM_OPTION_TYPE};

    foreach my $strOptionType (sort(keys(%{$rhOptionTypeMap})))
    {
        # Build C enum
        my $strOptionTypeEnum = bldEnum('cfgRuleOptDefType', $strOptionType);
        push(@{$rhEnum->{&BLD_LIST}}, $strOptionTypeEnum);
    };


    # Build command constants and data
    #-------------------------------------------------------------------------------------------------------------------------------
    $rhEnum = $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_RULE}{&BLD_ENUM}{&BLDLCL_ENUM_OPTION};

    $strBuildSource =
        "OptionRule optionRule[] = CONFIGURATION_DEFINITION_OPTION_LIST\n" .
        "(";

    foreach my $strOption (sort(keys(%{$rhOptionRule})))
    {
        # Build C enum
        my $strOptionEnum = bldEnum('cfgRuleOpt', $strOption);
        push(@{$rhEnum->{&BLD_LIST}}, $strOptionEnum);

        # Build option data
        my $rhOption = $rhOptionRule->{$strOption};

        my $strOptionPrefix = $rhOption->{&CFGBLDDEF_RULE_PREFIX};

        $strBuildSource .=
            "\n" .
            "    // " . (qw{-} x 125) . "\n" .
            "    CONFIGURATION_DEFINITION_OPTION\n" .
            "    (\n";

        my $bRequired = $rhOption->{&CFGBLDDEF_RULE_REQUIRED};

        $strBuildSource .=
            "        CONFIGURATION_DEFINITION_OPTION_NAME(\"${strOption}\")\n" .
            "        CONFIGURATION_DEFINITION_OPTION_REQUIRED(" . ($bRequired ? 'true' : 'false') . ")\n" .
            "        CONFIGURATION_DEFINITION_OPTION_SECTION(cfgRuleSection" .
                (defined($rhOption->{&CFGBLDDEF_RULE_SECTION}) ? ucfirst($rhOption->{&CFGBLDDEF_RULE_SECTION}) : 'CommandLine') .
                ")\n" .
            "        CONFIGURATION_DEFINITION_OPTION_TYPE(" . buildConfigOptionTypeRuleEnum($rhOption->{&CFGBLDDEF_RULE_TYPE}) . ")\n";

        $strBuildSource .=
            "\n" .
            "        CONFIGURATION_DEFINITION_OPTION_INDEX_TOTAL(" . $rhOption->{&CFGBLDDEF_RULE_INDEX_TOTAL} . ")\n" .
            "        CONFIGURATION_DEFINITION_OPTION_NEGATE(" . ($rhOption->{&CFGBLDDEF_RULE_NEGATE} ? 'true' : 'false') . ")\n" .
            "        CONFIGURATION_DEFINITION_OPTION_SECURE(" . ($rhOption->{&CFGBLDDEF_RULE_SECURE} ? 'true' : 'false') . ")\n" .
            "\n" .
            "        CONFIGURATION_DEFINITION_OPTION_COMMAND_LIST\n" .
            "        (\n";

        foreach my $strCommand (sort(keys(%{cfgbldCommandGet()})))
        {
            if (defined($rhOption->{&CFGBLDDEF_RULE_COMMAND}{$strCommand}))
            {
                $strBuildSource .=
                    "            CONFIGURATION_DEFINITION_OPTION_COMMAND(" . buildConfigCommandRuleEnum($strCommand) . ")\n";
            }
        }

        $strBuildSource .=
            "        )\n";

        # Render optional data
        my $strBuildSourceOptional = renderOptional($rhOption);

        # Render command overrides
        foreach my $strCommand (sort(keys(%{cfgbldCommandGet()})))
        {
            my $strBuildSourceOptionalCommand;
            my $rhCommand = $rhOption->{&CFGBLDDEF_RULE_COMMAND}{$strCommand};

            if (defined($rhCommand))
            {
                $strBuildSourceOptionalCommand = renderOptional($rhCommand, true);

                if (defined($strBuildSourceOptionalCommand))
                {
                    $strBuildSourceOptional .=
                        (defined($strBuildSourceOptional) ? "\n" : '') .
                        "            CONFIG_OPTION_COMMAND_DATA(" . buildConfigCommandRuleEnum($strCommand) . ")\n" .
                        "\n" .
                        $strBuildSourceOptionalCommand;
                }
            }

        };

        if (defined($strBuildSourceOptional))
        {
            $strBuildSource .=
                "\n" .
                "        CONFIG_OPTION_DATA\n" .
                "        (\n" .
                $strBuildSourceOptional .
                "        )\n";
        }

        $strBuildSource .=
            "    )\n";
    }

    $strBuildSource .=
        ")\n";

    $rhBuild->{&BLD_FILE}{&BLDLCL_FILE_RULE}{&BLD_DATA}{&BLDLCL_DATA_OPTION}{&BLD_SOURCE} = $strBuildSource;

    return $rhBuild;
}

push @EXPORT, qw(buildConfigRule);

1;
