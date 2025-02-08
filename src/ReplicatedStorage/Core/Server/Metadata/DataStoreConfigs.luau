--!strict
export type DataSetConfig = {
    MemCacheTTL : number,
    DiskStoreTTL : number,

    MemCacheKey : string,
    DiskStoreKey : string,
    TombStoreKey : string,
}

local SecondsInMin = 60
local SecondsInHour = SecondsInMin * 60
local SecondsInDay = SecondsInHour * 24

local playState : string = "Experimental-Alpha"
local cfg : {[string] : DataSetConfig} = {}
cfg.PlayerStats = {
    MemCacheKey = `{playState}_PlayerCache`,
    DiskStoreKey = `{playState}_PlayerDisk`,
    TombStoreKey = `{playState}_PlayerTomb`,

    MemCacheTTL = SecondsInDay,
    DiskStoreTTL = -1,
}

return cfg