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
WSCUR = 1
WSPRV = 1
LAYOUT = 1 -- 1 = tile, 0 = monocle

OUTPUT = false
CURSOR = kiwmi:cursor()

local _modstate
local _view = require('kiwmi.view')
local _wrksp = require('kiwmi.workspace')
local _lt = require('kiwmi.layout')

local keybinds = {
  -- super -- -- alt -- -- ctrl -- -- shift -- -- -- key -- -- -- action --
  { false,      true,     false,      false,        'Return',   function() kiwmi:spawn("alacritty") end },
  { false,      true,     false,      false,        'p',        function() kiwmi:spawn("kickoff") end },
  { false,      true,     false,      true,         'q',        function() kiwmi:quit() end },
  { false,      true,     false,      false,        'q',        function() local v = kiwmi:focused_view() if v then v:close() end end },

  { false,      true,     false,      false,        'Tab',      function() _view:focusViewNext(kiwmi:focused_view()) end },
  { false,      true,     false,      true,         'Tab',      function() _view:focusViewPrev(kiwmi:focused_view()) end },

  { false,      true,     false,      false,        'm',        function() _lt:layout_monocle() end },
  { false,      true,     false,      false,        't',        function() _lt:layout_tile() end },
  { false,      true,     false,      true,         'Return',   function() _lt:layout_last() end },

  { false,      true,     false,      false,        '1',        function() _wrksp:showWorkspace(1) end },
  { false,      true,     false,      false,        '2',        function() _wrksp:showWorkspace(2) end },
  { false,      true,     false,      false,        '3',        function() _wrksp:showWorkspace(3) end },
  { false,      true,     true,       false,        'Tab',      function() _wrksp:showLastWorkspace() end },
}

kiwmi:on("output", function(output)
  OUTPUT = output
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

CURSOR:on("button_up", function()
  kiwmi:stop_interactive()
end)

CURSOR:on("button_down", function(button)
  local v = CURSOR:view_at_pos()
  if v then
    _view:focusView(v)
    if _modstate then
      if button == 1 then v:imove() end
      if button == 2 then v:iresize({'b', 'r'}) end
    end
  end
end)

kiwmi:on("view", function(view)
  _view:addView(view)
  _view:focusView(view)
  view:move(50,50)

  view:on("destroy", function(view)
    _view:removeView(view)
  end)

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
