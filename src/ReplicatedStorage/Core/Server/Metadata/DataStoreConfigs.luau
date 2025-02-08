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
cfg.PlayerLeaderstats = {
    MemCacheKey = `{playState}_PlayerStatCache`,
    DiskStoreKey = `{playState}_PlayerStatDisk`,
    TombStoreKey = `{playState}_PlayerStatTomb`,

    MemCacheTTL = SecondsInDay,
    DiskStoreTTL = -1,
}

cfg.PlayerPurchaseStore = {
    MemCacheKey = `{playState}_PlayerPurchaseCache`,
    DiskStoreKey = `{playState}_PlayerPurchaseDisk`,
    TombStoreKey = `{playState}_PlayerPurchaseTomb`,

    MemCacheTTL = SecondsInDay,
    DiskStoreTTL = -1,
}

return cfg