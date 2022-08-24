module openal.al_interface;

import bindbc.openal;
import std.stdio;
import stb_vorbis;

/*
This is utilizing OpenAL Soft for maximum compatibility.

This acts as a static class/factory class and will allow the whole program
to easily access all OpenAL related components, safely
*/


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

    writeln("OpenAL initialized successfully!");


    string inputPath = "sounds/button.ogg";
    VorbisDecoder vorbisHandler = VorbisDecoder(inputPath);

    writeln("SampleRate:", vorbisHandler.sampleRate());
    writeln("Channels: ", vorbisHandler.chans());
    writeln("Length (seconds): ", vorbisHandler.streamLengthInSeconds());
    writeln("Length (samples): ", vorbisHandler.streamLengthInSamples());
    writeln("Max Frame Size: ", vorbisHandler.maxFrameSize());
    writeln("", );

    float[] pcm;

    vorbisHandler.seekFrame(0);    

    writeln(pcm);

    writeln("File is open: ",vorbisHandler.opened());



    // No errors
    return false;
}