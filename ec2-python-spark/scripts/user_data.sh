#!/bin/bash
set -euxo pipefail

# Install SSM, Python y Java 
yum -y update
yum -y install amazon-ssm-agent curl tar gzip python3
systemctl enable --now amazon-ssm-agent || true
yum -y install java-17-amazon-corretto-headless || true

# Install Apache Spark
SPARK_VERSION="3.4.1"
SPARK_PKG="spark-${SPARK_VERSION}-bin-hadoop3"
SPARK_TGZ="/tmp/${SPARK_PKG}.tgz"

if [[ ! -d "/opt/${SPARK_PKG}" ]]; then
  curl -fSL "https://downloads.apache.org/spark/spark-${SPARK_VERSION}/${SPARK_PKG}.tgz" -o "${SPARK_TGZ}" \
  || curl -fSL "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PKG}.tgz" -o "${SPARK_TGZ}"
  tar -xzf "${SPARK_TGZ}" -C /opt
fi
ln -sfn "/opt/${SPARK_PKG}" /opt/spark

# Create directory where job will run and output
mkdir -p /opt/spark_jobs

# Spark job that writes JSON to /opt/spark_jobs/out.json
cat >/opt/spark_jobs/sales_job.py <<'PY'
from pyspark.sql import SparkSession, functions as F
import json, os, sys

spark = (
    SparkSession.builder
    .appName("ec2-ssm-spark-job")
    .master("local[*]")
    .config("spark.ui.showConsoleProgress", "false")
    .getOrCreate()
)

data = [("A", 10.5, 3), ("B", 12.0, 5), ("C", 7.75, 2), ("A", 9.80, 4)]
df = spark.createDataFrame(data, ["product", "price", "qty"])

out = (
    df.withColumn("total", F.col("price") * F.col("qty"))
      .groupBy("product")
      .agg(
          F.sum("total").alias("total_sales"),
          F.avg("price").alias("avg_price"),
          F.sum("qty").alias("qty_total")
      )
      .orderBy("product")
)

rows = [r.asDict(recursive=True) for r in out.collect()]
os.makedirs("/opt/spark_jobs", exist_ok=True)
with open("/opt/spark_jobs/out.json", "w") as f:
    json.dump(rows, f, indent=2)

spark.stop()
print("WROTE:/opt/spark_jobs/out.json", file=sys.stderr)
PY

# Run job setting env, executes spark-submit, prints only the JSON payload
cat >/opt/spark_jobs/run_spark_job.sh <<'SH'
#!/bin/bash
set -euo pipefail
export SPARK_HOME=/opt/spark
export PATH="$SPARK_HOME/bin:$PATH"
export PYSPARK_PYTHON=/usr/bin/python3  # use system python3 on AL2

# spark-submit sets PYTHONPATH for pyspark; no pip install needed
"$SPARK_HOME/bin/spark-submit" /opt/spark_jobs/sales_job.py 1>&2
echo RESULT_START
cat /opt/spark_jobs/out.json
echo RESULT_END
SH
chmod +x /opt/spark_jobs/run_spark_job.sh

echo "Spark installed at /opt/spark; job baked at /opt/spark_jobs/sales_job.py"
