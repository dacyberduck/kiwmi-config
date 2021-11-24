MODKEY = "Alt_L"
BWIDTH = 2
MWIDTH = 0.5
COLORS = { "#4dc653", "#2d4654" }
WS = {
  [1]   = {},
  [2]   = {},
  [3]   = {},
  [-1]  = {},
  [0]   = 1,
}

local kiwmi = kiwmi
local _output = false
local _cursor = kiwmi:cursor()
local _modstate = false

local keybinds = {
  -- super -- -- alt -- -- ctrl -- -- shift -- -- -- key -- -- -- action --
  { false,      true,     false,      true,         'Return',   function() kiwmi:spawn("alacritty") end },
  { false,      true,     false,      true,         'p',        function() kiwmi:spawn("kickoff") end },
  { false,      true,     false,      true,         'q',        function() kiwmi:quit() end },
  { false,      true,     false,      false,        'q',        function() kiwmi:focused_view():close() end },
}

kiwmi:on("output", function(output)
  _output = output
end)

kiwmi:on("keyboard", function(keyboard)
  keyboard:on("key_up", function(ev)
    _modstate = ev.key == MODKEY and false
  end)

  keyboard:on("key_down", function(ev)
    _modstate = ev.key == MODKEY and true

    local m = ev.keyboard:modifiers()
    for _,k in ipairs(keybinds) do 
      if m.super == k[1] and m.alt == k[2] and m.ctrl == k[3] and m.shift == k[4] and ev.key == k[5] then
        k[6](ev)
        return true
      end
    end

    return false
  end)
end)

_cursor:on("button_up", function()
  kiwmi:stop_interactive()
end)

_cursor:on("button_down", function(button)
  local v = _cursor:view_at_pos()
  if v then
    v:focus()
    if _modstate then
      if button == 1 then v:imove() end
      if button == 2 then v:iresize({'b', 'r'}) end
    end
  end
end)

kiwmi:on("view", function(view)
  view:csd(false)
  view:tiled(true)
  view:show()
  view:focus()
  view:move(50,50)

  view:on("pre_render", function(ev)
    local vx,vy = view:pos()
    local vw,vh = view:size()

    if view == kiwmi:focused_view() then
      ev.renderer:draw_rect(COLORS[1], vx-BWIDTH, vy-BWIDTH, vw+2*BWIDTH, vh+2*BWIDTH)
    else
      ev.renderer:draw_rect(COLORS[2], vx-BWIDTH, vy-BWIDTH, vw+2*BWIDTH, vh+2*BWIDTH)
    end
  end)
end)
