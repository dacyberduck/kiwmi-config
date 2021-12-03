local M = {}

M.wscur = 1
M.wsprv = 1

local _lt = require('layout')

-- return the position of view in a workspace
-- and the workspace number
function M:getViewPos(view,ws)
  -- first check the workspace if given
  if ws and WS[ws]then
    for i,j in ipairs(WS[ws]) do
      if j == view then return i,ws end
    end
  end
  -- then check the current workspace
  for i,j in ipairs(WS[WSCUR]) do
    if j == view then return i,WSCUR end
  end
  -- check all other visible workspaces
  for w,_ in ipairs(WS) do
    if w ~= WSCUR and w ~= ws then
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
      self:switchToWorkspace(w)
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

function M:removeView(view,ws)
  -- get the position and workspace of the view
  local i,w = self:getViewPos(view,ws)

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
  local i,_ = self:getViewPos(WS[WSCUR][0],WSCUR)
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
  local i,_ = self:getViewPos(WS[WSCUR][0],WSCUR)
  if i > 1 then
    self:focusView(WS[WSCUR][i-1])
  else
    self:focusView(WS[WSCUR][#WS[WSCUR]])
  end
end

-- focus on last view spawned on current workspace
-- or simply the first view in the workspace table
-- from any other focused view on the current workspace
function M:focusViewLast()
  if #WS[WSCUR] < 2 or kiwmi:focused_view() == WS[WSCUR][1] then return end
  self:focusView(WS[WSCUR][1])
end

-- make the currently focused view the last view spawned
-- or simply the first entry in the workspace table
-- swap the last spawned view position with the current view position
-- in the workspace table of views
-- this makes the selected view the master view of the workspace
-- and automatically calls layout arrange
function M:makeViewLast()
  if #WS[WSCUR] < 2 then return end
  local i,_ = self:getViewPos(WS[WSCUR][0],WSCUR)
  WS[WSCUR][i],WS[WSCUR][1] = WS[WSCUR][1],WS[WSCUR][i]
  _lt:arrange_layout()
end

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
function M:switchToWorkspace(ws)
  if ws == WSCUR then return end
  self:hideWorkspace()
  if ws ~= -1 then
    self.wsprv = self.wscur
    self.wscur = ws
  end
  WSCUR = ws
  self:showWorkspace()
  self:focusView()
end

-- switch to last focused workspace(not hidden space)
function M:switchToLastWorkspace()
  if WSCUR == -1 then
    self:switchToWorkspace(self.wscur)
  else
    self:switchToWorkspace(self.wsprv)
  end
end

-- switch between hidden space and
-- current space
function M:toggleHiddenSpace()
  if WSCUR == -1 then
    self:switchToWorkspace(self.wscur)
  else
    self:switchToWorkspace(-1)
  end
end

-- send a view to a workspace
function M:sendViewToWorkspace(ws,view)
  local v = view or WS[WSCUR][0]
  if not v or not ws then return end
  -- first remove the vew from existing workspace
  -- and hide the view
  self:removeView(v)
  v:hide()
  -- add the view to the target workspace
  self:addView(v,ws)
  -- update current workspace
  self:focusView()
  self:showWorkspace()
end

-- send a view to hidden space
function M:pushViewToHiddenSpace()
  if WSCUR == -1 then return end
  self:sendViewToWorkspace(-1)
end

-- get back the last view from hidden space
-- to the current space
function M:popViewFromHiddenSpace()
  if WSCUR == -1 then return end
  local v = WS[-1][0]
  if not v then return end
  self:removeView(v,-1)
  self:addView(v)
  v:hide()
  self:focusView()
  self:showWorkspace()
end

return M
