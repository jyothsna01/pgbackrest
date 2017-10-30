/***********************************************************************************************************************************
Block Cipher XS Header
***********************************************************************************************************************************/
#include "../src/common/memContext.h"
#include "../src/cipher/block.h"

// Encipher/decipher modes
#define CIPHER_MODE_ENCIPHER                                        ((int)cipherModeEncipher)
#define CIPHER_MODE_DECIPHER                                        ((int)cipherModeDecipher)

typedef struct CipherBlockXs
{
    MemContext *memContext;
    CipherBlock *pxPayload;
} CipherBlockXs, *pgBackRest__LibC__Cipher__Block;
