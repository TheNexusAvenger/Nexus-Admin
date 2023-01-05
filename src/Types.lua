--[[
TheNexusAvenger

Types for Nexus Admin.
Since Nexus Admin is meant to be loaded at runtime, this file can be use independently to have types.
--]]

--Nexus Instance
export type NexusObject = {
    class: {[string]: any},
    object: NexusObject,
    super: NexusObject,
    ClassName: string,
    [string]: any,

    new: () -> (NexusObject),
    Extend: (self: NexusObject) -> (NexusObject),
    SetClassName: (self: NexusObject, ClassName: string) -> (NexusObject),

    InitializeSuper: (...any) -> (),
    IsA: (self: NexusObject, ClassName: string) -> (boolean),
}

export type NexusConnection<T...> = {
    new: (Event: NexusEvent<T...>, ConnectionFunction: (T...) -> ()) -> (NexusConnection<T...>),
    Extend: (self: NexusConnection<T...>) -> (NexusConnection<T...>),

    Connected: boolean,
    Fire: (NexusEvent<T...>, T...) -> (),
    Disconnect: () -> (),
} & NexusObject

export type NexusEvent<T...> = {
    new: () -> (NexusEvent<T...>),
    Extend: (self: NexusEvent<T...>) -> (NexusEvent<T...>),

    Connect: (self: NexusEvent<T...>, Callback: (T...) -> ()) -> (NexusConnection<T...>),
    Fire: (self: NexusEvent<T...>, T...) -> (),
    Disconnect: (self: NexusEvent<T...>) -> (),
} & NexusObject

--Cmdr
export type CmdrArgumentContext = {
    Command: CmdrCommandContext,
    Name: string,
    Type: CmdrTypeDefinition,
    Required: boolean,
    Executor: Player,
    RawValue: string,
    RawSegments: {string},
    Prefix: string,

    GetValue: (self: CmdrArgumentContext) -> (any),
    GetTransformedValue: (self: CmdrArgumentContext, Segment: number) -> (...any),
}

export type CmdrCommandContext = {
    Cmdr: Cmdr,
    Dispatcher: CmdrDispatcher,
    Name: string,
    Alias: string,
    RawText: string,
    Group: string,
    State: {[any]: any},
    Aliases: {string},
    Description: string,
    Executor: Player,
    RawArguments: {string},
    Arguments: {CmdrArgumentContext},
    Response: string?,

    GetArgument: (self: CmdrCommandContext, number) -> (CmdrArgumentContext),
    GetData: (self: CmdrCommandContext) -> (),
    GetStore: (self: CmdrCommandContext, name: string) -> ({[any]: any}),
    SendEvent: (self: CmdrCommandContext, Player: Player, Event: string) -> (),
    BroadcastEvent: (self: CmdrCommandContext, Evnet: string, ...any) -> (),
    Reply: (self: CmdrCommandContext, Text: string, Color: Color3?) -> (),
    HasImplementation: (self: CmdrCommandContext) -> (boolean),
}

export type CmdrTypeDefinition = {
    DisplayName: string,
    Prefixes: string,
    Transform: (<T>(RawText: string, Exeuctor: Player) -> (T))?,
    Validate: (<T>(Value: T) -> (boolean, string?))?,
    ValidateOnce: (<T>(Value: T) -> (boolean, string?))?,
    Autocomplete: (<T>(Value: T) -> ({string}, {IsPartial: boolean?}?))?,
    Parse: <T>(Value: T) -> (any),
    Default: ((Player: Player) -> (string?))?,
    Listable: boolean?,
}

export type CmdrCommandArgument = {
    Type: string | CmdrTypeDefinition,
    Name: string,
    Description: string,
    Optional: boolean?,
    Default: any?,
}

export type CmdrCommandDefinition = {
    Name: string,
    Aliases: {string}?,
    Description: string,
    Group: string?,
    Args: {CmdrCommandArgument | (Context: CmdrCommandContext) -> (CmdrCommandArgument)},
    Data: ((Context: CmdrCommandContext, ...any) -> (any))?,
    ClientRun: ((Context: CmdrCommandContext, ...any) -> (any))?,
    AutoExec: {string}?,
}

export type CmdrRegistry = {
    RegisterTypesIn: (self: CmdrRegistry, Container: Instance) -> (),
    RegisterType: (self: CmdrRegistry, Name: string, TypeDefinition: CmdrTypeDefinition) -> (),
    RegisterTypePrefix: (self: CmdrRegistry, Name: string, Union: string) -> (),
    RegisterTypeAlias: (self: CmdrRegistry, Name: string, Union: string) -> (),
    GetType: (self: CmdrRegistry, Name: string) -> (CmdrTypeDefinition?),
    GetTypeName: (self: CmdrRegistry, Name: string) -> (string),
    RegisterHooksIn: (self: CmdrRegistry, Container: Instance) -> (),
    RegisterCommandsIn: (self: CmdrRegistry, Container: Instance, Filter: ((Command: CmdrCommandDefinition) -> (boolean))?) -> (),
    RegisterCommand: (self: CmdrRegistry, CommandScript: ModuleScript, CommandServerScript: ModuleScript?, Filter: ((Command: CmdrCommandDefinition) -> (boolean))?) -> (),
    RegisterDefaultCommands: (self: CmdrRegistry, {string} | (Command: CmdrCommandDefinition) -> (boolean)) -> (),
    GetCommand: (self: CmdrRegistry, Name: string) -> (CmdrCommandDefinition?),
    GetCommands: (self: CmdrRegistry) -> ({CmdrCommandDefinition}),
    GetCommandNames: (self: CmdrRegistry) -> ({string}),
    RegisterHook: (self: CmdrRegistry, HookName: "BeforeRun" | "AfterRun", Callback: (Context: CmdrCommandContext) -> (string?), Priority: number?) -> (),
    GetStore: (self: CmdrRegistry, Name: string) -> ({[any]: any}),
}

export type CmdrDispatcher = {
    Cmdr: Cmdr,
    Run: (self: CmdrDispatcher, ...string) -> string,
    EvaluateAndRun: (self: CmdrDispatcher, CommandText: string, Executor: Player?, Options: {Data: any?, IsHuman: boolean}?) -> string,
    GetHistory: (self: CmdrDispatcher) -> {string},
}

export type CmdrUtil = {
    MakeDictionary: <T>(Array: {T}) -> ({[T]: true}),
    Map: <T, U>(Array: {T}, Mapper: (Value: T, Index: number) -> U) -> ({U}),
    Each: <T, U>(Mapper: (Value: T) -> (U), ...T) -> (...U),
    MakeFuzzyFinder: (Set: {string} | {Instance} | {Enum} | {{Name: string}} | Instance) -> ((Text: string, ReturnFirst: boolean?) -> (any)),
    GetNames: (Instances: {{Name: string}}) -> ({string}),
    SplitStringSimple: (Text: string, Separator: string) -> ({string}),
    SplitString: (Text: string, Max: number?) -> ({string}),
    TrimString: (Text: string) -> (string),
    GetTextSize: (Text: string, Label: TextLabel, Size: Vector2?) -> (Vector2),
    MakeEnumType: (Type: string, Values: {string | {{Name: string}}}) -> (CmdrTypeDefinition),
    MakeListableType: (Type: CmdrTypeDefinition, Override: {[any]: string}?) -> (CmdrTypeDefinition),
    SplitPrioritizedDelimeter: (Text: string, Delimeters: {string}) -> ({string}),
    SubstituteArgs: (Text: string, Replace: {string} | {[string]: string} | (Var: string) -> string) -> string,
    RunEmbeddedCommands: (Dispatcher: CmdrDispatcher, CommandString: string) -> (string),
    EmulateTabstops: (Text: string, TabWidth: number) -> (string),
    ParseEscapeSequences: (Text: string) -> (string),
}

export type Cmdr = {
    Registry: CmdrRegistry,
    Dispatcher: CmdrDispatcher,
    Util: CmdrUtil,
}

--Nexus Admin Data Types
export type NexusAdminCommandData = {

}

--Nexus Admin Modules
export type Authorization = {
    new: (Configuration: Configuration) -> (Authorization),

    AdminLevelChanged: NexusEvent<Player>,
    GetAdminLevel: (self: Authorization, Player: Player) -> number,
    IsPlayerAuthorized: (self: Authorization, Player: Player, AdminLevel: number) -> boolean,
    YieldForAdminLevel: (self: Authorization, Player: Player) -> (number),
    SetAdminLevel: (self: Authorization, Player: Player, AdminLevel: number) -> (),
}

export type Configuration = {
    new: (ConfigurationTable: {[string]: any}) -> (Configuration),

    Version: string,
    VersionNumberId: number,
    CmdrVersion: string,
    RawConfiguration: {[string]: any},
    CommandPrefix: string,
    ActivationKeys: {Enum.KeyCode},
    DefaultAdminLevel: number,
    AdministrativeLevel: number,
    BuildUtilityLevel: number,
    BasicCommandsLevel: number,
    UsefulFunCommandsLevel: number,
    FunCommandsLevel: number,
    PersistentCommandsLevel: number,
    Admins: {[number]: number},
    GroupAdminLevels: {[number]: {[number]: number}},
    BannedUsers: {[number]: string | boolean},
    CommandLevelOverrides: {[string]: {[string]: number}},
    FeatureFlagOverrides: {[string]: any},
    GetRaw: (self: Configuration) -> ({[string]: any}),
    GetCommandAdminLevel: (Category: string, Command: string) -> (number),
}

export type Executor = {
    new: (Cmdr: Cmdr, Registry: Registry) -> (Executor),

    Unescape: (self: Executor, Command: string) -> (string),
    ExecuteCommand: (self: Executor, Command: string, ReferencePlayer: Player, Data: any?) -> (string),
    ExecuteCommandWithPrefix: (self: Executor, Command: string, ReferencePlayer: Player, Data: any?) -> (string),
    ExecuteCommandWithOrWithoutPrefix: (self: Executor, Command: string, ReferencePlayer: Player, Data: any?) -> (string),
    SplitCommands: (Command: string, Separator: string) -> ({string}),
}

export type Filter = {
    new: (NexusAdminRemotes: Folder) -> Filter,

    FilterString: (self: Filter, String: string, PlayerFrom: Player, PlayerTo: Player?) -> (string),
    FilterStringForPlayers: (self: Filter, String: string, PlayerFrom: Player, PlayersTo: {Player}) -> ({[Player]: string}),
}

export type Logs = {
    new: (MaxLogs: number?) -> (Logs),

    MaxLogs: number,
    LogAdded: NexusEvent<any>,
    GetLogs: (self: Logs) -> ({any}),
    Add: (self: Logs, Log: any) -> (),
    Destroy: (self: Logs) -> (),
}

export type Registry = {
    LoadCommand: (self: Registry, CommandData: NexusAdminCommandData) -> (),
    SetUpEnumValue: (self: Registry, ChildValue: StringValue) -> (),
}

export type Time = {
    GetTimeString: (self: Time, Time: number?) -> (string),
}



return true