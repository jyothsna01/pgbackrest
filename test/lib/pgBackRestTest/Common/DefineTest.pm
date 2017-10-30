####################################################################################################################################
# DefineTest.pm - Defines all tests that can be run
####################################################################################################################################
package pgBackRestTest::Common::DefineTest;

####################################################################################################################################
# Perl includes
####################################################################################################################################
use strict;
use warnings FATAL => qw(all);
use Carp qw(confess);

use Exporter qw(import);
    our @EXPORT = qw();

use pgBackRest::Common::Log;
use pgBackRest::Common::String;

use pgBackRestTest::Common::VmTest;

################################################################################################################################
# Test definition constants
################################################################################################################################
use constant TESTDEF_MODULE                                         => 'module';
    push @EXPORT, qw(TESTDEF_MODULE);
use constant TESTDEF_NAME                                           => 'name';
    push @EXPORT, qw(TESTDEF_NAME);
use constant TESTDEF_TEST                                           => 'test';
    push @EXPORT, qw(TESTDEF_TEST);

# Determines if the test will be run against multiple db versions
use constant TESTDEF_DB                                             => 'db';
    push @EXPORT, qw(TESTDEF_DB);
# Determines if the test will be run in a container or will create containers itself
use constant TESTDEF_CONTAINER                                      => 'container';
    push @EXPORT, qw(TESTDEF_CONTAINER);
# Determines coverage for the test
use constant TESTDEF_COVERAGE                                       => 'coverage';
    push @EXPORT, qw(TESTDEF_COVERAGE);
# Should expect log tests be run
use constant TESTDEF_EXPECT                                         => 'expect';
    push @EXPORT, qw(TESTDEF_EXPECT);
# Is this a C test (instead of Perl)?
use constant TESTDEF_C                                              => 'c';
    push @EXPORT, qw(TESTDEF_C);
# Is the C library required?  This only applies to unit tests, the C library is always supplied for integration tests.
use constant TESTDEF_CLIB                                           => 'clib';
    push @EXPORT, qw(TESTDEF_CLIB);
# Determines if each run in a test will be run in a new container
use constant TESTDEF_INDIVIDUAL                                     => 'individual';
    push @EXPORT, qw(TESTDEF_INDIVIDUAL);
# Total runs in the test
use constant TESTDEF_TOTAL                                          => 'total';
    push @EXPORT, qw(TESTDEF_TOTAL);
# VMs that the test can run on
use constant TESTDEF_VM                                             => 'vm';
    push @EXPORT, qw(TESTDEF_VM);

# The test provides full coverage for the module
use constant TESTDEF_COVERAGE_FULL                                  => 'full';
    push @EXPORT, qw(TESTDEF_COVERAGE_FULL);
# The test provides partial coverage for the module
use constant TESTDEF_COVERAGE_PARTIAL                               => 'partial';
    push @EXPORT, qw(TESTDEF_COVERAGE_PARTIAL);
# The module does not have any code so does not have any coverage.  An error will be thrown if the module has code in the future.
use constant TESTDEF_COVERAGE_NOCODE                                => 'nocode';
    push @EXPORT, qw(TESTDEF_COVERAGE_NOCODE);

################################################################################################################################
# Code modules
################################################################################################################################
use constant TESTDEF_MODULE_COMMON                                  => 'Common';
    push @EXPORT, qw(TESTDEF_MODULE_COMMON);
use constant TESTDEF_MODULE_COMMON_INI                              => TESTDEF_MODULE_COMMON . '/Ini';
    push @EXPORT, qw(TESTDEF_MODULE_COMMON_INI);

use constant TESTDEF_MODULE_INFO                                    => 'Info';
    push @EXPORT, qw(TESTDEF_MODULE_INFO);

use constant TESTDEF_MODULE_STANZA                                  => 'Stanza';
    push @EXPORT, qw(TESTDEF_MODULE_STANZA);

use constant TESTDEF_MODULE_EXPIRE                                  => 'Expire';
    push @EXPORT, qw(TESTDEF_MODULE_EXPIRE);

################################################################################################################################
# Define tests
################################################################################################################################
my $oTestDef =
{
    &TESTDEF_MODULE =>
    [
        # Common tests
        {
            &TESTDEF_NAME => 'common',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'type',
                    &TESTDEF_TOTAL => 2,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'common/type' => TESTDEF_COVERAGE_NOCODE,
                    },
                },
                {
                    &TESTDEF_NAME => 'error',
                    &TESTDEF_TOTAL => 4,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'common/error' => TESTDEF_COVERAGE_FULL,
                        'common/errorType' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'mem-context',
                    &TESTDEF_TOTAL => 6,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'common/memContext' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'encode',
                    &TESTDEF_TOTAL => 1,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'common/encode' => TESTDEF_COVERAGE_FULL,
                        'common/encode/base64' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'encode-perl',
                    &TESTDEF_TOTAL => 1,
                    &TESTDEF_CLIB => true,
                },
                {
                    &TESTDEF_NAME => 'http-client',
                    &TESTDEF_TOTAL => 2,

                    &TESTDEF_COVERAGE =>
                    {
                        'Common/Http/Client' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'ini',
                    &TESTDEF_TOTAL => 10,

                    &TESTDEF_COVERAGE =>
                    {
                        &TESTDEF_MODULE_COMMON_INI => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'io-handle',
                    &TESTDEF_TOTAL => 6,

                    &TESTDEF_COVERAGE =>
                    {
                        'Common/Io/Handle' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'io-buffered',
                    &TESTDEF_TOTAL => 3,

                    &TESTDEF_COVERAGE =>
                    {
                        'Common/Io/Buffered' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'io-process',
                    &TESTDEF_TOTAL => 2,

                    &TESTDEF_COVERAGE =>
                    {
                        'Common/Io/Process' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'log',
                    &TESTDEF_TOTAL => 1,

                    &TESTDEF_COVERAGE =>
                    {
                        'Common/Log' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
            ]
        },
        # PostgreSQL tests
        {
            &TESTDEF_NAME => 'postgres',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'page-checksum',
                    &TESTDEF_TOTAL => 3,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'postgres/pageChecksum' => TESTDEF_COVERAGE_FULL,
                    },
                },
            ]
        },
        # Help tests
        {
            &TESTDEF_NAME => 'help',
            &TESTDEF_CONTAINER => true,
            &TESTDEF_EXPECT => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'help',
                    &TESTDEF_TOTAL => 1,
                }
            ]
        },
        # Config tests
        {
            &TESTDEF_NAME => 'config',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'rule',
                    &TESTDEF_TOTAL => 1,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'config/rule' => TESTDEF_COVERAGE_FULL,
                        'config/rule.auto' => TESTDEF_COVERAGE_NOCODE,
                    },
                },
                {
                    &TESTDEF_NAME => 'config',
                    &TESTDEF_TOTAL => 1,
                    &TESTDEF_C => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'config/config' => TESTDEF_COVERAGE_PARTIAL,
                        'config/config.auto' => TESTDEF_COVERAGE_NOCODE,
                    },
                },
                {
                    &TESTDEF_NAME => 'unit',
                    &TESTDEF_TOTAL => 1,
                },
                {
                    &TESTDEF_NAME => 'option',
                    &TESTDEF_CLIB => true,
                    &TESTDEF_TOTAL => 35,
                },
                {
                    &TESTDEF_NAME => 'config-perl',
                    &TESTDEF_TOTAL => 25,
                }
            ]
        },
        # Storage tests
        {
            &TESTDEF_NAME => 'storage',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'filter-gzip',
                    &TESTDEF_TOTAL => 3,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/Filter/Gzip' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'filter-sha',
                    &TESTDEF_TOTAL => 2,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/Filter/Sha' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'posix',
                    &TESTDEF_TOTAL => 9,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/Posix/Driver' => TESTDEF_COVERAGE_PARTIAL,
                        'Storage/Posix/FileRead' => TESTDEF_COVERAGE_PARTIAL,
                        'Storage/Posix/FileWrite' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 's3-auth',
                    &TESTDEF_TOTAL => 5,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/S3/Auth' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 's3-cert',
                    &TESTDEF_TOTAL => 1,
                },
                {
                    &TESTDEF_NAME => 's3-request',
                    &TESTDEF_TOTAL => 2,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/S3/Request' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 's3',
                    &TESTDEF_TOTAL => 7,
                    &TESTDEF_VM => [VM_CO7, VM_U14, VM_U16, VM_D8],

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/S3/Driver' => TESTDEF_COVERAGE_PARTIAL,
                        'Storage/S3/FileRead' => TESTDEF_COVERAGE_PARTIAL,
                        'Storage/S3/FileWrite' => TESTDEF_COVERAGE_FULL,
                    },
                },
                {
                    &TESTDEF_NAME => 'local',
                    &TESTDEF_TOTAL => 9,
                    &TESTDEF_CLIB => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/Local' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'helper',
                    &TESTDEF_TOTAL => 4,

                    &TESTDEF_COVERAGE =>
                    {
                        'Storage/Helper' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
            ]
        },
        # Protocol tests
        {
            &TESTDEF_NAME => 'protocol',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'common-minion',
                    &TESTDEF_TOTAL => 1,

                    &TESTDEF_COVERAGE =>
                    {
                        'Protocol/Base/Minion' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'helper',
                    &TESTDEF_TOTAL => 1,

                    &TESTDEF_COVERAGE =>
                    {
                        'Protocol/Helper' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
            ]
        },
        # Info tests
        {
            &TESTDEF_NAME => 'info',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'unit',
                    &TESTDEF_TOTAL => 1,

                    &TESTDEF_COVERAGE =>
                    {
                        &TESTDEF_MODULE_INFO => TESTDEF_COVERAGE_FULL,
                    },
                },
            ]
        },
        # Archive tests
        {
            &TESTDEF_NAME => 'archive',

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'common',
                    &TESTDEF_TOTAL => 4,
                    &TESTDEF_CONTAINER => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'Archive/Common' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'push',
                    &TESTDEF_TOTAL => 7,
                    &TESTDEF_CONTAINER => true,

                    &TESTDEF_COVERAGE =>
                    {
                        'Archive/Push/Push' => TESTDEF_COVERAGE_FULL,
                        'Archive/Push/Async' => TESTDEF_COVERAGE_FULL,
                        'Archive/Push/File' => TESTDEF_COVERAGE_FULL,
                        'Protocol/Local/Master' => TESTDEF_COVERAGE_FULL,
                        'Protocol/Local/Minion' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
                {
                    &TESTDEF_NAME => 'stop',
                    &TESTDEF_TOTAL => 7,
                    &TESTDEF_INDIVIDUAL => true,
                    &TESTDEF_EXPECT => true,
                },
            ]
        },
        # Backup tests
        {
            &TESTDEF_NAME => 'backup',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_COVERAGE =>
            {
                'Backup/Common' => TESTDEF_COVERAGE_FULL,
            },

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'unit',
                    &TESTDEF_TOTAL => 3,
                },
                {
                    &TESTDEF_NAME => 'info-unit',
                    &TESTDEF_TOTAL => 2,
                    &TESTDEF_COVERAGE =>
                    {
                        'Backup/Info' => TESTDEF_COVERAGE_PARTIAL,
                    },
                },
            ]
        },
        # Expire tests
        {
            &TESTDEF_NAME => 'expire',
            &TESTDEF_EXPECT => true,
            &TESTDEF_INDIVIDUAL => true,

            &TESTDEF_COVERAGE =>
            {
                &TESTDEF_MODULE_EXPIRE => TESTDEF_COVERAGE_PARTIAL,
            },

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'expire',
                    &TESTDEF_TOTAL => 2,
                },
            ]
        },
        # Stanza tests
        {
            &TESTDEF_NAME => 'stanza',

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'all',
                    &TESTDEF_TOTAL => 7,
                    &TESTDEF_CONTAINER => true,

                    &TESTDEF_COVERAGE =>
                    {
                        &TESTDEF_MODULE_STANZA => TESTDEF_COVERAGE_FULL,
                    },
                },
            ]
        },
        # Mock tests
        {
            &TESTDEF_NAME => 'mock',
            &TESTDEF_EXPECT => true,
            &TESTDEF_INDIVIDUAL => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'archive',
                    &TESTDEF_TOTAL => 3,
                },
                {
                    &TESTDEF_NAME => 'all',
                    &TESTDEF_TOTAL => 3,
                },
                {
                    &TESTDEF_NAME => 'stanza',
                    &TESTDEF_TOTAL => 3,
                },
            ]
        },
        # Real tests
        {
            &TESTDEF_NAME => 'real',
            &TESTDEF_EXPECT => true,
            &TESTDEF_INDIVIDUAL => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'all',
                    &TESTDEF_TOTAL => 6,
                    &TESTDEF_DB => true,
                }
            ]
        },
        # Performance tests
        {
            &TESTDEF_NAME => 'performance',
            &TESTDEF_CONTAINER => true,

            &TESTDEF_TEST =>
            [
                {
                    &TESTDEF_NAME => 'archive',
                    &TESTDEF_TOTAL => 1,
                },
                {
                    &TESTDEF_NAME => 'io',
                    &TESTDEF_TOTAL => 1,
                },
            ]
        },
    ]
};

####################################################################################################################################
# Process normalized data into a more queryable form
####################################################################################################################################
my $hTestDefHash;                                                   # An easier way to query hash version of the above
my @stryModule;                                                     # Ordered list of modules
my $hModuleTest;                                                    # Ordered list of tests for each module
my $hCoverageType;                                                  # Coverage type for each code module (full/partial)
my $hCoverageList;                                                  # Tests required for full code module coverage (if type full)

# Iterate each module
foreach my $hModule (@{$oTestDef->{&TESTDEF_MODULE}})
{
    # Push the module onto the ordered list
    my $strModule = $hModule->{&TESTDEF_NAME};
    push(@stryModule, $strModule);

    # Iterate each test
    my @stryModuleTest;

    foreach my $hModuleTest (@{$hModule->{&TESTDEF_TEST}})
    {
        # Push the test on the order list
        my $strTest = $hModuleTest->{&TESTDEF_NAME};
        push(@stryModuleTest, $strTest);

        # Resolve variables that can be set in the module or the test
        foreach my $strVar (
            TESTDEF_C, TESTDEF_CLIB, TESTDEF_CONTAINER, TESTDEF_EXPECT, TESTDEF_DB, TESTDEF_INDIVIDUAL, TESTDEF_VM)
        {
            $hTestDefHash->{$strModule}{$strTest}{$strVar} = coalesce(
                $hModuleTest->{$strVar}, $hModule->{$strVar}, $strVar eq TESTDEF_VM ? undef : false);
        }

        # Set test count
        $hTestDefHash->{$strModule}{$strTest}{&TESTDEF_TOTAL} = $hModuleTest->{&TESTDEF_TOTAL};

        # If this is a C test then add the test module to coverage
        if ($hModuleTest->{&TESTDEF_C})
        {
            my $strTestFile = "module/${strModule}/${strTest}Test";

            $hModuleTest->{&TESTDEF_COVERAGE}{$strTestFile} = TESTDEF_COVERAGE_FULL;
        }

        # Concatenate coverage for modules and tests
        foreach my $hCoverage ($hModule->{&TESTDEF_COVERAGE}, $hModuleTest->{&TESTDEF_COVERAGE})
        {
            foreach my $strCodeModule (sort(keys(%{$hCoverage})))
            {
                if (defined($hTestDefHash->{$strModule}{$strTest}{&TESTDEF_COVERAGE}{$strCodeModule}))
                {
                    confess &log(ASSERT,
                        "${strCodeModule} is defined for coverage in both module ${strModule} and test ${strTest}");
                }

                $hTestDefHash->{$strModule}{$strTest}{&TESTDEF_COVERAGE}{$strCodeModule} = $hCoverage->{$strCodeModule};

                # Build coverage type hash and make sure coverage type does not change
                if (!defined($hCoverageType->{$strCodeModule}))
                {
                    $hCoverageType->{$strCodeModule} = $hCoverage->{$strCodeModule};
                }
                elsif ($hCoverageType->{$strCodeModule} ne $hCoverage->{$strCodeModule})
                {
                    confess &log(ASSERT, "cannot mix coverage types for ${strCodeModule}");
                }

                # Add to coverage list
                push(@{$hCoverageList->{$strCodeModule}}, {strModule=> $strModule, strTest => $strTest});
            }
        }
    }

    $hModuleTest->{$strModule} = \@stryModuleTest;
}

####################################################################################################################################
# testDefModuleList
####################################################################################################################################
sub testDefModuleList
{
    return @stryModule;
}

push @EXPORT, qw(testDefModuleList);

####################################################################################################################################
# testDefModule
####################################################################################################################################
sub testDefModule
{
    my $strModule = shift;

    if (!defined($hTestDefHash->{$strModule}))
    {
        confess &log(ASSERT, "unable to find module ${strModule}");
    }

    return $hTestDefHash->{$strModule};
}

push @EXPORT, qw(testDefModule);

####################################################################################################################################
# testDefModuleTestList
####################################################################################################################################
sub testDefModuleTestList
{
    my $strModule = shift;

    if (!defined($hModuleTest->{$strModule}))
    {
        confess &log(ASSERT, "unable to find module ${strModule}");
    }

    return @{$hModuleTest->{$strModule}};
}

push @EXPORT, qw(testDefModuleTestList);

####################################################################################################################################
# testDefModuleTest
####################################################################################################################################
sub testDefModuleTest
{
    my $strModule = shift;
    my $strModuleTest = shift;

    if (!defined($hTestDefHash->{$strModule}{$strModuleTest}))
    {
        confess &log(ASSERT, "unable to find module ${strModule}, test ${strModuleTest}");
    }

    return $hTestDefHash->{$strModule}{$strModuleTest};
}

push @EXPORT, qw(testDefModuleTest);

####################################################################################################################################
# testDefCoverageType
####################################################################################################################################
sub testDefCoverageType
{
    return $hCoverageType;
}

push @EXPORT, qw(testDefCoverageType);

####################################################################################################################################
# testDefCoverageList
####################################################################################################################################
sub testDefCoverageList
{
    return $hCoverageList;
}

push @EXPORT, qw(testDefCoverageList);

1;
