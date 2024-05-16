To calculate the operations per second (ops/s) needed, we need to consider the number of players and the frequency at which each operation is performed.

1. For isolated player state nodes:

   - 8,000 players are handled at a frequency of 100hz. This means that each player is processed 100 times per second.
   - Therefore, the ops/s = 8,000 players \* 100 operations/player/second = 800,000 ops/s.

2. For individual player state processing:

   - Similarly, 8,000 players are handled at a frequency of 100hz.
   - Therefore, the ops/s = 8,000 players \* 100 operations/player/second = 800,000 ops/s.

3. For storing all player states in a history buffer:
   - 10,000 players are handled at a frequency of 100hz for 1 second.
   - Therefore, the ops/s = 10,000 players \* 100 operations/player/second = 1,000,000 ops/s.

So, if you want to run your production systems at 40% capacity at all times, as suggested in the article you linked, you would need a system capable of handling:

- For isolated player state nodes and individual player state processing: 800,000 ops/s / 0.4 = 2,000,000 ops/s.
- For storing all player states in a history buffer: 1,000,000 ops/s / 0.4 = 2,500,000 ops/s.

These calculations assume that each operation takes the same amount of time, which might not be the case in a real-world scenario. Also, keep in mind that these numbers represent the theoretical maximum capacity needed. The actual capacity required could be lower depending on the efficiency of your code and the specific workload characteristics.

## Math

32 cores with 10 gigabit internet.

1. **Player Server:**

   - 10,000 players are sending data at a frequency of 100hz (100 times per second), each sending 100 bytes of data.
   - Therefore, the total data processed per second = 10,000 players _ 100 operations/second/player _ 100 bytes/operation = 100,000,000 bytes or approximately 95.37 MB/s.
   - Assuming a 50/50 read/write ratio, the IOPS would be 1,000,000 reads/s + 1,000,000 writes/s = 2,000,000 IOPS.

2. **World Server:**

   - 8,000 players are sending data at a frequency of 100hz (100 times per second), each sending 100 bytes of data.
   - Therefore, the total data processed per second = 8,000 players _ 100 operations/second/player _ 100 bytes/operation = 80,000,000 bytes or approximately 76.29 MB/s.
   - Assuming a 50/50 read/write ratio, the IOPS would be 800,000 reads/s + 800,000 writes/s = 1,600,000 IOPS.

3. **World Server Sending Back to Client:**

   - The world server sends back data to 10,000 clients. Without knowing the size of the data being sent back and the frequency, it's hard to calculate the exact data rate or IOPS. If we assume it's also sending 100 bytes of data at a frequency of 100hz, then the calculation would be similar to the player server.

### Ideas

1. Paxos in the kernel ebpf
2. Ring buffer ebpf
3. udp networking ebpf
