--Types for Nexus Admin.
--Since Nexus Admin is meant to be loaded at runtime, this file can be used independently to have types.
--!strict

--Nexus Instance
export type TypedEventConnection<T...> = {
    Connected: boolean,
    Fire: (TypedEventConnection<T...>, T...) -> (),
    Disconnect: (self: TypedEventConnection<T...>) -> (),
    Destroy: (self: TypedEventConnection<T...>) -> (),
}

export type TypedEvent<T...> = {
    Connect: (self: TypedEvent<T...>, Callback: (T...) -> ()) -> (TypedEventConnection<T...>),
    Once: (self: TypedEvent<T...>, Callback: (T...) -> ()) -> (TypedEventConnection<T...>),
    Fire: (self: TypedEvent<T...>, T...) -> (),
    Wait: (self: TypedEvent<T...>) -> (T...),
    Destroy: (self: TypedEvent<T...>) -> (),
}

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
    GetData: (self: CmdrCommandContext) -> (any),
    GetStore: (self: CmdrCommandContext, name: string) -> ({[any]: any}),
    SendEvent: (self: CmdrCommandContext, Player: Player, Event: string) -> (),
    BroadcastEvent: (self: CmdrCommandContext, Evnet: string, ...any) -> (),
    Reply: (self: CmdrCommandContext, Text: string, Color: Color3?) -> (),
    HasImplementation: (self: CmdrCommandContext) -> (boolean),
}

export type CmdrTypeDefinition = {
    DisplayName: string?,
    Prefixes: string?,
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
    Aliases: {string},
    Description: string,
    Group: string?,
    Args: {CmdrCommandArgument | (Context: CmdrCommandContext) -> (CmdrCommandArgument)},
    Data: ((Context: CmdrCommandContext, ...any) -> (any))?,
    ClientRun: ((Context: CmdrCommandContext, ...any) -> (any))?,
    AutoExec: {string}?,
}

export type CmdrRegistry = {
    Commands: {[string]: CmdrCommandDefinition},
    RegisterTypesIn: (self: CmdrRegistry, Container: Instance) -> (),
    RegisterType: (self: CmdrRegistry, Name: string, TypeDefinition: CmdrTypeDefinition) -> (),
    RegisterTypePrefix: (self: CmdrRegistry, Name: string, Union: string) -> (),
    RegisterTypeAlias: (self: CmdrRegistry, Name: string, Union: string) -> (),
    GetType: (self: CmdrRegistry, Name: string) -> (CmdrTypeDefinition?),
    GetTypeName: (self: CmdrRegistry, Name: string) -> (string),
    RegisterHooksIn: (self: CmdrRegistry, Container: Instance) -> (),
    RegisterCommandObject: (self: CmdrRegistry, Command: CmdrCommandDefinition) -> (),
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

--Nexus Feature Flags
export type NexusFeatureFlagsSource = {
    FeatureFlagChanged: RBXScriptSignal,
    GetFeatureFlag: (NexusFeatureFlagsSource, Name: string) -> any?,
    GetAllFeatureFlags: (NexusFeatureFlagsSource) -> {string},
    AddFeatureFlag: (NexusFeatureFlagsSource, Name: string, Value: any, Type: string?) -> nil,
    SetFeatureFlag: (NexusFeatureFlagsSource, Name: string, Value: any) -> nil,
    GetFeatureFlagChangedEvent: (NexusFeatureFlagsSource, Name: string) -> RBXScriptSignal,
    Destroy: (NexusFeatureFlagsSource) -> nil,
}

--Nexus Admin Data Types
export type NexusAdminCommandData = {
    Prefix: string? | {string}?,
    AdminLevel: number?,
    Category: string?,
    CommandGroup: string?,
    Arguments: {CmdrCommandArgument | (Context: CmdrCommandContext) -> (CmdrCommandArgument)}?,
    ExtraInfo: string?,
    Keyword: string? | {string}?,
    Run: ((Context: CmdrCommandContext, ...any) -> (string?)),
} & CmdrCommandDefinition

--Nexus Admin Classes
export type ApiTextList = {
    new: (Parent: Instance, TextSize: number, TextType: ("TextLabel" | "TextBox")?) -> (),
    EnableSearching: (self: ApiTextList, Filter: ((SearchTerm: string, Lines: {{[string]: any}}) -> ({{[string]: any}}))?) -> (),
    Move: (self: ApiTextList, Size: UDim2?, Position: UDim2?, AnchorPoint: Vector2?) -> (),
    AddLines: (self: ApiTextList, Lines: {string | {[string]: any}}, Order: ("NewestFirst" | "OldestFirst")?) -> (),
    SetLines: (self: ApiTextList, Lines: {string | {[string]: any}}) -> (),
    DisplayLogs: (self: ApiTextList, Logs: Logs, Order: ("NewestFirst" | "OldestFirst")?) -> (),
    Destroy: (self: ApiTextList) -> (),
}

export type ApiWindow = {
    new: () -> (ApiWindow),
    TextHeight: number,
    ContentsAdorn: Frame,
    EnableResizing: (self: ApiWindow, MinWidth: number?, MinHeight: number?, MaxWidth: number?, MaxHeight: number?) -> (),
    EnableClosing: (self: ApiWindow, OnClose: (() -> ())?) -> (),
    EnableRefreshing: (self: ApiWindow, OnRefresh: () -> ()) -> (),
    AddTextList: (self: ApiWindow, TextType: ("TextLabel" | "TextBox")?) -> (ApiTextList),
    SetTitle: (self: ApiWindow, Name: string) -> (),
    SetDisplayOrder: (self: ApiWindow, DisplayOrder: number) -> (),
    SetRelativeSize: (self: ApiWindow, RelativeX: number, RelativeY: number) -> (),
    Show: (self: ApiWindow, InitialPosition: UDim2?, InitialAnchorPoint: Vector2?, StartSide: Enum.NormalId?) -> (),
    Close: (self: ApiWindow) -> (),
    Destroy: (self: ApiWindow) -> (),
}

--Nexus Admin Modules
export type Authorization = {
    new: (Configuration: Configuration) -> (Authorization),

    AdminLevelChanged: TypedEvent<Player>,
    GetAdminLevel: (self: Authorization, Player: Player) -> number,
    IsPlayerAuthorized: (self: Authorization, Player: Player, AdminLevel: number) -> boolean,
    YieldForAdminLevel: (self: Authorization, Player: Player) -> (number),
    SetAdminLevel: (self: Authorization, Player: Player, AdminLevel: number) -> (),
}

export type ServerAuthorization = {
    SetAdminLevel: (self: ServerAuthorization, Player: Player, AdminLevel: number) -> (),
    EvaluateAdminLevelAsync: (self: ServerAuthorization, UserId: number) -> number,
} & Authorization

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
    AdminNames: {[number]: string},
    GroupAdminLevels: {[number]: {[number]: number}},
    BannedUsers: {[number]: string | boolean},
    CommandConfigurations: {
        DefaultServerLockAdminLevel: number,
        PersistentBanImmuneLevel: number,
        [string]: any,
    },
    CommandLevelOverrides: {[string]: {[string]: number}},
    FeatureFlagOverrides: {[string]: any},
    GetRaw: (self: Configuration) -> ({[string]: any}),
    GetCommandAdminLevel: (self: Configuration, Category: string, Command: string) -> (number),
}

export type Executor = {
    new: (Cmdr: Cmdr, Registry: Registry) -> (Executor),

    Unescape: (self: Executor, Command: string) -> (string),
    ExecuteCommand: (self: Executor, Command: string, ReferencePlayer: Player?, Data: any?) -> (string),
    ExecuteCommandWithPrefix: (self: Executor, Command: string, ReferencePlayer: Player?, Data: any?) -> (string),
    ExecuteCommandWithOrWithoutPrefix: (self: Executor, Command: string, ReferencePlayer: Player?, Data: any?) -> (string),
    SplitCommands: (self: Executor, Command: string, Separator: string) -> ({string}),
}

export type Filter = {
    new: () -> Filter,

    EscapeRichText: (self: Filter, String: string) -> (string),
}

export type FilterServer = {
    new: () -> FilterServer,

    FilterString: (self: Filter, String: string, PlayerFrom: Player, PlayerTo: Player?) -> (string),
    FilterStringForPlayers: (self: Filter, String: string, PlayerFrom: Player, PlayersTo: {Player}) -> ({[Player]: string}),
} & Filter

export type Logs = {
    new: (MaxLogs: number?) -> (Logs),

    MaxLogs: number,
    LogAdded: TypedEvent<any>,
    GetLogs: (self: Logs) -> ({any}),
    Add: (self: Logs, Log: any) -> (),
    Destroy: (self: Logs) -> (),
}

export type LogsRegistry = {
    RegisterLogs: (self: LogsRegistry, LogName: string, Logs: Logs, MinimumAdminLevel: number) -> (),
    GetLogs: (self: LogsRegistry, LogName: string) -> (Logs),
}

export type LogsRegistryClient = {
    new: (NexusAdminRemotes: Folder) -> (LogsRegistryClient),
} & LogsRegistry

export type LogsRegistryServer = {
    new: (Authorization: Authorization, NexusAdminRemotes: Folder) -> (LogsRegistryServer),
} & LogsRegistry

export type MessagesClient = {
    new: (NexusAdminRemotes: Folder) -> MessagesClient,

    DisplayMessage: (self: MessagesClient, TopText: string, Message: string, DisplayTime: number?) -> (),
    DisplayHint: (self: MessagesClient, Message: string, DisplayTime: number?) -> (),
    DisplayNotification: (self: MessagesClient, TopText: string, Message: string, DisplayTime: number?) -> (),
}

export type MessagesServer = {
    new: (NexusAdminRemotes: Folder) -> MessagesServer,

    DisplayMessage: (self: MessagesServer, Player: Player, TopText: string, Message: string, DisplayTime: number?) -> (),
    DisplayHint: (self: MessagesServer, Player: Player, Message: string, DisplayTime: number?) -> (),
    DisplayNotification: (self: MessagesServer, Player: Player, TopText: string, Message: string, DisplayTime: number?) -> (),
}

export type Registry = {
    new: (Authorization: Authorization, Configuration: Configuration, Messages: MessagesServer | MessagesClient, Cmdr: Cmdr, NexusAdminRemotes: Folder) -> (Registry),

    GetReplicatableCmdrData: (self: Registry, CommandData: NexusAdminCommandData) -> (NexusAdminCommandData),
    PerformBeforeRun: (self: Registry, CommandContext: CmdrCommandContext) -> (string?),
    CreateRunMethod: (self: Registry, CommandData: NexusAdminCommandData) -> (CmdrCommandContext, ... any) -> (string?),
    LoadCommand: (self: Registry, CommandData: NexusAdminCommandData) -> (),
    AddEnumType: (self: Registry, Name: string, Options: {string}) -> (),
}

export type RegistryServer = {
    new: (Cmdr: Cmdr, Configuration: Configuration, Authorization: Authorization, Messages: MessagesServer, Logs: Logs, Time: Time, Filter: Filter, NexusAdminRemotes: Folder) -> (RegistryServer),
} & Registry

export type Replicator = {
    new: () -> Replicator,

    GiveScriptToPlayer: (self: Replicator, Player: Player, Script: BaseScript) -> (),
    GiveStarterScript: (self: Replicator, Script: BaseScript) -> (),
}

export type Time = {
    GetTimeString: (self: Time, Time: number?) -> (string),
    GetDateTimeString: (self: Time, Time: number?) -> (string),
    SecondsToDuration: (self: Time, Seconds: number) -> (string)
}

export type Window = {
    CreateWindow: (self: Window, TitleName: string) -> (ApiWindow),
}

--Nexus Admin API.
export type NexusAdminApi = {
    Types: {
        NexusAdminPlayers: {
            RegisterShortHand: (self: any, Name: string | {string}, Callback: (Text: string, Executor: Player, Players: {Player}) -> ({Player})) -> (),
            RegisterPatternShortHand: (self: any, Name: string | {string}, Callback: (Text: string, Executor: Player, Players: {Player}) -> ({Player})) -> (),
        },
        [any]: any,
    },
    CommandData: {[any]: any},
    Version: string,
    VersionNumberId: number,
    CmdrVersion: string,
    EventContainer: Folder,
    AdminItemContainer: Folder,
    Cmdr: Cmdr,
    Configuration: Configuration,
    Authorization: Authorization,
    Filter: Filter,
    Messages: MessagesServer | MessagesClient,
    Registry: Registry,
    LogsRegistry: LogsRegistry,
    Executor: Executor,
    FeatureFlags: NexusFeatureFlagsSource,
    Time: Time,
}

export type NexusAdminApiClient = {
    Messages: MessagesClient,
    Window: Window,
} & NexusAdminApi

export type NexusAdminApiServer = {
    Filter: FilterServer,
    Messages: MessagesServer,
    Replicator: Replicator,
    Logs: Logs,
    Authorization: ServerAuthorization,
    GetAdminLoaded: (self: NexusAdminApiServer) -> (boolean),
} & NexusAdminApi



return true
