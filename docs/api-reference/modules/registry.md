# Registry
Regisers commands to be able to be run.<br>
Exists on the server and client.

## `void Registry:LoadCommand(table CommandData)`
Loads a command.

!!! note
    If called on the server, the command will be registered on
    the client without a `Run` function. Commands only need
    to be registered on the client if they have a client-side
    `Run` or `ClientRun` method.

## `void Registry:AddEnumType(string Name, table Options)`
Adds an enum type (list of string options). Can be re-called to
change the options.

!!! warning
    The registered name must follow the Cmdr restrictions. It
    must start with a lowercase character and use only alphanumeric
    characters.

!!! info
    Registered enums will register 2 types: 1 singular and 1 multiple.
    For example, if the name is registered as `testEnum`, both `testEnum`
    and `testEnums` will be registered.