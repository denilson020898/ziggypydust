from zigffi import _lib
import numpy as np


# def test_fibonacci():
#     impls = [
#         _lib.nth_fibonacci_iterative,
#         _lib.nth_fibonacci_recursive,
#         _lib.nth_fibonacci_recursive_tail,
#     ]
#     for impl in impls:
#         assert impl(9) == 34
#
#
# def test_fubonacci_iterator():
#     fibonacci = _lib.Fibonacci(10)
#     expected = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
#
#     # As iterator
#     fibonacci_iter = iter(fibonacci)
#     for expected_item in expected:
#         actual = next(fibonacci_iter)
#         assert actual == expected_item
#
#     # As list
#     fibonacci_list = list(fibonacci)
#     for actual, expected_item in zip(fibonacci_list, expected):
#         assert actual == expected_item


# def test_process_lock_int():
#     result = [
#         (1, 2, 1, 9), 
#         (2, 3, 1, 9),
#         (2, 3, 1, 9),
#     ]
#     n = np.array(result)
#     print(n)
#     print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
#     a = _lib.process_lock_int(n, n.itemsize, n.shape[0], n.shape[1], n.strides[0], n.strides[1])
#     assert a == 10


def test_variadic():
    partner_dict = {
        'CJT-1585': {
            'display_name': 'CJT-1585',
            'partner_id': 71934,
            'partner_user_id': None,
            'schedule_cost': 'monthly'
        },
        'CON10850': {
            'display_name': 'CON10850',
            'partner_id': 71948,
            'partner_user_id': None,
            'schedule_cost': 'monthly'
        },
    }
    print(_lib.variadic("Son", partner_dict))


def test_process_lock_costing_selector():
    result = [
        ('11LP1706667699702;IDL-959;9',
        '20240327T062344;11LP1706667699702;IDL-959;9',
        'IDL-959',
        '2024-01-31 02-21-39',
        '2024-02-07 09-41-30',
        '2024-03-18 07-53-05'),
        ('11LP1706667699702;MJP-1079;11',
        '20240327T062344;11LP1706667699702;MJP-1079;11',
        'MJP-1079',
        '2024-01-31 02-21-39',
        '2024-02-07 09-41-30',
        '2024-03-18 07-53-05'),
        ('11LP1706667752515;CONS41;3',
        '20240327T062344;11LP1706667752515;CONS41;3',
        'CONS41',
        '2024-01-31 02-22-32',
        '2024-02-02 05-34-36',
        '2024-03-18 07-53-05'),
        ('11LP1706667752515;CONS41;7',
        '20240327T062344;11LP1706667752515;CONS41;7',
        'CONS41',
        '2024-01-31 02-22-32',
        '2024-02-02 05-34-36',
        '2024-03-18 07-53-05'),
    ]

    n = np.array(result)
    print()
    print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
    print()
    a = _lib.process_lock_costing_selector(
        n,
        n.itemsize,
        n.shape[0],
        n.shape[1],
        n.strides[0],
        n.strides[1]
    )
    assert a == 10
