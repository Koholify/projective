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
	vim.keymap.set('n', '<leader>pe', ':ProjectiveEnable', {desc = "Enable Projective"})
	vim.keymap.set('n', '<leader>pc', ':ProjectiveCompile<cr>', {desc = "Compile With Projective"})
	vim.keymap.set('n', '<leader>px', ':ProjectiveRun', {desc = "Run Proj From Projective Root"})
	vim.keymap.set('n', '<leader>pt', ':ProjectiveSetTarget ', {desc = "Set Target For Projective Run"})
	vim.keymap.set('n', '<leader>pz', ':ProjectiveRunAsync ', {desc = "Run target async with stdout/stderr to a buffer"})
```

