function dt = generateDecisionTimeFromOutcome(is_correct, peak_ms, max_interval_sec)
%generateDecisionTimeGamma Generates a decision time using Gamma distributions.
%
%   dt = generateDecisionTimeGamma(is_correct, peak_ms, max_interval_sec)
%
%   Generates a decision time (dt) by sampling from one of two Gamma
%   distributions, depending on whether the trial was correct or incorrect.
%
%   This approach is computationally simpler and gives direct control over
%   the shape of the decision time distributions.
%
%   - 'Correct' trials are sampled from a Gamma distribution whose peak (mode)
%     is set by the 'peak_ms' parameter.
%   - 'Incorrect' trials are sampled from a wider, pre-defined Gamma
%     distribution to simulate fast guesses and slow errors.
%
%   Inputs:
%     is_correct        - Logical scalar. True for correct, false for incorrect.
%     peak_ms           - Double scalar. The desired peak time (mode) for the
%                         'correct' trial distribution in milliseconds (e.g., 120).
%     max_interval_sec  - Double scalar. The maximum decision time to consider,
%                         in seconds (e.g., 3.0).
%
%   Output:
%     dt                - A single decision time in milliseconds.
%
%   Example Usage:
%   % Generate a DT for a correct trial with a peak at 120 ms.
%   correct_dt = generateDecisionTimeGamma(true, 120, 3);
%
%   % Generate a DT for an incorrect trial.
%   incorrect_dt = generateDecisionTimeGamma(false, 120, 3);

persistent cdf_correct cdf_incorrect time_vec last_peak last_max_interval

% --- Setup: Define distributions if parameters change or on first run ---
if isempty(cdf_correct) || peak_ms ~= last_peak || max_interval_sec ~= last_max_interval
%     fprintf('Initializing Gamma distributions (Peak: %d ms, Max Interval: %.1f s)...\n', peak_ms, max_interval_sec);

    % 1. Define the discrete time space
    max_ms = round(max_interval_sec * 1000);
    time_vec = 1:max_ms;

    % 2. Define the Gamma distribution for CORRECT trials
    % The mode (peak) of a Gamma distribution is (shape-1)*scale.
    % We fix the shape parameter and calculate the scale to match the desired peak.
    shape_correct = 3; % A shape > 2 gives a nice bell-like curve.
    
    assert(shape_correct > 1, 'Shape parameter must be > 1 to have a peak.');
    scale_correct = peak_ms / (shape_correct - 1);

    pmf_correct = gampdf(time_vec, shape_correct, scale_correct);
    pmf_correct = pmf_correct / sum(pmf_correct); % Normalize to a valid PMF

    % 3. Define the Gamma distribution for INCORRECT trials
    % We use a different shape/scale to make it wider and more skewed,
    % representing fast guesses and long, uncertain decisions
    
    shape_incorrect = 0.9; % A lower shape gives more weight to short DTs
    scale_incorrect = 600; % A larger scale makes the tail longer
    
    pmf_incorrect = gampdf(time_vec, shape_incorrect, scale_incorrect);
    pmf_incorrect = pmf_incorrect / sum(pmf_incorrect); % Normalize
    negpart       = (1 - pmf_correct);
    negpart       = negpart-min(negpart);
    pmf_incorrect = pmf_incorrect .* negpart/sum(negpart);
    pmf_incorrect = pmf_incorrect/sum(pmf_incorrect);
%     plot(time_vec, pmf_correct, time_vec, pmf_incorrect)
%     xline(peak_ms,'r--','peak performance time (user)')
%     xlabel('Decision time (ms)')
%     legend('p(DT|correct)', 'p(DT|incorrect)')
%     xlim([-20 2000]);
    %%
    % 4. Compute the Cumulative Distribution Functions (CDFs) for sampling
    cdf_correct = cumsum(pmf_correct);
    cdf_incorrect = cumsum(pmf_incorrect);
    
    % Store current parameters to avoid re-calculation
    last_peak = peak_ms;
    last_max_interval = max_interval_sec;
end


% --- Sampling: Generate a decision time ---
% Sample a DT using inverse transform sampling from the appropriate CDF.

if is_correct
    % Sample from the 'correct' distribution
    rand_val = rand();
    dt_index = find(cdf_correct >= rand_val, 1, 'first');
else
    % Sample from the 'incorrect' distribution
    rand_val = rand();
    dt_index = find(cdf_incorrect >= rand_val, 1, 'first');
end

if isempty(dt_index)
    dt_index = length(time_vec); % Handle edge case where rand_val is exactly 1
end

dt = time_vec(dt_index);

end