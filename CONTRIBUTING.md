# CONTRIBUTING
How to write modules for TitanFall

## Writing Payloads
Please make sure all of the following guidelines are implemented into the payload:
1. The first line in your file must be a comment with a very brief description of what the payload
does.
2. The second line of the file should list all the function dependancies of the 
payload.
2. No output (stdin or stderr) should be created unless it is with the "LOG" command
3. All payloads should run in both SH and BASH
4. Payloads must follow the naming convention. See [Naming conventions](#naming-conventions)
5. Each payload needs a function that is named the _payload name_ in order to be
called by the dropper. This function should be considered the _main_ of your payload.
6. Payloads should handle error checking on their own and should not hold up the main program
7. Payloads should NEVER exit the program. Instead return out of the main function.

### Naming Conventions
1. The _payload name_ and _filename_ are different
2. Each payload name must be unique to the other payloads
3. Payload names should be lowercase
4. Each payload name must be one word with letters only. No spaces, underscores, or other characters.
5. The filename will be the payload name with at most __one__ file extension

### Directory Layout
Sub groups of payloads may be made within the "payloads" directory for organization
Folder names do not matter and are solely for the authors.

## Tips and Tricks
### Ordering Payloads
Each payload can be assigned a weight. The default weight is 50. The higher the weight, the higher the priority.
Payloads are run from greatest weight to least weight.
To specify the weight, add a comment to the top of the payload like so
```
# WEIGHT 99
```

### Suppressing output
If you suspect a command will generate output, prefix the command with `QUIET`.
Example
```
QUIET echo hi; # No output printed
```

Avoid using `&>/dev/null` as that will not work in SH

### Validating Commands
Avoid using `which` as it is system dependent.
To check if a program is on the system, try the following
```
QUIET command -v ncat;
if [ "$?" != "0" ]; then
    LOG 2 "ncat doesn't exist!";
    return 1;
fi
```
### If statements
In order to comply with SH if statements, use the following rules:
1. You __cannot__ have double brackets. e.g. `[[ 1 = 1 ]]`
2. You __cannot__ have double equal signs. e.g. `[ 1 == 1 ]`
3. A space must be left on the inside of the brackets. This is __invalid__ `[1 = 1]`
4. Always surround both sides of the operator in quotes. e.g `[ "1" = "$foo" ]`
5. If you need to compare two numbers, make sure you use the following Bourne comparisons rather
than traditional programming operators


| Operator | Bourne Operator | Example              |
|----------|-----------------|----------------------|
|`==`      |`=`              | `[ "1" = "$foo" ]`   |
|`!=`      |`!=`             | `[ "1" != "$foo" ]`  |
|`>=`      |`-ge`            | `[ "1" -ge "$foo" ]` |
|`<`       |`-lt`            | `[ "1" -lt "$foo" ]` |
|`>`       |`-gt`            | `[ "1" -gt "$foo" ]` |
|`<=`      |`-le`            | `[ "1" -le "$foo" ]` |
|`>=`      |`-ge`            | `[ "1" -ge "$foo" ]` |

A valid if statement should look like this:
```
foo="hello";
if [ "$foo" = "hi" ]; then
    LOG "hi foo!";
elif [ "$foo" = "hello" ]; then
    LOG "hello foo!";
else
    LOG "foo?";
fi
```

__Ternary Statements__ can be done in the following way
```
[ "$foo" = "$bar" ] && LOG 0 "TRUE" || LOG 2 "FALSE";
```

### Logging output
TitanFall will handle all the printing. When the dropper is generated, the program can either log
all message in color, without color, or no messages at all.

> If the dropper is generated with no output, LOG will display nothing. Do not try to circumvent
this

A successful message will be green if color is enabled
A pending message will be blue if color is enabled
An error message will be red if color is enabled
A warning message will be yellow
All other messages will be without color

To print success/in progress/error messages, use the LOG function in the following way:
```
> LOG 0 "Payload dropped!"
[+] Payload dropped

> LOG 1 "Uploading files..."
[*] Uploading files...

> LOG 2 "Error in program"
[-] Error in program

> LOG warn "This is a warning"
[!] This is a warning

> LOG "Plain old message"
Plain old message
```
