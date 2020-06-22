function [alpha, beta, c_alpha, log_p_O_model] = hmm_fb (pi, A, B, O)



[~,N] = size(B);
T = length(O);

%% alpha [N x T]: forward step

alpha = zeros(N,T);
c_alpha = zeros(1,T); % scaling coefficients
% init
alpha(:,1) = pi .*  B(O(1), :)';
c_alpha(1) = 1/sum(alpha(:,1));
alpha(:,1) = alpha(:,1) .* c_alpha(1);
% induction
for t = 2:T
    alpha(:,t) = (alpha(:,t-1)' * A')' .* B(O(t), :)';
   % scaling
   c_alpha(t) = 1/sum(alpha(:,t));
   alpha(:,t) = alpha(:,t) .* c_alpha(t);
end
% termination
log_p_O_model = -sum(log(c_alpha));

%% beta [N x T]: backward step 
beta = ones(N,T);
% init
beta(:,T) = beta(:,T) * c_alpha(T);
% induction
for t = T-1:-1:1
    beta(:,t) = ((B(O(t+1), :)' .* beta(:, t+1))' * A)';
    % scaling
    beta(:,t) = beta(:,t) .* c_alpha(t);
end





























