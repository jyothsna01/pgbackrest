/***********************************************************************************************************************************
Command and Option Configuration Rules
***********************************************************************************************************************************/
#ifndef CONFIG_RULE_H
#define CONFIG_RULE_H

#include "common/type.h"
#include "config/rule.auto.h"

/***********************************************************************************************************************************
Section enum - defines which sections of the config an option can appear in
***********************************************************************************************************************************/
typedef enum
{
    cfgRuleSectionCommandLine,                                      // command-line only
    cfgRuleSectionGlobal,                                           // command-line or in any config section
    cfgRuleSectionStanza,                                           // command-line of in any config stanza section
} ConfigRuleSection;

/***********************************************************************************************************************************
Auto-Generated Functions
***********************************************************************************************************************************/
int cfgRuleCommandTotal();
void cfgRuleCommandCheck(ConfigRuleCommand ruleCommandId);

bool cfgRuleOptionAllowList(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
int cfgRuleOptionAllowListValueTotal(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
bool cfgRuleOptionAllowListValueValid(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, const char *value);
const char *cfgRuleOptionAllowListValue(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, int valueId);
bool cfgRuleOptionAllowRange(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
double cfgRuleOptionAllowRangeMax(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
double cfgRuleOptionAllowRangeMin(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
void cfgRuleOptionCheck(ConfigRuleOption ruleOptionId);
const char *cfgRuleOptionDefault(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
bool cfgRuleOptionDepend(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
ConfigRuleOption cfgRuleOptionDependOption(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
int cfgRuleOptionDependValueTotal(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
bool cfgRuleOptionDependValueValid(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, const char *value);
const char *cfgRuleOptionDependValue(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId, int valueId);
int cfgRuleOptionIndexTotal(ConfigRuleOption ruleOptionId);
const char *cfgRuleOptionName(ConfigRuleOption ruleOptionId);
const char *cfgRuleOptionNameAlt(ConfigRuleOption ruleOptionId);
bool cfgRuleOptionNegate(ConfigRuleOption ruleOptionId);
const char *cfgRuleOptionPrefix(ConfigRuleOption ruleOptionId);
bool cfgRuleOptionRequired(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);
ConfigRuleSection cfgRuleOptionSection(ConfigRuleOption ruleOptionId);
bool cfgRuleOptionSecure(ConfigRuleOption ruleOptionId);
int cfgRuleOptionTotal();
int cfgRuleOptionType(ConfigRuleOption ruleOptionId);
bool cfgRuleOptionValid(ConfigRuleCommand ruleCommandId, ConfigRuleOption ruleOptionId);

#endif
