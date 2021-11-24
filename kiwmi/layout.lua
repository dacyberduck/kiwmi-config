local M = {}

function M:ROUND(x) return math.floor(x+0.5) end

function M:layout_monocle()
  if #WS[WSCUR] < 1 then return end
  local o = OUTPUT:usable_area()
  for _,v in ipairs(WS[WSCUR]) do
    v:move(o.x+BWIDTH,o.y+BWIDTH)
    v:resize(o.width-2*BWIDTH,o.height-2*BWIDTH)
  end
  OUTPUT:redraw()
  LAYOUT = 0
end

function M:layout_tile()
  local n = #WS[WSCUR]
  if n < 1 then return end

  local o = OUTPUT:usable_area()

  if n == 1 then
    local v = WS[WSCUR][1]
    v:move(o.x+BWIDTH,o.y+BWIDTH)
    v:resize(o.width-2*BWIDTH,o.height-2*BWIDTH)
  else
    local vx,vy,vw,vh
    for i,j in ipairs(WS[WSCUR]) do
      vx = i == 1 and o.x+BWIDTH or o.x+self:ROUND(o.width*MWIDTH)+BWIDTH
      vy = i == 1 and o.y+BWIDTH or o.y+self:ROUND(o.height/(n-1))*(i-2)+BWIDTH
      vw = i == 1 and self:ROUND(o.width*MWIDTH)-2*BWIDTH or o.width-self:ROUND(o.width*MWIDTH)-2*BWIDTH
      vh = i == 1 and o.height-2*BWIDTH or self:ROUND(o.height/(n-1))-2*BWIDTH
      j:move(vx,vy)
      j:resize(vw,vh)
    end
  end
  OUTPUT:redraw()
  LAYOUT = 1
end

function M:layout_last()
  if LAYOUT == 1 then self:layout_tile() end
  if LAYOUT == 0 then self:layout_monocle() end
end

return M
