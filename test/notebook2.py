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

result = [
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-04-03 10:07:41",
        "2024-04-22 08:36:03",
        "2024-04-23 19:43:23",
    ),
    (
        "d2b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-04-21 09:07:54",
        "2024-04-29 04:22:37",
        "2024-05-09 12:28:30",
    ),
    (
        "d3b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-05-02 06:16:00",
        "2024-05-05 01:47:15",
        "2024-06-11 11:24:15",
    ),
    (
        "d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "20240610T041538;d1b7f0e7-9309-4288-8a58-f467c9519d80;AAAA;8",
        "AAAA",
        "2024-04-16 12:41:00",
        "2023-01-17 16:51:51",
        "2021-11-07 00:24:25",
    ),
    # (
    #     "e6792864-f187-4ba1-9af2-e524653e2fa8;AAAA;9",
    #     "20240610T041538;e6792864-f187-4ba1-9af2-e524653e2fa8;AAAA;9",
    #     "AAAA",
    #     "2023-12-20 12:46:48",
    #     "2023-01-13 10:20:29",
    #     "2021-01-12 19:14:26",
    # ),
    # (
    #     "199c9199-907d-4c71-ab47-a2d803ecf448;AAAA;6",
    #     "20240610T041538;199c9199-907d-4c71-ab47-a2d803ecf448;AAAA;6",
    #     "AAAA",
    #     "2024-01-12 09:15:12",
    #     "2023-08-07 07:15:36",
    #     "2021-11-14 02:34:56",
    # ),
    # (
    #     "3297651f-ac32-456a-8582-d00241f75dd6;AAAA;6",
    #     "20240610T041538;3297651f-ac32-456a-8582-d00241f75dd6;AAAA;6",
    #     "AAAA",
    #     "2023-09-06 06:55:32",
    #     "2023-10-03 17:32:19",
    #     "2022-12-21 18:05:41",
    # ),
    # (
    #     "5c1f7bd1-413a-4cfa-8628-a3c699068888;AAAA;4",
    #     "20240610T041538;5c1f7bd1-413a-4cfa-8628-a3c699068888;AAAA;4",
    #     "AAAA",
    #     "2023-05-12 10:34:29",
    #     "2023-10-17 19:13:46",
    #     "2022-07-17 22:39:27",
    # ),
    # (
    #     "c8ce18a7-6fd6-4cca-b86d-ed40c9dcd2e8;AAAA;6",
    #     "20240610T041538;c8ce18a7-6fd6-4cca-b86d-ed40c9dcd2e8;AAAA;6",
    #     "AAAA",
    #     "2023-01-14 01:45:29",
    #     "2023-12-23 02:15:31",
    #     "2021-10-26 23:20:33",
    # ),
    # (
    #     "7f1dc7d0-b69f-4a0b-895c-02de729fb1fa;AAAA;10",
    #     "20240610T041538;7f1dc7d0-b69f-4a0b-895c-02de729fb1fa;AAAA;10",
    #     "AAAA",
    #     "2023-05-23 13:34:05",
    #     "2024-01-29 19:37:08",
    #     "2022-03-13 02:27:59",
    # ),
    # (
    #     "73876ee8-645a-4fcf-b887-c09d74a69d7e;AAAA;5",
    #     "20240610T041538;73876ee8-645a-4fcf-b887-c09d74a69d7e;AAAA;5",
    #     "AAAA",
    #     "2024-01-25 14:56:38",
    #     "2024-04-27 10:42:10",
    #     "2022-12-20 08:04:50",
    # ),
    # (
    #     "1d4f4378-044d-4976-a24b-c999993a7da8;AAAA;5",
    #     "20240610T041538;1d4f4378-044d-4976-a24b-c999993a7da8;AAAA;5",
    #     "AAAA",
    #     "2023-03-15 18:42:04",
    #     "2024-04-05 19:58:53",
    #     "2022-10-24 13:53:51",
    # ),
    # (
    #     "11LP1706670615679;CONS104;1",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2024-03-27 14:11:54",
    #     "2024-03-31 20:38:19",
    #     "2024-05-09 19:28:31",
    # ),
    # (
    #     "11LP1706670615679;CONS105;1",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2024-03-27 14:11:54",
    #     "2024-03-31 20:38:19",
    #     "2024-04-17 00:00:00",
    # ),
    # (
    #     "11LP1706670615679;CONS105;1",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2024-05-10 14:11:54",
    #     "2024-05-11 20:38:19",
    #     "2024-06-22 00:00:00",
    # ),
    # (
    #     "11LP1706670615679;CONS105;1",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2024-03-27 14:11:54",
    #     "2024-03-31 20:38:19",
    #     "2024-05-21 19:28:31",
    # ),
    # (
    #     "11LP1706670615679;CONS104;2",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2024-03-27 14:11:54",
    #     "2024-03-31 20:38:19",
    #     "2024-06-09 19:28:31",
    # ),
    # (
    #     "11LP1706670615679;CONS104;3",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2023-05-31 03:10:15",
    #     "2024-04-03 01:11:59",
    #     "2024-04-23 17:00:00",
    # ),
    # (
    #     "11LP1706670615679;LION AIR CARGO;3",
    #     "20240327T062344;11LP1706670615679;LION AIR CARGO;",
    #     "LION AIR CARGO",
    #     "2024-01-31 03:10:15",
    #     "2024-02-03 01:11:59",
    #     "2024-03-20 07:53:05",
    # ),
    # (
    #     "21LP1706670615679;CONS104;2",
    #     "20240327T062344;11LP1706670615679;CONS104;2",
    #     "CONS104",
    #     "2023-01-31 03:10:15",
    #     "2023-11-03 01:11:59",
    #     "2024-03-18 07:53:05",
    # ),
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
