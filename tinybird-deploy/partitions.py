"""Set the partition key of each OpenStatus data source before `tb deploy`.

Tinybird rejects a new data source if its TTL is shorter than its partition
period. OpenStatus uses monthly partitions with TTLs of 1 to 30 days. Thus, a
new data source with a TTL of less than 32 days gets a partition for each day
or each week. An existing data source keeps its live partition key, because a
change to the key makes Tinybird write all its data again.
"""

import json
import os
import re
import urllib.request
from pathlib import Path

PARTITION = re.compile(r'^ENGINE_PARTITION_KEY "(.*)"$', re.MULTILINE)
TTL_DAYS = re.compile(r'^ENGINE_TTL ".* \+ toIntervalDay\((\d+)\)"$', re.MULTILINE)


def main():
    url = f"{os.environ['TB_HOST']}/v0/datasources?token={os.environ['TB_TOKEN']}"
    with urllib.request.urlopen(url, timeout=60) as response:
        live = {
            source["name"]: source["engine"].get("engine_partition_key")
            for source in json.load(response)["datasources"]
        }
    for path in sorted(Path("datasources").glob("*.datasource")):
        text = path.read_text()
        partition = PARTITION.search(text)
        if not partition:
            continue
        key = live[path.stem] if path.stem in live else new_key(partition.group(1), text)
        if key and key != partition.group(1):
            path.write_text(text[: partition.start(1)] + key + text[partition.end(1) :])
            print(f"{path}: partition by {key}")


def new_key(key, text):
    ttl = TTL_DAYS.search(text)
    if not (ttl and key.startswith("toYYYYMM(") and int(ttl.group(1)) < 32):
        return None
    column = key[len("toYYYYMM(") : -1]
    return f"{'toDate' if int(ttl.group(1)) < 7 else 'toMonday'}({column})"


main()
