# Adalm-PlutoSDR-FM-Communication-Lab-Detection-Reception-and-Transmission
Practical FM signal detection, reception, and transmission using ADALM-PlutoSDR with MATLAB and GNU Radio Companion.
<img width="966" height="495" alt="image" src="https://github.com/user-attachments/assets/77345d91-f013-40d3-99cf-20778a645710" />


1. Introduction

Software Defined Radio (SDR) is a radio communication system where components traditionally implemented in hardware (such as mixers, filters, amplifiers, modulators/demodulators, and detectors) are instead implemented by means of software on a computer or embedded system. This makes it possible to receive and process radio frequency (RF) signals using general-purpose hardware and flexible software tools.

This project implements a full FM broadcast receiver using the ADALM-PLUTO SDR hardware connected to MATLAB R2024b. The system is capable of:
•	Detecting live FM radio signals broadcast in Kigali, Rwanda
•	Visualizing the real-time RF spectrum of the received signal
•	Demodulating the FM signal to extract the audio content
•	Playing the audio output in real time through the computer speakers

The target station for this project is Kiss FM Rwanda, broadcasting at 102.3 MHz. The project demonstrates practical application of telecommunication concepts including signal processing, frequency modulation, and software-defined radio architecture all directly relevant to the Telecommunication Networks course.

2. Background Theory

2.1 Frequency Modulation (FM)
FM broadcasting is an analog radio broadcast technology that uses frequency modulation (FM) to provide high-fidelity sound over broadcast radio. In FM, the information (audio) signal varies the instantaneous frequency of the carrier wave. The key parameters are:


<img width="458" height="128" alt="image" src="https://github.com/user-attachments/assets/75961a8c-5aa1-483b-b345-bd391b3dbc43" />


2.2 Software Defined Radio (SDR)

A Software Defined Radio system replaces traditional analog RF hardware with digital signal processing (DSP) software. The ADALM-PLUTO SDR used in this project is an active learning module developed by Analog Devices. It acts as a wideband transceiver capable of receiving RF signals across a wide frequency range and converting them into digital samples for processing in MATLAB.

The SDR signal processing chain used in this project is:

  Antenna  -->  ADALM-PLUTO (RF to Digital)  -->  MATLAB (Digital Signal Processing)

  Step 1: Antenna captures RF signal at 102.3 MHz
  Step 2: ADALM-PLUTO down-converts RF to baseband digital samples
  Step 3: MATLAB receives complex I/Q samples at 1 MHz sample rate
  Step 4: Spectrum Analyzer displays live frequency spectrum
  Step 5: FM Demodulator extracts audio from the baseband signal 
  Step 6: Audio Device Writer plays audio through speakers

2.3 Electromagnetic Spectrum Context
FM radio occupies the frequency range from 88 MHz to 108 MHz within the Very High Frequency (VHF) portion of the electromagnetic spectrum. Kiss FM Rwanda broadcasts at 102.3 MHz, which falls within this standardized FM broadcast band. The signal captured in this experiment was detected and verified at this frequency.

3. Hardware setup – ADALM-PLUTO SDR

3.1 Device Specifications
Specification	Value
Device Name	ADALM-PLUTO (PlutoSDR)
Manufacturer	Analog Devices Inc.
RF Frequency Range	325 MHz to 3.8 GHz (standard firmware)
Extended Range (hacked firmware)	70 MHz to 6 GHz
Sample Rate	Up to 61.44 MSPS
Bandwidth	Up to 56 MHz
Interface	USB 2.0
Transmit/Receive	Full-duplex (1 TX, 1 RX)
Power Supply	USB powered (500 mA)
Antenna connector	SMA female (RX port used for this project)

3.2 Physical Connection Steps
The following steps were followed to connect and configure the ADALM-PLUTO for this experiment:

•	Attach the included SMA antenna to the RX port of the ADALM-PLUTO device.
•	Connect the ADALM-PLUTO to the laptop via the USB 2.0 cable.
•	Wait 10-15 seconds for Windows to recognize the device. The device appears as a USB drive in File Explorer - this is normal.
•	In MATLAB, run findPlutoRadio to verify the device is detected (expected output: RadioID: 'usb:0').
•	Position the antenna near a window for best FM signal reception.

4. Software Requirements- MATLAB R2024B Toolboxes
The following MATLAB toolboxes and support packages are required to run this project. Each must be installed before executing the code:

<img width="489" height="324" alt="image" src="https://github.com/user-attachments/assets/c814ef60-876d-4d1f-8601-1535b8b79cf4" />



Installation Command (Alternative - MATLAB Command Window):
  % Run in MATLAB Command Window to install all required support:
  matlab.addons.install('Communications Toolbox Support Package for Analog Devices ADALM-Pluto Radio')

  % Verify PlutoSDR is detected after installation:
  findPlutoRadio

Note: During installation of the ADALM-PLUTO support package, Windows will prompt to install USB drivers. These drivers must be accepted/installed for MATLAB to communicate with the hardware.
 

**5.MATLAB CODE – Full FM Receiver

**5.1 Complete Annotated Source Code****

The following is the full MATLAB code used in this project, with detailed explanation of each section:
  % =========================================================
  % Project #1 - Kiss FM Rwanda (102.3 MHz)
  % Full FM Receiver & Fixed Spectrum Visualizer using PlutoSDR
  % =========================================================
  clear;
  clc;
**5.2 Section-by-Section Explanation**

**Section 1: System Settings**
  centerFreq = 102.3e6;     % Kiss FM Rwanda Frequency (102.3 MHz)
  fs         = 1e6;         % Sampling Rate = 1 MHz
  frameLen   = 20000;       % Samples Per Frame
centerFreq = 102.3e6: Sets the center tuning frequency to 102.3 MHz (Kiss FM Rwanda). The SDR hardware will be tuned to receive signals at this frequency.
fs = 1e6: Sets the baseband sample rate to 1 MHz (1,000,000 samples per second). This determines how wide a frequency band is captured around the center frequency. At 1 MHz, we capture a 1 MHz window centered at 102.3 MHz (i.e., 101.8 MHz to 102.8 MHz).
frameLen = 20000: Each call to the SDR receiver returns 20,000 complex samples (I/Q samples). This sets the processing block size.

**Section 2: Configure PlutoSDR Receiver**
  sdrRx = sdrrx('Pluto', ...
      'CenterFrequency',    centerFreq, ...
      'BasebandSampleRate', fs, ...
      'SamplesPerFrame',    frameLen, ...
      'OutputDataType',     'double');
sdrrx('Pluto', ...): Creates a Software Defined Radio receiver object configured for the ADALM-PLUTO device. This object handles all low-level USB communication with the hardware.
•	CenterFrequency: Tunes the RF front-end of the Pluto to 102.3 MHz
•	BasebandSampleRate: Sets the ADC (Analog-to-Digital Converter) sample rate to 1 MHz
•	SamplesPerFrame: Number of samples returned per call to sdrRx()
•	OutputDataType 'double': Returns complex double-precision floating point samples (standard I/Q format)

**Section 3: Configure Spectrum Analyzer**
  specScope = spectrumAnalyzer(...
      'SampleRate',      fs, ...
      'SpectrumType',    'Power density', ...
      'FrequencySpan',   'Span and center frequency', ...
      'CenterFrequency', 0, ...
      'Span',            fs, ...
      'Title',           'Group #1 - Kiss FM 102.3 MHz Spectrum Analyzer', ...
      'YLimits',         [-110 -30], ...
      'ShowGrid',        true);
spectrumAnalyzer creates a real-time spectrum display window (the DSP System Toolbox spectrum analyzer). Key parameters:
•	SpectrumType 'Power density': Displays power spectral density (dBm/Hz) on the Y-axis — matches what is visible in the screenshot
•	CenterFrequency 0: Displays the baseband signal centered at 0 Hz (the actual RF center is handled by the SDR hardware)
•	Span = fs = 1e6: Shows the full 1 MHz capture bandwidth
•	YLimits [-110 -30]: Y-axis range from -110 dBm/Hz to -30 dBm/Hz

**Section 4: FM Demodulator**
  fmDemod = comm.FMBroadcastDemodulator(...
      'SampleRate',      fs, ...
      'AudioSampleRate', 48000, ...
      'Stereo',          false);
comm.FMBroadcastDemodulator is the core FM demodulation block from the Communications Toolbox. It performs all the digital signal processing required to extract audio from the FM-modulated baseband signal:
•	SampleRate = fs = 1e6: Input signal sample rate (1 MHz from the SDR)
•	AudioSampleRate = 48000: Output audio is resampled to 48 kHz for playback
•	Stereo = false: Receives mono audio only (simpler, avoids pilot tone decoding complexity)
Internally, the FMBroadcastDemodulator performs: low-pass filtering, FM discriminator (phase difference demodulation), de-emphasis filtering (75 us time constant), and sample rate conversion from 1 MHz to 48 kHz.

**Section 5: Audio Output**
  audioOut = audioDeviceWriter(...
      'SampleRate', 48000);
audioDeviceWriter (from the Audio Toolbox) sends the demodulated audio samples to the computer's default audio output device (speakers or headphones) at 48 kHz sample rate. This enables real-time listening to the radio station.

**Section 6: Stop Button GUI**
  stopListening = false;
  fig = uifigure('Name', 'Kiss FM Rwanda Controller', 'Position', [100 100 320 140]);
  uibutton(fig, 'Text', 'STOP RADIO by grp_1', 'Position', [85 50 150 40], ...
      'ButtonPushedFcn', @(~,~) assignin('base', 'stopListening', true));
A simple GUI (Graphical User Interface) window with a STOP RADIO button is created using MATLAB's App Designer UI components. When pressed, it sets the stopListening variable to true in the MATLAB base workspace, causing the main loop to exit gracefully.

**Section 7: Main Receive and Play Loop**
  while ~stopListening && ishandle(fig)
      [data, valid] = sdrRx();
      if valid
          specScope(data);         % Display Live Spectrum
          audioSignal = fmDemod(data);  % FM Demodulation
          audioOut(audioSignal);    % Play Audio
      end
      drawnow limitrate;
  end
The main loop continuously executes until the STOP button is pressed:
•	[data, valid] = sdrRx(): Receives one frame of 20,000 complex I/Q samples from the ADALM-PLUTO
•	if valid: Checks that the received frame is valid (not corrupted or dropped)
•	specScope(data): Feeds the raw I/Q data to the spectrum analyzer for real-time display
•	fmDemod(data): Applies FM broadcast demodulation to extract the audio signal
•	audioOut(audioSignal): Sends decoded audio to the speakers
•	drawnow limitrate: Forces MATLAB to update the GUI and spectrum display without overloading the processor

**Section 8: Release Resources**
  release(sdrRx);
  release(fmDemod);
  release(audioOut);
  release(specScope);
  if ishandle(fig); close(fig); end
  disp('Radio Receiver Stopped Successfully.');
After the loop exits, all System Objects must be released. This is critical without release(), the ADALM-PLUTO USB connection remains locked, and subsequent MATLAB runs will fail with a 'device already in use' error.



6. Experimental Results

**6.1 Spectrum Analyzer Screenshot**
The following screenshot was captured during live operation of the FM receiver. It shows the MATLAB Spectrum Analyzer displaying the real-time RF spectrum received from the ADALM-PLUTO, with a clearly visible FM signal peak:

<img width="1138" height="590" alt="image" src="https://github.com/user-attachments/assets/f0745114-8c0e-4e8d-abe8-38acde7e2d82" />

 Figure 1: MATLAB Spectrum Analyzer Live FM Signal Detection (Baseband View, 1 MHz span)


**System Implementation
The receiver was implemented using the following GNU Radio blocks:
•	Pluto SDR Source 
•	Center Frequency: 102.3 MHz 
•	Sample Rate: 2.4e6 
•	RF Gain: ~50–60 dB (adjusted experimentally) 
•	WBFM Receive Block 
•	Quadrature rate: 2.4e6 
•	Converts FM signal to audio baseband 
•	Audio Sink 
•	Sample rate 48KHZ**
                       <img width="1151" height="763" alt="image" src="https://github.com/user-attachments/assets/d4edc588-c8db-470e-a351-cfbde19c0d95" />


**7. Conclusion**
This project successfully demonstrated the use of Software Defined Radio (SDR) technology to detect, visualize, and demodulate a live FM broadcast signal from Kiss FM Rwanda (102.3 MHz, you can replace the radio of your choice) using the ADALM-PLUTO SDR hardware and MATLAB R2024b.

The key achievements of the project are:
•	Successfully configured and connected the ADALM-PLUTO SDR to MATLAB R2024b
•	Detected a clear FM signal peak in the real-time spectrum analyzer at the target frequency
•	Implemented a complete FM broadcast receiver chain: 
  -	RF reception
	- spectrum display
	- FM demodulation
	- audio playback
•	Built a functional GUI stop control for safe hardware release

The experiment confirms that Software Defined Radio is a powerful and flexible approach to radio signal processing. By replacing traditional analog hardware with software algorithms, SDR enables rapid prototyping, flexible tuning, and deep signal analysis all critical capabilities in modern telecommunication engineering.

10. References
•	ETE3262 Telecommunication Networks Lecture Notes - Lecture #3: Communication Signals and their Impairments. University of Rwanda, 2020.
•	Youtube tutorials
•	AI was used also for some verification and fostering work
•	Analog Devices, ADALM-PLUTO Overview. [Online]. Available: https://wiki.analog.com/university/tools/pluto
•	MathWorks, Communications Toolbox Support Package for ADALM-PLUTO Radio. [Online]. Available: https://www.mathworks.com/hardware-support/adalm-pluto-radio.html
•	MathWorks, comm.FMBroadcastDemodulator. MATLAB R2024b Documentation. Communications Toolbox.
•	Forouzan, B.A., Data Communications and Networking, 5th Edition. McGraw-Hill, 2013.

