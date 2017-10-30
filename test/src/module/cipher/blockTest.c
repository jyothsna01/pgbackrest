/***********************************************************************************************************************************
Test Block Cipher
***********************************************************************************************************************************/
#include <openssl/evp.h>

/***********************************************************************************************************************************
Data for testing
***********************************************************************************************************************************/
#define TEST_CIPHER                                                 "aes-256-cbc"
#define TEST_KEY                                                    "reallybadkey"
#define TEST_KEY_SIZE                                               strlen(TEST_KEY)
#define TEST_PLAINTEXT                                              "plaintext"
#define TEST_DIGEST                                                 "sha256"
#define TEST_BUFFER_SIZE                                            256

/***********************************************************************************************************************************
Test Run
***********************************************************************************************************************************/
void testRun()
{
    // -----------------------------------------------------------------------------------------------------------------------------
    if (testBegin("blockCipherNew() and blockCipherFree()"))
    {
        // -------------------------------------------------------------------------------------------------------------------------
        TEST_ERROR(
            cipherBlockNew(
                cipherModeEncipher, BOGUS_STR, TEST_KEY, TEST_KEY_SIZE, NULL), AssertError, "unable to load cipher 'BOGUS'");
        TEST_ERROR(
            cipherBlockNew(cipherModeEncipher, NULL, TEST_KEY, TEST_KEY_SIZE, NULL), AssertError, "unable to load cipher '(null)'");
        TEST_ERROR(
            cipherBlockNew(
                cipherModeEncipher, TEST_CIPHER, TEST_KEY, TEST_KEY_SIZE, BOGUS_STR), AssertError, "unable to load digest 'BOGUS'");

        // -------------------------------------------------------------------------------------------------------------------------
        CipherBlock *cipherBlock = cipherBlockNew(cipherModeEncipher, TEST_CIPHER, TEST_KEY, TEST_KEY_SIZE, NULL);
        TEST_RESULT_STR(memContextName(cipherBlock->memContext), "cipherBlock", "mem context name is valid");
        TEST_RESULT_INT(cipherBlock->mode, cipherModeEncipher, "mode is valid");
        TEST_RESULT_INT(cipherBlock->keySize, TEST_KEY_SIZE, "key size is valid");
        TEST_RESULT_BOOL(memcmp(cipherBlock->key, TEST_KEY, TEST_KEY_SIZE) == 0, true, "key is valid");
        TEST_RESULT_BOOL(cipherBlock->saltDone, false, "salt done is false");
        TEST_RESULT_BOOL(cipherBlock->processDone, false, "process done is false");
        TEST_RESULT_INT(cipherBlock->headerSize, 0, "header size is 0");
        TEST_RESULT_PTR_NE(cipherBlock->cipher, NULL, "cipher is set");
        TEST_RESULT_PTR_NE(cipherBlock->digest, NULL, "digest is set");
        TEST_RESULT_PTR(cipherBlock->cipherContext, NULL, "cipher context is not set");
        memContextFree(cipherBlock->memContext);
    }

    // -----------------------------------------------------------------------------------------------------------------------------
    if (testBegin("Encipher and Decipher"))
    {
        char encipherBuffer[TEST_BUFFER_SIZE];
        int encipherSize = 0;
        char decipherBuffer[TEST_BUFFER_SIZE];
        int decipherSize = 0;

        // -------------------------------------------------------------------------------------------------------------------------
        CipherBlock *cipherBlock = cipherBlockNew(cipherModeEncipher, TEST_CIPHER, TEST_KEY, TEST_KEY_SIZE, NULL);

        encipherSize = cipherBlockProcess(cipherBlock, TEST_PLAINTEXT, strlen(TEST_PLAINTEXT), encipherBuffer);

        TEST_RESULT_BOOL(cipherBlock->saltDone, true, "salt done is true");
        TEST_RESULT_BOOL(cipherBlock->processDone, true, "process done is true");
        TEST_RESULT_INT(cipherBlock->headerSize, 0, "header size is 0");
        TEST_RESULT_INT(encipherSize, CIPHER_BLOCK_HEADER_SIZE, "cipher size is header len");

        TEST_RESULT_INT(
            cipherBlockProcessSize(cipherBlock, strlen(TEST_PLAINTEXT)),
            strlen(TEST_PLAINTEXT) + EVP_MAX_BLOCK_LENGTH + CIPHER_BLOCK_MAGIC_SIZE + PKCS5_SALT_LEN, "check process size");

        encipherSize += cipherBlockProcess(cipherBlock, TEST_PLAINTEXT, strlen(TEST_PLAINTEXT), encipherBuffer + encipherSize);
        TEST_RESULT_INT(
            encipherSize, CIPHER_BLOCK_HEADER_SIZE + EVP_CIPHER_block_size(cipherBlock->cipher),
            "cipher size increases by one block");

        encipherSize += cipherBlockFlush(cipherBlock, encipherBuffer + encipherSize);
        TEST_RESULT_INT(
            encipherSize, CIPHER_BLOCK_HEADER_SIZE + (EVP_CIPHER_block_size(cipherBlock->cipher) * 2),
            "cipher size increases by one block on flush");

        cipherBlockFree(cipherBlock);

        // -------------------------------------------------------------------------------------------------------------------------
        cipherBlock = cipherBlockNew(cipherModeDecipher, TEST_CIPHER, TEST_KEY, TEST_KEY_SIZE, NULL);

        decipherSize = cipherBlockProcess(cipherBlock, encipherBuffer, encipherSize, decipherBuffer);
        TEST_RESULT_INT(decipherSize, EVP_CIPHER_block_size(cipherBlock->cipher), "decipher size is one block");

        decipherSize += cipherBlockFlush(cipherBlock, decipherBuffer + decipherSize);
        TEST_RESULT_INT(decipherSize, strlen(TEST_PLAINTEXT) * 2, "check final decipher size");

        decipherBuffer[decipherSize] = 0;
        TEST_RESULT_STR(decipherBuffer, (TEST_PLAINTEXT TEST_PLAINTEXT), "check final decipher buffer");

        // -------------------------------------------------------------------------------------------------------------------------
        cipherBlock = cipherBlockNew(cipherModeDecipher, TEST_CIPHER, TEST_KEY, TEST_KEY_SIZE, NULL);

        decipherSize = 0;
        memset(decipherBuffer, 0, TEST_BUFFER_SIZE);

        decipherSize = cipherBlockProcess(cipherBlock, encipherBuffer, CIPHER_BLOCK_MAGIC_SIZE, decipherBuffer);
        TEST_RESULT_INT(decipherSize, 0, "no decipher since header read is not complete");
        TEST_RESULT_BOOL(cipherBlock->saltDone, false, "salt done is false");
        TEST_RESULT_BOOL(cipherBlock->processDone, false, "process done is false");
        TEST_RESULT_INT(cipherBlock->headerSize, CIPHER_BLOCK_MAGIC_SIZE, "check header size");
        TEST_RESULT_BOOL(
            memcmp(cipherBlock->header, CIPHER_BLOCK_MAGIC, CIPHER_BLOCK_MAGIC_SIZE) == 0, true, "check header magic");

        decipherSize += cipherBlockProcess(
            cipherBlock, encipherBuffer + CIPHER_BLOCK_MAGIC_SIZE, PKCS5_SALT_LEN, decipherBuffer + decipherSize);
        TEST_RESULT_INT(decipherSize, 0, "no decipher since no data processed yet");
        TEST_RESULT_BOOL(cipherBlock->saltDone, true, "salt done is true");
        TEST_RESULT_BOOL(cipherBlock->processDone, false, "process done is false");
        TEST_RESULT_INT(cipherBlock->headerSize, CIPHER_BLOCK_MAGIC_SIZE, "check header size (not increased)");
        TEST_RESULT_BOOL(
            memcmp(
                cipherBlock->header + CIPHER_BLOCK_MAGIC_SIZE, encipherBuffer + CIPHER_BLOCK_MAGIC_SIZE,
                PKCS5_SALT_LEN) == 0,
            true, "check header salt");

        decipherSize += cipherBlockProcess(
            cipherBlock, encipherBuffer + CIPHER_BLOCK_HEADER_SIZE, encipherSize - CIPHER_BLOCK_HEADER_SIZE,
            decipherBuffer + decipherSize);
        TEST_RESULT_INT(decipherSize, EVP_CIPHER_block_size(cipherBlock->cipher), "decipher size is one block");

        decipherSize += cipherBlockFlush(cipherBlock, decipherBuffer + decipherSize);
        TEST_RESULT_INT(decipherSize, strlen(TEST_PLAINTEXT) * 2, "check final decipher size");

        decipherBuffer[decipherSize] = 0;
        TEST_RESULT_STR(decipherBuffer, (TEST_PLAINTEXT TEST_PLAINTEXT), "check final decipher buffer");

        // -------------------------------------------------------------------------------------------------------------------------
        cipherBlock = cipherBlockNew(cipherModeDecipher, TEST_CIPHER, TEST_KEY, TEST_KEY_SIZE, NULL);

        TEST_ERROR(cipherBlockProcess(cipherBlock, "1234567890123456", 16, decipherBuffer), CipherError, "cipher header missing");

        cipherBlockProcess(cipherBlock, CIPHER_BLOCK_MAGIC "12345678", 16, decipherBuffer);
        cipherBlockProcess(cipherBlock, "1234567890123456", 16, decipherBuffer);

        TEST_ERROR(cipherBlockFlush(cipherBlock, decipherBuffer), CipherError, "unable to flush");
    }
}
