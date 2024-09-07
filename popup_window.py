from typing import List
from kitty.boss import Boss
from kittens.tui.loop import debug
import sys
import subprocess


# in main, STDIN is for the kitten process and will contain
# the contents of the screen
def main(args: List[str]) -> str:
#    answer = input('Enter something')
#    return answer
#    subprocess.run(['fish -c'],['/home/vivian/.config/fish/functions/_fifc.fish'])
#    return sys.stdin.read()i
#    return 'HEEEEEY'
    pass


# in handle_result, STDIN is for the kitty process itself, rather
# than the kitten process and should not be read from.
from kittens.tui.handler import result_handler
@result_handler(no_ui=True)
def handle_result(args: List[str], stdin_data: str, target_window_id: int, boss: Boss) -> None:
    w = boss.window_id_map.get(target_window_id)
#    y = boss.window_id_map.get(active_window_id)
#    tab = boss.active_tab
#    boss.call_remote_control(w, ('send-text', '--bracketed-paste=enable', f'--match=id:{w.id}', f' {stdin_data}'))
#    boss.call_remote_control(w, ('get-text'))
#    popup_id = boss.call_remote_control(w, ('launch', '--type=os-window', '--color=background=black', '--no-response', '--window-title=Popup', '/usr/bin/fish', f'-c _fifc {args[1]} | kitten @ send-text --match=id:{w.id} --stdin'))
    argstr = ' '.join(args[1:])
#    popup_id = boss.call_remote_control(w, ('launch', '--spacing', 'padding=0', '--type=os-window', '--color=background=black', '--no-response', '--window-title=Popup', '/usr/bin/fish', f'-c kitten @ send-text --match=id:{w.id} (_fifc {argstr})'))
    popup_id = boss.call_remote_control(w, ('launch', '--spacing', 'padding=0', '--spacing', 'margin=15', '--type=os-window', '--color=background=black', '--no-response', '--window-title=Popup', '/usr/bin/fish', f'-c {argstr}'))
#    result = boss.call_remote_control(w, ('get-text', f'--match=id:{popup_id}', '--extent=last_cmd_output'))
    y = boss.window_id_map.get(popup_id)
#    boss.call_remote_control(y, ('--to', 'unix:/tmp/output'))
#    test = boss.call_remote_control(y,('get-text', '--extent=output'))
#    boss.call_remote_control(w, ('send-text', f'--match=id:{w.id}', '--bracketed-paste=enable', f'{test}'))
