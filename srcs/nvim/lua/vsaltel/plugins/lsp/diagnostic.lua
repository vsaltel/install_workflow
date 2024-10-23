return {
	"m-gail/diagnostic_manipulation.nvim",
	event = "VeryLazy",
	init = function ()
		require("diagnostic_manipulation").setup {
			blacklist = {
				function(diagnostic)
					blacklst = {
						-- "Included header",
						-- "Unknown type name",
						-- "declared as a function",
						-- "Call to undeclared function",
						"Too many errors",
						-- "In included file"
					}
					for i in ipairs(blacklst) do
						ret = string.find(diagnostic.message, blacklst[i])
						if ret then
							return ret
						end
					end
					return nil
				end
				--require("diagnostic_manipulation.builtin.tsserver").tsserver_codes({ 6133, 6196 })
			},
			whitelist = {
				-- Your whitelist here
			}
		}
	end
}
