


--[[
when loading these, do not run their give_aug code, as that's already been done when they were created this run.
names are case insensitive

loading this will be annoying-- span multiple files.
]]

local lwl = mods.lightweight_lua



local function NOOP() end






--#region Asshole
local function applyAsshole(locationEvent)
    local heft = .67
    locationEvent.text.data = lwl.trans1337(locationEvent.text.data)

    for choice in vter(locationEvent:GetChoices()) do
        choice.text.data = lwl.trans1337(choice.text.data, heft)
    end
end

function registerAssholeCode()
    lwl.safe_script.on_internal_event("NC_ASSHOLE", Defines.InternalEvents.PRE_CREATE_CHOICEBOX, function(locationEvent)
        applyAsshole(locationEvent)
    end)
end

function deregisterAsshole()
    lwl.safe_script.on_internal_event("NC_ASSHOLE", Defines.InternalEvents.PRE_CREATE_CHOICEBOX, function(locationEvent) end)
end
--#endregion Asshole

--#region Tyredo
local function applyTyredo()
    --If you ever don't have a bird in your crew, you die.
end

local function registerTyredoCode()
    --Give bird if you don't have one.
    lwl.safe_script.on_internal_event("NC_ASSHOLE", Defines.InternalEvents.ON_TICK, function()
        applyTyredo()
    end)
end
--#endregion Tyredo

--#region Chompski
local function applyChompski()
    --give the gnome if you don't have one already.  and set chaos flags.
end

local function registerChompskiCode()
    applyChompski()
end
--#endregion Chompski

--#region Nai

local function registerNaiCode()
    Hyperspace.ships.player.ship.hullIntegrity.second = 15
end
--#endregion Nai

local NAME_ASSHOLE = {names={"ass", "asshole"}, lua=registerAssholeCode, message="All this time, and you still can't get his name right?  Maybe this will help...", effect="Immersive education. :)"}
local NAME_A55H0L3 = {names={"a55", "a55h0l3"}, lua=NOOP, message="Since you're such a big, tough guy, you won't mind if all the other robots are too, right? :)", effect="Triple drone boosters on enemy ships."}
local NAME_NAI = {names={"nai", "naimeron"}, lua=registerNaiCode, message="I see.  Then you must desire... to suffer.", effect="Max hull set to 15."}

mods.neo_chaos.EMPOWERED_NAMES = {NAME_A55H0L3, NAME_ASSHOLE, NAME_NAI}


function mods.neo_chaos.applyNameEffects(signatory)
    --look through all names, else just save this name.  Even that is impressive.
    for _,nameDefinition in ipairs(mods.neo_chaos.EMPOWERED_NAMES) do
        for _,name in ipairs(nameDefinition.names) do
            if signatory:lower() == name then
                nameDefinition.lua()
                return nameDefinition
            end
        end
    end
    return {}
end