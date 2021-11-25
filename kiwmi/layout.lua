local M = {}

function M:ROUND(x) return math.floor(x+0.5) end

function M:layout_tile()
  local n = #WS[WSCUR]
  if n < 1 then return end

  local o = OUTPUT:usable_area()
  local vx,vy,vw,vh

  local m = (n<=MCOUNT and n or MCOUNT)       -- master count
  local s = n-m                               -- stack count

  local uw = o.width-4*BWIDTH-3*GAPS          -- total usable width
  local umw = self:ROUND(uw*MWIDTH)           -- total usable master width
  local usw = uw-umw                          -- total usable stack width

  local umh = o.height-2*m*BWIDTH-(m+1)*GAPS  -- total usable master height
  local mh = math.floor(umh/m)                -- mh = master view height
  local ush = o.height-2*s*BWIDTH-(s+1)*GAPS  -- total usable stack height
  local sh = math.floor(ush/s)                -- sh = stack view height

  for i,j in ipairs(WS[WSCUR]) do
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
  LAYOUT = 1
end

function M:layout_monocle()
  if #WS[WSCUR] < 1 then return end
  local o = OUTPUT:usable_area()
  for _,v in ipairs(WS[WSCUR]) do
    v:move(o.x+BWIDTH+GAPS,o.y+BWIDTH+GAPS)
    v:resize(o.width-2*(BWIDTH+GAPS),o.height-2*(BWIDTH+GAPS))
  end
  OUTPUT:redraw()
  LAYOUT = 2
end

function M:arrange_layout()
  if LAYOUT == 1 then
    self:layout_tile()
  elseif LAYOUT == 2 then
    self:layout_monocle()
  end
end

function M:incMasterWidth()
  MWIDTH = MWIDTH < 0.75 and MWIDTH+0.05 or 0.75
  self:arrange_layout()
end

function M:decMasterWidth()
  MWIDTH = MWIDTH > 0.25 and MWIDTH-0.05 or 0.25
  self:arrange_layout()
end

function M:incMasterCount()
  MCOUNT = MCOUNT+1
  self:arrange_layout()
end

function M:decMasterCount()
  MCOUNT = MCOUNT<=1 and 1 or MCOUNT-1
  self:arrange_layout()
end

return M
