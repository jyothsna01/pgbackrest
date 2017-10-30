/***********************************************************************************************************************************
Command and Option Configuration Rules
***********************************************************************************************************************************/
#include <string.h>

#include "common/error.h"
#include "config/rule.h"

typedef struct OptionRule
{
    char *name;
    unsigned int type:3;
    unsigned int indexTotal:4;
    ConfigRuleSection section:2;
    bool negate:1;
    bool required:1;
    bool secure:1;
    unsigned int commandValid:15;
    void **data;
} OptionRule;

#define CONFIG_OPTION_LIST(...)                                                                                                    \
    {__VA_ARGS__};

#define CONFIG_OPTION(...)                                                                                                         \
    {__VA_ARGS__},

#define CONFIG_OPTION_NAME(nameParam) .name = nameParam,
#define CONFIG_OPTION_INDEX_TOTAL(indexTotalParam) .indexTotal = indexTotalParam,
#define CONFIG_OPTION_NEGATE(negateParam) .negate = negateParam,
#define CONFIG_OPTION_REQUIRED(requiredParam) .required = requiredParam,
#define CONFIG_OPTION_SECTION(sectionParam) .section = sectionParam,
#define CONFIG_OPTION_SECURE(secureParam) .secure = secureParam,
#define CONFIG_OPTION_TYPE(typeParam) .type = typeParam,

#define CONFIG_DATA_PUSH_LIST(type, length, data, ...)                                                                             \
    (void *)((uint32)type << 24 | (uint32)length << 16 | (uint32)data), __VA_ARGS__

#define CONFIG_DATA_PUSH(type, length, data)                                                                                       \
    (void *)((uint32)type << 24 | (uint32)length << 16 | (uint32)data)

#define CONFIG_COMMAND_VALID_LIST(...)                                                                                             \
    .commandValid = 0 __VA_ARGS__,

#define CONFIG_COMMAND_VALID(commandParam)                                                                                         \
    | (1 << commandParam)

typedef enum
{
    configRuleDataTypeEnd,                                          // Indicates there there is no more data
    configRuleDataTypeAllowList,
    configRuleDataTypeAllowRange,
    configRuleDataTypeCommand,
    configRuleDataTypeDefault,
    configRuleDataTypeDepend,
    configRuleDataTypeNameAlt,
    configRuleDataTypePrefix,
    configRuleDataTypeRequired,
} ConfigRuleDataType;

#define CONFIG_OPTION_DATA(...)                                                                                                    \
    .data = (void *[]){__VA_ARGS__ NULL},

#define CONFIG_OPTION_DEFAULT(defaultValue)                                                                                        \
    CONFIG_DATA_PUSH_LIST(configRuleDataTypeDefault, 1, 0, defaultValue),

#define CONFIG_OPTION_COMMAND_DATA(commandParam)                                                                                   \
    CONFIG_DATA_PUSH(configRuleDataTypeCommand, 0, commandParam),

#define CONFIG_OPTION_ALLOW_LIST(...)                                                                                              \
    CONFIG_DATA_PUSH_LIST(configRuleDataTypeAllowList, sizeof((char *[]){__VA_ARGS__}) / sizeof(char *), 0, __VA_ARGS__),

#define CONFIG_OPTION_ALLOW_RANGE(rangeMinParam, rangeMaxParam)                                                                    \
    CONFIG_DATA_PUSH_LIST(                                                                                                         \
        configRuleDataTypeAllowRange, 2, 0, (void *)(intptr_t)(int32)(rangeMinParam * 100),                                        \
        (void *)(intptr_t)(int32)(rangeMaxParam * 100)),

#define CONFIG_OPTION_NAME_ALT(nameAltParam)                                                                                       \
    CONFIG_DATA_PUSH_LIST(configRuleDataTypeNameAlt, 1, 0, nameAltParam),

#define CONFIG_OPTION_PREFIX(prefixParam)                                                                                          \
    CONFIG_DATA_PUSH_LIST(configRuleDataTypePrefix, 1, 0, prefixParam),

#define CONFIG_OPTION_DEPEND(optionDepend)                                                                                         \
    CONFIG_DATA_PUSH(configRuleDataTypeDepend, 0, optionDepend),

#define CONFIG_OPTION_COMMAND_REQUIRED(optionRequired)                                                                             \
    CONFIG_DATA_PUSH(configRuleDataTypeRequired, 0, optionRequired),

#define CONFIG_OPTION_DEPEND_LIST(optionDepend, ...)                                                                               \
    CONFIG_DATA_PUSH_LIST(configRuleDataTypeDepend, sizeof((char *[]){__VA_ARGS__}) / sizeof(char *), optionDepend, __VA_ARGS__),

typedef struct CommandRule
{
    char *name;
} CommandRule;

#define CONFIG_COMMAND_LIST(...)                                                                                                   \
    {__VA_ARGS__};

#define CONFIG_COMMAND(...)                                                                                                        \
    {__VA_ARGS__},

#define CONFIG_COMMAND_NAME(nameParam) .name = nameParam,

#include "rule.auto.c"

/***********************************************************************************************************************************
Find optional data for a command and option
***********************************************************************************************************************************/
void
optionRuleDataFind(
    ConfigRuleDataType typeFind, ConfigRuleCommand ruleCommandId, void **dataList, bool *ruleFound, int *dataFound,
    void ***ruleList, int *lengthFound)
{
    *ruleFound = false;

    // Only proceed if there is data
    if (dataList != NULL)
    {
        ConfigRuleDataType type;
        int offset = 0;
        int length;
        int data;
        int commandCurrent = -1;

        // Loop through all data
        do
        {
            // Extract data
            type = (ConfigRuleDataType)(((uintptr_t)dataList[offset] >> 24) & 0xFF);
            length = ((uintptr_t)dataList[offset] >> 16) & 0xFF;
            data = (uintptr_t)dataList[offset] & 0xFFFF;

            // If a command block then set the current command
            if (type == configRuleDataTypeCommand)
            {
                // If data was not found in the expected command then there's nothing more to look for
                if (commandCurrent == ruleCommandId)
                    break;

                // Set the current command
                commandCurrent = data;
            }
            // Only find type if not in a command block yet or in the expected command
            else if (type == typeFind && (commandCurrent == -1 || commandCurrent == ruleCommandId))
            {
                // Store the data found
                *lengthFound = length;
                *ruleList = &dataList[offset + 1];
                *dataFound = data;
                *ruleFound = true;

                // If found in the expected command block then nothing more to look for
                if (commandCurrent == ruleCommandId)
                    break;
            }

            offset += length + 1;
        }
        while(type != configRuleDataTypeEnd);
    }
}

#define OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, type)                                                                   \
    bool ruleFound = false;                                                                                                        \
    int ruleData = 0;                                                                                                              \
    int ruleListSize = 0;                                                                                                          \
    void **ruleList = NULL;                                                                                                        \
                                                                                                                                   \
    optionRuleDataFind(type, ruleCommandId, optionRule[ruleOptionId].data, &ruleFound, &ruleData, &ruleList, &ruleListSize);

/***********************************************************************************************************************************
Command and option rule totals
***********************************************************************************************************************************/
int
cfgRuleCommandTotal()
{
    return sizeof(commandRule) / sizeof(CommandRule);
}

int
cfgRuleOptionTotal()
{
    return sizeof(optionRule) / sizeof(OptionRule);
}

/***********************************************************************************************************************************
Check that command and option ids are valid
***********************************************************************************************************************************/
void
cfgRuleCommandCheck(ConfigRuleCommand ruleCommandId)
{
    if (ruleCommandId < 0 || ruleCommandId >= cfgRuleCommandTotal())
        ERROR_THROW(AssertError, "command rule id %d invalid - must be >= 0 and < %d", ruleCommandId, cfgRuleCommandTotal());
}

void
cfgRuleOptionCheck(ConfigRuleOption ruleOptionId)
{
    if (ruleOptionId < 0 || ruleOptionId >= cfgRuleOptionTotal())
        ERROR_THROW(AssertError, "option rule id %d invalid - must be >= 0 and < %d", ruleOptionId, cfgRuleOptionTotal());
}

static void
cfgRuleCommandOptionCheck(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandCheck(ruleCommandId);
    cfgRuleOptionCheck(ruleOptionId);
}

/***********************************************************************************************************************************
Option allow lists
***********************************************************************************************************************************/
bool
cfgRuleOptionAllowList(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeAllowList);

    return ruleFound;
}

const char *
cfgRuleOptionAllowListValue(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, int valueId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeAllowList);

    if (valueId < 0 || valueId >= ruleListSize)
        ERROR_THROW(AssertError, "value id %d invalid - must be >= 0 and < %d", valueId, ruleListSize);

    return (char *)ruleList[valueId];
}

int
cfgRuleOptionAllowListValueTotal(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeAllowList);

    return ruleListSize;
}

// Check if the value matches a value in the allow list
bool
cfgRuleOptionAllowListValueValid(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, const char *value)
{
    if (value != NULL)
    {
        for (int valueIdx = 0; valueIdx < cfgRuleOptionAllowListValueTotal(ruleCommandId, ruleOptionId); valueIdx++)
            if (strcmp(value, cfgRuleOptionAllowListValue(ruleCommandId, ruleOptionId, valueIdx)) == 0)
                return true;
    }

    return false;
}

/***********************************************************************************************************************************
Allow range
***********************************************************************************************************************************/
bool
cfgRuleOptionAllowRange(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeAllowRange);

    return ruleFound;
}

double
cfgRuleOptionAllowRangeMax(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeAllowRange);

    return (double)(intptr_t)ruleList[1] / 100;
}

double
cfgRuleOptionAllowRangeMin(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeAllowRange);

    return (double)(intptr_t)ruleList[0] / 100;
}

/***********************************************************************************************************************************
Default value for the option
***********************************************************************************************************************************/
const char *
cfgRuleOptionDefault(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeDefault);

    if (ruleFound)
        return (char *)ruleList[0];

    return NULL;
}

/***********************************************************************************************************************************
Dependencies and depend lists
***********************************************************************************************************************************/
bool
cfgRuleOptionDepend(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeDepend);

    return ruleFound;
}

ConfigRuleOption
cfgRuleOptionDependOption(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeDepend);

    return (ConfigRuleOption)ruleData;
}

const char *
cfgRuleOptionDependValue(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, int valueId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeDepend);

    if (valueId < 0 || valueId >= ruleListSize)
        ERROR_THROW(AssertError, "value id %d invalid - must be >= 0 and < %d", valueId, ruleListSize);

    return (char *)ruleList[valueId];
}

int
cfgRuleOptionDependValueTotal(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeDepend);

    return ruleListSize;
}

// Check if the value matches a value in the allow list
bool
cfgRuleOptionDependValueValid(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, const char *value)
{
    if (value != NULL)
    {
        for (int valueIdx = 0; valueIdx < cfgRuleOptionDependValueTotal(ruleCommandId, ruleOptionId); valueIdx++)
            if (strcmp(value, cfgRuleOptionDependValue(ruleCommandId, ruleOptionId, valueIdx)) == 0)
                return true;
    }

    return false;
}

/***********************************************************************************************************************************
Get total indexed values for option
***********************************************************************************************************************************/
int
cfgRuleOptionIndexTotal(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);
    return optionRule[ruleOptionId].indexTotal;
}

/***********************************************************************************************************************************
Name of the option
***********************************************************************************************************************************/
const char *
cfgRuleOptionName(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);
    return optionRule[ruleOptionId].name;
}

/***********************************************************************************************************************************
Alternate name for the option -- generally used for deprecation
***********************************************************************************************************************************/
const char *
cfgRuleOptionNameAlt(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);

    OPTION_RULE_DATA_FIND(-1, ruleOptionId, configRuleDataTypeNameAlt);

    if (ruleFound)
        return (char *)ruleList[0];

    return NULL;
}

/***********************************************************************************************************************************
Can the option be negated?
***********************************************************************************************************************************/
bool
cfgRuleOptionNegate(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);
    return optionRule[ruleOptionId].negate;
}

/***********************************************************************************************************************************
Option prefix for indexed options
***********************************************************************************************************************************/
const char *
cfgRuleOptionPrefix(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);

    OPTION_RULE_DATA_FIND(-1, ruleOptionId, configRuleDataTypePrefix);

    if (ruleFound)
        return (char *)ruleList[0];

    return NULL;
}

/***********************************************************************************************************************************
Does the option need to be protected from showing up in logs, command lines, etc?
***********************************************************************************************************************************/
bool
cfgRuleOptionSecure(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);
    return optionRule[ruleOptionId].secure;
}

/***********************************************************************************************************************************
Is the option required
***********************************************************************************************************************************/
bool
cfgRuleOptionRequired(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);

    OPTION_RULE_DATA_FIND(ruleCommandId, ruleOptionId, configRuleDataTypeRequired);

    if (ruleFound)
        return ruleData;

    return optionRule[ruleOptionId].required;
}

/***********************************************************************************************************************************
Get option section
***********************************************************************************************************************************/
ConfigRuleSection
cfgRuleOptionSection(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);
    return optionRule[ruleOptionId].section;
}

/***********************************************************************************************************************************
Get option data type
***********************************************************************************************************************************/
int
cfgRuleOptionType(ConfigRuleOption ruleOptionId)
{
    cfgRuleOptionCheck(ruleOptionId);
    return optionRule[ruleOptionId].type;
}

/***********************************************************************************************************************************
Is the option valid for the command?
***********************************************************************************************************************************/
bool
cfgRuleOptionValid(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId)
{
    cfgRuleCommandOptionCheck(ruleCommandId, ruleOptionId);
    return optionRule[ruleOptionId].commandValid & (1 << ruleCommandId);
}
