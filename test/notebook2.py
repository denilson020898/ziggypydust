"""
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

# %%
import numpy as np
from zigffi import _lib
import time
# %%

start_time = time.perf_counter()


# var costing_number: []const u8 = undefined;
# var latest_costing_number_ts: []const u8 = undefined;
# var mitra_code_genesis: []const u8 = undefined;
# var stt_booked_date: []const u8 = undefined;
# var stt_pod_date: []const u8 = undefined;
# var etl_date: []const u8 = undefined;

result = [
    (
        "11LP1706670615679;CONS104;1",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-03-27 14:11:54",
        "2024-03-31 20:38:19",
        "2024-05-09 19:28:31",
    ),
    (
        "11LP1706670615679;CONS105;1",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-03-27 14:11:54",
        "2024-03-31 20:38:19",
        "2024-04-17 00:00:00",
    ),
    (
        "11LP1706670615679;CONS105;1",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-05-10 14:11:54",
        "2024-05-11 20:38:19",
        "2024-06-22 00:00:00",
    ),
    (
        "11LP1706670615679;CONS105;1",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-03-27 14:11:54",
        "2024-03-31 20:38:19",
        "2024-05-21 19:28:31",
    ),
    (
        "11LP1706670615679;CONS104;2",
        "20240327T062344;11LP1706670615679;CONS104;2",
        "CONS104",
        "2024-03-27 14:11:54",
        "2024-03-31 20:38:19",
        "2024-06-09 19:28:31",
    ),
    (
        "11LP1706670615679;CONS104;3",
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
    20,
)

# %%
#
end_time = time.perf_counter()
elapsed_time = end_time - start_time
print("Elapsed time process all string: ", elapsed_time)
print(a)
# print(len(a))

# %%
