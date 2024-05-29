The idea is we pop one state then for each every of the other 10_000 states in order then output
even if I cheat and make this a relay server instead of client server auth

I'm ok for example if we run both branches in the node state processing and keep the good one
oh I forgot to mention

remember we're doing the nodejs reactor system

so there's three parts to it

8_000 player server only collecting per user states

player database that takes player state from the player server and sticks it into the world server. This is where we iterate the world state using nx for example. aka game loop

10_000 world server collecting player states over 1 second

1 and 2 can literally be a linux kernel driver with file descriptors for each entry
