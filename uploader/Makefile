# turn off annoying built-ins
.SUFFIXES:

INSTALL_SCRIPT=./install-script

CLEAN_DIRS=./build ./dist ./*.egg-info

install: force
	python3 ./setup.py install

bundle-win: install force
	pyinstaller --clean synapse-upload-win.spec

bundle-mac: install force
	pyinstaller --clean synapse-upload-mac.spec

clean: force
	rm -rf $(CLEAN_DIRS)

uninstall: force
	pip3 uninstall synapse-upload

force:

