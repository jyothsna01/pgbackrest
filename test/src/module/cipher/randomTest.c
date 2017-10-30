/***********************************************************************************************************************************
Test Random
***********************************************************************************************************************************/
#include "common/memContext.h"

/***********************************************************************************************************************************
Test Run
***********************************************************************************************************************************/
void testRun()
{
    // -----------------------------------------------------------------------------------------------------------------------------
    if (testBegin("randomBytes()"))
    {
        // -------------------------------------------------------------------------------------------------------------------------
        // Test if the buffer was overrun
        int bufferSize = 256;
        char *buffer = memNew(bufferSize);

        randomBytes(buffer, bufferSize);
        TEST_RESULT_BOOL(buffer[bufferSize] == 0, true, "check that buffer did not overrun (though random byte could be 0)");

        // -------------------------------------------------------------------------------------------------------------------------
        // Count bytes that are not zero (there shouldn't be all zeroes)
        int nonZeroTotal = 0;

        for (int charIdx = 0; charIdx < bufferSize; charIdx++)
            if (buffer[charIdx] != 0)
                nonZeroTotal++;

        TEST_RESULT_INT_NE(nonZeroTotal, 0, "check that there are non-zero values in the buffer");
    }
}
