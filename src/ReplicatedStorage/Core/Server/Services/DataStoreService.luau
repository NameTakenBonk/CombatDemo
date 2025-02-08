--!strict
--[[
    Enhanced Custom Data Store Wrapper (Asynchronous Version)

    Layers:
        - MemCache: Ensures consistency across all game instances with fast reads and writes.
        - DiskStore: Provides eventual consistency to offload MemCache when records are too many or expired.
        - TombStore: Tracks all deleted records for lookup and logging.
]]

-- Services
local DataSetConfigs = require(game.ReplicatedStorage.Core.Server.Metadata.DataStoreConfigs)

local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local MemStoreService = game:GetService("MemoryStoreService")

-- Constants
local MAX_RETRIES = 5
local RETRY_BACKOFF_BASE = 2
local RETRY_BACKOFF_MAX = 30

-- Module
local Service = {}

-- Internal Data Connection Class
local DataConnection = {}
DataConnection.__index = DataConnection

-- Active Data Connections
local ActiveDataConnections = {}

-- Utility Functions

--[[
    Utility function for exponential backoff retries using coroutines.
    @param operation: The function to retry.
    @param retries: Number of allowed retries.
    @return: Success status and result or error message.
]]
local function RetryWithBackoffAsync(operation, retries)
    local attempt = 0
    while attempt < retries do
        attempt = attempt + 1
        local success, result : any = pcall(operation)
        if success then
            return true, result
        else
            local backoff = math.min(RETRY_BACKOFF_BASE ^ attempt, RETRY_BACKOFF_MAX)
            warn(string.format("Operation failed on attempt %d: %s. Retrying in %d seconds.", attempt, result, backoff))
            task.wait(backoff)
        end
    end
    return false, "Max retries exceeded."
end

-- DataConnection Methods

--[[
    Logs events for monitoring purposes.
    @param eventType: Type of the event (e.g., "GetAsync", "UpdateAsync").
    @param key: The key involved in the event.
    @param details: Additional details about the event.
]]
function DataConnection:LogEvent(eventType, key, details)
    print(string.format("[%s] Key: %s, Details: %s", eventType, key, details))
end

--[[
    Validates data before storing.
    @param data: The data to validate.
    @return: Boolean indicating if the data is valid.
]]
function DataConnection:ValidateData(data)
    if type(data) ~= "table" then
        return false
    end
    if data.TTL and type(data.TTL) ~= "number" then
        return false
    end
    -- Add more validation as needed
    return true
end

--[[
    Initializes subscriptions for synchronization across game instances.
]]
function DataConnection:Initialize()
    local success, err = pcall(function()
        MessagingService:SubscribeAsync("DataUpdates", function(message)
            local updatedKey = message.Data.key
            self:LogEvent("SyncUpdate", updatedKey, "Received update notification.")
            -- Invalidate the cached key to fetch the latest data next time
            self.MemCache:RemoveAsync(updatedKey)
        end)
    end)
    if not success then
        warn("Failed to subscribe to MessagingService: " .. err)
    end
end

--[[
    Retrieves data asynchronously with caching and fallback mechanisms.
    @param key: The key to retrieve.
    @return: The retrieved data or nil.
]]
function DataConnection:GetAsync<T>(key) : T?
    self:LogEvent("GetAsync", key, "Attempting to retrieve data.")

    local data : T? = nil

    -- Attempt to pull from MemCache with retries
    local memSuccess, memData = RetryWithBackoffAsync(function()
        return self.MemCache:GetAsync(key)
    end, MAX_RETRIES)

    if memSuccess and memData then
        self:LogEvent("GetAsync", key, "Data retrieved from MemCache.")
        data = memData :: T
    elseif not memSuccess then
        self:LogEvent("GetAsync", key, "Failed to retrieve data from MemCache after retries.")
    end

    if not data then
        -- Attempt to get from DiskStore with retries
        local diskSuccess, diskData = RetryWithBackoffAsync(function()
            return self.DiskStore:GetAsync(key)
        end, MAX_RETRIES)

        if diskSuccess and diskData then
            -- Validate data
            if not self:ValidateData(diskData) then
                self:LogEvent("GetAsync", key, "Invalid data format retrieved from DiskStore.")
                return nil
            end

            -- Check TTL and potentially remove expired data
            if diskData.TTL and diskData.TTL <= os.time() then
                self:LogEvent("GetAsync", key, "Data TTL expired. Initiating cleanup.")
                -- Clean up expired data asynchronously
                task.spawn(function()
                    self:SafeWriteToDiskAsync(key, function()
                        return nil -- TTL expired, remove data
                    end)
                end)
                return nil
            end

            -- Populate MemCache with retrieved data
            local cacheSuccess, cacheErr = pcall(function()
                self.MemCache:SetAsync(key, diskData, self.MemCacheTTL)
            end)
            if cacheSuccess then
                self:LogEvent("GetAsync", key, "Data cached in MemCache.")
            else
                warn(string.format("Failed to cache data in MemCache for key %s: %s", key, cacheErr))
            end

            data = diskData :: T
        else
            if not diskSuccess then
                self:LogEvent("GetAsync", key, "Failed to retrieve data from DiskStore after retries.")
            else
                self:LogEvent("GetAsync", key, "No data found for key.")
            end
        end
    end

    return data :: T?
end

--[[
    Writes updated data to DiskStore and TombStore with synchronization.
    @param key: The key to update.
    @param updateCallback: Function to update the data.
]]
function DataConnection:WriteToDiskAsync(key, updateCallback)
    local updatedData
    local success, err = pcall(function()
        self.DiskStore:UpdateAsync(key, function(oldData)
            updatedData = updateCallback(oldData)
            if self.DiskStoreTTL ~= -1 and updatedData then
                updatedData.TTL = os.time() + self.DiskStoreTTL
            end
            return updatedData
        end)
    end)
    if not success then
        error(string.format("WriteToDiskAsync failed for key %s: %s", key, err))
    end

    -- Validate data before storing
    if updatedData and not self:ValidateData(updatedData) then
        warn(string.format("Invalid data format for key %s: %s", key, HttpService:JSONEncode(updatedData)))
        return
    end

    -- Update TombStore with deletion log if data is removed
    if not updatedData then
        local saveTime = DateTime.now():ToIsoDate()
        local tombKey = string.format("%s_%s", saveTime, HttpService:GenerateGUID())
        local tombSuccess, tombErr = pcall(function()
            self.TombStore:UpdateAsync(key, function()
                return tombKey
            end)
        end)
        if tombSuccess then
            self:LogEvent("WriteToDiskAsync", key, "TombStore updated with deletion record.")
        else
            warn(string.format("Failed to update TombStore for key %s: %s", key, tombErr))
        end
    end
end

--[[
    Safely writes updated data to DiskStore and TombStore with retries and error handling.
    @param key: The key to update.
    @param updateCallback: Function to update the data.
    @return: Boolean indicating success.
]]
function DataConnection:SafeWriteToDiskAsync(key, updateCallback)
    local success, err = RetryWithBackoffAsync(function()
        self:WriteToDiskAsync(key, updateCallback)
    end, MAX_RETRIES)

    if success then
        -- Publish update to synchronize across instances asynchronously
        task.spawn(function()
            local publishSuccess, publishErr = pcall(function()
                MessagingService:PublishAsync("DataUpdates", { key = key })
            end)
            if publishSuccess then
                self:LogEvent("SafeWriteToDiskAsync", key, "Published update to MessagingService.")
            else
                warn(string.format("Failed to publish update to MessagingService for key %s: %s", key, publishErr))
            end
        end)
        return true
    else
        self:LogEvent("SafeWriteToDiskAsync", key, "Failed after retries: " .. err)
        return false
    end
end

--[[
    Updates data asynchronously in both MemCache and DiskStore with synchronization.
    @param key: The key to update.
    @param updateCallback: Function to update the data.
]]
function DataConnection:UpdateAsync(key, updateCallback)
    self:LogEvent("UpdateAsync", key, "Attempting to update data.")

    -- Update MemCache with retries asynchronously
    task.spawn(function()
        local memSuccess, memErr = RetryWithBackoffAsync(function()
            return self.MemCache:UpdateAsync(key, updateCallback, self.MemCacheTTL)
        end, MAX_RETRIES)

        if memSuccess then
            self:LogEvent("UpdateAsync", key, "MemCache updated successfully.")
        else
            self:LogEvent("UpdateAsync", key, "Failed to update MemCache: " .. memErr)
        end
    end)

    -- Safely write to DiskStore and TombStore asynchronously
    task.spawn(function()
        local diskSuccess = self:SafeWriteToDiskAsync(key, updateCallback)
        if diskSuccess then
            self:LogEvent("UpdateAsync", key, "DiskStore and TombStore updated successfully.")
        else
            self:LogEvent("UpdateAsync", key, "Failed to update DiskStore and TombStore.")
        end
    end)
end

--[[
    Retrieves the active data connection for a given set name.
    @param setName: The name of the data set.
    @return: The data connection or nil.
]]
function Service.GetDataConnection(setName) : typeof(DataConnection)
    assert( ActiveDataConnections[setName], `No store name found for {setName}`)
    return ActiveDataConnections[setName]
end

--[[
    Creates a new DataConnection instance.
    @param config: Configuration for the data set.
    @return: A new instance of DataConnection.
]]
export type DataConnection = typeof(DataConnection) & any
local function CreateDataConnection(config) : DataConnection
    local instance = setmetatable({
        MemCache = MemStoreService:GetSortedMap(config.MemCacheKey),
        DiskStore = DataStoreService:GetDataStore(config.DiskStoreKey),
        TombStore = DataStoreService:GetDataStore(config.TombStoreKey),
        MemCacheTTL = config.MemCacheTTL,
        DiskStoreTTL = config.DiskStoreTTL,
    }, DataConnection)
    instance:Initialize()

    return instance :: DataConnection
end

-- Initialize Data Connections
for setName, config in pairs(DataSetConfigs) do
    ActiveDataConnections[setName] = CreateDataConnection(config)
end

return Service