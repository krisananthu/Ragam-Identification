function [alpha_multiple, beta_multiple, c_alpha_multiple, log_p_O_model]...
    = hmm_fb_multiple(pi_prev, A_prev, B_prev, O_multiple)


L = length(O_multiple);
log_p_O_model_multiple = zeros(L,1);
alpha_multiple = cell(L,1);
beta_multiple = cell(L,1);
c_alpha_multiple = cell(L,1);

for l = 1:L
    [alpha_multiple{l}, beta_multiple{l}, c_alpha_multiple{l}, ...
        log_p_O_model_multiple(l)] = hmm_fb(pi_prev, A_prev, B_prev, O_multiple{l});
end

log_p_O_model = sum(log_p_O_model_multiple);
end
