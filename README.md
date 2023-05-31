# Next up
# Networking ideas:
## The Problem - Looping through every block in a chunk / world is bad when breaking block
- I could link a remove signal to every block? So there would be an onBlockRemoved signal that would tell the client "the block at vector3 was removed", and every block would compare it to themselves?