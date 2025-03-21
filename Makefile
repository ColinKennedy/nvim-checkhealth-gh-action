.PHONY: api_documentation llscheck luacheck stylua test

CONFIGURATION = .luarc.json

llscheck:
	VIMRUNTIME="`nvim --clean --headless --cmd 'lua io.write(os.getenv("VIMRUNTIME"))' --cmd 'quit'`" llscheck --configpath $(CONFIGURATION) .

luacheck:
	luacheck main.lua

check-stylua:
	stylua main.lua --color always --check

stylua:
	stylua main.lua
