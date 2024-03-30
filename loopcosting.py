# %%
import json
import numpy as np
import time
from zigffi._lib import process_lock_costing_selector
#%%

start_time = time.perf_counter()

# with open("/home/son/results.json", "r") as f:
#     result = json.loads(f.read())


result = [
#     # [
#     #     "AAA",
#     #     "BB",
#     # ],
#     # [
#     #     "BB",
#     #     "BB",
#     # ],
#     # [
#     #     "A;A",
#     #     "B-B",
#     #     "C:C",
#     #     "D D",
#     #     "E;E",
#     #     "FFF",
#     # ],
#     # [
#     #     "A;A",
#     #     "B-B",
#     #     "C:C",
#     #     "D D",
#     #     "E;E",
#     #     "FFF",
#     # ],
    [
        "11LP1706670615679;CONS104;2",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-01-31 03-10-15",
        "2024-02-03 01-11-59",
        "2024-03-18 07-53-05"
    ],
    [
        "11LP1706670615679;LION AIR CARGO;3",
        "20240327T062344;11LP1706670615679;LION AIR CARGO;",
        "LION AIR CARGO",
        "2024-01-31 03-10-15",
        "2024-02-03 01-11-59",
        "2024-03-18 07-53-05"
    ],
]

n = np.array(result)

# %%
print()
# print(n[0])
print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}, {len(n)}")
print()


with open("/home/son/res_partner_list.json", "r") as f:
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

# partner_dict = {
#     'CONS104': {
#         'display_name': 'CON10850',
#         'partner_id': 71948,
#         'partner_user_id': None,
#         'schedule_cost': 'monthly'
#     },
#     'LION AIR CARGO': {
#         'display_name': 'CON10850',
#         'partner_id': 71948,
#         'partner_user_id': None,
#         'schedule_cost': 'monthly'
#     },
# }

# #%%
a = process_lock_costing_selector(
    n,
    n.itemsize,
    n.shape[0],
    n.shape[1],
    n.strides[0],
    n.strides[1],
    partner_dict
)
print(a)

# %%
#
end_time = time.perf_counter()
elapsed_time = end_time - start_time
print("Elapsed time process all string: ", elapsed_time, a)
#
# #%%
# inp = [(1,2,3), (4,5,6)]
# n = np.array(inp)
# print()
# # print(n[0])
# print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
# print()
# # %%
