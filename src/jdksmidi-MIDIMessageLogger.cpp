#include <chrono>
#include <thread>
#include <iostream>
#include <iomanip>
#include <csignal>
#include <RtMidi.h>

#include <jdksmidi/world.h>
#include <jdksmidi/midi.h>
#include <jdksmidi/msg.h>
#include <jdksmidi/sysex.h>
#include <jdksmidi/parser.h>

//////////////////////////////////////////
//  Better way to cross platform sleep  //
//////////////////////////////////////////
// For using units of time. (s, ms, us, etc...)
using namespace std::chrono_literals;

inline void sleep(std::chrono::duration<double> time)
{
    return std::this_thread::sleep_for(time);
}


//////////////////////////////////////////////////////////////
// Handle SIGINT signal (Ctrl+C), for quit all loop thread. //
//////////////////////////////////////////////////////////////
bool QuitFlag;

void Quit(int Signal)
{
    QuitFlag = true;
    std::cout << "Interrupt." << std::endl;
}

int main()
{
    // Signal handling
    QuitFlag = false;
    std::signal(SIGINT, Quit);

    jdksmidi::MIDIMessage MidiInData; // MIDI class
    std::vector<unsigned char> message; // raw midi message from Rtidi
    RtMidiIn *midiin = new RtMidiIn();
    int nBytes,i;
    double stamp;
    char MIDIMessage[129]; // for console out
    jdksmidi::MIDIParser Parser ( 32 * 1024 ); // Parser. "32 * 1024" is max sysex size (32KiB)

    // Initializing MIDI Port by RtMidi
    std::cout << "Start" << std::endl;
    std::vector<::RtMidi::Api> CompiledAPI;
    midiin->getCompiledApi(CompiledAPI);
    std::cout << "Enable ";
    for(auto elem:CompiledAPI)
	std::cout << elem;
    std::cout << std::endl;

    // Check available ports.
    unsigned int nPorts = midiin->getPortCount();
    std::cout << "Check available ports." << std::endl;
    if (nPorts == 0){
	std::cout << "No ports available!" << std::endl;
	goto cleanup;
    }

    // Open a Midi input port
    midiin->openPort(0,"MIDIMessageLogger");
    // Don't ignore sysex, timing, or active sending messages.
    midiin->ignoreTypes(false,false,false);

    while(!QuitFlag){
	stamp = midiin->getMessage(&message); // Set raw message to variable "message"
	nBytes = message.size();
	for(i=0;i<nBytes;i++)
	{
	    Parser.Parse(message[i], &MidiInData);
	    MidiInData.MsgToText(MIDIMessage);
	    std::cout << MIDIMessage << "\r" << std::flush;
	}
	sleep(10us);
    }

cleanup:
    delete midiin;
}
