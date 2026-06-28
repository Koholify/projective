# Projective
## Project utility for running commands inside neovim

## Install

### Lazy
```
{
    'Koholify/projective',
    lazy = false,
    opts = {
        command = { 'cmake', '--build', 'build', },
        target = { './a.out' },
        ignore_keymap = false,
    },
}
```

### Local `init.lua`
```
require('projective').setup({
    command = { 'cmake', '--build', 'build', },
    target = { './a.out' },
    ignore_keymap = false,
})
```

## Keymap
```
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
```

