module openal.sound_manager;

import std.stdio;
import bindbc.openal;
import openal.al_interface;
import vector_3d;
import matrix_4d;

/*
This is the work horse of the game's OpenAL implementation.

No parts of the game will talk to OpenAL's buffer, source, and listener besides this.

This acts as a static factory class and will allow the whole program
to easily access all OpenAL related components, safely.
*/

// We do not need that many buffers, this is WAY more than enough
private SoundBuffer[256] buffers = new SoundBuffer[256];
private SoundSource[string] soundSources;
private SoundListener listener;

void playSoundSource(string name) {
    if ((name in soundSources) != null && !soundSources[name].isPlaying()) {
        soundSources[name].play();
    }
}

void removeSoundSource(string name) {
    if ((name in soundSources) != null) {
        soundSources[name].stop();
        soundSources.remove(name);
    }
}

void setAttenuationModel(ALint model) {
    alDistanceModel(model);
}

void updateListenerPosition(Matrix4d cameraMatrix, Vector3d cameraPosition) {
    listener.setPosition(cameraPosition);
    Vector3d at = Vector3d();
    // This might need testing
    cameraMatrix.positiveZ(at).negate();
    Vector3d up = Vector3d();
    //This might need testing
    cameraMatrix.positiveY(up);
    listener.setOrientation(at, up);

}







void initializeListener() {
    listener = SoundListener(Vector3d(0,0,0));
    writeln("OpenAL sound listener initialized");
}

void cleanUpSoundManager() {
    cleanSoundBuffers();
    cleanSoundSources();
}

private void cleanSoundBuffers(){
    for (int i = 0; i < 256; i++){
        // Call destructor by replacing it with blank
        buffers[i] = SoundBuffer();
    }

    writeln("Sound buffers are cleaned");
}

private void cleanSoundSources(){
    string[] keys = soundSources.keys();
    foreach (string key; keys) {
        writeln("cleaning: ",key);
        soundSources[key] = SoundSource();
        soundSources.remove(key);
    }

    writeln("Sound sources are cleaned");
}