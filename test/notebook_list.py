# %%
import numpy as np
import json
from zigffi import _lib
import boto3
import time
import gc

# %%
with open("/home/son/rnd/results.json") as f:
    result = json.loads(f.read())
print("lock costing selector result", len(result))

# %%

# n = np.array(result)
# print()
# print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
# print()

# del result
# gc.collect()

# %%
# s3_target = boto3.resource(
#     "s3",
#     aws_access_key_id="minioadmin",
#     aws_secret_access_key="minioadmin",
#     endpoint_url="http://localhost:9000",
# )
# COSTING_BUCKET_NAME = "costing-bucket"
# stt_cost_key = "AGGREGATE_COSTING/20240330T042222/res_partner_list.json"
# stt_cost_key  = "AGGREGATE_COSTING/20240329T073416/res_partner_list.json"
# stt_cost_key = "sampel.csv"
# obj = s3_target.Object(COSTING_BUCKET_NAME, stt_cost_key)
# stt_csv_data = obj.get()["Body"].read().decode("utf-8")

with open("/home/son/rnd/res_partner_list.json") as f:
    res_partner_list = json.loads(f.read())

partner_dict = {
    rp[0]: {
        "partner_id": rp[1],
        "schedule_cost": rp[2],
        "display_name": rp[3],
        "partner_user_id": rp[4],
    }
    for rp in res_partner_list
}

# print(res_partner_list)
print(len(partner_dict))

# %%
start_time = time.perf_counter()

a = _lib.process_lock_costing_selector_list(
    result,
    partner_dict,
)

end_time = time.perf_counter()
elapsed_time = end_time - start_time
print("Elapsed time call zig function: ", elapsed_time)
print(len(a))

# %%
