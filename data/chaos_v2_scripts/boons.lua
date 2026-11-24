
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

--Most things don't have a type name.

    --[[
    WEAPONS_BOMBS_CHEAP
    WEAPONS_MISSILES_EXPENSIVE
    WEAPONS_CRYSTAL
    SHOP_CRYSTAL_ITEM_WEAPONS_CRYSTAL
    BLUELIST_WEAPONS_CRYSTAL
    BLUELIST_WEAPONS_HEAVY
    BLUELIST_WEAPONS_FIRE_ALL
    BLUELIST_WEAPONS_FIRE_NODAMAGE
    BLUELIST_ANTIBIO
    BLUELIST_PARTICLE

    WEAPONS_ION --FR only probably
    MV_WEAPONS_ION
    BLUELIST_ION

    SHOP_VAMPWEED_ITEM_WEAPONS_SPORE
    SHOP_MANTIS_ITEM_WEAPONS_BOMB

    WEAPONS_MISSILES
    SHOP_ROCK_ITEM_WEAPONS_MISSILES
    SHOP_ORCHID_ITEM_WEAPONS_KERNEL
    SHOP_ITEM_SYLVAN_RUSTY_MISSILES

    SHOP_ITEM_SYLVAN_MINELAUNCHER
    SHOP_ITEM_SYLVAN_MINELAUNCHER_UNIQUE

    SHOP_ITEM_SYLVAN_FLAK
    SHOP_ITEM_SYLVAN_FLAK_ELEMENTAL
    SHOP_ITEM_SYLVAN_ATTRIBUTE


    MV_WEAPONS_BEAMS
    BLUELIST_WEAPONS_BEAM_POWERFUL --fr likely
    ]]

local TYPE_BEAM = {typeName="BEAM", internalName="BEAM", friendlyName="Beam",
 blueprintLists={"BLUELIST_BEAMS_ALL", "BLUELIST_FOCUS_ALL"}}
local TYPE_BOMB = {typeName="BOMB", internalName="BOMB", friendlyName="Bomb",
 blueprintLists={"SHOP_MANTIS_ITEM_WEAPONS_BOMB", "BLUELIST_BOMBS", "BLUELIST_BOMBS_CREWDAMAGE", "BLUELIST_BOMBS_HEAL", "BLUELIST_BOMB_REPAIR"}}
local TYPE_MISSILE = {typeName="MISSILES", internalName="MISSILE", friendlyName="Missile",
 blueprintLists={"BLUELIST_MISSILES_ALL"}}
--need pattern matching, fore and aft must be start/end or a non-letter character
local TYPE_ION = {internalName="ION", friendlyName="Ion", blueprintLists={"BLUELIST_ION"}}
local TYPE_FLAK = {internalName="FLAK", friendlyName="Flak",
 blueprintLists={"SHOP_ITEM_SYLVAN_FLAK", "SHOP_ITEM_SYLVAN_FLAK_ELEMENTAL", "SHOP_ITEM_SYLVAN_ATTRIBUTE"}}
local TYPE_LASER = {internalName="LASER", friendlyName="Laser",
 blueprintLists={"SHOP_ITEM_SYLVAN_RUSTY_LASER", "SHOP_ITEM_WEAPONS_LASERS"}} --pretty sure there's no laser list
local TYPE_MINELAUNCHER = {internalName="Minelauncher", friendlyName="Mine Launcher",
 blueprintLists={"BLUELIST_MINELAUNCHERS_ALL"}}

--Secondary Types
local TYPE_LOOT = "LOOT"
local TYPE_CHAOS = "CHAOS"
local TYPE_TURRET = "TURRET" --todo idk if counts
local WEAPON_TYPES = {TYPE_BEAM, TYPE_LASER, TYPE_FLAK, TYPE_ION, TYPE_MISSILE, TYPE_BOMB, TYPE_MINELAUNCHER}

local mSetupComplete = false
local mGlobal = Hyperspace.Global.GetInstance()
local mBlueprintManager = mGlobal:GetBlueprints()
local mKnownTypes = {} --All names with known types

--[[
Checks:
    Internal Lists
    Name
    Description
    Type (Beam/Bomb/Missile only)
    Properties
        Ion: A weapon with no system damage, and some amount of ion damage.
        Minelauncher: A burst weapon that consumes missiles (hits carnage, etc if not found already)
        Flak: A burst with some amount of fake particles and hull damage
        Laser: Anything else

]]
function lwl.findIgnoreCase(content, pattern)
    return string.find(string.lower(content), "[%A?]"..string.lower(pattern).."[%A?]")
end

local function tryFindType(foundTypesWrapper, newType, searchString, source, typeThing)
    if lwl.findIgnoreCase(searchString, typeThing) then
        print("adding type", newType.friendlyName, "from", source)
        
    end
end

--static load the bluelists as lua tables
local function setup()
    for _,type in ipairs(WEAPON_TYPES) do
        local lualist = {}
        for _,listName in ipairs(type.blueprintLists) do
            local bluelist = lwl.getBlueprintListSafe(listName)
            lualist = lwl.setMerge(lualist, lwl.vterToTable(bluelist))
        end
        type.flatlist = lualist
    end
    mSetupComplete = true
end


function lwl.findWeaponType(weaponName)
    if not mSetupComplete then
        setup()
    end
    local foundTypesWrapper = {foundTypes={}}--mKnownTypes[weaponName]
    --print("foundtype", lwl.dumpObject(foundTypesWrapper.foundTypes))
    --First try to find it in known weapon lists.  todo pinpoint?
    --If I really wanted to max perf, I could remove things from the list to check once I find them.
    local source = "bluelists"
    -- for _,type in ipairs(WEAPON_TYPES) do
    --     for _,listItem in ipairs(type.flatlist) do
    --         if weaponName == listItem then
    --             foundTypesWrapper.foundTypes = lwl.setMerge(foundTypesWrapper.foundTypes, {type})
    --             print("adding type", type.friendlyName, "from", source)
    --             break
    --         end
    --     end
    -- end


    --If we can't find it in any lists, look at the blueprint.
    if #(foundTypesWrapper.foundTypes) == 0 then
        local weaponBlueprint = mBlueprintManager:GetWeaponBlueprint(weaponName)
        print("Finding weapon type", weaponBlueprint.name, weaponBlueprint:GetNameLong(), weaponBlueprint.desc.title:GetText(),
        weaponBlueprint.desc.description:GetText(), weaponBlueprint.desc.tooltip:GetText(), weaponBlueprint.typeName, weaponBlueprint.flavorType:GetText())

        source = "type name"
        if weaponBlueprint.typeName == TYPE_BEAM.typeName then
            foundTypesWrapper.foundTypes = {TYPE_BEAM}
            print("adding type", TYPE_BEAM.friendlyName, "from", source)
            --todo a pinpoint is a beam with length <=2
        elseif weaponBlueprint.typeName == TYPE_BOMB.typeName then
            foundTypesWrapper.foundTypes = {TYPE_BOMB}
            print("adding type", TYPE_BOMB.friendlyName, "from", source)
        elseif weaponBlueprint.typeName == TYPE_MISSILE.typeName then
            foundTypesWrapper.foundTypes = {TYPE_MISSILE}
            print("adding type", TYPE_MISSILE.friendlyName, "from", source)
        end

        source = "BLUEPRINT_NAME"
        local searchString = weaponBlueprint.name
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
        end

        source = "ITEM_NAME"
        searchString = weaponBlueprint:GetNameLong()
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
        end
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.friendlyName)
        end
        
        source = "DESCRIPTION"
        searchString = weaponBlueprint.desc.description:GetText()
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
        end
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.friendlyName)
        end
        source = "TOOLTIP"
        searchString = weaponBlueprint.desc.tooltip:GetText()
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
        end
        for _,type in ipairs(WEAPON_TYPES) do
            tryFindType(foundTypesWrapper, type, searchString, source, type.friendlyName)
        end

        print("foundtype", lwl.dumpObject(foundTypesWrapper.foundTypes))
        if #(foundTypesWrapper.foundTypes) == 0 then
            --Try to determine type based on attributes
            source = "attributes"
            local damageValues = weaponBlueprint.damage
            if damageValues.iIonDamage > 0 and (damageValues.iDamage + damageValues.iSystemDamage <= 0) then
                foundTypesWrapper.foundTypes = {TYPE_ION}
                print("adding type", TYPE_ION.friendlyName, "from", source)
            elseif weaponBlueprint.missiles > 0 then
                foundTypesWrapper.foundTypes = {TYPE_MINELAUNCHER}
                print("adding type", TYPE_MINELAUNCHER.friendlyName, "from", source)
            elseif weaponBlueprint.typeName == "BURST" then
                foundTypesWrapper.foundTypes = {TYPE_FLAK}
                print("adding type", TYPE_FLAK.friendlyName, "from", source)
            else --Default to laser.
                foundTypesWrapper.foundTypes = {TYPE_LASER}
                print("adding type", TYPE_LASER.friendlyName, "from", source)
            end
        end
    end
--For each weapon type, check against the internal lists for that type.
--Get weapon name, description.
    
    --todo add mKnownTypes[weaponName] = foundType
    return foundTypesWrapper.foundTypes
end

--Testing command to print the weapon type of all weapons equipped
--[[
lua PrintWeaponTypes("LASER_BURST_2")
 ]]
function PrintWeaponTypes(name)
    local types = lwl.findWeaponType(name)
    print(name.." is weapon type "..lwl.dumpObject(types))
    --For each weapon, get the type and print it.
    --Huh, actually I want to do all weapons, huh?
    --And that means I still need to grab NC's stuff.
    --start with just the loadout, or whatever's easy to grab one.
    
    --GetRandomWeapon(int count, bool demo_lock);
end