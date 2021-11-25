local M = {}

M.fs = {
  s = false,
  x = 0,
  y = 0,
  w = 0,
  h = 0,
}

local _lt = require('layout')

-- hide all views in workspace given or current
function M:hideWorkspace(ws)
  local w = ws or WSCUR
  for _,v in ipairs(WS[w]) do
    v:hide()
  end
  OUTPUT:redraw()
end

-- show all views in workspace given or current
function M:showWorkspace(ws)
  local w = ws or WSCUR
  for _,v in ipairs(WS[w]) do
    v:show()
  end
  OUTPUT:redraw()
end

-- switch to given workspace
function M:switchWorkspace(ws)
  self:hideWorkspace()
  WSPRV = WSCUR
  WSCUR = ws
  self:showWorkspace()
  self:focusView()
end

-- show the last workspace switched from
function M:showLastWorkspace()
  self:showWorkspace(WSPRV)
end

-- return the position of view in a workspace
-- and the workspace number
function M:getViewPos(view)
  -- check the current workspace first
  for i,j in ipairs(WS[WSCUR]) do
    if j == view then return i,WSCUR end
  end
  -- check all other visible workspaces
  for w,_ in ipairs(WS) do
    if w ~= WSCUR then
      for i,j in ipairs(WS[w]) do
        if j == view then return i,w end
      end
    end
  end
  -- check the hidden workspace as well
  for i,j in ipairs(WS[-1]) do
    if j == view then return i,-1 end
  end
end

function M:focusView(view,ws)
  -- if workspace not given assume current workspace
  local w = ws or WSCUR
  -- if valid view and not focused already, then
  -- store the workspace[0] as focused view
  if view and view ~= kiwmi:focused_view() then
    WS[w][0] = view
  end
  -- focus on workspace[0] which stores focused view
  if WS[w][0] then
    if WS[w] == WS[WSCUR] then
      kiwmi:unfocus()
      WS[w][0]:show()
      WS[w][0]:focus()
    else
      self:switchWorkspace(w)
      self:focusView()
    end
  end
end

-- add view to workspace given or current
function M:addView(view,ws)
  local w = ws or WSCUR
  table.insert(WS[w],1,view)
  WS[w][0] = view -- store view at workspace[0]
  view:csd(false)
  view:tiled(true)
end

function M:removeView(view)
  -- get the position and workspace of the view
  local i,w = self:getViewPos(view)
  -- remove view from table
  table.remove(WS[w],i)
  -- if view was last focused view then
  -- update the focused view
  if view == WS[w][0] then
    local n = #WS[w]
    if n == 0 then WS[w][0] = false return end
    if i <= n then WS[w][0] = WS[w][i] end
    if i > n then WS[w][0] = WS[w][n] end
    if WS[w] == WS[WSCUR] then self:focusView() end
  end
end

-- focus next view on current workspace
function M:focusViewNext()
  if #WS[WSCUR] < 2 then return end
  local i,_ = self:getViewPos(WS[WSCUR][0])
  local next = WS[WSCUR][i+1]
  if next then
    self:focusView(next)
  else
    self:focusView(WS[WSCUR][1])
  end
end

-- focus prev view on current workspace
function M:focusViewPrev()
  if #WS[WSCUR] < 2 then return end
  local i,_ = self:getViewPos(WS[WSCUR][0])
  if i > 1 then
    self:focusView(WS[WSCUR][i-1])
  else
    self:focusView(WS[WSCUR][#WS[WSCUR]])
  end
end

-- focus on master/last view spawned on current workspace
-- from any other focused view on the current workspace
function M:focusViewMaster()
  if #WS[WSCUR] < 2 or kiwmi:focused_view() == WS[WSCUR][1] then return end
  self:focusView(WS[WSCUR][1])
end

-- make the currently focused view the master view
-- of the workspace
-- automatically calls layout arrange
function M:switchViewMaster()
  if #WS[WSCUR] < 2 then return end
  local i,_ = self:getViewPos(WS[WSCUR][0])
  WS[WSCUR][i],WS[WSCUR][1] = WS[WSCUR][1],WS[WSCUR][i]
  _lt:arrange_layout()
end

-- toggle fullscreen on a view
function M:toggleViewFullscreen(view)
  if not view then return end
  if self.fs.s then
    view:move(self.fs.x,self.fs.y)
    view:resize(self.fs.w,self.fs.h)
    self.fs.s = false
  else
    self.fs.x,self.fs.y = view:pos()
    self.fs.w,self.fs.h = view:size()
    view:move(OUTPUT:pos())
    view:resize(OUTPUT:size())
    self.fs.s = true
  end
  OUTPUT:redraw()
end

return M
