function pitch_quant = quantPitch(pitch, pitchFreq)


extra = length(pitchFreq); %36

n = 4:27;
f_extra = 2.^((n-49)/12) .* 440;

norm_pitch = pdist2(pitch, [pitchFreq; f_extra']);
[~, pitch_quant] = min(norm_pitch,[], 2);

pitch_quant(pitch_quant>extra) = mod(pitch_quant(pitch_quant>extra),12);
pitch_quant(pitch_quant==0) = 12;

end