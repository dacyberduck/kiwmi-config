local M = {}
local _lt = require('kiwmi.layout')

function M:getViewPos(view)
  for i,j in ipairs(WS[WSCUR]) do
    if j == view then return i end
  end
end

function M:focusView(view)
  if view and view ~= kiwmi:focused_view() then
    WS[WSCUR][0] = view
  end
  if WS[WSCUR][0] then
    kiwmi:unfocus()
    WS[WSCUR][0]:show()
    WS[WSCUR][0]:focus()
  end
end

function M:addView(view)
  table.insert(WS[WSCUR],1,view)
  WS[WSCUR][0] = view
  view:csd(false)
  view:tiled(true)
end

function M:removeView(view)
  local i = self:getViewPos(view)
  table.remove(WS[WSCUR],i)
  if view == kiwmi:focused_view() then
    local n = #WS[WSCUR]
    if n == 0 then return true end
    if i <= n then WS[WSCUR][0] = WS[WSCUR][i] end
    if i > n then WS[WSCUR][0] = WS[WSCUR][n] end
    self:focusView()
  end
end

function M:focusViewNext(view)
  if #WS[WSCUR] < 2 then return end
  local i = self:getViewPos(view)
  local next = WS[WSCUR][i+1]
  if next then
    self:focusView(next)
  else
    self:focusView(WS[WSCUR][1])
  end
end

function M:focusViewPrev(view)
  if #WS[WSCUR] < 2 then return end
  local i = self:getViewPos(view)
  if i > 1 then
    self:focusView(WS[WSCUR][i-1])
  else
    self:focusView(WS[WSCUR][#WS[WSCUR]])
  end
end

function M:focusViewMaster()
  if #WS[WSCUR] < 2 or kiwmi:focused_view() == WS[WSCUR][1] then return end
  self:focusView(WS[WSCUR][1])
end

function M:switchViewMaster(view)
  if #WS[WSCUR] < 2 then return end
  i = self:getViewPos(view)
  WS[WSCUR][i],WS[WSCUR][1] = WS[WSCUR][1],WS[WSCUR][i]
  _lt:arrange_layout()
end

return M
