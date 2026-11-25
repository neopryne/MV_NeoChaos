local userdata_table = mods.multiverse.userdata_table
local vter = mods.multiverse.vter
local get_room_at_location = mods.multiverse.get_room_at_location
local Brightness = mods.brightness
local lwl = mods.lightweight_lua

--TODO moving the stuff that identifies these weapons to LWL because that's cool and should be centralized.

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
    ]]

lwl.WEAPON_TYPE_BEAM = {typeName="BEAM", internalName="BEAM", friendlyName="Beam",
 blueprintLists={"BLUELIST_BEAMS_ALL", "BLUELIST_FOCUS_ALL"}}
lwl.WEAPON_TYPE_BOMB = {typeName="BOMB", internalName="BOMB", friendlyName="Bomb",
 blueprintLists={"SHOP_MANTIS_ITEM_WEAPONS_BOMB", "BLUELIST_BOMBS", "BLUELIST_BOMBS_CREWDAMAGE", "BLUELIST_BOMBS_HEAL", "BLUELIST_BOMB_REPAIR"}}
lwl.WEAPON_TYPE_MISSILE = {typeName="MISSILES", internalName="MISSILE", friendlyName="Missile",
 blueprintLists={"BLUELIST_MISSILES_ALL"}}
--need pattern matching, fore and aft must be start/end or a non-letter character
lwl.WEAPON_TYPE_ION = {internalName="ION", friendlyName="Ion", blueprintLists={"BLUELIST_ION"}}
lwl.WEAPON_TYPE_FLAK = {internalName="FLAK", friendlyName="Flak",
 blueprintLists={"SHOP_ITEM_SYLVAN_FLAK", "SHOP_ITEM_SYLVAN_FLAK_ELEMENTAL", "SHOP_ITEM_SYLVAN_ATTRIBUTE"}}
lwl.WEAPON_TYPE_LASER = {internalName="LASER", friendlyName="Laser",
 blueprintLists={"SHOP_ITEM_SYLVAN_RUSTY_LASER", "SHOP_ITEM_WEAPONS_LASERS"}} --pretty sure there's no laser list
lwl.WEAPON_TYPE_MINELAUNCHER = {internalName="MINELAUNCHER", friendlyName="Mine Launcher",
 blueprintLists={"BLUELIST_MINELAUNCHERS_ALL"}}

--Secondary Types
local TYPE_LOOT = "LOOT"
local TYPE_CHAOS = "CHAOS"
lwl.WEAPON_TYPES = {lwl.WEAPON_TYPE_BEAM, lwl.WEAPON_TYPE_LASER, lwl.WEAPON_TYPE_FLAK, lwl.WEAPON_TYPE_ION,
        lwl.WEAPON_TYPE_MISSILE, lwl.WEAPON_TYPE_BOMB, lwl.WEAPON_TYPE_MINELAUNCHER}
local FINDABLE_BY_TYPE = {lwl.WEAPON_TYPE_BEAM, lwl.WEAPON_TYPE_BOMB, lwl.WEAPON_TYPE_MISSILE}
--todo i guess beams can't use lists? maybe?

local mSetupComplete = false
local mGlobal = Hyperspace.Global.GetInstance()
local mBlueprintManager = mGlobal:GetBlueprints()
local mKnownTypes = {} --All names with known types
--local mObligationStruct = lwl.CreatePlayerVariableInterface(OBLIGATION_NAME)


function lwl.findIgnoreCase(content, pattern)
    return string.find(string.lower(content), "[%A?]"..string.lower(pattern).."[%A?]")
end

local function tryFindType(foundTypesWrapper, newType, searchString, source, typeThing)
    if newType.foundThisPass then return end
    if lwl.findIgnoreCase(searchString, typeThing) then
        print("adding type", newType.friendlyName, "from", source)
        newType.foundThisPass = true
        foundTypesWrapper.foundTypes = lwl.setMerge(foundTypesWrapper.foundTypes, {newType})
    end
end

--static load the bluelists as lua tables
local function setup()
    for _,type in ipairs(lwl.WEAPON_TYPES) do
        local lualist = {}
        for _,listName in ipairs(type.blueprintLists) do
            local bluelist = lwl.getBlueprintListSafe(listName)
            lualist = lwl.setMerge(lualist, lwl.vterToTable(bluelist))
        end
        type.flatlist = lualist
    end

    --load restrictions

    mSetupComplete = true
end

--todo more testing of this, but it seems solid.  I do want to split out pinpoints for leah reasons.
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
function lwl.findWeaponType(weaponName)
    if not mSetupComplete then
        setup()
    end
    local foundTypesWrapper = mKnownTypes[weaponName]
    foundTypesWrapper = lwl.setIfNil(foundTypesWrapper, {foundTypes={}})
    print("foundtype", lwl.dumpObject(foundTypesWrapper.foundTypes))

    --First try to find it in known weapon lists.  todo add seperate pinpoints?
    --If I really wanted to max perf, I could remove things from the list to check once I find them.
    if #foundTypesWrapper.foundTypes == 0 then
        local source = "bluelists"
        for _,type in ipairs(lwl.WEAPON_TYPES) do
            for _,listItem in ipairs(type.flatlist) do
                if weaponName == listItem then
                    foundTypesWrapper.foundTypes = lwl.setMerge(foundTypesWrapper.foundTypes, {type})
                    print("adding type", type.friendlyName, "from", source)
                    break
                end
            end
        end

        --If we can't find it in any lists, look at the blueprint.
        if #foundTypesWrapper.foundTypes == 0 then
            local weaponBlueprint = mBlueprintManager:GetWeaponBlueprint(weaponName)
            print("Finding weapon type", weaponBlueprint.name, weaponBlueprint:GetNameLong(), weaponBlueprint.desc.title:GetText(),
            weaponBlueprint.desc.description:GetText(), weaponBlueprint.desc.tooltip:GetText(), weaponBlueprint.typeName, weaponBlueprint.flavorType:GetText())

            source = "type name"
            for _,type in ipairs(FINDABLE_BY_TYPE) do
                foundTypesWrapper.foundTypes = {type}
                print("adding type", type.friendlyName, "from", source)
                type.foundThisPass = true
            end

            source = "BLUEPRINT_NAME"
            local searchString = weaponBlueprint.name
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
            end

            source = "ITEM_NAME"
            searchString = weaponBlueprint:GetNameLong()
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
            end
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.friendlyName)
            end
            
            source = "DESCRIPTION"
            searchString = weaponBlueprint.desc.description:GetText()
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
            end
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.friendlyName)
            end
            source = "TOOLTIP"
            searchString = weaponBlueprint.desc.tooltip:GetText()
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.internalName)
            end
            for _,type in ipairs(lwl.WEAPON_TYPES) do
                tryFindType(foundTypesWrapper, type, searchString, source, type.friendlyName)
            end

            print("foundtype", lwl.dumpObject(foundTypesWrapper.foundTypes))
            if #foundTypesWrapper.foundTypes == 0 then
                --Try to determine type based on attributes
                source = "attributes"
                local damageValues = weaponBlueprint.damage
                if damageValues.iIonDamage > 0 and (damageValues.iDamage + damageValues.iSystemDamage <= 0) then
                    foundTypesWrapper.foundTypes = {lwl.WEAPON_TYPE_ION}
                    print("adding type", lwl.WEAPON_TYPE_ION.friendlyName, "from", source)
                elseif weaponBlueprint.missiles > 0 then
                    foundTypesWrapper.foundTypes = {lwl.WEAPON_TYPE_MINELAUNCHER}
                    print("adding type", lwl.WEAPON_TYPE_MINELAUNCHER.friendlyName, "from", source)
                elseif weaponBlueprint.typeName == "BURST" then
                    foundTypesWrapper.foundTypes = {lwl.WEAPON_TYPE_FLAK}
                    print("adding type", lwl.WEAPON_TYPE_FLAK.friendlyName, "from", source)
                else --Default to laser.
                    foundTypesWrapper.foundTypes = {lwl.WEAPON_TYPE_LASER}
                    print("adding type", lwl.WEAPON_TYPE_LASER.friendlyName, "from", source)
                end
            end
        end
    end
    
    
    for _,type in ipairs(lwl.WEAPON_TYPES) do
        type.foundThisPass = false
    end
    mKnownTypes[weaponName] = foundTypesWrapper
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