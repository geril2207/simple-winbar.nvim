---@class SimpleWinbarConfig
local default_config = {
	enabled = true,
	events = { "DirChanged", "BufEnter", "BufFilePost", "BufWritePost" },
	separator = "›",
	show_path = true,
	left_spacing = nil,

	exclude_filetypes = {},
}

---@class SimpleWinbar
---@field config SimpleWinbarConfig
local M = {}

---@param opts SimpleWinbarConfig?
M.setup = function(opts)
	opts = opts or {}
	M.config = vim.tbl_deep_extend("force", default_config, opts)

	if M.config.enabled then
		require("simple-winbar.core").attach_aucmd()
	end
end

return M
