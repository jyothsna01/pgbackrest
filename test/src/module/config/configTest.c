/***********************************************************************************************************************************
Test Configuration Commands and Options
***********************************************************************************************************************************/

/***********************************************************************************************************************************
Test run
***********************************************************************************************************************************/
void testRun()
{
    // Static tests against known values -- these may break as options change so will need to be kept up to date.  The tests have
    // generally been selected to favor values that are not expected to change but adjustments are welcome as long as the type of
    // test is not drastically changed.
    // -----------------------------------------------------------------------------------------------------------------------------
    if (testBegin("check known values"))
    {
        // Generate standard error messages
        char optionIdInvalidHighError[256];
        snprintf(
            optionIdInvalidHighError, sizeof(optionIdInvalidHighError), "option id %d invalid - must be >= 0 and < %d",
            cfgOptionTotal(), cfgOptionTotal());

        char optionIdInvalidLowError[256];
        snprintf(
            optionIdInvalidLowError, sizeof(optionIdInvalidLowError), "option id -1 invalid - must be >= 0 and < %d",
            cfgOptionTotal());

        char commandIdInvalidHighError[256];
        snprintf(
            commandIdInvalidHighError, sizeof(commandIdInvalidHighError), "command id %d invalid - must be >= 0 and < %d",
            cfgCommandTotal(), cfgCommandTotal());

        char commandIdInvalidLowError[256];
        snprintf(
            commandIdInvalidLowError, sizeof(commandIdInvalidLowError), "command id -1 invalid - must be >= 0 and < %d",
            cfgCommandTotal());

        // -------------------------------------------------------------------------------------------------------------------------
        // TEST_ERROR(cfgCommandName(-1), AssertError, commandIdInvalidLowError);
        // TEST_RESULT_INT(cfgCommandId("archive-push"), cfgRuleCmdArchivePush, "command id from name");
        // TEST_RESULT_INT(cfgCommandId(BOGUS_STR), -1, "command id from invalid command name");

        TEST_ERROR(cfgOptionName(-1), AssertError, optionIdInvalidLowError);
        TEST_RESULT_INT(cfgOptionId("target"), cfgOptionTarget, "option id from name");
        TEST_RESULT_INT(cfgOptionId(BOGUS_STR), -1, "option id from invalid option name");
    }
}
