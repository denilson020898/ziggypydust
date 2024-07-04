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

# stt_booked_date   |    stt_pod_date     |          etl_date
# 2024-04-03 10:07:41 | 2024-04-22 08:36:03 | 2024-04-23 19:43:23.901366
# 2024-04-21 09:07:54 | 2024-04-29 04:22:37 | 2024-05-09 12:28:30.915889
# 2024-05-02 06:16:00 | 2024-05-05 01:47:15 | 2024-06-11 11:24:15.047538

# 2024-04-03 10:07:41 | 2024-04-22 08:36:03 | 2024-04-23 19:43:23.901366

result = [

    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;9",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-06-01 10:07:41",
        "2022-07-19 08:36:03",
        "2024-06-01 19:43:23",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-05-25 05:46:26",
        "2024-05-27 12:08:10",
        # "2024-06-11 11:24:15",
        "2024-06-20 10:44:02",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-04-03 10:07:41",
        "2024-04-22 08:36:03",
        "2024-04-23 19:43:23",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-02-25 05:46:26",
        "2024-02-27 12:08:10",
        # "2024-06-11 11:24:15",
        "2024-03-02 10:44:02",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-02-25 05:46:26",
        "2024-02-27 12:08:10",
        # "2024-06-11 11:24:15",
        "2024-03-20 10:44:02",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-02-25 05:46:26",
        "2024-02-27 12:08:10",
        # "2024-06-11 11:24:15",
        "2024-03-21 10:44:02",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-02-25 05:46:26",
        "2024-02-27 12:08:10",
        "2024-05-11 11:24:15",
        # "2024-07-21 10:44:02",
    ),

    (
        "T",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-01-25 06:40:46",
        "2024-03-19 23:39:00",
        "2024-06-20 16:13:11"
    ),
    (
        "T",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-06-01 05:25:47",
        "2024-06-03 03:59:24",
        "2024-07-04 03:28:37"
    ),
    (
        "B",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-06-14 18:54:10",
        "2024-06-19 06:20:54",
        "2024-07-04 03:28:37"
    ),
    (
        "T",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-07-01 04:19:58",
        "2024-07-03 01:19:29",
        "2024-07-04 03:28:24"
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
    "AAAA": {
        "display_name": "CON10850",
        "partner_id": 71933,
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
