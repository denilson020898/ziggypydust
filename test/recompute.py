# %%
import numpy as np
import json
from zigffi import _lib
import boto3
import time
import gc
import psycopg2

# %%
# with open("/home/son/rnd/latest_cni_values.json") as f:
#     latest_cni_values = json.loads(f.read())
# %%
# latest_cni_values[0]
# %%
latest_cni_values = [
    (
        "PNK",
        "CGK",
        "REGPACK",
        0.0,
        0.0,
        "costing-bucket/INPUT/lp_costing001.csv_be2c6226-366d-4226-8675-68f958eee10a",
        "990-52686060",
        None,
        "2024-01-31 02:10:45",
        "2024-02-01 04:48:43",
        3.8,
        0.17,
        4.0,
        "POS2549",
        "PT.ADVENTOUR JELAJAH INDONESIA",
        "RETAIL",
        "INTER-ISLAND",
        "PNK",
        "CGK",
        14700.0,
        84000.0,
        0.0,
        0.0,
        25200.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        1764.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        "PNK",
        "FLIGHT",
        "KONSOLIDATOR",
        "CONS138",
        "PNK-0230",
        "2024-03-18 07:53:05",
        0.0,
        0.0,
        "20240327T062344;11LP1706667045401;CONS138;1",
        1,
    ),
    (
        "PNK",
        "CGK",
        "REGPACK",
        0.0,
        16777.0,
        "costing-bucket/INPUT/lp_costing001.csv_be2c6226-366d-4226-8675-68f958eee10a",
        "990-52686060",
        None,
        "2024-01-31 02:10:45",
        "2024-02-01 04:48:43",
        3.8,
        0.17,
        4.0,
        "POS2549",
        "PT.ADVENTOUR JELAJAH INDONESIA",
        "RETAIL",
        "INTER-ISLAND",
        "PNK",
        "CGK",
        14700.0,
        84000.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        12357.6,
        8698.2,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        "PNK",
        "FLIGHT",
        "KONSOLIDATOR",
        "CONS138",
        "PNK-0230",
        "2024-03-18 07:53:05",
        0.0,
        0.0,
        "20240327T062344;11LP1706667045401;CONS138;3",
        3,
    ),
]
len(latest_cni_values[0])

# %%
# n = np.array(latest_cni_values)
# del latest_cni_values
# gc.collect()
# %%
start_time = time.perf_counter()
queries = _lib.generate_recompute_queries(
    latest_cni_values,
)
end_time = time.perf_counter()
elapsed_time = end_time - start_time
print("Elapsed time process all string: ", elapsed_time)
print(queries)
# %%
