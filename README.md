# Next up
# Networking ideas:
## Major Problems
I need a more standardized chunk determining system.

Currently, every time a chunk is created, I am manually calculating what that chunk is defined as, and where the containing blocks need to be. Instead of doing pos/3/16, I need a replicatedstorage module to map this position.

Specifically, I think the problem is that the chunk starts at a different position than how I am offsetting it via code.

test