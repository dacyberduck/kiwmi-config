local _kw = require('kiwmi')
local _lt = require('layout')

local keybinds = {
  -- super -- -- alt -- -- ctrl -- -- shift -- -- -- key -- -- -- action --
  { true,       false,    false,      false,        'Return',   function() kiwmi:spawn("footclient") end },
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
  { true,       false,    true,       false,        'Tab',      function() _kw:switchToLastWorkspace() end },

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

return keybinds
