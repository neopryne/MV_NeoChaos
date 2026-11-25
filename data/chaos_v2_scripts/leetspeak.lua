--[[
Replaces normal text with 13375P34]<
idk if I get |, need to check.  I don't, that's drone.  }{ are missiles and fuel. $ is repair
]]

local lwl = mods.lightweight_lua

--percent chance for each letter to swap them.  force lower before formatting, it's cooler that way.
local REPLACEMENTS = {a={"4", "@"}, b={"8"}, c={"("}, d={"])"}, e={"3"}, f={"7-"}, g={"6"}, h={"]-[", ")-("},
     i={"1", "!"}, j={"?"}, k={"]<"}, l={"1"}, m={"]\\/[", "^^"}, n={"]\\[", "/\\/"}, o={"0"}, p={"?"}, q={"9"}, 
     r={"4", "]?", "]?", "]?"}, s={"5"}, t={"7"}, u={"\\/", "[_]", "(_)"}, v={"\\/"}, w={"\\/\\/"}, x={"%", "><", "*"}, y={"`/"}, z={Z}}

--If enabled, whenever an event is rendered, translate text into this.
--[[
oh right, I need to force it lowercase first.
then force it uppercase
]]

---Turns normal text into 1337sp34k
---@param text string Text to translate
---@param weight number [0-1], chance to translate a given character.
---@return string translated
function lwl.trans1337(text, weight)
    weight = lwl.setIfNil(weight, 1)
    local modifiedText = string.lower(text)
    --None of the options in the replace list are characters we would replace.
    for character,replacements in pairs(REPLACEMENTS) do
        
        if #replacements == 1 and weight == 1 then
            modifiedText = modifiedText:gsub(character, replacements[1])
        else
            while modifiedText:find(character) do
                if (math.random() < weight) then
                    local chosenReplacement = replacements[math.random(#replacements)]
                    modifiedText = modifiedText:gsub(character, chosenReplacement, 1)
                else
                    modifiedText = modifiedText:gsub(character, string.upper(character), 1)
                end
            end
        end
    end
    -- print("1337ified:", text, modifiedText)
    return modifiedText
end





