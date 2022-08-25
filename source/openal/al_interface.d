module openal.al_interface;

import bindbc.openal;
import std.stdio;
import stb_vorbis;
import std.conv: to;

/*
This is utilizing OpenAL Soft for maximum compatibility.

This acts as a static class/factory class and will allow the whole program
to easily access all OpenAL related components, safely
*/

private void* context;
private void* device;
private string deviceName;

private ALuint[256] buffers = new ALuint[256];

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
    alGenBuffers(256,buffers.ptr);

    // Make sure nothing dumb is happening
    debugOpenAL();

    writeln("OpenAL initialized successfully!");

    // No errors
    return false;
}

// Make this private
struct Buffer {

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