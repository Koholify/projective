local defaults = require("projective.defaults")

local Projective = {}

Projective.root_dir = nil
Projective.compile_command = nil
Projective.async_buffer = nil
Projective.async_running = nil

Projective.setup = function(opts)
	opts = opts or {}
	Projective.root_dir_identifiers = opts.root_markers or defaults.root_dir_identifiers
	Projective.compile_command = opts.cmd or defaults.command
	Projective.run_target = opts.target or defaults.run_target

	if not opts.ignore_keymap then
		require("projective.keymap").setup(Projective)
	else
		require("projective.keymap").create_commands(Projective)
	end
end

Projective.get_root = function()
	if vim.lsp.buf_is_attached then
		local root = vim.lsp.get_clients()[1].config.root_dir
		if root then
			vim.print("using lsp root directory")
			return root
		end
	end

	local root = vim.fs.root(0, Projective.root_dir_identifiers);
	if root then
		vim.print("using parent directory with matching identifier")
		return root
	else
		vim.print("using current directory")
		return vim.fn.getcwd(0)
	end
end

Projective.set_root = function()
	if not (vim.fn.getcwd(0) == Projective.root_dir) then
		vim.print("changing root dir: " .. Projective.root_dir)
		vim.api.nvim_set_current_dir(Projective.root_dir)
	end
end

Projective.enable = function(cmd)
	Projective.root_dir = Projective.get_root()
	if not Projective.root_dir then
		vim.print("Root Directory Not Found, abort")
		return
	end

	vim.api.nvim_set_current_dir(Projective.root_dir)
	if type(cmd) == "string" or type(cmd) == "table" then
		Projective.compile_command = cmd
	else
		Projective.compile_command = defaults.command
	end

	if type(Projective.compile_command) == "string" then
		vim.cmd("set makeprg=" .. string.gsub(Projective.compile_command, " ", "\\ "))
	elseif type(Projective.compile_command) == "table" then
		vim.cmd("set makeprg=" .. table.concat(Projective.compile_command, "\\ "))
	end

	vim.print("settings ", {cd = Projective.root_dir, cmd = Projective.compile_command})
end

Projective.compile = function()
	if Projective.root_dir then
		Projective.set_root()
		vim.cmd[[:make]]
	else
		vim.print("Projective Workspace Not Enabled")
	end
end

Projective.run = function(f)
	Projective.set_target(f)
	Projective.set_root()
	vim.cmd(":!" .. table.concat(Projective.run_target, " "))
end

Projective.set_target = function(f)
	if f and #f > 0 then
		if type(f) == "string" then
			f = vim.split(f, " ", { trimempty = true })
		end

		if type(f) == 'table' then
			Projective.run_target = f
		end
	end
end

Projective.close_async_buffer = function()

	if Projective.async_buffer then
		vim.api.nvim_buf_delete(Projective.async_buffer, { force = true })
		Projective.async_buffer = nil
	end

	if Projective.async_running then
		Projective.async_running:kill('sigterm')
		Projective.async_running:wait(5000)
	end
end

Projective.run_async = function(f)
	Projective.set_target(f)

	local buf_num = 0
	local buf_name = table.concat(Projective.run_target, " ")

	if Projective.async_running then
		Projective.async_running:kill('sigterm')
		Projective.async_running:wait(5000)
	end

	if Projective.async_buffer then
		buf_num = Projective.async_buffer
		local info = vim.fn.getbufinfo(buf_num)[1]

		if info.hidden == 1 then
			vim.cmd("vs")
			vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf_num)
		end
	else
		vim.cmd("vs")
		buf_num = vim.api.nvim_create_buf(true, true)
		vim.api.nvim_buf_set_name(buf_num, "running "..buf_name)
		vim.keymap.set("n", "q", Projective.close_async_buffer, { buf=buf_num })
		Projective.async_buffer = buf_num

		vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf_num)
	end


	vim.schedule(function()
		vim.api.nvim_buf_set_lines(buf_num, 0, -2, false, {
			"",
			"Exit: q",
			">>" .. buf_name,
			string.rep("-", vim.api.nvim_win_get_width(0) * 0.7)
		})
	end)

	local on_exit = function(obj)
		Projective.async_running = nil;

		if Projective.async_buffer then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf_num, -2, -2, false, { "", string.format("exit status: %d - signal: %d", obj.code, obj.signal) })
			end)

			vim.schedule(function()
				vim.api.nvim_buf_set_name(buf_num, "complete "..buf_name)
			end)
		end
	end

	local on_stdout = function(err, data)
		if err then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf_num, -2, -2, false, vim.split(err:gsub('\r\n', '\n'), '\n', { trimempty = true }))
			end)
		end
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf_num, -2, -2, false, vim.split(data:gsub('\r\n', '\n'), '\n', {trimempty = true }))
			end)
		end
	end

	local on_stderr = function(err, data)
		if err then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf_num, -2, -2, false, vim.split(err:gsub('\r\n', '\n'), '\n', { trimempty = true }))
			end)
		end
		if data then
			vim.schedule(function()
				vim.api.nvim_buf_set_lines(buf_num, -2, -2, false, vim.split(data:gsub('\r\n', '\n'), '\n', {trimempty = true }))
			end)
		end
	end

	local opts = {
		cwd = Projective.root_dir,
		text = true,
		stdout = on_stdout,
		stderr = on_stderr,
	}

	Projective.async_running = vim.system(Projective.run_target, opts, on_exit)
end

return Projective
