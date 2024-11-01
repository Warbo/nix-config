#!/usr/bin/env python3
from json import loads
from shutil import which
from subprocess import run, DEVNULL
from sys import stderr
from threading import Thread

dbg = lambda **xs: stderr.write(repr(xs) + "\n")

def socat(ip, from_port=80, to_port=80):
    """Tunnel localhost:from_port to ip:to_port in a background socat process"""
    # We need to look up socat in our PATH, since sudo uses a different PATH
    executable = which("socat")
    assert executable is not None
    Thread(
        target=run,
        args=([
            "sudo",
            executable,
            f"tcp-listen:{from_port},reuseaddr,fork",
            f"tcp:{ip}:{to_port}",
        ],),
        kwargs=dict(stdout=DEVNULL, stderr=DEVNULL, check=True),
        daemon=True,
    ).start()

def podman_url(ip=None, port=None):
    if ip is None:
        # TODO: Allow container ID to be passed. For now we use -l for latest.
        dbg(action="Fetching IP")
        proc = run(
            ["podman", "container", "inspect", "-l"],
            capture_output=True
        )
        got = loads(proc.stdout)[0]["NetworkSettings"]["IPAddress"]
        dbg(got=got)
    else:
        got = ip
    socat(got)

    return "http://" + got + ":" + str(port or 4444) + "/wd/hub"

def selenium_session(url):
    import urllib.request
    got = loads(urllib.request.urlopen(url + "/sessions").read())
    dbg(got=got)
    error = {
        (got["status"] == 0): "Expected status 0",
        (len(got["value"]) == 1): "Expected a single session",
    }.get(False)
    assert error is None, repr({"error": error, "got": got})
    return got["value"][0]["id"]

def setup_selenium():
    url = input(
        "Enter Selenium server URL (leave empty to inspect Podman): "
    ) or podman_url()
    dbg(url=url)

    from selenium.webdriver.remote.webdriver import WebDriver
    class ExistingSessionDriver(WebDriver):
        def start_session(self, capabilities):
            self.session_id = selenium_session(url)

    return ExistingSessionDriver(command_executor=url, options=[])

import code
code.InteractiveConsole(locals={'driver': setup_selenium()}).interact(
    banner="""
      Selenium WebDriver connected. Use 'driver' to interact with the browser.
      Example: driver.execute_script('''return window.location.href''').
    """
)
