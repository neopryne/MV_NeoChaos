--[[

    Boons banning weapons cannot appear with banes buffing them, and once removed, those boons can no longer spawn.
    Some banes can stack.

lots of the weapon-affecting things are going to work like UWM.

Banes will never happen more than once.  Boons can happen repeatedly.


Contract terms have a set of tags
    Associated type
    actually does anything else matter?
    maybe not now but tags are a nice system to have
    perhaps I sort them by type first?  Manually?

All of the augment stuff only runs when you get it, but the lua has to run on load every time.
So if you add player augs with lua, you have to track it in pvs.
]]

local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local get_room_at_location = mods.multiverse.get_room_at_location
local Brightness = mods.brightness
local lwl = mods.lightweight_lua

local function NOOP() end
local WEAPON_TYPES = lwl.WEAPON_TYPES
--Saved in player vars under NC_OBLIGATION_[N], where N is index.  0 is disabled, 1 is enabled.  I don't need my structs.
local OBLIGATION_NAME = "NC_CONTRACT_OBLIGATIONS"



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







local OLBIGATIONS_BEAM = {}
--
local OBLIGATION_UNTYPED = {{name="Mandate of Madness", description="All crew on your ship are inflicted with the madness debuff (cannot use abilities).",
     augment="NC_BANE_MADNESS", lua=NOOP}}

local OBLIGATIONS_ALL = {}

local OBLIGATION_SPECIAL_NAMED = {{name="Gabe", description="Shield charge rate -100%, 50% ion resist.",
     augment="NC_NAME_GABE", lua=NOOP},
    {name="Asshole", description="Y0u c4n'7 3v3n b3 4R53D t0 G37 H15 N4M3 R1GH7??!", lua=NOOP},}

local function applyRestriction()
    --kick all incompatible weapons into inventory, or overflow if no room.  I can't just disable the jump button...  Though I could make the player take damage whenever they jump if they don't clear things.

end

--[[
Choose a valid bane (some names invalidate banes)
]]
local function generateContract()
    
end