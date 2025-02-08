--!strict
local Util = {}

function Util.MakeTableReadOnly(tbl: any): any
    -- Create a new metatable for the proxy
    local mt = {
        -- __index allows read access to the original table
        __index = tbl,

        -- __newindex intercepts all write attempts and throws an error
        __newindex = function(_, key, _)
            error("Attempt to modify a read-only table", 2)
        end,

        -- Prevent further modification of the metatable itself
        __metatable = "Locked"
    }

    -- Create the proxy table with the defined metatable
    local proxy = setmetatable({}, mt)

    -- Recursively make all subtables read-only
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            tbl[key] = Util.MakeTableReadOnly(value)
        end
    end

    return proxy
end

return Util