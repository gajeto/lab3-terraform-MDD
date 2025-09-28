#!/bin/bash
set -euxo pipefail

# --- Amazon Linux 2 base ---
yum -y update
yum -y install python3 python3-pip amazon-ssm-agent || true
systemctl enable --now amazon-ssm-agent || true

# --- Python venv + pandas ---
VENV_DIR="/opt/app-venv"
if [[ ! -d "$VENV_DIR" ]]; then
  /usr/bin/python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install flask pandas
deactivate

# --- Non-versioned Flask app written at boot ---
mkdir -p /opt/hello
cat >/opt/hello/app.py <<'PY'
from flask import Flask
import sys, platform
import pandas as pd

app = Flask(__name__)

@app.get("/")
def root():
    # Create a tiny DataFrame and a derived column
    df = pd.DataFrame({"product": ["A", "B", "C"], "price": [10.5, 12.0, 7.75], "qty": [3, 5, 2]})
    df["total"] = df["price"] * df["qty"]

    # Build a simple HTML page with versions + table
    html = f"""
    <html>
      <head>
        <meta charset="utf-8" />
        <title>EC2 over SSM — Demo</title>
        <style>
          body {{ font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 24px; }}
          h1 {{ margin-bottom: 8px; }}
          .muted {{ color: #666; font-size: 12px; }}
          table {{ border-collapse: collapse; margin-top: 16px; }}
          th, td {{ border: 1px solid #ccc; padding: 8px 12px; text-align: left; }}
          th {{ background: #f5f5f5; }}
          code {{ background: #f5f5f5; padding: 2px 4px; border-radius: 4px; }}
        </style>
      </head>
      <body>
        <h1>!Hello from EC2 over SSM with python and pandas!</h1>
        <h3>Configured by GAJETO for MDD LAB 3 - Terraform</h3>

        <h2>Versions</h2>
        <ul>
          <li><b>Python:</b> {platform.python_version()}</li>
          <li><b>Pandas:</b> {pd.__version__}</li>
        </ul>
        <details>
          <summary>Python build string</summary>
          <pre>{sys.version}</pre>
        </details>

        <h2>Sample pandas DataFrame</h2>
        {df.to_html(index=False, border=1)}
      </body>
    </html>
    """
    return html

if __name__ == "__main__":
    # Bind to 0.0.0.0 so systemd service can serve on 8080
    app.run(host="0.0.0.0", port=8080)
PY

# --- Systemd unit to keep it running ---
cat >/etc/systemd/system/hello.service <<'UNIT'
[Unit]
Description=Hello app (SSM demo)
After=network.target

[Service]
Type=simple
User=ec2-user
Environment="PATH=/opt/app-venv/bin:/usr/local/bin:/usr/bin"
WorkingDirectory=/opt/hello
ExecStart=/opt/app-venv/bin/python /opt/hello/app.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

# Enable and start the service
systemctl daemon-reload
systemctl enable --now hello.service

echo "Terraform configuration complete: EC2 instance with python and pandas installed, and html app runing on 8080."
