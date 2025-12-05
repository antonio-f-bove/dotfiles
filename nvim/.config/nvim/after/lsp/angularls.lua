return {
  on_attach = function(client, bufnr)
    Snacks.util.lsp.on({ name = 'angularls' }, function(_, client)
      --HACK: disable angular renaming capability due to duplicate rename popping up
      client.server_capabilities.renameProvider = false
    end)
    print(vim.inspect(client))
  end,
}
