
addpath(genpath('Ragam'));


% dataProcessing
load models/data

model = struct('raag', {}, 'pi', {}, 'A', {}, 'B', {}, ...
        'costFunction', {});
    
fprintf ('Learning model... \n');
for c = 1:length(data)
    model(c).raag = data(c).raag;
    fprintf('Raag %d: %s \n',c, model(c).raag);
    
    % initializing a fully connected markov model
    N = 36; M = 36;
    pi_prev = 1/N * ones(N,1);
    A_prev = rand(N,N); 
    A_prev = A_prev ./ repmat(sum(A_prev), N,1); % normalize
    B_prev = rand(M,N); 
    B_prev = B_prev ./ repmat(sum(B_prev), M,1); % normalize
    
    % init
    log_p_prev = 1;
    costFunc = zeros(50,1);
    O_multiple = data(c).pitch_quant; 
    
    iter = 200;
    for i = 1:iter
        % E step: forward backward
        [alpha, beta, c_alpha_multiple, log_p] = ...
            hmm_fb_multiple(pi_prev, A_prev, B_prev, O_multiple);
        % M step: update step
        [pi, A, B] = hmm_update_multiple (alpha, beta, c_alpha_multiple,...
                                            O_multiple, A_prev, B_prev);
    
        % convergence function: max (log_p_O_model) 
        costFunc(i) = log_p;
        changeLog2 = abs(log_p - log_p_prev) / (1+abs(log_p_prev));
        changeLog = abs(log_p - log_p_prev);
        fprintf('Iteration %d: %f | changeLog: %f | changeLog2: %f \n', ...
            i, log_p, changeLog, changeLog2);

        if (changeLog < 0.1)
            % use the previous values
            pi = pi_prev;
            A = A_prev;
            B = B_prev;
            break;
        end
        log_p_prev = log_p;
        pi_prev = pi;
        A_prev = A;
        B_prev = B;
    end % em iteration
    
    % update model
    model(c).pi = pi;
    model(c).A = A;
    model(c).B = B;
    model(c).costFunction = costFunc;
    
    fprintf('\n');
end 
    
save ('models/model.mat', 'model');
    
    


addpath(genpath('D:\final year project\ragam\ragam-identification'));

true = [4 2 3 1 1 2 2 5 5 3 4 3 2 4 4 5]; 

load models/model;

load models/pitch_freq;
pitchFreq = zeros(length(pitch_freq),1);
for i = 1:length(pitch_freq)
    pitchFreq(i) = pitch_freq(i).frequency;
end

T = readtable('models/GTraagDB.csv');
tonicFreq = 261.625565300599;

testDir = dir('test/*.txt');

log_p_all = zeros(length(model),length(testDir));
for i = 1:length(testDir)
    
    filename = strcat('test/',testDir(i).name);
    pitch_quant = getPitchVec(filename, tonicFreq, pitchFreq, T);
    
    % forward-backward
    log_p = zeros(length(model),1);
    for c = 1:length(model)
        [~, ~, ~, log_p(c)] = hmm_fb (model(c).pi, model(c).A,...
                                            model(c).B, pitch_quant);
    end
    log_p_all(:,i) = log_p; 
    fprintf('%s \n', testDir(i).name);
end


[~, ind] = max(log_p_all)

temp = log_p_all;
linInd = sub2ind(size(log_p_all), ind,1:size(log_p_all,2));
temp(linInd)=nan;
[~, second] = max(temp)
linInd = sub2ind(size(log_p_all), second,1:size(log_p_all,2));
temp(linInd) = nan;
[~, third] = max(temp)
fprintf('Accuracy: %d / %d \n',sum(ind==true), length(ind));

confusion = zeros(length(model));
for i=1:length(ind)
    confusion(true(i), ind(i)) = confusion(true(i), ind(i)) + 1;
end

  
    