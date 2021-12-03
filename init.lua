MODKEY = "Super_L"      -- default modkey for mouse actions
BWIDTH = 2              -- border width in pixels
GAPS = 5                -- gaps between edge and views in pixels
COLORS = { "#4dc653", "#2d4654" }   -- colors for borders and stuff
WS = {  -- workspaces - tables that holds views per workspace
  -- the behaviour of these tables are like the stack; last in first output
  -- which means; the last view spawned will be at first position and
  -- will be the "master" view
  [1]   = {},   -- workspace - 1
  [2]   = {},   -- workspace - 2
  [3]   = {},   -- worlspace - 3
  [-1]  = {},   -- hidden space
  [0]   = 1,    -- holds currnt workspace id
}
WSP = {  -- workspace properties ; this separtion is to reduce nested table accessing
  -- layouts; 1 - tile; 2 - monocle; 0 - no layout; manual or float behaviour
  layout = { [1] = 1,     [2] = 1,    [3] = 2,    [-1] = 0, },
  -- count of views in master area; for tile layout, value = 1 or higher
  mcount = { [1] = 1,     [2] = 1,    [3] = 1,    [-1] = 1, },
  -- master view width; for tile layout; value = between 0.25 to 0.75
  mwidth = { [1] = 0.52,  [2] = 0.5,  [3] = 0.6,  [-1] = 0.5, },
}
WSCUR = 1                 -- holds id of curent workspace
WSPRV = 1                 -- holds id of previous workspace

OUTPUT = false            -- holds reference to the output
CURSOR = kiwmi:cursor()   -- holds rference to the cursor

local _modstate           -- holds the state of mod key; pressed = true, released = false
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

  { true,       false,    false,      false,        'm',        function() _kw:focusViewLast() end },
  { true,       false,    false,      true,         'm',        function() _kw:makeViewLast() end },

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
  { true,       false,    true,       false,        'Return',   function() _lt:toggleViewMaximize() end },
  { true,       false,    false,      true,         'f',        function() _lt:toggleViewFullscreen() end },
  { true,       false,    false,      false,        't',        function() _lt:layout_tile() end },
  { true,       false,    false,      true,         't',        function() _lt:layout_monocle() end },
  { true,       false,    true,       false,        't',        function() _lt:layout_null() end },
  { true,       false,    false,      true,         'Return',   function() _lt:arrange_layout() end },

  { true,       false,    false,      false,        '1',        function() _kw:switchToWorkspace(1) end },
  { true,       false,    false,      false,        '2',        function() _kw:switchToWorkspace(2) end },
  { true,       false,    false,      false,        '3',        function() _kw:switchToWorkspace(3) end },
  { true,       false,    false,      true,         '1',        function() _kw:sendViewToWorkspace(1) end },
  { true,       false,    false,      true,         '2',        function() _kw:sendViewToWorkspace(2) end },
  { true,       false,    false,      true,         '3',        function() _kw:sendViewToWorkspace(3) end },

  { true,       false,    false,      false,        'h',        function() _kw:pushViewToHiddenSpace() end },
  { true,       false,    false,      true,         'h',        function() _kw:popViewFromHiddenSpace() end },
  { true,       false,    true,       false,        'h',        function() _kw:toggleHiddenSpace() end },

  { false, false, false, false, 'XF86MonBrightnessUp',    function() kiwmi:spawn("xbacklight -inc 5") end },
  { false, false, false, false, 'XF86MonBrightnessDown',  function() kiwmi:spawn("xbacklight -dec 5") end },
  { false, false, false, false, 'XF86AudioRaiseVolume',   function() kiwmi:spawn("amixer -D pipewire set Master 5%+") end },
  { false, false, false, false, 'XF86AudioLowerVolume',   function() kiwmi:spawn("amixer -D pipewire set Master 5%-") end },
  { false, false, false, false, 'XF86AudioMute',          function() kiwmi:spawn("amixer set Master toggle") end },
  { false, false, false, false, 'XF86AudioMicMute',       function() kiwmi:spawn("amixer set Capture toggle") end },
  { false, false, false, false, 'Print', function() kiwmi:spawn("grim -t png "..os.getenv("HOME").."/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png") end },
  { true,  false, false, false, 'Print', function() kiwmi:spawn("grim -t png -g \"$(slurp)\" "..os.getenv("HOME").."/Pictures/screenshot-$(date +%Y-%m-%d-%H-%M-%S).png") end },
}

-- on new output, store it's reference in OUTPUT
kiwmi:on("output", function(output)
  OUTPUT = output
end)

-- initialize keyboard
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

-- cursor button release handling
CURSOR:on("button_up", function()
  kiwmi:stop_interactive()
end)

-- cursor button press handling
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

-- on event view
kiwmi:on("view", function(view)
  -- when a new view is spawned
  _kw:addView(view)
  _kw:focusView(view)
  view:move(100,100)

  -- when a view is getting destoyed
  view:on("destroy", function(view)
    _kw:removeView(view)
  end)

  -- render objects before the view is drawn
  view:on("pre_render", function(ev)
    local vx,vy = view:pos()
    local vw,vh = view:size()

    if view == kiwmi:focused_view() then
      ev.renderer:draw_rect(COLORS[1], vx-BWIDTH, vy-BWIDTH, vw+2*BWIDTH, vh+2*BWIDTH)
    else
      ev.renderer:draw_rect(COLORS[2], vx-BWIDTH, vy-BWIDTH, vw+2*BWIDTH, vh+2*BWIDTH)
    end
  end)

  -- when the view request for interactive move
  view:on("request_move", function()
    view:imove()
  end)

  -- when the view request for interactive resize
  view:on("request_resize", function(ev)
    view:iresize(ev.edges)
  end)

end)

-- startup programs; this is probably ugly but works
kiwmi:spawn("swaybg -m fit -i " .. os.getenv("HOME") .. "/Pictures/wallpaper.jpg")
kiwmi:spawn("pipewire 2>/dev/null")
