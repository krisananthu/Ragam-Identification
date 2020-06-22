function [pitch_quant, pitch, t_pitch] = getPitchVec(filename, tonicFreq, pitchFreq, T)


    % .txt -> vector
    fID = fopen(filename);
    pitch_file = textscan(fID, '%f %f');
    fclose(fID);
     t_pitch = pitch_file{1};
    pitch = pitch_file{2};
    % replacing pitch with tonic frequency C (since the recordings take
    % are mostly in C shruti.
    pitch(pitch==0) = nan;  

    % quantizing the pitch to nearest semitone
    pitch_quant= quantPitch(pitch, pitchFreq);
    
    % shift relative to tonic frequency
    % get tonic freq from .csv file
    [~,name,~] = fileparts(filename);
    tf = T.TonicFrequency(strcmp(T.Filename,strcat(name,'.wav')));
    % shifting pitch to tonic frequency(Tanpura note)
    shift = quantPitch(tonicFreq,pitchFreq) - quantPitch(tf,pitchFreq);
    pitch_quant = pitch_quant + shift;
    pitch_quant(pitch_quant<=0) = pitch_quant(pitch_quant<=0) + 12;
    
    pitch_quant(isnan(pitch)) = 1;



end