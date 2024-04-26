# %%
import numpy as np
from zigffi import _lib
import time

start_time = time.perf_counter()

result = [
    (
        "11LP1706670615679;CONS104;2",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2023-05-31 03:10:15",
        "2024-04-03 01:11:59",
        "2024-04-23 17:00:00",
    ),
    (
        "11LP1706670615679;LION AIR CARGO;3",
        "20240327T062344;11LP1706670615679;LION AIR CARGO;",
        "LION AIR CARGO",
        "2024-01-31 03:10:15",
        "2024-02-03 01:11:59",
        "2024-03-20 07:53:05",
    ),
    (
        "21LP1706670615679;CONS104;2",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2023-01-31 03:10:15",
        "2023-11-03 01:11:59",
        "2024-03-18 07:53:05",
    ),
]
# %%

partner_dict = {
    "LION AIR CARGO": {
        "display_name": "CON10850",
        "partner_id": 71948,
        "partner_user_id": None,
        "schedule_cost": "monthly",
    },
    "CONS104": {
        "display_name": "CON10850",
        "partner_id": 71949,
        "partner_user_id": 123,
        "schedule_cost": "monthly",
    },
}

# #%%

a = _lib.process_lock_costing_selector_list(
    result,
    partner_dict,
    20
)

# %%
#
end_time = time.perf_counter()
elapsed_time = end_time - start_time
print("Elapsed time process all string: ", elapsed_time)
print(a)
# print(len(a))
