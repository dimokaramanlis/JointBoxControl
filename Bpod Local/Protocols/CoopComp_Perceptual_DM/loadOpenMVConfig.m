function localOpenMVConfig = loadOpenMVConfig(useStartingLine)

% 2. Define File Path
configDir = 'E:\';
if useStartingLine
    configFile = 'configStartingLine.txt'; % New filename
else
    configFile = 'config.txt';
end
configfilesettings = fullfile(configDir, configFile);

localOpenMVConfig = struct();

% 3. Check if file exists and process it
if exist(configfilesettings, 'file')
    fid = -1; % Initialize file identifier
    try
        fid = fopen(configfilesettings, 'rt'); % Open for text reading
        if fid == -1
            warning('loadconfig:FileOpenError', ...
                'Could not open config file.');
        else
            disp(['Loading OpenMV config from: ', configfilesettings]);
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
%                     warning('loadLocalSettings:ParseError', ...
%                         'Skipping line %d (no "=" found): %s', lineNumber, line);
                    continue; % Skip this line
                end
                
                fieldName = strtrim(line(1:eqPos(1)-1));
                valueStr  = strtrim(line(eqPos(1)+1:end));
                localOpenMVConfig.(fieldName) = valueStr;
            end
            
            data_fieldnames = fieldnames(localOpenMVConfig);
            for iField = 1:numel(fields(localOpenMVConfig))
                this_field = string(localOpenMVConfig.(data_fieldnames{iField}));
                this_field=erase(this_field,')');
                localOpenMVConfig.(data_fieldnames{iField})=erase(this_field,'(');
                if strcmpi(this_field,'true')
                    localOpenMVConfig.(data_fieldnames{iField})=true;
                elseif strcmpi(this_field,'false')
                    localOpenMVConfig.(data_fieldnames{iField})=false;
                end
            end   

        end % End check if file opened successfully
    catch 
        warning('loadLocalSettings:FileReadError', ...
            'Error reading config file.');
    end
    
    % Ensure file is closed if it was opened
    if fid ~= -1
        fclose(fid);
    end
else
    localOpenMVConfig = NaN;
end
