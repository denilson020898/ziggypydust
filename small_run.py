import numpy as np
from zigffi._lib import process_lock, process_lock_int

# result = [
# ('ZIG001_10LP6795367643232;MJP-1079;9', '20240327T041119;ZIG001_10LP6795367643232;MJP-1079;9', 'MJP-1079',),
# ('ZIG001_10LP6795367075454;CONS41;8', '20240327T041119;ZIG001_10LP6795367075454;CONS41;8', 'CONS41',),
# ]
# nparr = np.array(result)
# process_lock(nparr)

# result = [('aaaa', 'ccccc'), ('bbbb', 'dddd')]
# result = [("aa", "cd", "bb"), ("aa", "bb", "cc")]
# result = ["aa\x00", "cde\x00", "bb\x00"]
result = [
    ('aa','bb'),
    ('aa','bb'),
    ('aa','bb'),
]
nparr = np.array(result)
print()
print(nparr)
print(f"itemsize: {nparr.itemsize}, ndim: {nparr.ndim}, shape: {nparr.shape}, strides: {nparr.strides}, dtype: {nparr.dtype}")
print()
process_lock(nparr, nparr.shape[0], nparr.shape[1])


# result = [
#     (1, 2, 1, 9), 
#     (2, 3, 1, 9),
#     (2, 3, 1, 9),
#     (6, 6, 6, 9),
# ]
# nparr = np.array(result)
# print()
# print(nparr)
# print(f"itemsize: {nparr.itemsize}, ndim: {nparr.ndim}, shape: {nparr.shape}, strides: {nparr.strides}, dtype: {nparr.dtype}")
# print()
# process_lock_int(nparr, nparr.shape[0], nparr.shape[1])
