MODKEY = "Super_L"      -- default modkey for mouse actions
BWIDTH = 2              -- border width in pixels
GAPS = 8                -- gaps between edge and views in pixels
COLORS = {
  { "#4dc653", "#2d4654" },
  { "#d56a55", "#2d5568" },
}   -- colors for borders and stuff
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

OUTPUT = false            -- holds reference to the output
CURSOR = kiwmi:cursor()   -- holds rference to the cursor

local _modstate           -- holds the state of mod key; pressed = true, released = false
local _kw = require('kiwmi')
local _lt = require('layout')
local keybinds = require('keybind')

-- on new output, store it's reference in OUTPUT
kiwmi:on("output", function(output)
  OUTPUT = output
end)

-- initialize keyboard
kiwmi:on("keyboard", function(keyboard)
  keyboard:on("key_up", function(ev)
    if ev.key == MODKEY then
      _modstate = false
      OUTPUT:redraw()
    end
  end)

  keyboard:on("key_down", function(ev)
    if ev.key == MODKEY then
      _modstate = true
      OUTPUT:redraw()
    end

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

function drawborder(renderer,view,colors)
  local vx,vy = view:pos()
  local vw,vh = view:size()

  -- top border
  renderer:draw_rect(kiwmi:focused_view() == view and colors[1] or colors[2],vx-BWIDTH,vy-BWIDTH,vw+2*BWIDTH,BWIDTH)
  -- bottom border
  renderer:draw_rect(kiwmi:focused_view() == view and colors[1] or colors[2],vx-BWIDTH,vy+vh,vw+2*BWIDTH,BWIDTH)
  -- left border
  renderer:draw_rect(kiwmi:focused_view() == view and colors[1] or colors[2],vx-BWIDTH,vy,BWIDTH,vh)
  -- right border
  renderer:draw_rect(kiwmi:focused_view() == view and colors[1] or colors[2],vx+vw,vy,BWIDTH,vh)
end

function drawallborders(renderer,views,colors)
  for _,j in ipairs(views) do
    if j ~= kiwmi:focused_view() then
      drawborder(renderer,j,colors)
    end
  end
  drawborder(renderer,kiwmi:focused_view(),colors)
end

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
  view:on("post_render", function(ev)
    if _modstate then
      drawallborders(ev.renderer,WS[WSCUR],COLORS[2])
    else
      drawborder(ev.renderer,view,COLORS[1])
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
-- kiwmi:spawn("swaybg -m fit -i " .. os.getenv("HOME") .. "/Pictures/wallpaper.jpg")
kiwmi:spawn("foot --server 2>/dev/null")
kiwmi:spawn("pipewire 2>/dev/null")
