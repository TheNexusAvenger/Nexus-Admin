# Executor
Executes commands using Cmdr.<br>
Exists on the server and client.

## `string Executor:ExecuteCommand(string Command,Player? ReferencePlayer,object? Data)`
Executes a command. Authorization checks are performs
in the command if it was registered through Nexus Admin.

## `string Executor:ExecuteCommandWithPrefix(string Command,Player? ReferencePlayer,object? Data)`
Executes a command with prefixes. Authorization checks are performs
in the command if it was registered through Nexus Admin.

## `string Executor:ExecuteCommandWithOrWithoutPrefix(string Command,Player? ReferencePlayer,object? Data)`
Executes a command that may or may not have a prefix. Authorization
checks are performs in the command if it was registered through
Nexus Admin.