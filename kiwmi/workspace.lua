local M = {}
local _view = require('kiwmi.view')

function M:hideWorkspace()
  for _,v in ipairs(WS[WSCUR]) do
    v:hide()
  end
end

function M:updateWorkspace()
  for _,v in ipairs(WS[WSCUR]) do
    v:show()
  end
  _view:focusView()
  OUTPUT:redraw()
end

function M:showWorkspace(id)
  self:hideWorkspace()
  WSPRV = WSCUR
  WSCUR = id
  self:updateWorkspace()
end

function M:showLastWorkspace()
  self:showWorkspace(WSPRV)
end

function M:sendViewToWorkspace(view,ws_id)
  if WS[ws_id] == WS[WSCUR] or not WS[ws_id] then return end
  local i = _view:getViewPos(view)
  _view:removeView(view)
  table.insert(WS[ws_id],1,view)
  WS[ws_id][0] = view
  view:hide()
  self:updateWorkspace()
end


return M
