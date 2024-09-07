#! /usr/bin/env fish
function popup
	#set -x cmd (commandline -co) (commandline -ct)
	#set -l newcmdline (commandline -co)
	#commandline -r (string collect "$newcmdline ")
	#		wrangle_cmdline
		#		set -S cmd
		#	kitty \
		#		-o background_opacity=1 \
		#		-o background=black \
		#		#--listen-on unix:/tmp/popup
		#		kitten @ launch \
		#		--type os-window \
		#		--window-title 'Popup' \
		#		--copy-env \
		#		--cwd \
		#		--copy-cmdline \
		#		--no-response \
		#		/home/vivian/fif.fish $cmd \
		#		2>/dev/null
	kitten @ kitten popup_window.py "$cmd" &
		#	get_comp_result
end

function wrangle_cmdline
    set -f --export SHELL (command --search fish)
    set -Ux result
    set -Ux _fifc_extract_regex
    set -gx _fifc_complist_path (string join '' (mktemp) "_fifc")
    set -gx _fifc_custom_fzf_opts
    set -gx fifc_extracted
    set -gx fifc_commandline
    set -gx fifc_token (commandline --current-token)
    set -gx fifc_query "$fifc_token"
	#	echo "fifc_token is $fifc_token"
    # Get commandline buffer
    if test "$argv" = ""; and status --is-interactive
        set fifc_commandline (commandline --cut-at-cursor)
    end

    if _fifc_test_version "$FISH_VERSION" -ge "3.4"
        set complete_opts --escape
    end

    complete -C $complete_opts -- "$fifc_commandline" | string split '\n' >$_fifc_complist_path

    set -gx fifc_group (_fifc_completion_group)
    set source_cmd (_fifc_action source)

    set fifc_fzf_query (string trim --chars '\'' -- "$fifc_fzf_query")
	kitten @ kitten popup_window.py menu
	#set -S result
    # Add space trailing space only if:
    # - there is no trailing space already present
    # - Result is not a directory
    # We need to unescape $result for directory test as we escaped it before
    if test (count $result) -eq 1; and not test -d (string unescape -- $result[1])
			set -x buffer (string split -- "$fifc_commandline" (commandline -b))
			set -S fifc_commandline
			echo "Buffer is: $buffer"
		else
			if not string match -- ' *' "$buffer[2]"
        	set -a result ''
			echo "Didn't match space adding: $result"
        end
    end
end

function get_comp_result
	if test -n "$result"
		if status --is-interactive
			echo "Replacing current token with $result"
			commandline --replace --current-token -- (string join -- ' ' $result)
		else
			set -l trimresult (string replace -ar '[^[:graph:]]' '' "$result")
			#			echo (string replace -ar '\r' '' $trimresult)
			echo $trimresult
			#			kitten @ send-text --to unix:/tmp/output (string join -- ' ' $result)
		end
	end

	if status --is-interactive	
		echo Repainting
		commandline --function repaint
		#	else
		#		echo $result
		#		kitten @ send-text --to unix:/tmp/output (string join -- ' ' $result)
	end
		


	rm $_fifc_complist_path
    # Clean state
    set -e _fifc_extract_regex
    set -e _fifc_custom_fzf_opts
    set -e _fifc_complist_path
    set -e fifc_token
    set -e fifc_group
    set -e fifc_extracted
    set -e fifc_candidate
    set -e fifc_commandline
    set -e fifc_query
end

function menu
    set -l fzf_cmd "
		fzf \
            -d \t \
            --exact \
            --tiebreak=length \
            --select-1 \
            --exit-0 \
            --ansi \
            --tabstop=4 \
            --reverse \
			--height 15 \
			--cycle \
            --header '$header' \
            --preview '_fifc_action preview {} {q}' \
            --bind='$fifc_open_keybinding:execute(_fifc_action open {} {q} &> /dev/tty)' \
			--bind='tab:down' \
			--bind='shift-tab:up' \
            --query '$fifc_query' \
            $_fifc_custom_fzf_opts"
    set -l cmd (string join -- " | " $source_cmd $fzf_cmd)
	kitten @ kitten popup_window.py 
	#	set -S cmd
	#	eval $cmd
    # We use eval hack because wrapping source command
    # inside a function cause some delay before fzf to show up
    eval $cmd | while read -l token
		echo "Token is: $token"
        # don't escape '~' for path, `$` for environ
        if string match --quiet '~*' -- $token
            set -a result (string join -- "" "~" (string sub --start 2 -- $token | string escape))
			echo "Matched ~*: $result"
        else if string match --quiet '$*' -- $token
            set -a result (string join -- "" "\$" (string sub --start 2 -- $token | string escape))
			echo "Matched \$*: $result"
        else
            set -a result (string escape --no-quoted -- $token)
			echo "Else case match: $result"
        end
        # Perform extraction if needed
        if test -n "$_fifc_extract_regex"
            set result[-1] (string match --regex --groups-only -- "$_fifc_extract_regex" "$token")
			echo "Extract regex case: $result"
        end
    end
end
