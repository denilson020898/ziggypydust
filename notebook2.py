import numpy as np
import json
from zigffi import _lib
import boto3
import time

# result = [
#     (
#         "11LP1706667699702;IDL-959;9",
#         "20240327T062344;11LP1706667699702;IDL-959;9",
#         "CON10850",
#         "2024-01-31 02-21-39",
#         "2024-02-07 09-41-30",
#         "2024-03-18 07-53-05",
#     ),
#     (
#         "11LP1706667699702;MJP-1079;11",
#         "20240327T062344;11LP1706667699702;MJP-1079;11",
#         "CON10850",
#         "2024-01-31 02-21-39",
#         "2024-02-07 09-41-30",
#         "2024-03-18 07-53-05",
#     ),
#     (
#         "11LP1706667752515;CONS41;3",
#         "20240327T062344;11LP1706667752515;CONS41;3",
#         "CJT-1585",
#         "2024-01-31 02-22-32",
#         "2024-02-02 05-34-36",
#         "2024-03-18 07-53-05",
#     ),
#     (
#         "11LP1706667752515;CONS41;7",
#         "20240327T062344;11LP1706667752515;CONS41;7",
#         "CJT-1585",
#         "2024-01-31 02-22-32",
#         "2024-02-02 05-34-36",
#         "2024-03-18 07-53-05",
#     ),
# ]
#
# n = np.array(result)
# print()
# print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
# print()
#
# partner_dict = {
#     "CJT-1585": {
#         "display_name": "CJT-1585",
#         "partner_id": 71934,
#         "partner_user_id": None,
#         "schedule_cost": "monthly",
#     },
#     "CON10850": {
#         "display_name": "CON10850",
#         "partner_id": 71948,
#         "partner_user_id": None,
#         "schedule_cost": "monthly",
#     },
# }
#
# a = _lib.process_lock_costing_selector(
#     n,
#     n.itemsize,
#     n.shape[0],
#     n.shape[1],
#     n.strides[0],
#     n.strides[1],
#     partner_dict,
# )
# assert a == len(result)


# def test_process_lock_costing_selector():
start_time = time.perf_counter()

result = [
    [
        "11LP1706670615679;CONS104;2",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-01-31 03-10-15",
        "2024-02-03 01-11-59",
        "2024-03-18 07-53-05",
    ],
    [
        "11LP1706670615679;LION AIR CARGO;3",
        "20240327T062344;11LP1706670615679;LION AIR CARGO;",
        "LION AIR CARGO",
        "2024-01-31 03-10-15",
        "2024-02-03 01-11-59",
        "2024-03-18 07-53-05",
    ],
]

n = np.array(result)

partner_dict = {
    "CONS104": {
        "display_name": "CON10850",
        "partner_id": 71948,
        "partner_user_id": None,
        "schedule_cost": "monthly",
    },
    "LION AIR CARGO": {
        "display_name": "CON10850",
        "partner_id": 71948,
        "partner_user_id": None,
        "schedule_cost": "monthly",
    },
}

# #%%
a = _lib.process_lock_costing_selector(
    n, n.itemsize, n.shape[0], n.shape[1], n.strides[0], n.strides[1], partner_dict
)
print(a)

# %%
#
end_time = time.perf_counter()
elapsed_time = end_time - start_time
print("Elapsed time process all string: ", elapsed_time, a)
