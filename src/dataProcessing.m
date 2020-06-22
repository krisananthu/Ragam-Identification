
n = 28:63;
f = 2.^((n-49)/12) .* 440;

pitch_str = {'C3','C#3','D3','D#3','E3','F3','F#3','G3','G#3','A3','A#3','B3','C','C#', 'D','D#','E','F','F#','G','G#','A','A#','B','C5','C#5','D5','D#5','E5','F5','F#5','G5','G#5','A5','A#5','B5'};
pitch_freq = struct('pitch', {}, 'frequency', {});
for i = 1:length(pitch_str)
    pitch_freq(i).pitch = pitch_str{i};
    pitch_freq(i).frequency = f(i);
end

save('models/pitch_freq.mat', 'pitch_freq');



% load pitch-freq mapping
load models/pitch_freq;
pitchFreq = zeros(length(pitch_freq),1);
for i = 1:length(pitch_freq)
    pitchFreq(i) = pitch_freq(i).frequency;
end

% read csv file: tonic frequency
T = readtable('models/GTraagDB.csv');
tonicFreq = 261.625565300599;

trainDir = dir('train/');

data = struct('raag', {}, 'pitch', {}, 'pitch_quant', {});

% looping in train dir across all raag dir
raagInd = 1;
for i = 1:length(trainDir)
    if (trainDir(i).isdir && ~strcmp(trainDir(i).name, '.') && ...
            ~strcmp(trainDir(i).name, '..'))
        % raag class
        raagClass = trainDir(i).name;
        data(raagInd).raag = raagClass;
        raagDir = dir(strcat('train/',raagClass,'/*.txt'));
        pitch_cell = cell(length(raagDir),1);
        pitch_quant_cell = cell(length(raagDir),1);
        % in each raag dir, loop through all *.txt files
        for j = 1:length(raagDir)
            
            % get the quantized, normalized pitch vector from the text file
            filename = strcat('train/',raagClass,'/',raagDir(j).name);
            [pitch_quant, pitch] = getPitchVec(filename, tonicFreq, pitchFreq, T);
            
            pitch_cell{j} = pitch;
            pitch_quant_cell{j} = pitch_quant;
            
        end % for raagClass
        data(raagInd).pitch = pitch_cell;
        data(raagInd).pitch_quant = pitch_quant_cell;
        raagInd = raagInd+1;
    end % if
end % for train

save ('models/data.mat', 'data');











