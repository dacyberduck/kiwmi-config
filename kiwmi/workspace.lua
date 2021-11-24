local M = {}
local _view = require('kiwmi.view')

function M:hideWorkspace()
  for _,v in ipairs(WS[WSCUR]) do
    v:hide()
  end
end

function M:showWorkspace(id)
  self:hideWorkspace()
  WSPRV = WSCUR
  WSCUR = id
  for _,v in ipairs(WS[WSCUR]) do
    v:show()
  end
  _view:focusView()
  OUTPUT:redraw()
end

return M
