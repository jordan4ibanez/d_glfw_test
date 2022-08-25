module openal.al_interface;

import bindbc.openal;
import std.stdio;
import stb_vorbis;
import std.conv: to;
import vector_3d;

/*
This is utilizing OpenAL Soft for maximum compatibility.

This holds all OpenAL init, and structs for sound_manager to use.
*/

private void* context;
private void* device;
private string deviceName;

bool initializeOpenAL() {

    ALSupport returnedError;
    
    version(Windows) {
        returnedError = loadOpenAL("libs/soft_oal.dll");
    } else {
        // Linux,FreeBSD, OpenBSD, macOSX, haiku, etc
        returnedError = loadOpenAL();
    }

    if(returnedError < ALSupport.al11) {

        if(returnedError == ALSupport.noLibrary) {
            // GLFW shared library failed to load
            writeln("FAILED TO LOAD OPENAL! LIBRARY IS NOT INSTALLED!");
        }
        else if(returnedError == ALSupport.badLibrary) {
            // One or more symbols failed to load.
            writeln("BAD OPENAL LIBRARY INSTALLED! DO YOU HAVE OPENAL 1.1+?");
        }
        return true;
    }

    device = alcOpenDevice(cast(const(char)*)null);

    deviceName = to!string(alcGetString(device, ALC_DEVICE_SPECIFIER));

    // Blank devices aren't allowed, this is a software api
    if (deviceName == null) {
        writeln("OPENAL NULL DEVICE!!");
        return true;
    }
    
    writeln("the AL device pointer: ", device);
    writeln("the AL device name: ", deviceName);

    ALCint[] attributes = [
        ALC_MAJOR_VERSION, 1,
        ALC_MINOR_VERSION, 1,
        0,                 0
    ];

    // Attempt to get a context
    if (device != null) {
        context = alcCreateContext(device,attributes.ptr);
    } else {
        // Something went horribly wrong
        return true;
    }

    // Now we have a context
    alcMakeContextCurrent(context);

    // Generate buffers
    alGetError();

    // We don't need that many buffers
    // alGenBuffers(256,buffers.ptr);

    // Make sure nothing dumb is happening
    debugOpenAL();

    writeln("OpenAL initialized successfully!");

    // No errors
    return false;
}

struct SoundBuffer {

    private bool exists = false;
    private ALuint id = 0;

    this(string fileName) {

        // Hold this data in an associative array
        // After the first call, the game can pull data out of it instead of from disk

        VorbisDecoder vorbisHandler = VorbisDecoder(fileName);

        writeln("SampleRate:", vorbisHandler.sampleRate());
        writeln("Channels: ", vorbisHandler.chans());
        writeln("Length (seconds): ", vorbisHandler.streamLengthInSeconds());
        writeln("Length (samples): ", vorbisHandler.streamLengthInSamples());
        writeln("Max Frame Size: ", vorbisHandler.maxFrameSize());
        writeln("", );

        short[] pcm = new short[vorbisHandler.streamLengthInSamples];

        vorbisHandler.getSamplesShortInterleaved(vorbisHandler.chans(), pcm.ptr, vorbisHandler.streamLengthInSamples());

        writeln(cast(short[])pcm);
        writeln("File is open: ",vorbisHandler.opened());


        // Get a buffer ID
        alGenBuffers(1, &this.id);

        writeln("my buffer ID is: ", this.id);

        alBufferData(this.id, vorbisHandler.chans() == 1 ? AL_FORMAT_MONO16 : AL_FORMAT_STEREO16, cast(const(void)*)pcm, cast(int)(pcm.length * short.sizeof), vorbisHandler.sampleRate());

        // Make sure nothing dumb is happening
        debugOpenAL();

        this.exists = true;
    }

    @disable this(this);

    ~this() {
        if (this.exists) {
            alDeleteBuffers(1, &this.id);
            writeln("cleaned up albuffer ", this.id);
        }
    }
}


struct SoundSource {
    private bool exists = false;
    private ALuint id = 0;

    this(bool loop, bool relative) {
        alGenSources(1, &this.id);
        alSourcei(this.id,AL_LOOPING, loop ? AL_TRUE : AL_FALSE);
        alSourcei(this.id, AL_SOURCE_RELATIVE, relative ? AL_TRUE : AL_FALSE);
        this.exists = true;
    }

    @disable this(this);

    ~this() {
        stop();
        alDeleteSources(1, &this.id);
    }

    bool isPlaying() {
        ALint value;
        alGetSourcei(this.id, AL_SOURCE_STATE, &value);
        return value == AL_PLAYING;
    }

    void pause() {
        alSourcePause(this.id);
    }

    void play() {
        alSourcePlay(this.id);
    }

    void setBuffer(ALuint bufferID) {
        stop();
        alSourcei(this.id, AL_BUFFER, bufferID);
    }

    void setPosition(Vector3d newPosition) {
        alSource3f(
            this.id,
            AL_POSITION,
            newPosition.x,
            newPosition.y,
            newPosition.z
        );
    }

    void stop() {
        alSourceStop(this.id);
    }
}


// There can only be one listener or else weird things will happen
struct SoundListener {
    this(Vector3d position) {
        alListener3f(AL_POSITION, position.x, position.y, position.z);
        alListener3f(AL_VELOCITY,0.0,0.0,0.0);
    }

    void setSpeed(Vector3d speed){
        alListener3f(AL_VELOCITY, speed.x, speed.y, speed.z);
    }

    void setPosition(Vector3d newPosition){
        alListener3f(AL_POSITION, newPosition.x, newPosition.y, newPosition.z);
    }

    void setOrientation(Vector3d at, Vector3d up) {
        float[6] data = [
            at.x,
            at.y,
            at.z,
            up.x,
            up.y,
            up.z
        ];
        alListenerfv(AL_ORIENTATION, data.ptr);
    }
}





void debugOpenAL() {
    int error = alGetError();

    if (!error == AL_NO_ERROR) {

        writeln("OpenAL buffer error! Error number: ", error);
        switch (error) {
            case ALC_INVALID_DEVICE: {
                writeln("AL_INVALID_DEVICE");
                break;
            }
            case ALC_INVALID_CONTEXT: {
                writeln("AL_INVALID_CONTEXT");
                break;
            }
            case AL_INVALID_VALUE:{
                writeln("AL_INVALID_VALUE");
                break;
            }
            case AL_OUT_OF_MEMORY: {
                writeln("AL_OUT_OF_MEMORY");
                break;
            }                
            default:
                writeln("Unknown error code");
        }

        assert(true == false);
    }
}

void cleanUpOpenAL() {
    alcMakeContextCurrent(null);
    alcDestroyContext(context);
    alcCloseDevice(device);

    writeln("OpenAL has successfully closed");
}