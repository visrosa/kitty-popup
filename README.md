Attempts at making fzf completion (through [fifc](https://github.com/gazorby/fifc) open in a popup).

`popup.fish` opens a new kitty window while saving the current commandline in a variable.
`fif.fish` only exists because `kitten launch` requires an executable.
`_fifc` is the completion function that I modified to work without an interactive shell (not sure why it's considered non-interactive) and to send the results to a socket which the original window has to be listening to.
