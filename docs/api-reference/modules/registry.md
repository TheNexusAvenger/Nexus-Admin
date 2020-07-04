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