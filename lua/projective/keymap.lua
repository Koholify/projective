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

	vim.keymap.set('n', '<leader>pe', ':ProjectiveEnable', {desc = "Enable Projective"})
	vim.keymap.set('n', '<leader>pc', ':ProjectiveCompile<cr>', {desc = "Compile With Projective"})
	vim.keymap.set('n', '<leader>px', ':ProjectiveRun', {desc = "Run Proj From Projective Root"})
	vim.keymap.set('n', '<leader>pt', ':ProjectiveSetTarget ', {desc = "Set Target For Projective Run"})
	vim.keymap.set('n', '<leader>pz', ':ProjectiveRunAsync ', {desc = "Run target async with stdout/stderr to a buffer"})
end

return {
	setup = setup,
	create_commands = create_commands,
}
