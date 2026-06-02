-- TODO: vtsls config
-- https://www.lazyvim.org/extras/lang/typescript/vtsls
-- might want to use for inspiration?

local utils = require 'anto.utils'

return {
  settings = {
    vtsls = {
      autoUseWorkspaceTsdk = true,
    },
  },
  on_attach = function(client, bufnr)
    if utils.is_angular_project(bufnr) then
      client.server_capabilities.referencesProvider = false
      client.server_capabilities.renameProvider = false
    end
  end,
}
