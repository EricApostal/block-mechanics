# Block Mechanics
NOTE: **This is a DEMO!** It's a proof of concept I want to really want to work on. Check out the `limitations` section of this document for more information on why this isn't ideal *yet*.

An open-sourced voxel engine built for Roblox.

The demo can be played [here](https://roblox.com/games/13555520675)!

# About
Block Mechanics (not the final name) is a demo of what is possible as far as voxels go in Roblox. There are multiple iterations of this project.


# Current Structure
## Diagram
![image](https://github.com/EricApostal/block-mechanics/assets/60072374/c5e10e65-331a-4cd7-a4bc-d5e7bdfb8220)

## How it works
Currently, chunk loading is handled on a web server. While this isn't completely ideal, it works for what I need. Earlier iterations of this project saw me doing fully custom 3D Perlin noise chunk generation, however, this was relatively limited. By using a webserver, I'm able to offload the heavy computations to more suitable platforms, but I can also use more sophisticated projects to do so.

This does introduce inherent latency, however, due to the nature of chunk loading it's very possible to extend the radius of the requested chunks, and run a caching routine, since most of the latency occurs in transit. For the sake of copyright, I'm using [minetest](https://github.com/minetest/minetest), an open-sourced Voxel Engine game. I made a mod for Minetest that utilizes HTTP Long-Polling to connect to a locally hosted Flask webserver. More information on that project can be found [here](https://github.com/EricApostal/minetest-rblx-chunkgen/). In case you are wondering, this is possible via an official Minecraft server, however I am unsure of how copyright law applies. If that's a project you would like to try, I'd recommend giving [LeviLamina](https://github.com/LiteLDev/LeviLamina) a go.

# Limitations
Like all voxel engine projects on Roblox, there is frame lag. This is largely due to overhead in instancing, and the lack of full meshing control ([for now](https://devforum.roblox.com/t/introducing-in-experience-mesh-image-apis-studio-beta/2725284)). While mutable meshing is coming at some point, instances alone cause lots of lag. This project mostly solves these issues by introducing the block cache. Since much of the lag is caused at `Instance.new`, instances are created ahead of time and use optimized APIs to bulk move blocks into position.
