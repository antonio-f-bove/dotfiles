return {
  'ggandor/leap.nvim',
  config = function()
    require 'leap'.create_default_mappings()
    -- require'leap.user'.set_repeat_keys('<enter>', '<backspace>')
  end,
  -- TODO:
  -- dependencies = {
  --   'repeat.vim'
  -- }
}
