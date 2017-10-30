# pgBackRest <br/> Coding Standards

## Introduction

!!!These are the C coding standards, blah, blah, blah.

## Standards

!!!These are the C coding standards, blah, blah, blah.

### indentation

Indentation is four spaces - no tabs.

### Naming

#### Variables

Variable names use camel case with the first letter lower-case.

- `stanzaName` - the name of the stanza

- `nameIdx` - loop variable for iterating through a list of names

Variable names should be descriptive. Avoid `i`, `j`, etc.

#### Types

Type names use camel case with the first letter upper case:

`typedef struct MemContext <...>`

`typedef enum {<...>} ErrorState;`

#### Constants

Two ways to do constants:

- #define should be all caps with `_`

- Enums follow the same case rules as variables. They are strongly typed so this shouldn't present any confusion.

#### Macros

Macro names should always be upper-case with underscores between words. However, these types of macros should be avoided whenever possible as they make code less clear and test coverage harder to measure.

Should follow the format:
```
#define MACRO(paramName1, paramName2)   \
    <code>
```
If the macro defines a block it should look like:
```
#define MACRO(paramName1, paramName2)   \
{                                       \
    <code>                              \
}
```
Continuation characters should all be aligned at column 132 (unlike the examples above that have been shortened for display purposes.

To avoid conflicts, variables in a macro will be named `[macro name]_[var name]`, e.g. `TEST_RESULT_resultExpected`. Variables that need to be accessed in wrapped code should be provided accessor macros.

#### Begin / End

Rather than `Start` / `Finish`, etc.

#### New / Free

Rather than `Create` / `Destroy`, etc.

### Formatting

#### Line Wrapper

!!!

#### Braces

C allows braces to be excluded for a single statement. However, braces should be used when the control statement (if, while, etc.) spans more than one line or the statement to be executed spans more than one line.
```
if (condition)
    return value;
```
```
if (conditionThatUsesEntireLine1 &&
    conditionThatUsesEntireLine2)
{
    return value;
}
```
```
if (condition)
{
    return
        valueThatUsesEntireLine1 &&
        valueThatUsesEntireLine2;
}
```
Braces needed when the if is more than one line.

## Language Elements

### Data Types

Don't get exotic - use the simplest type that will work.

Use `int` for general cases. `int` will be at least 32 bits. When not using `int` use one of the defined types.

### Macros

Don't use a macro when a function could be used instead. Macros make it hard to measure code coverage.

### Objects

Object oriented programming is used extensively. Object pointer is always referred to as `this`.

## Testing

### Uncoverable/Uncovered Code

Code coverage is an important part of !!!.

#### Uncoverable Code

The `uncoverable` keyword marks code that can never be covered. For instance, a function that never returns because it always throws a error. Uncoverable code should be rare to non-existent outside the common libraries and test code.
```
}   // {uncoverable - function throws error so never returns}
```
Subsequent code that is uncoverable for the same reason is marked with `// {+uncoverable}`.

#### Uncovered Code

Marks code that is not tested for one reason or another. This should be kept to a minimum and an excuse given for each instance.
```
exit(EXIT_FAILURE); // {uncoverable - test harness does not support non-zero exit}
```
Subsequent code that is uncovered for the same reason is marked with `// {+uncovered}`.
