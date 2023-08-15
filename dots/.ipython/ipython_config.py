c = get_config()

c.TerminalIPythonApp.display_banner = False
c.InteractiveShellApp.log_level = 20
# c.InteractiveShellApp.matplotlib = 'gtk4'
c.InteractiveShellApp.extensions = ['autoreload']
c.InteractiveShellApp.exec_lines = [
    '%autoreload 2',
    'import numpy as np',
    'import pandas as pd',
]
c.InteractiveShell.autoindent = True
c.InteractiveShell.confirm_exit = False
c.InteractiveShell.editor = 'vim'
c.InteractiveShell.xmode = 'Context'

c.PrefilterManager.multi_line_specials = True
c.AliasManager.user_aliases = [('ls', 'ls')]
