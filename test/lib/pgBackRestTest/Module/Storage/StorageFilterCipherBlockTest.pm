####################################################################################################################################
# Tests for Block Cipher
####################################################################################################################################
package pgBackRestTest::Module::Storage::StorageFilterCipherBlockTest;
use parent 'pgBackRestTest::Common::RunTest';

####################################################################################################################################
# Perl includes
####################################################################################################################################
use strict;
use warnings FATAL => qw(all);
use Carp qw(confess);
use English '-no_match_vars';

use Fcntl qw(O_RDONLY);
use Digest::SHA qw(sha1_hex);

use pgBackRest::Common::Exception;
use pgBackRest::Common::Log;
use pgBackRest::LibC qw(:random);
use pgBackRest::Storage::Base;
use pgBackRest::Storage::Filter::CipherBlock;
use pgBackRest::Storage::Posix::Driver;

use pgBackRestTest::Common::ExecuteTest;
use pgBackRestTest::Common::RunTest;

####################################################################################################################################
# run
####################################################################################################################################
sub run
{
    my $self = shift;

    # Test data
    my $strFile = $self->testPath() . qw{/} . 'file.txt';
    my $strFileEncipher = $self->testPath() . qw{/} . 'file.enc.txt';
    my $strFileDecipher = $self->testPath() . qw{/} . 'file.dcr.txt';
    my $strFileBin = $self->testPath() . qw{/} . 'file.bin';
    my $strFileBinEncipher = $self->testPath() . qw{/} . 'file.enc.bin';
    my $strFileContent = 'TESTDATA';
    my $iFileLength = length($strFileContent);
    my $oDriver = new pgBackRest::Storage::Posix::Driver();
    my $tCipherKey = 'areallybadkey';
    my $strCipherType = 'aes-256-cbc';
    my $tContent;

    ################################################################################################################################
    if ($self->begin('new()'))
    {
        #---------------------------------------------------------------------------------------------------------------------------
        # Create an unenciphered file
        executeTest("echo -n '${strFileContent}' | tee ${strFile}");

        $self->testException(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openRead($strFile), $strCipherType, $tCipherKey, {strMode => BOGUS})},
                ERROR_ASSERT, 'unknown cipher mode: ' . BOGUS);

        $self->testException(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openRead($strFile), $strCipherType, $tCipherKey, {strMode => BOGUS})},
                ERROR_ASSERT, 'unknown cipher mode: ' . BOGUS);

        $self->testException(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openRead($strFile), BOGUS, $tCipherKey)},
                ERROR_ASSERT, "unable to load cipher '" . BOGUS . "'");

        $self->testException(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openWrite($strFile), $strCipherType, $tCipherKey, {strMode => BOGUS})},
                ERROR_ASSERT, 'unknown cipher mode: ' . BOGUS);

        $self->testException(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openWrite($strFile), BOGUS, $tCipherKey)},
            ERROR_ASSERT, "unable to load cipher '" . BOGUS . "'");
    }

    ################################################################################################################################
    if ($self->begin('read() and write()'))
    {
        my $tBuffer;

        #---------------------------------------------------------------------------------------------------------------------------
        # Create an plaintext file
        executeTest("echo -n '${strFileContent}' | tee ${strFile}");

        # Instantiate the cipher object - default action ENCIPHER
        my $oEncipherIo = $self->testResult(sub {new pgBackRest::Storage::Filter::CipherBlock($oDriver->openRead($strFile),
            $strCipherType, $tCipherKey)}, '[object]', 'new encipher file');

        $self->testResult(sub {$oEncipherIo->read(\$tBuffer, 2)}, 16, '    read 16 bytes (header)');
        $self->testResult(sub {$oEncipherIo->read(\$tBuffer, 2)}, 16, '    read 16 bytes (data)');
        $self->testResult(sub {$oEncipherIo->read(\$tBuffer, 2)},  0, '    read 0 bytes');

        $self->testResult(sub {$tBuffer ne $strFileContent}, true, '    data read is enciphered');

        $self->testResult(sub {$oEncipherIo->close()}, true, '    close');
        $self->testResult(sub {$oEncipherIo->close()}, false, '    close again');

        # tBuffer is now enciphered - test write deciphers correctly
        my $oDecipherFileIo = $self->testResult(
            sub {new pgBackRest::Storage::Filter::CipherBlock($oDriver->openWrite($strFileDecipher),
                $strCipherType, $tCipherKey, {strMode => STORAGE_DECIPHER})},
            '[object]', '    new decipher file');

        $self->testResult(sub {$oDecipherFileIo->write(\$tBuffer)}, 32, '    write deciphered');
        $self->testResult(sub {$oDecipherFileIo->close()}, true, '    close');

        $self->testResult(sub {${$self->storageTest()->get($strFileDecipher)}}, $strFileContent, '    data written is deciphered');

        #---------------------------------------------------------------------------------------------------------------------------
        $tBuffer = $strFileContent;
        my $oEncipherFileIo = $self->testResult(
            sub {new pgBackRest::Storage::Filter::CipherBlock($oDriver->openWrite($strFileEncipher),
                $strCipherType, $tCipherKey)},
            '[object]', 'new write encipher');

        $tContent = '';
        $self->testResult(sub {$oEncipherFileIo->write(\$tContent)}, 0, '    attempt empty buffer write');

        undef($tContent);
        $self->testException(
            sub {$oEncipherFileIo->write(\$tContent)}, ERROR_FILE_WRITE,
            "unable to write to '${strFileEncipher}': Use of uninitialized value");

        # Enciphered length is not known so use tBuffer then test that tBuffer was enciphered
        my $iWritten = $self->testResult(sub {$oEncipherFileIo->write(\$tBuffer)}, length($tBuffer), '    write enciphered');
        $self->testResult(sub {$oEncipherFileIo->close()}, true, '    close');

        $tContent = $self->storageTest()->get($strFileDecipher);
        $self->testResult(sub {defined($tContent) && $tContent ne $strFileContent}, true, '    data written is enciphered');

        #---------------------------------------------------------------------------------------------------------------------------
        undef($tBuffer);
        # Open enciphered file for deciphering
        $oEncipherFileIo =
            $self->testResult(
                sub {new pgBackRest::Storage::Filter::CipherBlock(
                    $oDriver->openRead($strFileEncipher), $strCipherType, $tCipherKey,
                    {strMode => STORAGE_DECIPHER})},
                '[object]', 'new read enciphered file, decipher');

        # Try to read more than the length of the data expected to be output from the decipher and confirm the deciphered length is
        # the same as the original deciphered content.
        $self->testResult(sub {$oEncipherFileIo->read(\$tBuffer, $iFileLength+4)}, $iFileLength, '    read all bytes');

        # Just because length is the same does not mean content is so confirm
        $self->testResult($tBuffer, $strFileContent, '    data read is deciphered');
        $self->testResult(sub {$oEncipherFileIo->close()}, true, '    close');

        #---------------------------------------------------------------------------------------------------------------------------
        undef($tContent);
        undef($tBuffer);
        my $strFileBinHash = '1c7e00fd09b9dd11fc2966590b3e3274645dd031';

        executeTest('cp ' . $self->dataPath() . "/filecopy.archive2.bin ${strFileBin}");
        $self->testResult(
            sub {sha1_hex(${storageTest()->get($strFileBin)})}, $strFileBinHash, 'bin test - check sha1');

        $tContent = ${storageTest()->get($strFileBin)};

        $oEncipherFileIo = $self->testResult(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openWrite($strFileBinEncipher), $strCipherType, $tCipherKey)},
            '[object]', '    new write encipher');

        $self->testResult(sub {$oEncipherFileIo->write(\$tContent)}, length($tContent), '    write enciphered');
        $self->testResult(sub {$oEncipherFileIo->close()}, true, '    close');
        $self->testResult(
            sub {sha1_hex(${storageTest()->get($strFileBinEncipher)}) ne $strFileBinHash}, true, '    check sha1 different');

        my $oEncipherBinFileIo = $self->testResult(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openRead($strFileBinEncipher), $strCipherType, $tCipherKey,
                {strMode => STORAGE_DECIPHER})},
            '[object]', 'new read enciphered bin file');

        $self->testResult(sub {$oEncipherBinFileIo->read(\$tBuffer, 16777216)}, 16777216, '    read 16777216 bytes');
        $self->testResult(sub {sha1_hex($tBuffer)}, $strFileBinHash, '    check sha1 same as original');
        $self->testResult(sub {$oEncipherBinFileIo->close()}, true, '    close');

        #---------------------------------------------------------------------------------------------------------------------------
        undef($tBuffer);

        $self->storageTest()->put($strFile, $strFileContent);

        executeTest(
            "openssl enc -k ${tCipherKey} -md sha1 -aes-256-cbc -in ${strFile} -out ${strFileEncipher}");

        $oEncipherFileIo = $self->testResult(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openRead($strFileEncipher), $strCipherType, $tCipherKey,
                {strMode => STORAGE_DECIPHER})},
            '[object]', 'read file enciphered by openssl');

        $self->testResult(sub {$oEncipherFileIo->read(\$tBuffer, 16)}, 8, '    read 8 bytes');
        $self->testResult(sub {$oEncipherFileIo->close()}, true, '    close');
        $self->testResult(sub {$tBuffer}, $strFileContent, '    check content same as original');

        $self->storageTest()->remove($strFile);
        $self->storageTest()->remove($strFileEncipher);

        $oEncipherFileIo = $self->testResult(
            sub {new pgBackRest::Storage::Filter::CipherBlock(
                $oDriver->openWrite($strFileEncipher), $strCipherType, $tCipherKey)},
            '[object]', 'write file to be read by openssl');

        $self->testResult(sub {$oEncipherFileIo->write(\$tBuffer)}, 8, '    write 8 bytes');
        $self->testResult(sub {$oEncipherFileIo->close()}, true, '    close');

        executeTest(
            "openssl enc -d -k ${tCipherKey} -md sha1 -aes-256-cbc -in ${strFileEncipher} -out ${strFile}");

        $self->testResult(sub {${$self->storageTest()->get($strFile)}}, $strFileContent, '    check content same as original');
    }
}

1;
