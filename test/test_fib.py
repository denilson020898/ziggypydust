from zigffi import _lib
import numpy as np


def test_fibonacci():
    impls = [
        _lib.nth_fibonacci_iterative,
        _lib.nth_fibonacci_recursive,
        _lib.nth_fibonacci_recursive_tail,
    ]
    for impl in impls:
        assert impl(9) == 34


def test_fubonacci_iterator():
    fibonacci = _lib.Fibonacci(10)
    expected = [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

    # As iterator
    fibonacci_iter = iter(fibonacci)
    for expected_item in expected:
        actual = next(fibonacci_iter)
        assert actual == expected_item

    # As list
    fibonacci_list = list(fibonacci)
    for actual, expected_item in zip(fibonacci_list, expected):
        assert actual == expected_item


def test_process_lock_int():
    result = [
        (1, 2, 1, 9), 
        (2, 3, 1, 9),
        (2, 3, 1, 9),
    ]
    n = np.array(result)
    print(n)
    print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
    a = _lib.process_lock_int(n, n.itemsize, n.shape[0], n.shape[1], n.strides[0], n.strides[1])
    assert a == 10


def test_process_lock_pystr():
    result = [
    ('ZIG001_10LP6795367643232;MJP-1079;9', '20240327T041119;ZIG001_10LP6795367643232;MJP-1079;9', 'MJP-1079',),
    ('ZIG001_10LP6795367075454;CONS41;8', '20240327T041119;ZIG001_10LP6795367075454;CONS41;8', 'CONS41',),
    ]
    # nparr = np.array(result)
    # process_lock(nparr)

    # result = [('aaaa', 'ccccc'), ('bbbb', 'dddd')]
    # result = [("aa", "cd", "bb"), ("aa", "bb", "cc")]
    # result = ["aa\x00", "cde\x00", "bb\x00"]
    # result = [
    #     ('aa','bb'),
    #     ('4444','bb'),
    #     ('aa','bb'),
    # ]
    n = np.array(result)
    print()
    print(n)
    print(f"itemsize: {n.itemsize}, ndim: {n.ndim}, shape: {n.shape}, strides: {n.strides}, dtype: {n.dtype}")
    print()
    a = _lib.process_lock(
        n,
        n.itemsize,
        n.shape[0],
        n.shape[1],
        n.strides[0],
        n.strides[1]
    )
    assert a == 10
