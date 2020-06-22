function [pi, A, B, A_num, A_den, B_num, B_den] = hmm_update (alpha, beta, c_alpha, O, A_prev, B_prev)

[N, T] = size(alpha);
[M, ~] = size(B_prev);

pi = alpha(:,1) .* beta(:,1);
pi = pi / sum(pi);

A_num = zeros(N,N);
A_den = zeros(N,N);
for i = 1:N
    num = repmat(alpha(i, 1:T-1), N,1) .* repmat(A_prev(:,i),1,T-1)  .* B_prev(O(2:T), :)' .* beta(:,2:T);
    A_num(:,i) = sum(num,2);
    den = alpha(i, 1:T-1) .* beta(i, 1:T-1) ./ c_alpha(1:T-1);
    A_den(:,i) = repmat(sum(den), N,1);
end
A = A_num ./ A_den; 
B_num = zeros(M,N);
B_den = zeros(M,N);
for j = 1:N
    for k = 1:M
        ind = (O==k);
        num = alpha(j, ind) .* beta(j, ind) ./ c_alpha(ind);
        B_num(k,j) = sum(num);
    end
    den = alpha(j, 1:T) .* beta(j, 1:T) ./ c_alpha(1:T);
    B_den(:,j) = repmat(sum(den), M,1);
end
B = B_num ./ B_den; 
