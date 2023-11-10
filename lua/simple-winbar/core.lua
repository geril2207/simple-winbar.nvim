local config = require("simple-winbar").config
local status_web_devicons_ok, web_devicons = pcall(require, "nvim-web-devicons")
local api = vim.api
local fn = vim.fn

local M = {}

local hl_groups = {
	filename = "WinbarFile",
	path = "WinbarFilePath",
	icon = "WinbarFileIcon",
	separator = "WinbarSeparator",
}

---@param value string
---@param hl_group string
---@return string
local wrap_with_hl = function(value, hl_group)
	return "%#" .. hl_group .. "#" .. value .. "%*"
end

local get_filename_line = function()
	local result = ""
	local filename = fn.expand("%:t")
	local filetype = fn.expand("%:e")

	if not filename or filename == "" then
		return result
	end

	if filetype and filetype ~= "" and status_web_devicons_ok then
		local file_icon = web_devicons.get_icon(filename, filetype, { default = false })
		result = result .. "%#DevIcon" .. filetype .. "#" .. file_icon .. " %*"
	end

	result = result .. wrap_with_hl(filename, hl_groups.filename)

	return result
end

---@return string
local get_filepath_line = function()
	local file_path = vim.fn.expand("%:~:.:h")
	file_path = file_path:gsub("^%.", "")
	file_path = file_path:gsub("^%/", "")

	local file_path_list = {}
	local _ = string.gsub(file_path, "[^/]+", function(w)
		table.insert(file_path_list, w)
	end)

	local value = ""

	for i = 1, #file_path_list do
		value = value .. "%#NvimTreeFolderIcon# %*"
		value = value
			.. wrap_with_hl(file_path_list[i], hl_groups.path)
			.. " "
			.. wrap_with_hl(config.separator, hl_groups.separator)
			.. " "
	end

	return value
end

local combine_winbar_line = function()
	local result = ""

	if config.left_spacing then
		if type(config.left_spacing) == "string" then
			result = result .. config.left_spacing
		elseif type(config.left_spacing) == "function" then
			result = result .. config.left_spacing()
		end
	end

	if config.show_path then
		result = result .. get_filepath_line()
	end

	result = result .. get_filename_line()

	return result
end

M.attach_aucmd = function()
	api.nvim_create_autocmd(config.events, {
		callback = function()
			if vim.tbl_contains(config.exclude_filetypes, vim.bo.filetype) then
				return api.nvim_set_option_value("winbar", nil, { scope = "local" })
			end
			local line = combine_winbar_line()

			api.nvim_set_option_value("winbar", line, { scope = "local" })
		end,
	})
end

return M
