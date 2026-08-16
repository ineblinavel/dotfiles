#!/usr/bin/env python3

"""
    Um script basico que pega todos os meu repos e mostra com o rofi
"""

import sys
from subprocess import run
import json
import urllib.request
import os

def open_in_browser(url):
    return run(["xdg-open", url])


def open_in_rofi(choices):
    blob = "\n".join(choices)
    cmd = ['rofi', '-dmenu', '-p', 'repos']
    result = run(cmd, input=blob, capture_output=True, text=True)
    return result.stdout.strip()


def get_all_projects():
    url = "https://api.github.com/user/repos"
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        raise SystemExit("Defina GITHUB_TOKEN para consultar seus repositórios privados")
    request = urllib.request.Request(url)
    request.add_header("Authorization", f"Bearer {token}")
    request.add_header("Accept", "application/vnd.github+json")

    with urllib.request.urlopen(request, timeout=15) as response:
        data = response.read().decode()
        json_data = json.loads(data)

    return {repo["name"]: repo["html_url"] for repo in json_data}


def main():
    choices = get_all_projects()
    choice = open_in_rofi(choices.keys())
    if not choice:
        sys.exit(1)
    result = open_in_browser(choices[choice])
    if result.returncode != 0:
        sys.exit(1)
    
if __name__ == "__main__":
    main()
