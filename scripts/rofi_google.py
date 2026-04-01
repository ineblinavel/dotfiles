#!/usr/bin/env python3

"""
Um simples script pra abrir uma barra de pesquisa do google
"""

import sys
from subprocess import run
import urllib.parse
import webbrowser

def open_rofi_input():
    cmd = [
        'rofi', 
        '-dmenu', 
        '-p', 'Google', 
        '-theme-str',
        'window {width: 60%; height: 2.7em;} listview {enabled: false;}'
    ]
    result = run(cmd, input="", capture_output=True, text=True)
    return result.stdout.strip()

def main():
    query = open_rofi_input()
    if not query:
        sys.exit(1)
    encoded_query = urllib.parse.quote_plus(query)
    url = f"https://www.google.com/search?q={encoded_query}"
    webbrowser.open(url)

if __name__ == "__main__":
    main()