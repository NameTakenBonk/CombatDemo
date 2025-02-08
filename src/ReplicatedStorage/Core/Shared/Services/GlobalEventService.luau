--!strict
export type SubscriptionTopic = {
    Name : string,
    Object : BindableEvent,
    Event : RBXScriptSignal,

    EventMetadata : {
        EventRate : number,
        NextUpdate : number,
        Automatic : boolean,
    },

    IsThreadLocked : boolean,
}

local OS_CLOCK = os.clock

local RS : RunService = game:GetService("RunService")

local Topics : {SubscriptionTopic} = {}
local AutomaticTopics : {SubscriptionTopic} = {}
local Service = {}

function Service.GetTopicFromName(topicName : string)
    local topicData : SubscriptionTopic?

    for _, td : SubscriptionTopic in Topics do
        if td.Name == topicName then
            topicData = td
        end
    end

    return topicData
end

function Service.PublishToTopic(topicName : string, args)
    local topicData : SubscriptionTopic? = Service.GetTopicFromName(topicName)
    assert(topicData, `No topic under name {topicName}`)

    topicData.Object:Fire(args)
end

function Service.MassPublish(topicNames, topicArgs)
    for id, topicName : string in topicNames do
        local args : any = topicArgs[id]
        Service.PublishToTopic(topicName, unpack(args))
    end
end

function Service.newTopic(topicName : string, isAutomatic : boolean)
    local topic : BindableEvent = Instance.new("BindableEvent")
    local threadLockingEvent : BindableEvent = Instance.fromExisting(topic)

    local eventMetadata
    if isAutomatic then
        eventMetadata =  {
            EventRate = 1 / 60,
            NextUpdate = 0,
            Automatic = isAutomatic,
        }
    end

    local topicData : SubscriptionTopic = {
        Name = topicName,
        Object = threadLockingEvent,
        Event = threadLockingEvent.Event,
        EventMetadata = eventMetadata :: any,
        IsThreadLocked = false
    }

    threadLockingEvent.Event:Connect(function(...)
        if topicData.IsThreadLocked then
            return warn(`Thread under that event is locked, please check the topic named {topicName}`)
        end
        
        topicData.IsThreadLocked = true
        topic:Fire(...)
        topicData.IsThreadLocked = false
    end)

    --We update these internally
    if isAutomatic then
        table.insert(AutomaticTopics, topicData)
    end

    table.insert(Topics, topicData)

    --Return ref so we can modify default data if needed
    return topicData, eventMetadata
end

function Service.SubscribeToTopic(topicName : string, onTrigger : (...any) -> (...any))
    local topicData : SubscriptionTopic? = Service.GetTopicFromName(topicName)
    assert(topicData, `No topic under name {topicName}`)

    return topicData.Event:Connect(onTrigger)
end

RS.Heartbeat:Connect(function(dt : number)
    for _, td : SubscriptionTopic in AutomaticTopics do
        local eventMeta = td.EventMetadata
        local canFire : boolean = eventMeta.NextUpdate < OS_CLOCK() and not td.IsThreadLocked
        if canFire then
            eventMeta.NextUpdate = OS_CLOCK() + eventMeta.EventRate
            td.Object:Fire(dt)
        end
    end
end)

return Service