--[[
Extended calls to render text with a nice wrapper.  Call as you would normally, and have text printed fancy-style.
]]


lwl = mods.lightweight_lua--todo make local

local WHITE = Graphics.GL_Color(1, 1, 1, 1)
local RED = Graphics.GL_Color(1, 0, 0, 1)
local CYAN = Graphics.GL_Color(0, 1, 1, 1)
local saved = Graphics.GL_Color(252/256, 217/256, 217/256, 1)

function lwl.print_fancy_her(fontSize, xPos, yPos, text)
    Graphics.CSurface.GL_PushMatrix()
    Graphics.CSurface.GL_SetColor(RED)
    Graphics.freetype.easy_print(fontSize, xPos + 1, yPos - 1, text)
    Graphics.CSurface.GL_SetColor(CYAN)
    Graphics.freetype.easy_print(fontSize, xPos - 1, yPos + 1, text)
    Graphics.CSurface.GL_SetColor(WHITE)
    Graphics.freetype.easy_print(fontSize, xPos, yPos, text)
    Graphics.CSurface.GL_PopMatrix()
end

--[[
lua testHer("hellowo wha;)")
]]
function testHer(text)
    lwl.safe_script.on_render_event("NC_TEST_TEXT_HER", Defines.RenderEvents.GUI_CONTAINER, function () end, function()
        lwl.print_fancy_her(50, 300, 300, text)
end)
end

