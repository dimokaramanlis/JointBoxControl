function [dt, is_correct] = generateTrial(target_p_correct)
%generateTrial Generates a single trial with a calibrated DT/accuracy model.
%
%   This function models the relationship between decision time (DT) and
%   accuracy P(Correct|DT) to achieve a specific overall target accuracy.
%
%   - It defines a base DT distribution (the agent's response tendency).
%   - It defines an accuracy curve (low at DT extremes, high in the middle).
%   - It numerically calibrates the accuracy curve so the average performance
%     matches the target_p_correct.
%   - It then samples a DT and an outcome according to this calibrated model.
%
%   [dt, is_correct] = generateTrial(target_p_correct)
%
%   Input:
%     target_p_correct - The desired overall average accuracy (e.g., 0.80).
%
%   Outputs:
%     dt               - The sampled decision time (ms) for this trial.
%     is_correct       - The logical outcome (true/false) for this trial.

persistent p_correct_given_dt_calibrated cdf_overall_dt time_vec last_target

% --- 1. SETUP & CALIBRATION (runs only when target changes) ---
if isempty(last_target) || target_p_correct ~= last_target
    fprintf('Calibrating model for target P(Correct) = %.2f...\n', target_p_correct);

    % --- Define Model Ingredients ---
    time_vec = 1:3000; % Max DT of 3 seconds

    % a) Agent's Tendency P(DT): A Gamma distribution for all response times
    shape = 3; scale = 75; % Peaks around 150ms, has a long tail
    overall_dt_dist = gampdf(time_vec, shape, scale);
    overall_dt_dist = overall_dt_dist / sum(overall_dt_dist); % Normalize
    
    % b) Agent's Ability P(Correct|DT) Shape: Baseline + Skill Bump
    peak_time = 120; % ms
    skill_width = 40;  % How wide the peak of high accuracy is
    
    % The curve starts at 0.5 (chance) and adds a Gaussian "skill bump"
    skill_bump = exp(-(time_vec - peak_time).^2 / (2 * skill_width^2));
    base_accuracy_curve = 0.5 + 0.5 * skill_bump; % Uncalibrated, peaks at 1.0

    % --- Calibrate the Accuracy Curve ---
    % We need to find a scaling factor 'A' such that:
    % P(target) = sum( (0.5 + A * (base_curve - 0.5)) .* P(DT) )
    p_variable_part = base_accuracy_curve - 0.5;
    
    % Iteratively find the right scaling factor
    scale_factor = 1.0;
    for iter = 1:100 
        p_correct_given_dt_current = 0.5 + scale_factor * p_variable_part;
        p_correct_given_dt_current(p_correct_given_dt_current > 1) = 1;
        
        achieved_p_correct = sum(p_correct_given_dt_current .* overall_dt_dist);
        
        if abs(achieved_p_correct - target_p_correct) < 1e-4, break; end
        
        % Adjust scale_factor based on error
        scale_factor = scale_factor * (target_p_correct - 0.5) / (achieved_p_correct - 0.5);
    end
    
    % Store the final, calibrated curve and the DT distribution for sampling
    p_correct_given_dt_calibrated = 0.5 + scale_factor * p_variable_part;
    p_correct_given_dt_calibrated(p_correct_given_dt_calibrated > 1) = 1;
    cdf_overall_dt = cumsum(overall_dt_dist);
    last_target = target_p_correct;
end

% --- 2. SAMPLING (runs on every call) ---

% a) Sample a Decision Time from the overall P(DT) distribution
rand_dt = rand();
dt_idx = find(cdf_overall_dt >= rand_dt, 1, 'first');
dt = time_vec(dt_idx);

% b) Determine the probability of being correct for this specific DT
p_success_for_this_dt = p_correct_given_dt_calibrated(dt_idx);

% c) Flip a weighted coin to determine the outcome
is_correct = rand() < p_success_for_this_dt;

end