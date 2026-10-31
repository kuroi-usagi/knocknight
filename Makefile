.PHONY: fmt lint serve build sourcemap

fmt:
	stylua src tests

lint:
	selene src

serve:
	rojo serve

build:
	rojo build -o knocknight.rbxlx

sourcemap:
	rojo sourcemap default.project.json -o sourcemap.json
	wally-package-types --sourcemap sourcemap.json Packages ServerPackages
