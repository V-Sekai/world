# ebpf prototypes

This operation is O(1) per state retrieval, which means it takes constant time regardless of the number of states. However, if you're retrieving 'n' states, the total time complexity would be O(n).

Converting the states into a Left-child right-sibling binary tree has a time complexity of O(n), as each state needs to be visited once.

Interpolating player states in binary tree order has a time complexity of O(n). This is optimal as you need to visit each node at least once.

Writing 'n' items together as one blob per client also has a time complexity of O(n). This is optimal as you need to write each item at least once.

In conclusion, the overall time complexity is O(n) as all operations are linear.

## Attribution

    Copyright (c) 2018-present. This file is part of V-Sekai https://v-sekai.org/.
    K. S. Ernest (Fire) Lee & Contributors
    README.md
    SPDX-License-Identifier: MIT
