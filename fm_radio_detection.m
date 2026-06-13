% Project #1 - Kiss FM Rwanda (102.3 MHz)
% Full FM Receiver & Fixed Spectrum Visualizer using PlutoSDR
clear;
clc;

%% 1. System Settings
centerFreq = 102.3e6;     % Kiss FM Rwanda Frequency
fs         = 1e6;         % Sampling Rate
frameLen   = 20000;       % Samples Per Frame

%% 2. Configure PlutoSDR Receiver
sdrRx = sdrrx('Pluto', ...
    'CenterFrequency',    centerFreq, ...
    'BasebandSampleRate', fs, ...
    'SamplesPerFrame',    frameLen, ...
    'OutputDataType',     'double');

%% 3. Configure Spectrum Analyzer
specScope = spectrumAnalyzer(...
    'SampleRate',      fs, ...
    'SpectrumType',    'Power density', ...
    'FrequencySpan',   'Span and center frequency', ...
    'CenterFrequency', 0, ...
    'Span',            fs, ...
    'Title',           'Project #1 - Kiss FM 102.3 MHz Spectrum Analyzer', ...
    'YLimits',         [-110 -30], ...
    'ShowGrid',        true);

%% 4. FM Demodulator Configuration
fmDemod = comm.FMBroadcastDemodulator(...
    'SampleRate',      fs, ...
    'AudioSampleRate', 48000, ...
    'Stereo',          false);

%% 5. Audio Output Device
audioOut = audioDeviceWriter(...
    'SampleRate', 48000);

%% 6. Create Stop Button GUI
stopListening = false;

fig = uifigure(...
    'Name', 'Kiss FM Rwanda Controller', ...
    'Position', [100 100 320 140]);

uibutton(fig, ...
    'Text', 'STOP RADIO', ...
    'Position', [85 50 150 40], ...
    'ButtonPushedFcn', ...
    @(~,~) assignin('base', 'stopListening', true));

%% 7. Start Receiving & Playing Radio
disp('==============================================');
disp(' Project #1 - Kiss FM Rwanda 102.3 MHz ');
disp(' PlutoSDR FM Receiver Started...');
disp('==============================================');

while ~stopListening && ishandle(fig)

    [data, valid] = sdrRx();

    if valid

        % Display Live Spectrum
        specScope(data);

        % FM Demodulation
        audioSignal = fmDemod(data);

        % Play Audio
        audioOut(audioSignal);

    end

    drawnow limitrate;

end

%% 8. Release System Objects
release(sdrRx);
release(fmDemod);
release(audioOut);
release(specScope);

if ishandle(fig)
    close(fig);
end

disp('Radio Receiver Stopped Successfully.');
