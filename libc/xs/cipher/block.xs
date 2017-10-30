####################################################################################################################################
# Block Cipher Perl Exports
####################################################################################################################################

MODULE = pgBackRest::LibC PACKAGE = pgBackRest::LibC::Cipher::Block

####################################################################################################################################
# cipherBlockNew - create the object
####################################################################################################################################
pgBackRest::LibC::Cipher::Block
new(class, mode, type, key, keySize, digest = NULL)
    const char *class
    U32 mode
    const char *type
    unsigned char *key
    I32 keySize
    const char *digest
CODE:
    RETVAL = NULL;

    // Not much point to this but it keeps the var from being unused
    if (strcmp(class, PACKAGE_NAME_LIBC "::Cipher::Block") != 0)
        croak("unexpected class name '%s'", class);

    MEM_CONTEXT_XS_NEW_BEGIN("cipherBlockXs")
    {
        RETVAL = memNew(sizeof(CipherBlockXs));

        RETVAL->memContext = MEM_COMTEXT_XS();

        RETVAL->pxPayload = cipherBlockNew(mode, type, key, keySize, digest);
    }
    MEM_CONTEXT_XS_NEW_END();
OUTPUT:
    RETVAL

####################################################################################################################################
# process - encipher/decipher data
####################################################################################################################################
SV *
process(self, svSource)
    pgBackRest::LibC::Cipher::Block self
    SV *svSource
CODE:
    RETVAL = NULL;
    STRLEN tSize;
    const unsigned char *pvSource = (const unsigned char *)SvPV(svSource, tSize);

    MEM_CONTEXT_XS_BEGIN(self->memContext)
    {
        RETVAL = NEWSV(0, cipherBlockProcessSize(self->pxPayload, tSize));
        SvPOK_only(RETVAL);

        SvCUR_set(RETVAL, cipherBlockProcess(self->pxPayload, pvSource, tSize, (unsigned char *)SvPV_nolen(RETVAL)));
    }
    MEM_CONTEXT_XS_END();
OUTPUT:
    RETVAL

####################################################################################################################################
# flush - flush remaining data
####################################################################################################################################
SV *
flush(self)
    pgBackRest::LibC::Cipher::Block self
CODE:
    RETVAL = NULL;

    MEM_CONTEXT_XS_BEGIN(self->memContext)
    {
        RETVAL = NEWSV(0, cipherBlockProcessSize(self->pxPayload, 0));
        SvPOK_only(RETVAL);

        SvCUR_set(RETVAL, cipherBlockFlush(self->pxPayload, (unsigned char *)SvPV_nolen(RETVAL)));
    }
    MEM_CONTEXT_XS_END();
OUTPUT:
    RETVAL

####################################################################################################################################
# DESTROY - free memory
####################################################################################################################################
void
DESTROY(self)
    pgBackRest::LibC::Cipher::Block self
CODE:
    MEM_CONTEXT_XS_DESTROY(self->memContext);
