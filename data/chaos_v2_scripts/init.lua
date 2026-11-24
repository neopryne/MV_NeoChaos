local MOD_NAME = "Neo/Chaos"
local MOD_NAME_INTERNAL = "neo_chaos"
if not mods.multiverse then
    error("Multiverse was not patched, or was patched after "..MOD_NAME..".  It will be broken.")
end

--This is the minimal code you need for an init file of this style, which accounts for multiple contributers to a table.
local function initIfNil(modTable, name)
    if not modTable then
        modTable = {}
        modTable.name = name
    end
    if not modTable.owners then
        modTable.owners = {}
    else
        print(MOD_NAME.." loading "..name..", previously modified by: ")
        for owner in modTable.owners do
            print(owner)
        end
    end
    table.insert(modTable.owners, MOD_NAME_INTERNAL)
    return modTable
end


mods.neo_chaos = initIfNil(mods.neo_chaos, "neo_chaos")