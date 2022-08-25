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
immutable int MAX_SOUNDS = 512;
private SoundBuffer[MAX_SOUNDS] buffers      = new SoundBuffer[MAX_SOUNDS];
private SoundSource[MAX_SOUNDS] soundSources = new SoundSource[MAX_SOUNDS];
private SoundListener listener;

public void playMusic(string name) {

    bool found = false;
    for (int i = 0; i < MAX_SOUNDS; i++) {
        SoundSource thisSoundSource = soundSources[i];
        if (!thisSoundSource.isPlaying()){
            // Free the buffer & sound source
            buffers[thisSoundSource.getBuffer()].cleanUp();
            soundSources[i].cleanUp();

            // Now they're both freed
            found = true;
            break;
        }
    }

    // Couldn't find a free slot, something went seriously wrong
    // Either that, or somebody found a bug and went crazy
    if (!found) {
        writeln("All ", MAX_SOUNDS, " buffers are full (OpenAL)");
        return;
    }

    SoundBuffer thisBuffer = SoundBuffer(name);
    SoundSource thisSource = SoundSource(false, false);
    thisSource.setBuffer(thisBuffer.getID());
    thisSource.play();

    buffers[thisBuffer.getID()] = thisBuffer;
    soundSources[thisBuffer.getID()] = thisSource;
}

void playSoundSource(string name) {
    // soundSources[name].play();
}

void removeSoundSource(string name) {
    // if ((name in soundSources) != null) {
       // soundSources[name].stop();
        // soundSources.remove(name);
    // }
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

private void cleanSoundBuffers() {
    for (int i = 0; i < MAX_SOUNDS; i++) {
        buffers[i].cleanUp();
    }
    writeln("Sound buffers are cleaned");
}

private void cleanSoundSources() {
    for (int i = 0; i < MAX_SOUNDS; i++) {
        soundSources[i].cleanUp();
    }
    writeln("Sound sources are cleaned");
}