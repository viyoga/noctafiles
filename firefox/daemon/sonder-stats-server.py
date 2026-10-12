#!/usr/bin/env python3
"""
Sonder Startpage System Stats Server
Ultra-lightweight background daemon serving live CPU, RAM, and Network I/O stats to Sonder.
"""

import json
import os
import sys
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler

HOST = "127.0.0.1"
PORT = 9191

current_stats = {
    "cpu": "0%",
    "cpu_val": 0,
    "ram": "0%",
    "ram_val": 0,
    "ram_display": "0%",
    "ram_used_gb": "0.0",
    "ram_total_gb": "0.0",
    "down": "0 B/s",
    "down_bytes": 0,
    "up": "0 B/s",
    "up_bytes": 0,
}
stats_lock = threading.Lock()


def format_speed(b):
    if b < 1024:
        return f"{int(b)} B/s"
    elif b < 1024 * 1024:
        return f"{b / 1024:.1f} KB/s"
    elif b < 1024 * 1024 * 1024:
        return f"{b / (1024 * 1024):.1f} MB/s"
    else:
        return f"{b / (1024 * 1024 * 1024):.2f} GB/s"


def read_proc_stat():
    try:
        with open("/proc/stat", "r") as f:
            fields = [float(x) for x in f.readline().split()[1:]]
        idle = fields[3] + (fields[4] if len(fields) > 4 else 0)
        total = sum(fields)
        return idle, total
    except Exception:
        return 0.0, 0.0


def read_proc_mem():
    try:
        with open("/proc/meminfo", "r") as f:
            lines = dict(line.split(":") for line in f if ":" in line)
        total = int(lines["MemTotal"].split()[0])
        avail = int(lines["MemAvailable"].split()[0])
        used = total - avail
        pct = round((used / total) * 100) if total > 0 else 0
        used_gb = used / (1024 * 1024)
        total_gb = total / (1024 * 1024)
        return pct, used_gb, total_gb
    except Exception:
        return 0, 0.0, 0.0


def read_proc_net():
    rx = 0
    tx = 0
    try:
        with open("/proc/net/dev", "r") as f:
            for line in f:
                if ":" in line:
                    iface, data = line.split(":", 1)
                    iface = iface.strip()
                    if iface != "lo":
                        cols = data.split()
                        rx += int(cols[0])
                        tx += int(cols[8])
    except Exception:
        pass
    return rx, tx


def stats_sampler():
    global current_stats
    prev_idle, prev_total = read_proc_stat()
    prev_rx, prev_tx = read_proc_net()
    prev_time = time.time()

    while True:
        time.sleep(1.0)
        now = time.time()
        dt = max(0.001, now - prev_time)

        # 1. CPU
        curr_idle, curr_total = read_proc_stat()
        diff_idle = curr_idle - prev_idle
        diff_total = curr_total - prev_total
        if diff_total > 0:
            cpu_usage = max(0, min(100, round((1.0 - diff_idle / diff_total) * 100)))
        else:
            cpu_usage = 0
        prev_idle, prev_total = curr_idle, curr_total

        # 2. RAM
        ram_pct, ram_used_gb, ram_total_gb = read_proc_mem()

        # 3. Network
        curr_rx, curr_tx = read_proc_net()
        down_bps = max(0, (curr_rx - prev_rx) / dt)
        up_bps = max(0, (curr_tx - prev_tx) / dt)
        prev_rx, prev_tx = curr_rx, curr_tx
        prev_time = now

        new_data = {
            "cpu": f"{cpu_usage}%",
            "cpu_val": cpu_usage,
            "ram": f"{ram_pct}%",
            "ram_val": ram_pct,
            "ram_display": f"{ram_pct}% ({ram_used_gb:.1f}G)",
            "ram_used_gb": f"{ram_used_gb:.1f}",
            "ram_total_gb": f"{ram_total_gb:.1f}",
            "down": format_speed(down_bps),
            "down_bytes": round(down_bps),
            "up": format_speed(up_bps),
            "up_bytes": round(up_bps),
        }

        with stats_lock:
            current_stats = new_data


DEFAULT_COLORS_CANDIDATES = [
    os.path.expanduser("~/web-project/sonder-newtab-extension/css/noctalia-colors.css"),
    os.path.expanduser("~/.config/sonder/noctalia-colors.css"),
    os.path.expanduser("~/.local/share/noctalia/colors.css"),
    "/home/kabir/web-project/sonder-newtab-extension/css/noctalia-colors.css",
]
NOCTALIA_COLORS_PATH = os.environ.get("NOCTALIA_COLORS_PATH")
if not NOCTALIA_COLORS_PATH:
    for cand in DEFAULT_COLORS_CANDIDATES:
        if os.path.isfile(cand):
            NOCTALIA_COLORS_PATH = cand
            break
    if not NOCTALIA_COLORS_PATH:
        NOCTALIA_COLORS_PATH = DEFAULT_COLORS_CANDIDATES[0]


class StatsHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(204)
        self.send_cors_headers()
        self.end_headers()

    def do_GET(self):
        clean_path = self.path.split("?")[0]
        if clean_path in ("/colors.css", "/colors", "/noctalia-colors.css"):
            try:
                with open(NOCTALIA_COLORS_PATH, "rb") as f:
                    body = f.read()
            except Exception:
                body = b":root {}\n"
            self.send_response(200)
            self.send_cors_headers()
            self.send_header("Content-Type", "text/css; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
            self.end_headers()
            self.wfile.write(body)
        elif clean_path == "/stats" or clean_path == "/":
            with stats_lock:
                body = json.dumps(current_stats).encode("utf-8")
            self.send_response(200)
            self.send_cors_headers()
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store, no-cache, must-revalidate")
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")

    def log_message(self, format, *args):
        # Silence per-request stdout/stderr logging
        pass


def main():
    sampler_thread = threading.Thread(target=stats_sampler, daemon=True)
    sampler_thread.start()

    server = HTTPServer((HOST, PORT), StatsHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
