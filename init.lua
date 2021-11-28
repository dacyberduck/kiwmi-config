MODKEY = "Super_L"      -- default modkey for mouse actions
BWIDTH = 2              -- border width in pixels
GAPS = 5                -- gaps between edge and views in pixels
COLORS = { "#4dc653", "#2d4654" }   -- colors for borders and stuff
WS = {  -- workspaces - lists that holds views per workspace
  [1]   = {},
  [2]   = {},
  [3]   = {},
  [-1]  = {},
  [0]   = 1,
}
WSP = {  -- workspace properties ; to reduce unnecessary list accessing
  layout = { [1] = 1,     [2] = 1,    [3] = 2,    [-1] = 0, },
  mcount = { [1] = 1,     [2] = 1,    [3] = 1,    [-1] = 1, },
  mwidth = { [1] = 0.52,  [2] = 0.5,  [3] = 0.6,  [-1] = 0.5, },
}
WSCUR = 1
WSPRV = 1

OUTPUT = false
CURSOR = kiwmi:cursor()

local _modstate
local _kw = require('kiwmi')
local _lt = require('layout')

local keybinds = {
  -- super -- -- alt -- -- ctrl -- -- shift -- -- -- key -- -- -- action --
  { true,       false,    false,      false,        'Return',   function() kiwmi:spawn("alacritty") end },
  { true,       false,    false,      false,        'space',    function() kiwmi:spawn("kickoff") end },
  { true,       false,    true,       true,         'q',        function() kiwmi:quit() end },
  { true,       false,    false,      false,        'q',        function() local v = kiwmi:focused_view() if v then v:close() end end },

  { true,       false,    false,      false,        'Tab',      function() _kw:focusViewNext() end },
  { true,       false,    false,      true,         'Tab',      function() _kw:focusViewPrev() end },

  { true,       false,    false,      false,        'm',        function() _kw:focusViewMaster() end },
  { true,       false,    false,      true,         'm',        function() _kw:switchViewMaster() end },

  { true,       false,    false,      false,        'comma',    function() _lt:decMasterWidth() end },
  { true,       false,    false,      false,        'period',   function() _lt:incMasterWidth() end },
  { true,       false,    false,      true,         'comma',    function() _lt:decMasterCount() end },
  { true,       false,    false,      true,         'period',   function() _lt:incMasterCount() end },

  { true,       false,    false,      true,         'Left',     function() _lt:moveView(kiwmi:focused_view(),20,{-1,0}) end },
  { true,       false,    false,      true,         'Right',    function() _lt:moveView(kiwmi:focused_view(),20,{1,0}) end },
  { true,       false,    false,      true,         'Up',       function() _lt:moveView(kiwmi:focused_view(),20,{0,-1}) end },
  { true,       false,    false,      true,         'Down',     function() _lt:moveView(kiwmi:focused_view(),20,{0,1}) end },
  { true,       false,    true,       false,        'Left',     function() _lt:snapViewToEdge(kiwmi:focused_view(),"left") end },
  { true,       false,    true,       false,        'Right',    function() _lt:snapViewToEdge(kiwmi:focused_view(),"right") end },
  { true,       false,    true,       false,        'Up',       function() _lt:snapViewToEdge(kiwmi:focused_view(),"up") end },
  { true,       false,    true,       false,        'Down',     function() _lt:snapViewToEdge(kiwmi:focused_view(),"down") end },
  { true,       false,    true,       false,        'Return',   function() _kw:toggleViewMaximize() end },
  { true,       false,    false,      true,         'f',        function() _kw:toggleViewFullscreen() end },
  { true,       false,    false,      false,        't',        function() _lt:layout_tile() end },
  { true,       false,    false,      true,         't',        function() _lt:layout_monocle() end },
  { true,       false,    false,      true,         'Return',   function() _lt:arrange_layout() end },

  { true,       false,    false,      false,        '1',        function() _kw:switchWorkspace(1) end },
  { true,       false,    false,      false,        '2',        function() _kw:switchWorkspace(2) end },
  { true,       false,    false,      false,        '3',        function() _kw:switchWorkspace(3) end },
  { true,       false,    false,      true,         '1',        function() _kw:sendViewToWorkspace(1) end },
  { true,       false,    false,      true,         '2',        function() _kw:sendViewToWorkspace(2) end },
  { true,       false,    false,      true,         '3',        function() _kw:sendViewToWorkspace(3) end },

  { true,       false,    false,      false,        'h',        function() _kw:pushViewToHiddenSpace() end },
  { true,       false,    false,      true,         'h',        function() _kw:popViewFromHiddenSpace() end },
  { true,       false,    true,       false,        'h',        function() _kw:toggleHiddenSpace() end },

  { false, false, false, false, 'XF86MonBrighnessUp',     function() kiwmi:spawn("xbacklight -inc 5") end },
  { false, false, false, false, 'XF86MonBrighnessDown',   function() kiwmi:spawn("xbacklight -dec 5") end },
  { false, false, false, false, 'XF86AudioRaiseVolume',   function() kiwmi:spawn("amixer -D pipewire set Master 5%+") end },
  { false, false, false, false, 'XF86AudioLowerVolume',   function() kiwmi:spawn("amixer -D pipewire set Master 5%-") end },
  { false, false, false, false, 'XF86AudioMute',          function() kiwmi:spawn("amixer set Master toggle") end },
  { false, false, false, false, 'XF86AudioMicMute',       function() kiwmi:spawn("amixer set Capture toggle") end },
  { false, false, false, false, 'Print', function() kiwmi:spawn("grim -t png "..os.getenv("HOME").."/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png") end },
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
    _kw:focusView(v)
    if _modstate then
      if button == 1 then v:imove() end
      if button == 2 then v:iresize({'b', 'r'}) end
    end
  end
end)

kiwmi:on("view", function(view)
  _kw:addView(view)
  _kw:focusView(view)
  view:move(100,100)

  view:on("destroy", function(view)
    _kw:removeView(view)
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

  view:on("request_move", function()
    view:imove()
  end)

  view:on("request_resize", function(ev)
    view:iresize(ev.edges)
  end)

end)

kiwmi:spawn("swaybg -m fit -i " .. os.getenv("HOME") .. "/Pictures/wallpaper.jpg")
kiwmi:spawn("pipewire 2>/dev/null")
