local function create_commands(P)
	vim.api.nvim_create_user_command('ProjectiveEnable',
	function(t)
		if #t.fargs > 0 then P.enable(t.args)
		else P.enable() end
	end,
	{nargs = "*", complete = "shellcmdline"})

	vim.api.nvim_create_user_command('ProjectiveCompile',
	function() P.compile() end,
	{})

	vim.api.nvim_create_user_command('ProjectiveRun',
	function(t) P.run(t.args) end,
	{nargs = "*", complete = "shellcmdline"})

	vim.api.nvim_create_user_command('ProjectiveRunAsync',
	function(t) P.run_async(t.args) end,
	{nargs = "*", complete = "shellcmdline"})

	vim.api.nvim_create_user_command('ProjectiveSetTarget',
	function(t) if #t.args > 0 then P.set_target(t.args) end end,
	{nargs = "*", complete = "shellcmdline"})

	vim.api.nvim_create_user_command('ProjectiveInfo',
	function() vim.print(P) end,
	{})
end

local function setup(P)
	create_commands(P)

    -- Init projective in current working directory, insert compile command to change from default
    -- Directory will be chosen from this priority
    -- 1. Current LSP root folder
    -- 2. Parent Folder with .git, README.md, .editorconfig, Makefile
    -- 3. Current working directory
    -- eg. :ProjectiveEnable make arm-debug
	vim.keymap.set('n', '<leader>pe', ':ProjectiveEnable', {desc = "Enable Projective"})

    -- Run the current compile command
	vim.keymap.set('n', '<leader>pc', ':ProjectiveCompile<cr>', {desc = "Compile With Projective"})

    -- Run an target executable, command will be remembered if run again without args
    -- :ProjectiveRun npm run start
	vim.keymap.set('n', '<leader>px', ':ProjectiveRun', {desc = "Run Proj From Projective Root"})
    -- Run in background with outpput in a seperate buffer
	vim.keymap.set('n', '<leader>pz', ':ProjectiveRunAsync ', {desc = "Run target async with stdout/stderr to a buffer"})

    -- Set target exexutable without running
	vim.keymap.set('n', '<leader>pt', ':ProjectiveSetTarget ', {desc = "Set Target For Projective Run"})
end

return {
	setup = setup,
	create_commands = create_commands,
}
