module openal.sound_manager;



/*
This is the work horse of the game's OpenAL implementation.

No parts of the game will talk to OpenAL's buffer, source, and listener besides this.
*/

// We do not need that many buffers, this is WAY more than enough
private ALuint[256] buffers = new ALuint[256];