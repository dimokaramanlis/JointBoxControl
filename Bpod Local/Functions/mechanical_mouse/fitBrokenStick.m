function [a, x0, c, fitted_y, exitflag] = fitBrokenStick(x, y)
% Fits a broken-stick (piecewise linear) function to data.
%
% Args:
%   x: The independent variable data (vector).
%   y: The dependent variable data (vector).
%
% Returns:
%   a: The slope of the linear segment.
%   x0: The x-value of the breakpoint (transition point).
%   c: The plateau value.
%   fitted_y: The y-values of the fitted function at the input x values.
%   exitflag:  Exit flag from lsqcurvefit (see lsqcurvefit documentation).

% --- Input Validation ---
if ~isvector(x) || ~isvector(y) || length(x) ~= length(y)
    error('x and y must be vectors of the same length.');
end
if length(x) < 3
    error('At least 3 data points are required for fitting.');
end
x = x(:); % Ensure column vectors
y = y(:);

% --- Broken Stick Function Definition ---
brokenStick = @(params, x) (x <= params(2)) .* (params(1) * (x - params(2)) + params(3)) ...
                        + (x > params(2)) .* params(3);

% --- Initial Parameter Guesses ---
%  These are crucial for good convergence.
a_guess = (max(y) - min(y)) / (max(x) - min(x)); % Estimate initial slope
x0_guess = mean(x); % Start in the middle
c_guess = max(y);   % Estimate plateau as max y-value

initialParams = [a_guess, x0_guess, c_guess];

% --- Parameter Bounds (Optional but Recommended) ---
%   Constrain the parameters to reasonable ranges.
lb = [-Inf, min(x), 0];       % Lower bounds (slope can be negative, x0 >= min(x), plateau >= 0)
ub = [Inf, max(x), max(y)*1.1];  % Upper bounds (x0 <= max(x), allow plateau to be slightly above max(y))

% --- Optimization (Nonlinear Least Squares) ---
options = optimoptions('lsqcurvefit', 'Display', 'off'); % Suppress iterative display, or set to 'iter' for verbose output
[params, ~, ~, exitflag, ~] = lsqcurvefit(brokenStick, initialParams, x, y, lb, ub, options);

% --- Extract Fitted Parameters ---
a = params(1);
x0 = params(2);
c = params(3);
fitted_y = brokenStick(params, x);

% --- Plotting (Optional, but highly recommended for visualization) ---
%  figure;
%  plot(x, y, 'o', 'DisplayName', 'Original Data'); hold on;
%  plot(x, fitted_y, '-', 'LineWidth', 2, 'DisplayName', 'Fitted Broken Stick');
%  plot(x0, c, 'rx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Transition Point'); % Mark the transition
%  xlabel('x');
%  ylabel('y');
%  title('Broken Stick Fit');
%  legend('Location', 'best');
%  grid on;
%  hold off;

% % --- Output message ---
% if exitflag > 0
%   fprintf('Fit converged successfully. Transition point (x0): %.4f\n', x0);
% else
%   warning('Fit may not have converged.  Check exitflag and the plot. Exitflag: %d', exitflag);
%   %  Consider adjusting initial guesses, bounds, or using a different solver.
% end

end


