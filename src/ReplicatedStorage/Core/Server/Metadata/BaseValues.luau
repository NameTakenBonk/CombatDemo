--!strict
--[[
    I needed a way to add custom logic to base types like int, bool, byte, ect...
]]



local function newValue(valueType : string, value : any)
    local instanceType = Instance.new(valueType.."Value") :: any
    instanceType.Value = value
    return {
        CurrentValue = instanceType, 
        Type = valueType,
    }
end

local contract = {
   Integer = function(value : number)
        return newValue("Int", value)
   end,

   Float = function(value : number)
        return newValue("Number", value)
   end,

   Boolean = function(value : boolean)
        return newValue("Bool", value)
   end,

   GetValueInstance = function(object)
        return object.CurrentValue :: ValueBase
    end,

    ToString = function(object)
        return tostring(object.CurrentValue.Value)
    end,

    GetValue = function<T>(object) : T
        return (object.CurrentValue.Value :: any) :: T
    end,

    SetValue = function(object, newValue : any)
        object.CurrentValue.Value = newValue
        if object.CurrentValue.Value ~= newValue then
            error(`Value not set because wrong type was given! Value given: {newValue}, expected: {object.Type}`)
        end
    end
}

export type BaseType<T, E> = {
    CurrentValue : {
        Value : T,
    },

    ServiceContract : {
        GetValue : (object : any) -> T,
        SetValue : (object : any, newValue : T) -> unknown?,
        GetValueInstance : (object : any) -> E
    }
}
export type Boolean = BaseType<boolean, BoolValue>
export type Integer = BaseType<number, IntValue>
export type Float =   BaseType<number, NumberValue>

return contract