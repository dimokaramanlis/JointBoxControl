function localsettings = loadLocalSettings()
%loadLocalSettings Loads settings from a text file or sets defaults.
%   Reads settings from 'local_settings.txt' in the specified directory.
%   Each line should be in the format 'settingName = value'.
%   - Boolean values should be 'true' or 'false' (case-insensitive).
%   - Numeric values are parsed as numbers.
%   - Lines starting with '%' or '#' are ignored as comments.
%   - Blank lines are ignored.
%   - If a setting is missing in the file, its default value is used.
%   - If the file doesn't exist, defaults are used and a default file
%     is created for guidance.

    %----------------------------------------------------------------------
    % 1. Define Defaults First
    % This structure defines ALL possible settings and their defaults.
    % Any setting not found in the file will keep its default value.
    defaults = struct();
    defaults.useAIM         = true;
    defaults.useFrame2TTL   = false;
    defaults.pulseWindow    = false;
    defaults.useMouseSlider = 0; % Default is 0, can be 0, 1, or 2
    defaults.sliderCOM      = 7;
    % Initialize localsettings with defaults
    localsettings = defaults;
    %----------------------------------------------------------------------
    % 2. Define File Path
    settingsDir = 'C:\BoxSettings';
    settingsFile = 'local_settings.txt'; % New filename
    dpfilesettings = fullfile(settingsDir, settingsFile);

    % 3. Check if file exists and process it
    if exist(dpfilesettings, 'file')
        fid = -1; % Initialize file identifier
        try
            fid = fopen(dpfilesettings, 'rt'); % Open for text reading
            if fid == -1
                warning('loadLocalSettings:FileOpenError', ...
                        'Could not open settings file: %s. Using default settings.', dpfilesettings);
            else
                disp(['Loading settings from: ', dpfilesettings]);
                lineNumber = 0;
                while ~feof(fid)
                    lineNumber = lineNumber + 1;
                    line = strtrim(fgetl(fid)); % Read line and trim whitespace

                    % Skip blank lines or comment lines
                    if isempty(line) || startsWith(line, '%') || startsWith(line, '#')
                        continue;
                    end

                    % Parse the line: find the first '='
                    eqPos = strfind(line, '=');
                    if isempty(eqPos)
                        warning('loadLocalSettings:ParseError', ...
                                'Skipping line %d (no "=" found): %s', lineNumber, line);
                        continue; % Skip this line
                    end

                    fieldName = strtrim(line(1:eqPos(1)-1));
                    valueStr  = strtrim(line(eqPos(1)+1:end));

                    % Check if the field name is valid (i.e., defined in defaults)
                    if ~isfield(defaults, fieldName)
                        warning('loadLocalSettings:UnknownField', ...
                                'Skipping unknown setting "%s" on line %d.', fieldName, lineNumber);
                        continue;
                    end

                    % Convert value string based on the default type
                    try
                        defaultValue = defaults.(fieldName); % Get default to check type

                        if islogical(defaultValue)
                            % Handle boolean: true/false (case-insensitive)
                            if strcmpi(valueStr, 'true')
                                parsedValue = true;
                            elseif strcmpi(valueStr, 'false')
                                parsedValue = false;
                            else
                                warning('loadLocalSettings:InvalidBoolean', ...
                                        'Invalid boolean value "%s" for setting "%s" on line %d. Using default.', valueStr, fieldName, lineNumber);
                                continue; % Skip - keep default for this field
                            end
                        elseif isnumeric(defaultValue)
                            % Handle numeric
                            parsedValue = str2double(valueStr);
                            if isnan(parsedValue) || ~isscalar(parsedValue)
                                warning('loadLocalSettings:InvalidNumeric', ...
                                        'Invalid numeric value "%s" for setting "%s" on line %d. Using default.', valueStr, fieldName, lineNumber);
                                continue; % Skip - keep default
                            end

                            % Specific validation for useMouseSlider
                            if strcmp(fieldName, 'useMouseSlider') && ~ismember(parsedValue, [0, 1, 2])
                                warning('loadLocalSettings:InvalidMouseSliderValue', ...
                                        'Invalid value "%d" for useMouseSlider on line %d (must be 0, 1, or 2). Using default.', parsedValue, lineNumber);
                                continue; % Skip - keep default
                            end
                        else
                             warning('loadLocalSettings:UnsupportedType', ...
                                     'Settings type for "%s" (line %d) is not supported (must be logical or numeric). Using default.', fieldName, lineNumber);
                             continue; % Skip - keep default
                        end

                        % Assign the successfully parsed value
                        localsettings.(fieldName) = parsedValue;

                    catch ME_convert
                         warning('loadLocalSettings:ConversionError', ...
                                 'Error processing value "%s" for setting "%s" on line %d: %s. Using default.', valueStr, fieldName, lineNumber, ME_convert.message);
                         continue; % Skip - keep default
                    end % End try-catch for conversion

                end % End while loop (reading lines)
            end % End check if file opened successfully
        catch ME_read
            warning('loadLocalSettings:FileReadError', ...
                    'Error reading settings file %s: %s. Using default settings.', dpfilesettings, ME_read.message);
            localsettings = defaults; % Reset to defaults on major read error
        end

        % Ensure file is closed if it was opened
        if fid ~= -1
            fclose(fid);
        end

    else
        % File does not exist - use defaults and create a default file
        warning('loadLocalSettings:FileNotFound', ...
               'Settings file not found: %s. Using default settings.', dpfilesettings);

        try
            % Ensure directory exists
            if ~exist(settingsDir, 'dir')
                 disp(['Creating settings directory: ', settingsDir]);
                 mkdir(settingsDir);
            end

            % Write default file
            fid_write = fopen(dpfilesettings, 'wt');
            if fid_write ~= -1
               fprintf(fid_write, '%% Local Settings File - %s\n', datestr(now));
               fprintf(fid_write, '%% Edit the values below. Lines starting with %% or # are comments.\n');
               fprintf(fid_write, '%% Settings not found in this file will use internal defaults.\n\n');
               % Write defaults to the file
               fprintf(fid_write, '%s = %s\n', 'useAIM', mat2str(defaults.useAIM));
               fprintf(fid_write, '%s = %s\n', 'useFrame2TTL', mat2str(defaults.useFrame2TTL));
               fprintf(fid_write, '%s = %s\n', 'pulseWindow', mat2str(defaults.pulseWindow));
               fprintf(fid_write, '%s = %d\n', 'useMouseSlider', defaults.useMouseSlider); % Write numeric directly
               % Add other settings here if you have more defaults
               fclose(fid_write);
               disp(['Created default settings file with instructions: ', dpfilesettings]);
            else
               warning('loadLocalSettings:CantCreateDefault', ...
                       'Could not write default settings file to %s.', dpfilesettings);
            end
        catch ME_create
            warning('loadLocalSettings:CreateDefaultError', ...
                    'Error trying to create default settings file: %s', ME_create.message);
        end
        % Keep the defaults already assigned to localsettings
    end

    % 4. Calculate Dependent Settings (always do this last)
    % Ensure pulseWindow exists and is logical (should be, due to defaults)
    if ~isfield(localsettings, 'pulseWindow') || ~islogical(localsettings.pulseWindow)
        warning('loadLocalSettings:PulseWindowInvalid', 'PulseWindow setting is missing or invalid type after loading. Resetting to default (false).');
        localsettings.pulseWindow = defaults.pulseWindow; % Use default
    end

    if localsettings.pulseWindow
        winsize = 50;
    else
        winsize = 1;
    end
    localsettings.pulseWinWidth = winsize;

    disp('Finished loading settings.'); % Confirmation message
end