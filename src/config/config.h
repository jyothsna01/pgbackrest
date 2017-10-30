/***********************************************************************************************************************************
Command and Option Configuration
***********************************************************************************************************************************/
#ifndef CONFIG_H
#define CONFIG_H

#include "common/type.h"
#include "config/rule.h"

#include "config/config.auto.h"

/***********************************************************************************************************************************
Functions
***********************************************************************************************************************************/
int cfgCommandId(const char *commandName);
const char *cfgCommandName(ConfigCommand commandId);
ConfigRuleCommand cfgCommandRuleIdFromId(ConfigCommand commandId);
int cfgCommandTotal();

int cfgOptionId(const char *optionName);
ConfigOption cfgOptionIdFromRuleId(ConfigRuleOption ruleOptionId, int index);
int cfgOptionIndex(ConfigOption optionId);
int cfgOptionIndexTotal(ConfigOption ruleOptionId);
const char *cfgOptionName(ConfigOption optionId);
ConfigRuleOption cfgOptionRuleIdFromId(ConfigOption optionId);
int cfgOptionTotal();

#endif
