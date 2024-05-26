# %%
import numpy as np
import json
from zigffi import _lib
import boto3
import time
import gc
import psycopg2

# %%
# DSN_AIRFLOW = "postgres://son:son@127.0.0.1:6543/costing_airflow4"
# with psycopg2.connect(DSN_AIRFLOW) as airflow_conn:
#     with airflow_conn.cursor() as airflow_cur:
#         DSN_ODOO = "postgres://son:son@127.0.0.1:6543/lion_dev"
#         with psycopg2.connect(DSN_ODOO) as odoo_conn:
#             with odoo_conn.cursor() as odoo_cur:
#                 start_time = time.perf_counter()
#
#                 cs_query = """
#                     SELECT
#                         cs.costing_number,
#                         cs.latest_costing_number_ts,
#                         cs.costing_number_ts
#                     FROM costing_selector cs
#                     WHERE cs.latest_costing_number_ts IS NOT NULL
#                     AND cs.odoo_stt_costing_id IS NOT NULL
#                     AND cs.costing_number_ts != cs.latest_costing_number_ts;
#                 """
#                 airflow_cur.execute(cs_query)
#                 cs_to_update = airflow_cur.fetchall()
#
#                 print(f"\n\nCS_TO_UPDATE:{len(cs_to_update)}\n\n")
#                 latest_cnis = [cs[1] for cs in cs_to_update]
#
#                 costing_number_query = """
#                     SELECT
#                         origin,
#                         destination,
#                         product,
#                         pickup_fee::float,
#                         flight_cost::float,
#                         bucket_file_version,
#                         awb_number,
#                         tuc_number,
#                         to_char(stt_booked_date, 'YYYY-MM-DD HH24:MI:SS') as stt_booked_date,
#                         to_char(stt_pod_date, 'YYYY-MM-DD HH24:MI:SS') as stt_pod_date,
#                         gross_weight::float,
#                         volume_weight::float,
#                         chargeable_weight::float,
#                         client_code,
#                         client_name,
#                         client_category,
#                         route_type,
#                         lag_route_origin,
#                         lag_route_destination,
#                         publish_rate_cost::float,
#                         stt_total_amount::float,
#                         insurance_commission_to_lp::float,
#                         insurance_cost::float,
#                         agent_commision::float,
#                         corporate_discount::float,
#                         woodpacking_fee::float,
#                         pickup_fee_kvp::float,
#                         forward_origin_cost::float,
#                         pcu_fee::float,
#                         outbound_fee::float,
#                         ra_outgoing::float,
#                         wh_outgoing::float,
#                         wh_incoming::float,
#                         truck_cost::float,
#                         train_cost::float,
#                         sea_freight_cost::float,
#                         inbound_fee::float,
#                         delivery_fee_kvp::float,
#                         delivery_fee_mitra::float,
#                         forward_destination_cost_mitra::float,
#                         forward_destination_cost_vendor::float,
#                         cod_commission::float,
#                         lag_route,
#                         lag_moda,
#                         partner_type,
#                         mitra_code_genesis,
#                         poscode_on_going_inv_mitra,
#                         to_char(etl_date, 'YYYY-MM-DD HH24:MI:SS') as etl_date,
#                         handling_cost::float,
#                         other_cost::float,
#                         total_bonus::float,
#                         costing_number_ts,
#                         route_rank
#                     FROM costing_number_ingest
#                     where costing_number_ts = ANY(%(latest_cnis)s)
#                 """
#                 airflow_cur.execute(
#                     costing_number_query,
#                     {"latest_cnis": latest_cnis},
#                 )
#                 latest_cni_values = airflow_cur.fetchall()
#
#                 end_time = time.perf_counter()
#                 elapsed_time = end_time - start_time
#                 print("Elapsed time query cs to update: ", elapsed_time)
#
#                 if latest_cni_values:
#                     start_time = time.perf_counter()
#                     airflow_query, odoo_query = _lib.generate_recompute_queries(
#                         latest_cni_values,
#                     )
#                     end_time = time.perf_counter()
#                     elapsed_time = end_time - start_time
#                     print("Elapsed time process all string: ", elapsed_time)

# %%
latest_cni_values = [
    (
        "PNK",
        "CGK",
        "REGPACK",
        0.0,
        8984.560000000001,
        "costing-bucket/INPUT/lp_costing001.csv_be2c6226-366d-4226-8675-68f958eee10a",
        "990-52686060",
        "None",
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
        8984.560000000001,
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
        312.0,
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
        "POS LION PARCEL KH. AHMAD SYA'YANI",
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
        -123.0,
        "20240327T062344;11LP1706667045401;CONS138;3",
        3,
    ),
]

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
# print(queries)
print(len(queries))
# %%
print("####")
print(queries[0])
print("####")
print(queries[1])
