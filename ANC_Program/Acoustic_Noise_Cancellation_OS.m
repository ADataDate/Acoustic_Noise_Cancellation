%Written by Mary West

clear;

omega=1:1:1024;
coeffecientTitle = 'Coeffecient Weights';

noise_source=dsp.AudioFileReader('mp3filename', 'OutputDataType', 'double') 
%Enter your n'(noise) source file in .mp3 format between the quotations
%above. Make sure your audio file is contained in the folder where this
%program lives on your computer. Matlab needs the path. 

signal_source=dsp.AudioFileReader('mp3filename', 'OutputDataType', 'double')
%Enter your d[n](desired output) source file in .mp3 format 
%between the quotations above. Make sure your audio file is contained in 
%the folder where this program lives on your computer. Matlab needs the 
%path. This desired output should have some of the correlated unwanted
%noise.

%Create and Configure an LMS adpative filter System Object 
LMS=dsp.LMSFilter(64, 'Method', 'LMS', 'StepSize', .01);

%Create and Configure an audio player system object with sample rate of
%44100 HZ to play the audio signal.

audioout = dsp.AudioPlayer('SampleRate', 44100)

%Set up a waterfall plot that displays 8 traces of the 64 filter
%coefficients

plotw=plotancdata(coeffecientTitle, 8, 64)

playlength = 0;

%Play Original Audio for comparison

%waitfor(msgbox('Click Ok to Play Unfiltered Audio', 'Unfiltered Audio Playback'));
%warndlg('Playing Unfiltered Audio');
button = questdlg('Would you like to play the unfiltered audio?', 'Unfiltered Audio?');

switch button
    case 'Yes'
       
        while playlength < 1000
    
            [signal, eof]=step(signal_source); %Signal source read from audio file
            noise=step(noise_source);          %Noise source
            desired=signal(:,1)+noise(:,1);    %Add Noise to Signal
   
            step(audioout, desired);       %Audio Out
            %numplays=numplays+eof;
            playlength = playlength + 1;
        end
        
    case 'No'
    case 'Cancel'
        release(noise_source);
        release(signal_source);
        release(audioout);
        return;   
end

button = questdlg('Would you like to play the filtered audio?', 'Filtered Audio?');
fftbutton = questdlg('Would you like to see the FFT?', 'FFT');

switch button
    case 'Yes'
        noise_source=dsp.AudioFileReader('VA001 ground run.mp3', 'OutputDataType', 'double')   

        signal_source=dsp.AudioFileReader('MaryVoice.mp3', 'OutputDataType', 'double')
        
        playlength = 0;
        
        while playlength < 1000
    
            [signal, eof]=step(signal_source); %Signal source read from audio file
            noise=step(noise_source);          %Noise source         
            desired=signal(:,1)+noise(:,1);    %Add Noise to Signal
            desiredfft = fft(desired);         %Compute FFT for display
            [out, err, w]=step(LMS, noise(:,1), desired); %Filter using LMS filter
            step(audioout, double(err));       %Audio Out
            errfft=fft(double(err));           %Compute the FFT of Error Signal
    
            if 1
                
                plotw(w);                       %Plot Coeffecients
            end
    
            if strcmp(fftbutton, 'Yes')
                figure(1);                      %Plot the FFT
                subplot(2,1,1)
                plot(omega,abs(desiredfft));
                axis([0 512 0 100]);
                title('Signal Plus Noise');
                subplot(2,1,2);
                plot(omega,abs(errfft));
                axis([0 512 0 100]);
                title('Signal');
            end
    
          %numplays=numplays+eof;
            playlength = playlength + 1;
        end
        
    case 'No'
    case 'Cancel'
        release(noise_source);
        release(signal_source);
        release(audioout);
        return;
end

release(noise_source);
release(signal_source);
release(audioout);

return
      





