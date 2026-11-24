
local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local get_room_at_location = mods.multiverse.get_room_at_location
local Brightness = mods.brightness
local lwl = mods.lightweight_lua

--TODO moving the stuff that identifies these weapons to LWL because that's cool and should be centralized.


--I really want type systems to work with multiple types.
--Yeah, it should be something I can add types to?  Or not?
--Nah, types is a {list of attributes}
--It's a match if it has all of the things you're looking for.  It's an exact match if it has nothing else.

local TYPE_BEAM = "BEAM"
local TYPE_LASER = "LASER"
local TYPE_FLAK = "FLAK"
local TYPE_ION = "ION"
local TYPE_MISSILE = "MISSILE"
local TYPE_BOMB = "BOMB"
local TYPE_MINELAUNCHER = "MINE_LAUNCHER"

--Secondary Types
local TYPE_LOOT = "LOOT"
local TYPE_CHAOS = "CHAOS"
local TYPE_TURRET = "TURRET" --todo idk if counts
local WEAPONS = {TYPE_BEAM, TYPE_LASER, TYPE_FLAK, TYPE_ION, TYPE_MISSILE, TYPE_BOMB, TYPE_MINELAUNCHER}


local mGlobal = Hyperspace.Global.GetInstance()
local mBlueprintManager = mGlobal:GetBlueprints()
local mKnownTypes = {} --All names with known types

--[[
Checks:
    Internal Lists
    Name
    Description
    Type (Beam/Bomb only)
    Properties
        Ion: A weapon with no system damage, and some amount of ion damage.
        Minelauncher: A burst weapon that consumes missiles (hits carnage, etc if not found already)
        Flak: A burst with some amount of fake particles and hull damage
        Missile: Anything else that uses missiles.
        Laser: Anything else

]]
function lwl.findIgnoreCase(content, pattern)
    return string.find(string.lower(content), string.lower(pattern))
end

function lwl.findWeaponType(weaponName)
    local foundType = nil--mKnownTypes[weaponName]
    print("foundtype", foundType)
    if not foundType then
        local weaponBlueprint = mBlueprintManager:GetWeaponBlueprint(weaponName)
        print("Finding weapon type", weaponBlueprint.name, weaponBlueprint:GetNameLong(), weaponBlueprint.desc.title,
        weaponBlueprint.desc.description, weaponBlueprint.desc.tooltip, weaponBlueprint.typeName, weaponBlueprint.flavorType:GetText())
        if weaponBlueprint.typeName == TYPE_BEAM then
            foundType = TYPE_BEAM
        elseif weaponBlueprint.typeName == TYPE_BOMB then
            foundType = TYPE_BOMB
        end

        
        if not foundType then
            if lwl.findIgnoreCase(weaponBlueprint.name, TYPE_MISSILE) then
                
            end
        end
        if not foundType then
            
        end
        if not foundType then
            foundType = "unknown" --todo remove
        end
    end
--For each weapon type, check against the internal lists for that type.
--Get weapon name, description.
    
    --todo add mKnownTypes[weaponName] = foundType
    return foundType
end

--Testing command to print the weapon type of all weapons equipped
--[[
 lua PrintWeaponTypes("LASER_BURST_2")
 ]]
function PrintWeaponTypes(name)
    local type = lwl.findWeaponType(name)
    print(name.." is weapon type "..type)
    --For each weapon, get the type and print it.
    --Huh, actually I want to do all weapons, huh?
    --And that means I still need to grab NC's stuff.
    --start with just the loadout, or whatever's easy to grab one.
    
    --GetRandomWeapon(int count, bool demo_lock);
end