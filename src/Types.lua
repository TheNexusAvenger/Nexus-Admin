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

--Nexus Admin
export type Logs = {
    new: (MaxLogs: number?) -> (Logs),

    MaxLogs: number,
    LogAdded: NexusEvent<any>,
    GetLogs: (self: Logs) -> ({any}),
    Add: (self: Logs, Log: any) -> (),
    Destroy: (self: Logs) -> (),
}

return true