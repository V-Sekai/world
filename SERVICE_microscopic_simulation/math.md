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

```mermaid
sequenceDiagram
    SingleClient->>8_000_PlayerServer: Send 100 bytes
    8_000_PlayerServer->>10_000_WorldServer1: Propose operation (Paxos)
    8_000_PlayerServer->>10_000_WorldServer2: Propose operation (Paxos)
    8_000_PlayerServer->>10_000_WorldServer3: Propose operation (Paxos)
    10_000_WorldServer1-->>8_000_PlayerServer: Promise to accept operation (Paxos)
    10_000_WorldServer2-->>8_000_PlayerServer: Promise to accept operation (Paxos)
    10_000_WorldServer3-->>8_000_PlayerServer: Promise to accept operation (Paxos)
    8_000_PlayerServer->>10_000_WorldServer1: Accept operation and send 100 bytes (Paxos)
    8_000_PlayerServer->>10_000_WorldServer2: Accept operation and send 100 bytes (Paxos)
    8_000_PlayerServer->>10_000_WorldServer3: Accept operation and send 100 bytes (Paxos)
    10_000_WorldServer1-->>8_000_PlayerServer: Acknowledge acceptance and send Tree Order of Player States (Paxos)
    10_000_WorldServer2-->>8_000_PlayerServer: Acknowledge acceptance and send Tree Order of Player States (Paxos)
    10_000_WorldServer3-->>8_000_PlayerServer: Acknowledge acceptance and send Tree Order of Player States (Paxos)
    8_000_PlayerServer->>SingleClient: Process 100 bytes in received Tree Order
    10_000_WorldServer1->>SingleClient: Send data for all authority states
    10_000_WorldServer2->>SingleClient: Send data for all authority states
    10_000_WorldServer3->>SingleClient: Send data for all authority states
```
