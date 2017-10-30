####################################################################################################################################
# Auto-Generate XS and PM Files Required for Perl
####################################################################################################################################
package pgBackRestLibC::Build;

use strict;
use warnings FATAL => qw(all);
use Carp qw(confess);
use English '-no_match_vars';

use Cwd qw(abs_path);
use Exporter qw(import);
    our @EXPORT = qw();
use File::Basename qw(dirname);
use Storable qw(dclone);

use lib dirname($0) . '/../build/lib';
use lib dirname($0) . '/../lib';

use pgBackRest::Common::Log;
use pgBackRest::Common::String;
use pgBackRest::Config::Data;
use pgBackRest::Storage::Local;
use pgBackRest::Storage::Posix::Driver;
use pgBackRest::Version;

use pgBackRestBuild::Build;
use pgBackRestBuild::Build::Common;

use pgBackRestLibC::Config::Build;
use pgBackRestLibC::Config::BuildRule;

####################################################################################################################################
# Perl function and constant exports
####################################################################################################################################
use constant BLD_EXPORTTYPE_SUB                                     => 'sub';
use constant BLD_EXPORTTYPE_CONSTANT                                => 'constant';

use constant LIB_AUTO_NAME                                          => 'LibCAuto';

####################################################################################################################################
# Static exports
####################################################################################################################################
my $rhExport =
{
    'checksum' =>
    {
        &BLD_EXPORTTYPE_SUB => [qw(
            pageChecksum
            pageChecksumBufferTest
            pageChecksumTest
        )],
    },

    'config' =>
    {
        &BLD_EXPORTTYPE_SUB => [qw(
            cfgCommandName
            cfgOptionIndex
            cfgOptionIndexTotal
            cfgOptionName
        )],
    },

    'configRule' =>
    {
        &BLD_EXPORTTYPE_SUB => [qw(
            cfgCommandId
            cfgOptionId
            cfgRuleOptionAllowList
            cfgRuleOptionAllowListValue
            cfgRuleOptionAllowListValueTotal
            cfgRuleOptionAllowListValueValid
            cfgRuleOptionAllowRange
            cfgRuleOptionAllowRangeMax
            cfgRuleOptionAllowRangeMin
            cfgRuleOptionDefault
            cfgRuleOptionDepend
            cfgRuleOptionDependOption
            cfgRuleOptionDependValue
            cfgRuleOptionDependValueTotal
            cfgRuleOptionDependValueValid
            cfgRuleOptionNameAlt
            cfgRuleOptionNegate
            cfgRuleOptionPrefix
            cfgRuleOptionRequired
            cfgRuleOptionSection
            cfgRuleOptionSecure
            cfgRuleOptionType
            cfgRuleOptionValid
            cfgOptionTotal
            cfgRuleOptionValueHash
        )],
    },

    'debug' =>
    {
        &BLD_EXPORTTYPE_CONSTANT => [qw(
            UVSIZE
        )],

        &BLD_EXPORTTYPE_SUB => [qw(
            libcVersion
        )],
    },

    'encode' =>
    {
        &BLD_EXPORTTYPE_CONSTANT => [qw(
            ENCODE_TYPE_BASE64
        )],

        &BLD_EXPORTTYPE_SUB => [qw(
            decodeToBin
            encodeToStr
        )],
    },
};

####################################################################################################################################
# Execute all build functions
####################################################################################################################################
sub buildXsAll
{
    my $strBuildPath = shift;

    my $rhBuild =
    {
        'config' =>
        {
            &BLD_DATA => buildXsConfig(),
            &BLD_PATH => 'xs/config',
        },

        'configRule' =>
        {
            &BLD_DATA => buildXsConfigRule(),
            &BLD_PATH => 'xs/config',
        },
    };

    buildAll($strBuildPath, $rhBuild, 'xs');

    # Storage
    my $oStorage = new pgBackRest::Storage::Local(
        $strBuildPath, new pgBackRest::Storage::Posix::Driver({bFileSync => false, bPathSync => false}));

    # Get current version
    my $strVersion = BACKREST_VERSION;
    my $bDev = false;

    if ($strVersion =~ /dev$/)
    {
        $strVersion = substr($strVersion, 0, length($strVersion) - 3) . '.999';
        $bDev = true;
    }

    # Build interface file
    my $strContent =
        ('#' x 132) . "\n" .
        '# ' . bldAutoWarning('Build.pm') . "\n" .
        ('#' x 132) . "\n" .
        "package pgBackRest::LibCAuto;\n" .
        "\n" .
        "# Library version (.999 indicates development version)\n" .
        "sub libcAutoVersion\n" .
        "{\n" .
        "    return '${strVersion}';\n" .
        "}\n";

    # Generate constants for options that have a list of strings as allowed values
    my $rhOptionRule = cfgdefRule();
    my $strConstantBlock;

    foreach my $strOption (sort(keys(%{$rhOptionRule})))
    {
        my $rhOption = $rhOptionRule->{$strOption};

        next if $rhOption->{&CFGBLDDEF_RULE_TYPE} ne CFGOPTDEF_TYPE_STRING;
        next if $strOption =~ /^log-level-/;

        if (defined($rhOption->{&CFGBLDDEF_RULE_ALLOW_LIST}))
        {
            $strConstantBlock .= defined($strConstantBlock) ? "\n" : '';

            foreach my $strValue (@{$rhOption->{&CFGBLDDEF_RULE_ALLOW_LIST}})
            {
                my $strConstant = 'CFGOPTVAL_' . uc("${strOption}_${strValue}");
                $strConstant =~ s/\-/\_/g;

                $strConstantBlock .= "        ${strConstant}" . (' ' x (69 - length($strConstant) - 4)) . "=> '${strValue}',\n";
                push(@{$rhExport->{'config'}{&BLD_EXPORTTYPE_CONSTANT}}, $strConstant);
            }
        }

        foreach my $strCommand (sort(keys(%{$rhOption->{&CFGBLDDEF_RULE_COMMAND}})))
        {
            my $rhCommand = $rhOption->{&CFGBLDDEF_RULE_COMMAND}{$strCommand};

            if (defined($rhCommand->{&CFGBLDDEF_RULE_ALLOW_LIST}))
            {
                $strConstantBlock .= defined($strConstantBlock) ? "\n" : '';

                foreach my $strValue (@{$rhCommand->{&CFGBLDDEF_RULE_ALLOW_LIST}})
                {
                    my $strConstant = 'CFGOPTVAL_' . uc("${strCommand}_${strOption}_${strValue}");
                    $strConstant =~ s/\-/\_/g;

                    $strConstantBlock .= "        ${strConstant}" . (' ' x (69 - length($strConstant) - 4)) . "=> '${strValue}',\n";
                    push(@{$rhExport->{'config'}{&BLD_EXPORTTYPE_CONSTANT}}, $strConstant);
                }
            }
        }
    }

    $strContent .=
        "\n" .
        "# Configuration option value constants\n" .
        "sub libcAutoConstant\n" .
        "{\n" .
        "    return \n" .
        # "        use constant\n" .
        "    {\n" .
        "        " . trim($strConstantBlock) . "\n" .
        "    }\n" .
        "}\n";

    foreach my $strBuild (sort(keys(%{$rhBuild})))
    {
        foreach my $strFile (sort(keys(%{$rhBuild->{$strBuild}{&BLD_DATA}{&BLD_FILE}})))
        {
            my $rhFileConstant = $rhBuild->{$strBuild}{&BLD_DATA}{&BLD_FILE}{$strFile}{&BLD_CONSTANT_GROUP};

            foreach my $strConstantGroup (sort(keys(%{$rhFileConstant})))
            {
                my $rhConstantGroup = $rhFileConstant->{$strConstantGroup};

                foreach my $strConstant (sort(keys(%{$rhConstantGroup->{&BLD_CONSTANT}})))
                {
                    my $rhConstant = $rhConstantGroup->{&BLD_CONSTANT}{$strConstant};

                    if ($rhConstant->{&BLD_CONSTANT_EXPORT})
                    {
                        push(@{$rhExport->{$strBuild}{&BLD_EXPORTTYPE_CONSTANT}}, $strConstant);
                    }
                }
            }
        }
    }

    # Generate export tags
    my $strExportTags;

    foreach my $strSection (sort(keys(%{$rhExport})))
    {
        my $rhExportSection = $rhExport->{$strSection};

        $strExportTags .= (defined($strExportTags) ? "\n" : '') . "        ${strSection} =>\n        [\n";

        if (defined($rhExportSection->{&BLD_EXPORTTYPE_CONSTANT}) && @{$rhExportSection->{&BLD_EXPORTTYPE_CONSTANT}} > 0)
        {
            foreach my $strConstant (@{$rhExportSection->{&BLD_EXPORTTYPE_CONSTANT}})
            {
                $strExportTags .= "            '${strConstant}',\n";
            }
        }

        if (defined($rhExportSection->{&BLD_EXPORTTYPE_SUB}) && @{$rhExportSection->{&BLD_EXPORTTYPE_SUB}} > 0)
        {
            foreach my $strSub (@{$rhExportSection->{&BLD_EXPORTTYPE_SUB}})
            {
                $strExportTags .= "            '${strSub}',\n";
            }
        }

        $strExportTags .= "        ],\n";
    }

    $strContent .=
        "\n" .
        "# Export function and constants\n" .
        "sub libcAutoExportTag\n" .
        "{\n" .
        "    return\n" .
        "    {\n" .
        $strExportTags .
        "    }\n" .
        "}\n";

    # Add module end marker
    $strContent .=
        "\n" .
        "1;\n";

    # Only save the file if it has changed
    my $strLibFile = 'lib/' . BACKREST_NAME . '/' . LIB_AUTO_NAME . '.pm';
    my $bChanged = true;

    if ($oStorage->exists($strLibFile))
    {
        my $strContentOld = ${$oStorage->get($strLibFile)};

        if ($strContent eq $strContentOld)
        {
            $bChanged = false;
        }
    }

    if ($bChanged)
    {
        $oStorage->put($strLibFile, $strContent);
    }
}

push @EXPORT, qw(buildXsAll);

1;
