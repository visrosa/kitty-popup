#! /usr/bin/env fish
function popup
	set -x cmd (commandline -co) (commandline -ct)
	set -S cmd
	kitty \
			-o background_opacity=1 \
			-o background=black \
			#--listen-on unix:/tmp/popup
		kitten @ launch \
			--type os-window \
			--window-title 'Popup' \
			--copy-env \
			--cwd \
			--copy-cmdline \
			--no-response \
			/home/vivian/fif.fish $cmd \
		2>/dev/null
end

