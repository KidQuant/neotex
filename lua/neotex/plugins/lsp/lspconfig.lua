return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },

	dependencies = {
		{ "antosha417/nvim-lsp-file-operations", event = "BufReadPost" },
	},

	config = function()
		-- Suppress specific deprecation warnings
		local original_notify = vim.notify
		vim.notify = function(msg, ...)
			if msg:match("framework.*deprecated") or msg:match("vim.lsp.config") then
				return
			end
			return original_notify(msg, ...)
		end
		vim.defer_fn(function()
			vim.notify = original_notify
		end, 100)

		-- Diagnostic signs and display
		local signs = { Error = "", Warn = "", Hint = "󰠠", Info = "" }
		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = signs.Error,
					[vim.diagnostic.severity.WARN] = signs.Warn,
					[vim.diagnostic.severity.HINT] = signs.Hint,
					[vim.diagnostic.severity.INFO] = signs.Info,
				},
			},
			update_in_insert = false,
			severity_sort = true,
		})

		-- Prevent stylua from being used as LSP
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "stylua" then
					vim.lsp.stop_client(client.id)
				end
			end,
			desc = "Disable stylua as LSP client",
		})

		-- Extra protection if stylua somehow runs
		if vim.lsp.handlers and vim.lsp.handlers["textDocument/didOpen"] then
			local original_handler = vim.lsp.handlers["textDocument/didOpen"]
			vim.lsp.handlers["textDocument/didOpen"] = function(err, result, ctx, config)
				local client = vim.lsp.get_client_by_id(ctx.client_id)
				if client and client.name == "stylua" then
					return
				end
				return original_handler(err, result, ctx, config)
			end
		end

		-- Filetype to server mapping
		local filetype_servers = {
			lua = "lua_ls",
			python = "pyright",
			tex = "texlab",
			latex = "texlab",
		}

		local capabilities = vim.lsp.protocol.make_client_capabilities()

		-- Auto-setup per filetype
		vim.api.nvim_create_autocmd("FileType", {
			pattern = vim.tbl_keys(filetype_servers),
			callback = function()
				local ft = vim.bo.filetype
				local server = filetype_servers[ft]
				if not server then
					return
				end

				local ok, lsp = pcall(require, "lspconfig." .. server)
				if not ok then
					vim.notify("Could not load LSP server: " .. server, vim.log.levels.WARN)
					return
				end

				local ok_cmp, blink = pcall(require, "blink.cmp")
				if ok_cmp then
					capabilities = blink.get_lsp_capabilities(capabilities)
				end

				local on_attach = function(client, bufnr)
					-- Put your keymaps or LSP-related buffer logic here
				end

				local config = {
					capabilities = capabilities,
					on_attach = on_attach,
				}

				-- Server-specific settings
				if server == "lua_ls" then
					config.settings = {
						Lua = {
							diagnostics = { globals = { "vim" } },
							workspace = {
								library = {
									[vim.fn.expand("$VIMRUNTIME/lua")] = true,
									[vim.fn.stdpath("config") .. "/lua"] = true,
								},
							},
						},
					}
				elseif server == "texlab" then
					config.settings = {
						texlab = {
							build = { onSave = true },
							chktex = { onEdit = false, onOpenAndSave = false },
							diagnosticsDelay = 300,
						},
					}
				end

				-- Start the server
				lsp.setup(config)
			end,
			desc = "Auto-load LSP server by filetype",
		})
	end,
}
