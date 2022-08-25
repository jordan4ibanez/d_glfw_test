module openal.sound_manager;

import std.stdio;
import openal.al_interface;
import vector_3d;

/*
This is the work horse of the game's OpenAL implementation.

No parts of the game will talk to OpenAL's buffer, source, and listener besides this.

This acts as a static factory class and will allow the whole program
to easily access all OpenAL related components, safely.
*/

// We do not need that many buffers, this is WAY more than enough
private ALuint[256] buffers = new ALuint[256];