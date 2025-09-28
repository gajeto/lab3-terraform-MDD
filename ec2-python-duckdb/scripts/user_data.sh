#!/bin/bash
set -euxo pipefail

# --- Amazon Linux 2023 base + SSM ---
dnf -y update
dnf -y install python3 python3-pip htop amazon-ssm-agent
systemctl enable --now amazon-ssm-agent || true

# --- Python venv ---
VENV_DIR="/opt/app-venv"
if [[ ! -d "$VENV_DIR" ]]; then
  /usr/bin/python3 -m venv "$VENV_DIR"
fi

# --- Packages: Flask + pandas + DuckDB (prefer wheels; no builds) ---
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install --only-binary=:all: flask pandas duckdb
deactivate

# --- Non-versioned Flask app (pandas + DuckDB; everything at "/") ---
mkdir -p /opt/hello
cat >/opt/hello/app.py <<'PY'
from flask import Flask
import sys, platform
import pandas as pd
import duckdb

app = Flask(__name__)

@app.get("/")
def root():
    # Sample pandas DataFrame + computed column
    df = pd.DataFrame({
        "product": ["A","B","C","A"],
        "price":   [10.5, 12.0, 7.75, 9.80],
        "qty":     [3, 5, 2, 4],
    })
    df["total"] = df["price"] * df["qty"]

    # DuckDB SQL directly over the pandas DataFrame
    con = duckdb.connect()
    con.register("df", df)  # register pandas DF as table "df"
    q = """
        SELECT product,
               SUM(total) AS total_sales,
               AVG(price) AS avg_price,
               SUM(qty)   AS qty_total
        FROM df
        GROUP BY product
        ORDER BY product
    """
    res_df = con.sql(q).df()  # pandas DataFrame

    html = f"""
    <html>
      <head>
        <meta charset="utf-8" />
        <title>EC2 over SSM — pandas + DuckDB Demo</title>
        <style>
          body {{ font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 24px; }}
          h1 {{ margin-bottom: 8px; }}
          .muted {{ color: #666; font-size: 12px; }}
          table {{ border-collapse: collapse; margin-top: 16px; }}
          th, td {{ border: 1px solid #ccc; padding: 8px 12px; text-align: left; }}
          th {{ background: #f5f5f5; }}
          section {{ margin-bottom: 24px; }}
          code {{ background:#f5f5f5; padding:2px 4px; border-radius:4px; }}
        </style>
      </head>
      <body>
        <h1>!Hello from EC2 over SSM with python and DuckDB!</h1>
        <h3>Configured by GAJETO for MDD LAB 3 - Terraform</h3>

        <section>
          <h2>Versions</h2>
          <ul>
            <li><b>Python:</b> {platform.python_version()}</li>
            <li><b>DuckDB:</b> {duckdb.__version__}</li>
          </ul>
          <details>
            <summary>Python build string</summary>
            <pre>{sys.version}</pre>
          </details>
        </section>

        <section>
          <h2>DuckDB SQL result</h2>
          <div><code>SELECT product, SUM(total) AS total_sales, AVG(price) AS avg_price, SUM(qty) AS qty_total FROM df GROUP BY product ORDER BY product</code></div>
          {res_df.to_html(index=False, border=1)}
        </section>
      </body>
    </html>
    """
    return html

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PY

# --- systemd unit using the venv Python ---
cat >/etc/systemd/system/hello.service <<'UNIT'
[Unit]
Description=Hello Flask app
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

# Start service
systemctl daemon-reload
systemctl enable --now hello.service

echo "Bootstrap complete."
