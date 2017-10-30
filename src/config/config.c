/***********************************************************************************************************************************
Command and Option Configuration
***********************************************************************************************************************************/
#include <string.h>

#include "common/error.h"
#include "config/config.h"
#include "config/rule.h"

typedef struct ConfigOptionData
{
    const char *name;

    unsigned int index:5;
    ConfigRuleOption ruleId:8;
} ConfigOptionData;

#define CONFIG_OPTION_LIST(...)                                                                                                    \
    {__VA_ARGS__};

#define CONFIG_OPTION(...)                                                                                                         \
    {__VA_ARGS__},

#define CONFIG_OPTION_INDEX(indexParam) .index = indexParam,
#define CONFIG_OPTION_NAME(nameParam) .name = nameParam,
#define CONFIG_OPTION_RULE_ID(ruleIdParam) .ruleId = ruleIdParam,

typedef struct ConfigCommandData
{
    const char *name;
    ConfigRuleCommand ruleId:5;
} ConfigCommandData;

#define CONFIG_COMMAND_LIST(...)                                                                                                   \
    {__VA_ARGS__};

#define CONFIG_COMMAND(...)                                                                                                        \
    {__VA_ARGS__},

#define CONFIG_COMMAND_NAME(nameParam) .name = nameParam,

#include "config.auto.c"

/***********************************************************************************************************************************
Ensure that command id is valid
***********************************************************************************************************************************/
void
cfgCommandCheck(ConfigCommand commandId)
{
    if (commandId < 0 || commandId >= cfgCommandTotal())
        ERROR_THROW(AssertError, "command id %d invalid - must be >= 0 and < %d", commandId, cfgCommandTotal());
}

/***********************************************************************************************************************************
Get command id by name
***********************************************************************************************************************************/
int
cfgCommandId(const char *commandName)
{
    for (ConfigCommand commandId = 0; commandId < cfgCommandTotal(); commandId++)
        if (strcmp(commandName, configCommandData[commandId].name) == 0)
            return commandId;

    return -1;
}

/***********************************************************************************************************************************
Get command name by id
***********************************************************************************************************************************/
const char *
cfgCommandName(ConfigCommand commandId)
{
    cfgCommandCheck(commandId);
    return configCommandData[commandId].name;
}

/***********************************************************************************************************************************
Get the rule for this command

!!! Need to create a real mapping here
***********************************************************************************************************************************/
ConfigRuleCommand
cfgCommandRuleIdFromId(ConfigCommand commandId)
{
    cfgCommandCheck(commandId);
    return (ConfigRuleCommand)commandId;
}

/***********************************************************************************************************************************
cfgCommandTotal - total number of commands
***********************************************************************************************************************************/
int
cfgCommandTotal()
{
    return sizeof(configCommandData) / sizeof(ConfigCommandData);
}

/***********************************************************************************************************************************
Ensure that option id is valid
***********************************************************************************************************************************/
void
cfgOptionCheck(ConfigOption optionId)
{
    if (optionId < 0 || optionId >= cfgOptionTotal())
        ERROR_THROW(AssertError, "option id %d invalid - must be >= 0 and < %d", optionId, cfgOptionTotal());
}

/***********************************************************************************************************************************
Get option id by name
***********************************************************************************************************************************/
int
cfgOptionId(const char *optionName)
{
    for (ConfigOption optionId = 0; optionId < cfgOptionTotal(); optionId++)
        if (strcmp(optionName, configOptionData[optionId].name) == 0)
            return optionId;

    return -1;
}

/***********************************************************************************************************************************
Get total indexed values for option
***********************************************************************************************************************************/
int
cfgOptionIndex(ConfigOption optionId)
{
    cfgOptionCheck(optionId);
    return configOptionData[optionId].index;
}

/***********************************************************************************************************************************
Get total indexed values for option
***********************************************************************************************************************************/
int
cfgOptionIndexTotal(ConfigOption optionId)
{
    cfgOptionCheck(optionId);
    return cfgRuleOptionIndexTotal(configOptionData[optionId].ruleId);
}

/***********************************************************************************************************************************
Get option name by id
***********************************************************************************************************************************/
const char *
cfgOptionName(ConfigOption optionId)
{
    cfgOptionCheck(optionId);
    return configOptionData[optionId].name;
}

/***********************************************************************************************************************************
Get the rule for this option
***********************************************************************************************************************************/
ConfigRuleOption
cfgOptionRuleIdFromId(ConfigOption optionId)
{
    cfgOptionCheck(optionId);
    return configOptionData[optionId].ruleId;
}

/***********************************************************************************************************************************
Get the rule for this option
***********************************************************************************************************************************/
ConfigOption
cfgOptionIdFromRuleId(ConfigRuleOption ruleOptionId, int index)
{
    cfgRuleOptionCheck(ruleOptionId);

    // Search for the option
    ConfigOption optionId;

    for (optionId = 0; optionId < cfgOptionTotal(); optionId++)
        if (configOptionData[optionId].ruleId == ruleOptionId)
            break;

    // Error when not found -- this should not be possible
    if (optionId == cfgOptionTotal())
        ERROR_THROW(AssertError, "cannot find option rule id %d", ruleOptionId);

    // Return with original index
    return optionId + index;
}

/***********************************************************************************************************************************
cfgOptionTotal - total number of configuration options
***********************************************************************************************************************************/
int
cfgOptionTotal()
{
    return sizeof(configOptionData) / sizeof(ConfigOptionData);
}
