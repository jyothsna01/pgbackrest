/***********************************************************************************************************************************
Block Cipher
***********************************************************************************************************************************/
#include <string.h>

#include <openssl/evp.h>
#include <openssl/err.h>
#include <openssl/rand.h>

#include "common/errorType.h"
#include "common/memContext.h"
#include "cipher/block.h"
#include "cipher/random.h"

/***********************************************************************************************************************************
Header constants and sizes
***********************************************************************************************************************************/
// Magic constant for salted encipher.  Only salted encipher is done here, but this constant is required for compatibility with the
// openssl command-line tool.
#define CIPHER_BLOCK_MAGIC                                          "Salted__"
#define CIPHER_BLOCK_MAGIC_SIZE                                     8

// Total length of cipher header
#define CIPHER_BLOCK_HEADER_SIZE                                    (CIPHER_BLOCK_MAGIC_SIZE + PKCS5_SALT_LEN)

/***********************************************************************************************************************************
Track state during block encipher/decipher
***********************************************************************************************************************************/
struct CipherBlock
{
    MemContext *memContext;                                         // Context to store data
    CipherMode mode;                                                // Mode encipher/decipher
    bool saltDone;                                                  // Has the salt been read/generated?
    bool processDone;                                               // Has any data been processed?
    int keySize;                                                    // Size of key in bytes
    unsigned char *key;                                             // Key used for encipher/decipher
    int headerSize;                                                 // Size of header read during decipher
    unsigned char header[CIPHER_BLOCK_HEADER_SIZE];                 // Buffer to hold partial header during decipher
    const EVP_CIPHER *cipher;                                       // Cipher object
    const EVP_MD *digest;                                           // Message digest object
    EVP_CIPHER_CTX *cipherContext;                                  // Encipher/decipher context
};

/***********************************************************************************************************************************
Flag to indicate if OpenSSL has already been initialized
***********************************************************************************************************************************/
bool openSslInitDone = false;

/***********************************************************************************************************************************
cipherBlockNew - new block encipher/decipher object
***********************************************************************************************************************************/
CipherBlock *
cipherBlockNew(CipherMode mode, const char *cipherName, const unsigned char *key, int keySize, const char *digestName)
{
    // Only need to init once.  This memory could be freed, but ciphers are used for the life of the process so don't bother.
    if (!openSslInitDone)
    {
        ERR_load_crypto_strings();
        OpenSSL_add_all_algorithms();

        openSslInitDone = true;
    }

    // Lookup cipher by name.  This means the ciphers passed in must exactly match a name expected by OpenSSL.  This is a good
    // thing since the name required by the openssl command-line tool will match what is used by pgBackRest.
    const EVP_CIPHER *cipher = EVP_get_cipherbyname(cipherName);

    if (!cipher)
        ERROR_THROW(AssertError, "unable to load cipher '%s'", cipherName);

    // Lookup digest.  If not defined it will be set to sha1.
    const EVP_MD *digest;

    if (digestName)
        digest = EVP_get_digestbyname(digestName);
    else
        digest = EVP_sha1();

    if (!digest)
        ERROR_THROW(AssertError, "unable to load digest '%s'", digestName);

    // Allocate memory to hold process state
    CipherBlock *this = NULL;

    MEM_CONTEXT_NEW_BEGIN("cipherBlock")
    {
        // Allocate state and set context
        this = memNew(sizeof(CipherBlock));
        this->memContext = MEM_CONTEXT_NEW();

        // Set mode, encipher or decipher
        this->mode = mode;

        // Set cipher and digest
        this->cipher = cipher;
        this->digest = digest;

        // Store the key
        this->keySize = keySize;
        this->key = memNewRaw(this->keySize);
        memcpy(this->key, key, this->keySize);
    }
    MEM_CONTEXT_NEW_END();

    return this;
}

/***********************************************************************************************************************************
cipherBlockProcessSize - determine how large the destination buffer should be
***********************************************************************************************************************************/
int
cipherBlockProcessSize(CipherBlock *this, int sourceSize)
{
    return sourceSize + EVP_MAX_BLOCK_LENGTH + CIPHER_BLOCK_MAGIC_SIZE + PKCS5_SALT_LEN;
}

/***********************************************************************************************************************************
cipherBlockProcess - encipher/decipher data
***********************************************************************************************************************************/
int
cipherBlockProcess(CipherBlock *this, const unsigned char *source, int sourceSize, unsigned char *destination)
{
    // Actual destination size
    uint32 destinationSize = 0;

    MEM_CONTEXT_BEGIN(this->memContext)
    {
        // Return 0 if there is nothing to process
        if (sourceSize > 0)
        {
            // If the salt has not been generated/read yet
            if (!this->saltDone)
            {
                const unsigned char *salt = NULL;

                // On encipher the salt is generated
                if (this->mode == cipherModeEncipher)
                {
                    // Add magic to the destination buffer so openssl knows the file is salted
                    memcpy(destination, CIPHER_BLOCK_MAGIC, CIPHER_BLOCK_MAGIC_SIZE);
                    destination += CIPHER_BLOCK_MAGIC_SIZE;
                    destinationSize += CIPHER_BLOCK_MAGIC_SIZE;

                    // Add salt to the destination buffer
                    randomBytes(destination, PKCS5_SALT_LEN);
                    salt = destination;
                    destination += PKCS5_SALT_LEN;
                    destinationSize += PKCS5_SALT_LEN;
                }
                // On decipher the salt is read from the header
                else
                {
                    // Check if the entire header has been read
                    if (this->headerSize + sourceSize >= CIPHER_BLOCK_HEADER_SIZE)
                    {
                        // Copy header (or remains of header) from source into the header buffer
                        memcpy(this->header + this->headerSize, source, CIPHER_BLOCK_HEADER_SIZE - this->headerSize);
                        salt = this->header + CIPHER_BLOCK_MAGIC_SIZE;

                        // Advance source and source size by the number of bytes read
                        source += CIPHER_BLOCK_HEADER_SIZE - this->headerSize;
                        sourceSize -= CIPHER_BLOCK_HEADER_SIZE - this->headerSize;

                        // The first bytes of the file to decipher should be equal to the magic.  If not then this is not an
                        // enciphered file, or at least not in a format we recognize.
                        if (memcmp(this->header, CIPHER_BLOCK_MAGIC, CIPHER_BLOCK_MAGIC_SIZE) != 0)
                            ERROR_THROW(CipherError, "cipher header missing");
                    }
                    // Else copy what was provided into the header buffer and return 0
                    else
                    {
                        memcpy(this->header + this->headerSize, source, sourceSize);
                        this->headerSize += sourceSize;

                        // Indicate that there is nothing left to process
                        sourceSize = 0;
                    }
                }

                // If salt generation/read is done
                if (salt)
                {
                    // Setup key and initialization vector
                    unsigned char key[EVP_MAX_KEY_LENGTH];
                    unsigned char initVector[EVP_MAX_IV_LENGTH];

                    EVP_BytesToKey(
                        this->cipher, this->digest, salt, (unsigned char *)this->key, this->keySize, 1, key, initVector);

                    // Set free callback to ensure cipher context is freed
                    memContextCallback(this->memContext, (MemContextCallback)cipherBlockFree, this);

                    // Create context to track cipher
                    if (!(this->cipherContext = EVP_CIPHER_CTX_new()))
                        ERROR_THROW(MemoryError, "unable to create context");               // {uncoverable - no failure path known}

                    // Initialize cipher
                    if (EVP_CipherInit_ex(
                        this->cipherContext, this->cipher, NULL, key, initVector, this->mode == cipherModeEncipher) != 1)
                    {
                        ERROR_THROW(MemoryError, "unable to initialize cipher");            // {uncoverable - no failure path known}
                    }

                    this->saltDone = true;
                }
            }

            // Recheck that source size > 0 as the bytes may have been consumed reading the header
            if (sourceSize > 0)
            {
                // Process the data
                int destinationUpdateSize = 0;

                if (!EVP_CipherUpdate(this->cipherContext, destination, &destinationUpdateSize, source, sourceSize))
                    ERROR_THROW(CipherError, "unable to process");                           // {uncoverable - no failure path known}

                destinationSize += destinationUpdateSize;

                // Note that data has been processed so flush is valid
                this->processDone = true;
            }
        }
    }
    MEM_CONTEXT_END();

    // Return actual destination size
    return destinationSize;
}

/***********************************************************************************************************************************
cipherBlockFlush - flush the remaining data
***********************************************************************************************************************************/
int
cipherBlockFlush(CipherBlock *this, unsigned char *destination)
{
    // Actual destination size
    int iDestinationSize = 0;

    MEM_CONTEXT_BEGIN(this->memContext)
    {
        // Only flush remaining data if some data was processed
        if (this->processDone && !EVP_CipherFinal(this->cipherContext, destination, &iDestinationSize))
            ERROR_THROW(CipherError, "unable to flush");
    }
    MEM_CONTEXT_END();

    // Return actual destination size
    return iDestinationSize;
}

/***********************************************************************************************************************************
cipherBlockFree - free memory
***********************************************************************************************************************************/
void
cipherBlockFree(CipherBlock *this)
{
    // Free cipher context
    if (this->cipherContext)
        EVP_CIPHER_CTX_cleanup(this->cipherContext);

    // Free mem context
    memContextFree(this->memContext);
}
