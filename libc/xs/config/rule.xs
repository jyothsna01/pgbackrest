# ----------------------------------------------------------------------------------------------------------------------------------
# Config Rule Perl Exports
# ----------------------------------------------------------------------------------------------------------------------------------

MODULE = pgBackRest::LibC PACKAGE = pgBackRest::LibC

I32
cfgCommandId(commandName)
    const char *commandName
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgCommandId(commandName);
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

I32
cfgOptionId(optionName)
    const char *optionName
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgOptionId(optionName);
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionAllowList(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowList(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

const char *
cfgRuleOptionAllowListValue(commandId, optionId, valueId)
    U32 commandId
    U32 optionId
    U32 valueId
CODE:
    RETVAL = NULL;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowListValue(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId), valueId);
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

I32
cfgRuleOptionAllowListValueTotal(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowListValueTotal(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionAllowListValueValid(commandId, optionId, value);
    U32 commandId
    U32 optionId
    const char *value
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowListValueValid(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId), value);
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionAllowRange(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowRange(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

double
cfgRuleOptionAllowRangeMax(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowRangeMax(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

double
cfgRuleOptionAllowRangeMin(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionAllowRangeMin(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

const char *
cfgRuleOptionDefault(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = NULL;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionDefault(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionDepend(commandId, optionId);
    U32 commandId
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionDepend(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

I32
cfgRuleOptionDependOption(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgOptionIdFromRuleId(
            cfgRuleOptionDependOption(
                cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId)), cfgOptionIndex(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

const char *
cfgRuleOptionDependValue(commandId, optionId, valueId)
    U32 commandId
    U32 optionId
    U32 valueId
CODE:
    RETVAL = NULL;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionDependValue(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId), valueId);
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

I32
cfgRuleOptionDependValueTotal(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionDependValueTotal(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionDependValueValid(commandId, optionId, value)
    U32 commandId
    U32 optionId
    const char *value
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionDependValueValid(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId), value);
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

const char *
cfgRuleOptionNameAlt(optionId)
    U32 optionId
CODE:
    RETVAL = NULL;

    ERROR_XS_BEGIN()
    {
        if (cfgOptionIndexTotal(optionId) > 1 && cfgOptionIndex(optionId) == 0)
            RETVAL = cfgRuleOptionName(cfgOptionRuleIdFromId(optionId));
        else
            RETVAL = cfgRuleOptionNameAlt(cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool cfgRuleOptionNegate(optionId)
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionNegate(cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

const char *
cfgRuleOptionPrefix(optionId)
    U32 optionId
CODE:
    RETVAL = NULL;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionPrefix(cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionRequired(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        // Only the first indexed option is ever required
        if (cfgOptionIndex(optionId) == 0)
        {
            RETVAL = cfgRuleOptionRequired(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
        }
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

const char *
cfgRuleOptionSection(optionId)
    U32 optionId
CODE:
    RETVAL = NULL;

    ERROR_XS_BEGIN()
    {
        switch (cfgRuleOptionSection(cfgOptionRuleIdFromId(optionId)))
        {
            case cfgRuleSectionGlobal:
                RETVAL = "global";
                break;

            case cfgRuleSectionStanza:
                RETVAL = "stanza";
                break;

            default:
                RETVAL = NULL;
                break;
        }
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionSecure(optionId)
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionSecure(cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

I32
cfgRuleOptionType(optionId);
    U32 optionId
CODE:
    RETVAL = 0;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionType(cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

bool
cfgRuleOptionValid(commandId, optionId)
    U32 commandId
    U32 optionId
CODE:
    RETVAL = false;

    ERROR_XS_BEGIN()
    {
        RETVAL = cfgRuleOptionValid(cfgCommandRuleIdFromId(commandId), cfgOptionRuleIdFromId(optionId));
    }
    ERROR_XS_END();
OUTPUT:
    RETVAL

U32
cfgOptionTotal()

bool
cfgRuleOptionValueHash(optionId)
    U32 optionId
CODE:
    RETVAL = false;

    if (cfgRuleOptionType(cfgOptionRuleIdFromId(optionId)) == cfgRuleOptDefTypeHash &&
        cfgOptionRuleIdFromId(optionId) != cfgRuleOptDbInclude)
    {
        RETVAL = true;
    }
OUTPUT:
    RETVAL
