####################################################################################################################################
# BackupInfoUnitTest.pm - Unit tests for BackupInfo
####################################################################################################################################
package pgBackRestTest::Module::Archive::ArchiveInfoUnitTest;
use parent 'pgBackRestTest::Env::ConfigEnvTest';

####################################################################################################################################
# Perl includes
####################################################################################################################################
use strict;
use warnings FATAL => qw(all);
use Carp qw(confess);
use English '-no_match_vars';

use File::Basename qw(dirname);
use Storable qw(dclone);

use pgBackRest::Archive::Info;
use pgBackRest::Backup::Info;
use pgBackRest::Common::Exception;
use pgBackRest::Common::Ini;
use pgBackRest::Common::Lock;
use pgBackRest::Common::Log;
use pgBackRest::Config::Config;
use pgBackRest::DbVersion;
use pgBackRest::InfoCommon;
use pgBackRest::Manifest;
use pgBackRest::Protocol::Storage::Helper;
use pgBackRest::Storage::Base;

use pgBackRestTest::Env::HostEnvTest;
use pgBackRestTest::Common::ExecuteTest;
use pgBackRestTest::Common::RunTest;

####################################################################################################################################
# initModule
####################################################################################################################################
sub initModule
{
    my $self = shift;

    $self->{strRepoPath} = $self->testPath() . '/repo';
}

####################################################################################################################################
# initTest
####################################################################################################################################
sub initTest
{
    my $self = shift;

    # Clear cache from the previous test
    storageRepoCacheClear($self->stanza());

    # Load options
    $self->configTestClear();
    $self->optionTestSet(CFGOPT_STANZA, $self->stanza());
    $self->optionTestSet(CFGOPT_REPO_PATH, $self->testPath() . '/repo');
    $self->configTestLoad(CFGCMD_ARCHIVE_PUSH);

    # Create backup info path
    storageRepo()->pathCreate(STORAGE_REPO_BACKUP, {bCreateParent => true});

    # Create archive info path
    storageRepo()->pathCreate(STORAGE_REPO_ARCHIVE, {bCreateParent => true});
}

####################################################################################################################################
# run
####################################################################################################################################
sub run
{
    my $self = shift;

    my $strArchiveTestFile = $self->dataPath() . '/backup.wal1_';

    ################################################################################################################################
    if ($self->begin("Archive::Info::reconstruct()"))
    {
        my $oArchiveInfo = new pgBackRest::Archive::Info(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE), false,
            {bLoad => false, bIgnoreMissing => true});

        storageRepo()->pathCreate(STORAGE_REPO_ARCHIVE . "/" . PG_VERSION_94 . "-1/0000000100000001", {bCreateParent => true});
        my $strArchiveFile = storageRepo()->pathGet(STORAGE_REPO_ARCHIVE . "/" . PG_VERSION_94 . "-1/0000000100000001/") .
            "000000010000000100000001-1e34fa1c833090d94b9bb14f2a8d3153dca6ea27";
        executeTest('cp ' . $strArchiveTestFile . WAL_VERSION_94 . '.bin ' . $strArchiveFile);

        $self->testResult(sub {$oArchiveInfo->reconstruct(PG_VERSION_94, WAL_VERSION_94_SYS_ID)}, "[undef]", 'reconstruct');
        $self->testResult(sub {$oArchiveInfo->check(PG_VERSION_94, WAL_VERSION_94_SYS_ID, false)}, PG_VERSION_94 . "-1",
            '    check reconstruct');

        # Attempt to reconstruct from an encypted archived WAL for an unencrypted repo
        #---------------------------------------------------------------------------------------------------------------------------
        # Prepend encryption Magic signature to simulate encryption
        executeTest('echo "' . CIPHER_MAGIC . '$(cat ' . $strArchiveFile . ')" > ' . $strArchiveFile);

        $self->testException(sub {$oArchiveInfo->reconstruct(PG_VERSION_94, WAL_VERSION_94_SYS_ID)}, ERROR_CIPHER,
            "encryption incompatible for '$strArchiveFile'" .
            "\nHINT: Is or was the repo encrypted?");

        executeTest('sudo rm ' . $strArchiveFile);

        # Attempt to reconstruct from an encypted archived WAL with an encrypted repo
        #---------------------------------------------------------------------------------------------------------------------------
        storageRepoCacheClear($self->stanza());
        $self->optionTestSet(CFGOPT_REPO_CIPHER_TYPE, CFGOPTVAL_REPO_CIPHER_TYPE_AES_256_CBC);
        $self->optionTestSet(CFGOPT_REPO_CIPHER_KEY, 'x');
        $self->configTestLoad(CFGCMD_ARCHIVE_PUSH);

        # Get the unencrypted contents
        my $tContent = ${storageTest()->get($strArchiveTestFile . WAL_VERSION_94 . '.bin')};

        # Instantiate an archive.info object with a sub key for the archived WAL
        my $strCipherKeySub = 'y';
        $oArchiveInfo = new pgBackRest::Archive::Info(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE), false,
            {bLoad => false, bIgnoreMissing => true, strCipherKeySub => $strCipherKeySub});

        # Create an encrypted archived WAL
        storageRepo()->put($strArchiveFile, $tContent, {strCipherKey => $strCipherKeySub});

        $self->testResult(sub {$oArchiveInfo->reconstruct(PG_VERSION_94, WAL_VERSION_94_SYS_ID)}, "[undef]", 'reconstruct');
        $self->testResult(sub {$oArchiveInfo->check(PG_VERSION_94, WAL_VERSION_94_SYS_ID, false)}, PG_VERSION_94 . "-1",
            '    check reconstruction from encrypted archive');

        $oArchiveInfo->save();

        # Confirm encrypted
        $self->testResult(sub {storageRepo()->encrypted(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE) . '/'
            . ARCHIVE_INFO_FILE) && ($oArchiveInfo->cipherKeySub() eq $strCipherKeySub)}, true,
            '    new archive info encrypted');
    }

    ################################################################################################################################
    if ($self->begin("encryption"))
    {
        # Create an unencrypted archive.info file
        #---------------------------------------------------------------------------------------------------------------------------
        my $oArchiveInfo = new pgBackRest::Archive::Info(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE), false,
            {bLoad => false, bIgnoreMissing => true});
        $oArchiveInfo->create(PG_VERSION_94, WAL_VERSION_94_SYS_ID, true);

        # Confirm unencrypted
        $self->testResult(sub {storageRepo()->encrypted(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE) . '/'
            . ARCHIVE_INFO_FILE)}, false, '    new archive info unencrypted');

        my $strFile = $oArchiveInfo->{strFileName};

        # Prepend encryption Magic signature to simulate encryption
        executeTest('echo "' . CIPHER_MAGIC . '$(cat ' . $strFile . ')" > ' . $strFile);

        $self->testException(sub {new pgBackRest::Archive::Info(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE))}, ERROR_CIPHER,
            "unable to parse '$strFile'" .
            "\nHINT: Is or was the repo encrypted?");

        # Remove the archive info files
        executeTest('sudo rm ' . $oArchiveInfo->{strFileName} . '*');

        # Create an encrypted storage and archive.info file
        #---------------------------------------------------------------------------------------------------------------------------
        my $strCipherKey = 'x';
        $self->configTestClear();
        $self->optionTestSet(CFGOPT_REPO_CIPHER_TYPE, CFGOPTVAL_REPO_CIPHER_TYPE_AES_256_CBC);
        $self->optionTestSet(CFGOPT_REPO_CIPHER_KEY, $strCipherKey);
        $self->optionTestSet(CFGOPT_STANZA, $self->stanza());
        $self->optionTestSet(CFGOPT_REPO_PATH, $self->testPath() . '/repo');
        $self->configTestLoad(CFGCMD_ARCHIVE_PUSH);

        # Clear the storage repo settings
        storageRepoCacheClear($self->stanza());

        # Create an encrypted storage and generate an encyption sub key to store in the file
        my $strCipherKeySub = storageRepo()->cipherKeyGen();

        # Error on encrypted repo but no key passed to store in the file
        $self->testException(sub {new pgBackRest::Archive::Info(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE), false,
            {bLoad => false, bIgnoreMissing => true})}, ERROR_ASSERT,
            'a user encryption key and sub encryption key are both required when encrypting');

        # Create an encrypted archiveInfo file
        $oArchiveInfo = new pgBackRest::Archive::Info(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE), false,
            {bLoad => false, bIgnoreMissing => true, strCipherKeySub => $strCipherKeySub});
        $oArchiveInfo->create(PG_VERSION_94, WAL_VERSION_94_SYS_ID, true);

        # Confirm encrypted
        $self->testResult(sub {storageRepo()->encrypted(storageRepo()->pathGet(STORAGE_REPO_ARCHIVE) . '/'
            . ARCHIVE_INFO_FILE)}, true, '    new archive info encrypted');

        $self->testResult(sub {$oArchiveInfo->test(INI_SECTION_CIPHER, INI_KEY_CIPHER_KEY, undef, $strCipherKeySub)},
            true, '    generated key stored');
    }
}

1;
