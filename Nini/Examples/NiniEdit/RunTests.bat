@ECHO off

REM Runs all the tests for the NiniEdit program.  
REM Usage: RunTests.bat Tests\[CONFIG FILE]
REM The test files are in the Test directory
REM All tests are run in verbose mode

SET PROGRAM=Bin\DotNet\Release\NiniEdit.exe --verbose
REM SET PROGRAM=mono Bin\Mono\Release\NiniEdit.exe --verbose

ECHO ****** Test: Lists usage ******
%PROGRAM% --help

ECHO ****** Test: Prints version ******
%PROGRAM% -V %1

ECHO ****** Test: Lists configs ******
%PROGRAM% -l %1

ECHO ****** Test: Adds config "TestConfig" ******
%PROGRAM% --add TestConfig %1
%PROGRAM% -l %1

ECHO ****** Test: Removes config "TestConfig" ******
%PROGRAM% --remove TestConfig %1
%PROGRAM% -l %1

ECHO ****** Test: Lists keys in "Logging" ******
%PROGRAM% --config Logging --list-keys %1

ECHO ****** Test: Sets key "TestKey" ******
%PROGRAM% --config Logging --set-key TestKey,TestValue %1
%PROGRAM% --config Logging --list-keys %1

ECHO ****** Test: Prints "TestKey" value: "TestValue" ******
%PROGRAM% --config Logging --get-key TestKey %1

ECHO ****** Test: Removes key "TestKey" ******
%PROGRAM% --config Logging --remove-key TestKey %1
%PROGRAM% --config Logging --list-keys %1
