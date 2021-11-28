local M = {}

function M:ROUND(x) return math.floor(x+0.5) end

-- simple tiling layout
function M:layout_tile(ws)
  -- --------------------
  -- |          |       |
  -- |    M     |   S   |
  -- |    A     |-------|
  -- |    S     |       |
  -- | - -T - - |   S   |
  -- |    E     |-------|
  -- |    R     |       |
  -- |          |   S   |
  -- --------------------
  --
  -- simply tile the views equally on the
  -- stack space ; on the master area respect
  -- master count and divide equally
  -- does not handle extra spaces ; left unused
  -- so some extra spaces may be visible
  -- respects border width and gaps
  -- since the tiling behaviour is not something like dwm or bspwm
  -- and tiling is only handled by keybinding when required rather
  -- than always doing it dynamically, we don't need to worry about
  -- those small unused spaces.

  local w = ws or WSCUR

  local n = #WS[w]
  if n < 1 then return end

  local o = OUTPUT:usable_area()
  local vx,vy,vw,vh

  local mc = WSP.mcount[w]
  local mw = WSP.mwidth[w]

  local m = (n<=mc and n or mc)               -- master count
  local s = n-m                               -- stack count

  local uw = o.width-4*BWIDTH-3*GAPS          -- total usable width
  local umw = self:ROUND(uw*mw)               -- total usable master width
  local usw = uw-umw                          -- total usable stack width

  local umh = o.height-2*m*BWIDTH-(m+1)*GAPS  -- total usable master height
  local mh = math.floor(umh/m)                -- mh = master view height
  local ush = o.height-2*s*BWIDTH-(s+1)*GAPS  -- total usable stack height
  local sh = math.floor(ush/s)                -- sh = stack view height

  for i,j in ipairs(WS[w]) do
    -- simple tiling layout; no extra space handling
    vx = i <= m and o.x+BWIDTH+GAPS
      or o.x+umw+3*BWIDTH+2*GAPS

    vy = i <= m and o.y+BWIDTH+(i-1)*mh+2*(i-1)*BWIDTH+i*GAPS
      or o.y+BWIDTH+(i-m-1)*sh+2*(i-m-1)*BWIDTH+(i-m)*GAPS

    vw = i <= m and (n <= m and uw+2*BWIDTH+GAPS or umw)
      or usw

    vh = i <= m and mh
      or sh

    j:move(vx,vy)
    j:resize(vw,vh)
  end

  OUTPUT:redraw()
  WSP.layout[w] = 1
end

-- monocle layout; maximize all view
function M:layout_monocle(ws)
  local w = ws or WSCUR
  if #WS[w] < 1 then return end
  local o = OUTPUT:usable_area()
  for _,v in ipairs(WS[w]) do
    v:move(o.x+BWIDTH+GAPS,o.y+BWIDTH+GAPS)
    v:resize(o.width-2*(BWIDTH+GAPS),o.height-2*(BWIDTH+GAPS))
  end
  OUTPUT:redraw()
  WSP.layout[w] = 2
end

-- arrange layout depending on workspace layout
function M:arrange_layout(ws,layout)
  local w = ws or WSCUR
  local lt = layout or WSP.layout[w]
  if lt == 1 then
    self:layout_tile(w)
  elseif lt == 2 then
    self:layout_monocle(w)
  end
end

-- increment master area
function M:incMasterWidth(ws)
  local w = ws or WSCUR
  local mw = WSP.mwidth[w]
  WSP.mwidth[w] = mw+0.05 < 0.75 and mw+0.05 or 0.75
  self:arrange_layout(w)
end

-- decrement master area
function M:decMasterWidth(ws)
  local w = ws or WSCUR
  local mw = WSP.mwidth[w]
  WSP.mwidth[w] = mw-0.05 > 0.25 and mw-0.05 or 0.25
  self:arrange_layout(w)
end

-- increment view count in master area
function M:incMasterCount(ws)
  local w = ws or WSCUR
  WSP.mcount[w] = WSP.mcount[w]+1
  self:arrange_layout(w)
end

-- decrement view count in master area
function M:decMasterCount(ws)
  local w = ws or WSCUR
  local mc = WSP.mcount[w]
  WSP.mcount[w] = mc<=1 and 1 or mc-1
  self:arrange_layout(w)
end

-- move a view to a direction
-- view -> takes a view
-- step -> how many pixels to move
-- dir  -> direction - a table with x,y
-- { x = -1/0/1, y = -1/0/1 }
function M:moveView(view,step,dir)
  if not view then return end
  local vx,vy = view:pos()
  view:move(vx+step*dir[1],vy+step*dir[2])
end

-- snap view to an edge
function M:snapViewToEdge(view,dir)
  if not view then return end
  local o = OUTPUT:usable_area()
  if dir == "left" then
    view:move(o.x+BWIDTH+GAPS,o.y+BWIDTH+GAPS)
    view:resize(o.width/2-2*(BWIDTH+GAPS),o.height-2*(BWIDTH+GAPS))
  end
  if dir == "right" then
    view:move(o.x+o.width/2+BWIDTH+GAPS,o.y+BWIDTH+GAPS)
    view:resize(o.width/2-2*(BWIDTH+GAPS),o.height-2*(BWIDTH+GAPS))
  end
  if dir == "up" then
    view:move(o.x+BWIDTH+GAPS,o.y+BWIDTH+GAPS)
    view:resize(o.width-2*(BWIDTH+GAPS),o.height/2-2*(BWIDTH+GAPS))
  end
  if dir == "down" then
    view:move(o.x+BWIDTH+GAPS,o.y+o.height/2+BWIDTH+GAPS)
    view:resize(o.width-2*(BWIDTH+GAPS),o.height/2-2*(BWIDTH+GAPS))
  end
end

return M
