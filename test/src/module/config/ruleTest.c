/***********************************************************************************************************************************
Test Configuration Command and Option Rules
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
            optionIdInvalidHighError, sizeof(optionIdInvalidHighError), "option rule id %d invalid - must be >= 0 and < %d",
            cfgRuleOptionTotal(), cfgRuleOptionTotal());

        char optionIdInvalidLowError[256];
        snprintf(
            optionIdInvalidLowError, sizeof(optionIdInvalidLowError), "option rule id -1 invalid - must be >= 0 and < %d",
            cfgRuleOptionTotal());

        char commandIdInvalidHighError[256];
        snprintf(
            commandIdInvalidHighError, sizeof(commandIdInvalidHighError), "command rule id %d invalid - must be >= 0 and < %d",
            cfgRuleCommandTotal(), cfgRuleCommandTotal());

        char commandIdInvalidLowError[256];
        snprintf(
            commandIdInvalidLowError, sizeof(commandIdInvalidLowError), "command rule id -1 invalid - must be >= 0 and < %d",
            cfgRuleCommandTotal());

        // -------------------------------------------------------------------------------------------------------------------------
        TEST_RESULT_STR(cfgRuleOptionName(cfgRuleOptConfig), "config", "option name");
        TEST_ERROR(cfgRuleOptionName(-1), AssertError, optionIdInvalidLowError);

        TEST_RESULT_BOOL(cfgRuleOptionAllowList(cfgRuleCmdBackup, cfgRuleOptLogLevelConsole), true, "allow list valid");
        TEST_RESULT_BOOL(cfgRuleOptionAllowList(cfgRuleCmdBackup, cfgRuleOptDbHost), false, "allow list not valid");
        TEST_RESULT_BOOL(cfgRuleOptionAllowList(cfgRuleCmdBackup, cfgRuleOptType), true, "command allow list valid");

        TEST_RESULT_INT(cfgRuleOptionAllowListValueTotal(cfgRuleCmdBackup, cfgRuleOptType), 3, "allow list total");

        TEST_RESULT_STR(cfgRuleOptionAllowListValue(cfgRuleCmdBackup, cfgRuleOptType, 0), "full", "allow list value 0");
        TEST_RESULT_STR(cfgRuleOptionAllowListValue(cfgRuleCmdBackup, cfgRuleOptType, 1), "diff", "allow list value 1");
        TEST_RESULT_STR(cfgRuleOptionAllowListValue(cfgRuleCmdBackup, cfgRuleOptType, 2), "incr", "allow list value 2");
        TEST_ERROR(
            cfgRuleOptionAllowListValue(cfgRuleCmdBackup, cfgRuleOptType, 3), AssertError,
            "value id 3 invalid - must be >= 0 and < 3");

        TEST_RESULT_BOOL(
            cfgRuleOptionAllowListValueValid(cfgRuleCmdBackup, cfgRuleOptType, "diff"), true, "allow list value valid");
        TEST_RESULT_BOOL(
            cfgRuleOptionAllowListValueValid(cfgRuleCmdBackup, cfgRuleOptType, BOGUS_STR), false, "allow list value not valid");

        TEST_RESULT_BOOL(cfgRuleOptionAllowRange(cfgRuleCmdBackup, cfgRuleOptCompressLevel), true, "range allowed");
        TEST_RESULT_BOOL(cfgRuleOptionAllowRange(cfgRuleCmdBackup, cfgRuleOptBackupHost), false, "range not allowed");

        TEST_RESULT_DOUBLE(cfgRuleOptionAllowRangeMin(cfgRuleCmdBackup, cfgRuleOptDbTimeout), 0.1, "range min");
        TEST_RESULT_DOUBLE(cfgRuleOptionAllowRangeMax(cfgRuleCmdBackup, cfgRuleOptCompressLevel), 9, "range max");

        TEST_ERROR(cfgRuleOptionDefault(-1, cfgRuleOptCompressLevel), AssertError, commandIdInvalidLowError);
        TEST_ERROR(cfgRuleOptionDefault(cfgRuleCmdBackup, cfgRuleOptionTotal()), AssertError, optionIdInvalidHighError);
        TEST_RESULT_STR(cfgRuleOptionDefault(cfgRuleCmdBackup, cfgRuleOptCompressLevel), "6", "option default exists");
        TEST_RESULT_STR(cfgRuleOptionDefault(cfgRuleCmdRestore, cfgRuleOptType), "default", "command default exists");
        TEST_RESULT_STR(cfgRuleOptionDefault(cfgRuleCmdLocal, cfgRuleOptType), NULL, "command default does not exist");
        TEST_RESULT_STR(cfgRuleOptionDefault(cfgRuleCmdBackup, cfgRuleOptBackupHost), NULL, "default does not exist");

        TEST_RESULT_BOOL(cfgRuleOptionDepend(cfgRuleCmdRestore, cfgRuleOptRepoS3Key), true, "has depend option");
        TEST_RESULT_BOOL(cfgRuleOptionDepend(cfgRuleCmdRestore, cfgRuleOptType), false, "does not have depend option");

        TEST_RESULT_INT(cfgRuleOptionDependOption(cfgRuleCmdBackup, cfgRuleOptDbUser), cfgRuleOptDbHost, "depend option id");
        TEST_RESULT_INT(cfgRuleOptionDependOption(cfgRuleCmdBackup, cfgRuleOptBackupCmd), cfgRuleOptBackupHost, "depend option id");

        TEST_RESULT_INT(cfgRuleOptionDependValueTotal(cfgRuleCmdRestore, cfgRuleOptTarget), 3, "depend option value total");
        TEST_RESULT_STR(cfgRuleOptionDependValue(cfgRuleCmdRestore, cfgRuleOptTarget, 0), "name", "depend option value 0");
        TEST_RESULT_STR(cfgRuleOptionDependValue(cfgRuleCmdRestore, cfgRuleOptTarget, 1), "time", "depend option value 1");
        TEST_RESULT_STR(cfgRuleOptionDependValue(cfgRuleCmdRestore, cfgRuleOptTarget, 2), "xid", "depend option value 2");
        TEST_ERROR(
            cfgRuleOptionDependValue(cfgRuleCmdRestore, cfgRuleOptTarget, 3), AssertError,
            "value id 3 invalid - must be >= 0 and < 3");

        TEST_RESULT_BOOL(
                cfgRuleOptionDependValueValid(cfgRuleCmdRestore, cfgRuleOptTarget, "time"), true, "depend option value valid");
        TEST_RESULT_BOOL(
            cfgRuleOptionDependValueValid(cfgRuleCmdRestore, cfgRuleOptTarget, BOGUS_STR), false, "depend option value not valid");

        TEST_ERROR(cfgRuleOptionIndexTotal(cfgRuleOptionTotal()), AssertError, optionIdInvalidHighError);
        TEST_RESULT_INT(cfgRuleOptionIndexTotal(cfgRuleOptDbPath), 8, "index total > 1");
        TEST_RESULT_INT(cfgRuleOptionIndexTotal(cfgRuleOptRepoPath), 1, "index total == 1");

        TEST_RESULT_STR(cfgRuleOptionNameAlt(cfgRuleOptProcessMax), "thread-max", "alt name");
        TEST_RESULT_STR(cfgRuleOptionNameAlt(cfgRuleOptType), NULL, "no alt name");

        TEST_ERROR(cfgRuleOptionNegate(cfgRuleOptionTotal()), AssertError, optionIdInvalidHighError);
        TEST_RESULT_BOOL(cfgRuleOptionNegate(cfgRuleOptOnline), true, "option can be negated");
        TEST_RESULT_BOOL(cfgRuleOptionNegate(cfgRuleOptType), false, "option cannot be negated");

        TEST_RESULT_STR(cfgRuleOptionPrefix(cfgRuleOptDbHost), "db", "option prefix");
        TEST_RESULT_STR(cfgRuleOptionPrefix(cfgRuleOptType), NULL, "option has no prefix");

        TEST_RESULT_BOOL(cfgRuleOptionRequired(cfgRuleCmdBackup, cfgRuleOptConfig), true, "option required");
        TEST_RESULT_BOOL(cfgRuleOptionRequired(cfgRuleCmdRestore, cfgRuleOptBackupHost), false, "option not required");
        TEST_RESULT_BOOL(cfgRuleOptionRequired(cfgRuleCmdInfo, cfgRuleOptStanza), false, "command option not required");

        TEST_RESULT_INT(cfgRuleOptionSection(cfgRuleOptRepoS3Key), cfgRuleSectionGlobal, "global section");
        TEST_RESULT_INT(cfgRuleOptionSection(cfgRuleOptDbPath), cfgRuleSectionStanza, "stanza section");
        TEST_RESULT_INT(cfgRuleOptionSection(cfgRuleOptType), cfgRuleSectionCommandLine, "command line only");

        TEST_ERROR(cfgRuleOptionSecure(-1), AssertError, optionIdInvalidLowError);
        TEST_RESULT_BOOL(cfgRuleOptionSecure(cfgRuleOptRepoS3Key), true, "option secure");
        TEST_RESULT_BOOL(cfgRuleOptionSecure(cfgRuleOptBackupHost), false, "option not secure");

        TEST_ERROR(cfgRuleOptionType(-1), AssertError, optionIdInvalidLowError);
        TEST_RESULT_INT(cfgRuleOptionType(cfgRuleOptType), cfgRuleOptDefTypeString, "string type");
        TEST_RESULT_INT(cfgRuleOptionType(cfgRuleOptCompress), cfgRuleOptDefTypeBoolean, "boolean type");

        TEST_ERROR(cfgRuleOptionValid(cfgRuleCmdInfo, cfgRuleOptionTotal()), AssertError, optionIdInvalidHighError);
        TEST_RESULT_BOOL(cfgRuleOptionValid(cfgRuleCmdBackup, cfgRuleOptType), true, "option valid");
        TEST_RESULT_BOOL(cfgRuleOptionValid(cfgRuleCmdInfo, cfgRuleOptType), false, "option not valid");
    }
}
