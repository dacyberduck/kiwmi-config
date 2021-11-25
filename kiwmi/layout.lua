local M = {}

function M:ROUND(x) return math.floor(x+0.5) end

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
      vx = i <= MCOUNT and o.x+BWIDTH or o.x+self:ROUND(o.width*MWIDTH)+BWIDTH
      vy = i <= MCOUNT and o.y+self:ROUND(o.height/MCOUNT)*(i-1)+BWIDTH or o.y+self:ROUND(o.height/(n-MCOUNT))*(i-(MCOUNT+1))+BWIDTH
      vw = i <= MCOUNT and self:ROUND(o.width*MWIDTH)-2*BWIDTH or o.width-self:ROUND(o.width*MWIDTH)-2*BWIDTH
      vh = i <= MCOUNT and self:ROUND(o.height/MCOUNT)-2*BWIDTH or self:ROUND(o.height/(n-MCOUNT))-2*BWIDTH
      j:move(vx,vy)
      j:resize(vw,vh)
    end
  end
  OUTPUT:redraw()
  LAYOUT = 1
end

function M:layout_monocle()
  if #WS[WSCUR] < 1 then return end
  local o = OUTPUT:usable_area()
  for _,v in ipairs(WS[WSCUR]) do
    v:move(o.x+BWIDTH,o.y+BWIDTH)
    v:resize(o.width-2*BWIDTH,o.height-2*BWIDTH)
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
