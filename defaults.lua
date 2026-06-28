return {
	root_dir_identifiers = {
		'.git',
		'.editorconfig',
		'README.md',
		'Makefile',
		'CMakeLists.txt',
	},

	command = {
		'cmake',
		'--build',
		'build',
	},

	run_target = {
		'./a.out',
	},
}
