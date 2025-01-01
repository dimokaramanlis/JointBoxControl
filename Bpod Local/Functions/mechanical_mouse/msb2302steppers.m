classdef msb2302steppers
    properties
        serialObj;                   % Objet série pour la connexion
        i2cAdr = 0x59;
    end

    properties (Constant) % Use Constant for properties that don't change
        BOARD_TYPE_LIBRARY = 'STEPPER';
        VALID_FRAME_BYTE_COUNT = 36 ;   % This is the frame byte count from device include header[0x0D 0x0A, 0x23] and footer[0x23, 0x0D, 0x0A]

        %BOARD_TYPE_LIBRARY = 'FEEDER';
        %BOARD_TYPE_LIBRARY = 'WEIGHTMEAS';
        %BOARD_TYPE_LIBRARY = 'SERVO';
        %BOARD_TYPE_LIBRARY = 'NOSEPOKE';
        %BOARD_TYPE_LIBRARY = 'LICKPORT';
        %BOARD_TYPE_LIBRARY = 'CAMTRACKING';

        WRITE = 0x00;
        READ = 0x01;
    end

    methods

        % Constructeur avec handle de port série ou nom de port
        function obj = msb2302steppers(portNameOrHandle, baudRate, boardAddr)

             obj.i2cAdr = boardAddr;
            if nargin == 0
                error('Aucun argument fourni. Veuillez spécifier un port ou un handle.');
            elseif isprop(portNameOrHandle, 'BaudRate') && isprop(portNameOrHandle, 'Port')
             % Détecte un objet de type serialport
                obj.serialObj = portNameOrHandle;
                disp(sprintf('%s using GATEWAY serial communication handle', obj.BOARD_TYPE_LIBRARY));
            elseif ischar(portNameOrHandle) || isstring(portNameOrHandle)
                % Vérifie si le port est déjà ouvert
                if any(strcmp(serialportlist("all"), portNameOrHandle))
                    existingObj = instrfind("Port", portNameOrHandle); % Recherche d'objet existant
                    if ~isempty(existingObj) % Si un objet existe, le supprimer
                        delete(existingObj);
                    end
                end
                
                % Initialise le port série
                obj.serialObj = serialport(portNameOrHandle, baudRate);
                configureTerminator(obj.serialObj, "CR/LF"); % Configurer le terminateur
                disp(sprintf('%s using serial port %s with %d baud rate.', obj.BOARD_TYPE_LIBRARY,  portNameOrHandle, baudRate));                
                disp('Cleaning buffer, please wait ... ');
                pause(2); % Pause pour stabiliser la connexion
                
                % READ(CLEAR) INPUT SERIAL BUFFER AFTER STARTUP MESSAGE SEQUENCE
                dummyReceive = readSerialData(obj, 500, 1); % attend jusqu'à 1 secondes 
            else
                error(['Argument non valide pour le constructeur. Type reçu : ', class(portNameOrHandle)]);
            end
        end

        function isReady = isDeviceReady(obj)
            % Disable the verbose mode debug for get only the data frame
            disp('Send command for disable verbose mode (get data only)');
            reqRegistersSeq = [0x00, obj.i2cAdr, 0x04, 0x00];
            %reqRegistersSeq = [0x00, obj.BOARD_ADR, 0x04, 0x00];
            obj.writeSerialData(reqRegistersSeq); % Utilisation de la méthode définie ici

            % READ(CLEAR) INPUT SERIAL BUFFER AFTER STARTUP MESSAGE SEQUENCE
            dummyReceive = readSerialData(obj, 500, 1); % attend jusqu'à 1 secondes
            
            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registre du module
            disp(sprintf('Trying to detect board on address 0x%.2X...', obj.i2cAdr));
            reqRegistersSeq = [0x01, obj.i2cAdr];
            %reqRegistersSeq = [0x01, obj.BOARD_ADR];
            obj.writeSerialData(reqRegistersSeq); % Utilisation de la méthode définie ici

            % Lecture de la réponse
            rxFrame = obj.readSerialData(100, 1);

            [brdInfo, brdType] = obj.extractBoardInfos(rxFrame); % Appel à la méthode via l'instance

            if isempty(brdInfo) % Vérification si la chaîne est vide
                disp('#Bad frame format');
                isReady = false;
                return;
            else
                if ~strcmp(brdType, obj.BOARD_TYPE_LIBRARY)
                    disp(sprintf('[ERROR] Incompatible detected board [%s] with this library [%s]', brdType, obj.BOARD_TYPE_LIBRARY));
                    isReady = false;
                    return;
                else
                    disp(brdInfo);
                    isReady = true;
                end
            end
        end
    
        function error = setMotorAcceleration(obj, motorNb, rampUPvalue, rampDOWNvalue)
            xstep_ramp_reg = 0x16;
            rampValues = 0x00;       % Ramp down 0 (4bit MSB), Ramp up 6(4bit LSB) Max value = 13 for both

            switch motorNb
                case 0
                    xstep_ramp_reg = 0x16;  % Select motor A config register
                case 1
                    xstep_config_reg = 0x17;  % Select motor B config register
                otherwise
                   error = "[ERROR] setMotorAcceleration: Unknown motor number";
                   return;
            end

            rampValues = bitor(rampValues, uint8(rampUPvalue));
            rampValues = bitor(rampValues, bitshift(uint8(rampDOWNvalue), 4));

            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registre du module
            setRegistersSeq = [0x00, obj.i2cAdr, xstep_ramp_reg, rampValues];
            obj.writeSerialData(setRegistersSeq); % Utilisation de la méthode définie ici

            % Lecture de la réponse
            [isValid, registersData] = obj.getDeviceAck();
            
            if ~isValid
                disp('[ERROR] setMotorAcceleration: Invalid ack');
            end             
        end

        function error = setMotorTopFrequency(obj, motorNb, frequency)
            xstep_top_freq_reg = 0x12;
            topFreqLowVal = 0x00;       % Top frequency (8bit LSB)
            topFreqHighVal = 0x00;       % Top frequency (8bit MSB)

            switch motorNb
                case 0
                    xstep_top_freq_reg = 0x12;  % Select motor A top freq register low
                case 1
                    xstep_top_freq_reg = 0x14;  % Select motor B top freq register low
                otherwise
                   error = "[ERROR] setMotorTopFrequency: Unknown motor number";
                   return;
            end

            topFreqLowVal = bitand(uint16(frequency), uint16(0x00FF));      %
            topFreqHighVal = bitand(bitshift(uint16(frequency), -8), uint16(0x00FF));              % 8 bits de poids fort

            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registre du module
            setRegistersSeq = [0x00, obj.i2cAdr, xstep_top_freq_reg, topFreqLowVal, topFreqHighVal];
            obj.writeSerialData(setRegistersSeq); % Utilisation de la méthode définie ici

            % Lecture de la réponse
            [isValid, registersData] = obj.getDeviceAck();
            
            if ~isValid
                disp('[ERROR] setMotorTopFrequency: Invalid ack');
            end             
        end

        function error = setMotorConfig(obj, motorNb, AccelRampEnable, EndStopsEnable, CWbreakEnable, CCWbreakEnable)
            xstep_config_reg = 0x18;
            switch motorNb
                case 0
                    xstep_config_reg = 0x18;  % Select motor A config register
                case 1
                    xstep_config_reg = 0x19;  % Select motor B config register
                otherwise
                   error = "[ERROR] setMotorConfig: Unknown motor number";
                   return;
            end

            % Get the actual motors configuration from device
            devConfigValue = obj.getDeviceRegisterValue(xstep_config_reg);

            % Adjust acceleration ramp setting
            if AccelRampEnable == 1
                devConfigValue = bitor(devConfigValue, uint8(0x04));
            else
                devConfigValue = bitand(devConfigValue, bitcmp(0x04, 'uint8'));
            end

            % Adjust Endstops enable setting
            if EndStopsEnable == 1
                devConfigValue = bitor(devConfigValue, uint8(0x08));
            else
                devConfigValue = bitand(devConfigValue, bitcmp(0x08, 'uint8'));
            end

            % Adjust CW break enable setting
            if CWbreakEnable  == 1
                devConfigValue = bitor(devConfigValue, uint8(0x10));
            else
                devConfigValue = bitand(devConfigValue, bitcmp(0x10, 'uint8'));
            end

            % Adjust CCW break enable setting
            if CCWbreakEnable == 1
                devConfigValue = bitor(devConfigValue, uint8(0x20));
            else
                devConfigValue = bitand(devConfigValue, bitcmp(0x20, 'uint8'));
            end

            % Force rotation count mode
            %devConfigValue = bitor(devConfigValue, uint8(0x40));

            % Force step count mode
            devConfigValue = bitand(devConfigValue, bitcmp(0x40, 'uint8'));
            
            % New config reload request
            devConfigValue = bitor(devConfigValue, uint8(0x80));

            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registre du module
            setRegistersSeq = [0x00, obj.i2cAdr, xstep_config_reg, devConfigValue];
            obj.writeSerialData(setRegistersSeq); % Utilisation de la méthode définie ici

            % Lecture de la réponse
            [isValid, registersData] = obj.getDeviceAck();
            
            if ~isValid
                disp('[ERROR] setMotorConfig: Invalid ack');
            end            
        end

        function error = startMotorRotation(obj, motorNb, stepsDirection, speed)
            msg = sprintf('Starting motor rotation for %d steps with speed %d', stepsDirection, speed);
            disp(msg);

            regAdr=0x0C;    % Select motor A command register 0x0A(0x0B for motor B)
            regSteps=0x0E;  % Select motor A step registers 0x0E & 0x0F (0x10 & 0x11 for motor B)
            regSpeed=0x1A; % Select motor A speed register (0x1B for motor B)
            motCmd = 0x82;

            switch motorNb
                case 0
                    regAdr = 0x0C;  % Select motor A command register
                    regSteps = 0x0E;  % Select motor A step registers (0x0E & 0x0F)
                    regSpeed = 0x1A;  % Select motor A speed register (0x1A)
                case 1
                    regAdr = 0x0D;  % Select motor B command register
                    regSteps = 0x10;  % Select motor B step registers (0x10 & 0x11)
                    regSpeed = 0x1B;  % Select motor B speed register (0x1B)
                otherwise
                   error = "[ERROR] startMotorRotation: Unknown motor number";
            end
            

            % Set motor number of steps to do
            if stepsDirection < 0
                stepsDirection = stepsDirection * -1;
                motCmd = 0x82;
            else
                motCmd = 0x83;
            end
            
            % Supposons que stepsDirection est un entier 16 bits
            stepsDirL = bitand(stepsDirection, 255);       % Octet de poids faible (8 bits inférieurs)
            stepsDirH = bitshift(stepsDirection, -8);      % Octet de poids fort (8 bits supérieurs)

            dataFrame = [obj.WRITE, obj.i2cAdr, regSteps, stepsDirL, stepsDirH];            
            %dataFrame = [obj.WRITE, obj.BOARD_ADR, regSteps, stepsDirection];            
            obj.writeSerialData(dataFrame);
            [isValid, registersData] = obj.getDeviceAck();
            
            if isValid
                % Set motor speed in %
                if speed < 0
                    speed = speed * -1;
                end                
                dataFrame = [obj.WRITE, obj.i2cAdr, regSpeed, speed];            
                %dataFrame = [obj.WRITE, obj.BOARD_ADR, regSpeed, speed];            
                obj.writeSerialData(dataFrame);
                [isValid, registersData] = obj.getDeviceAck();

                if isValid
                    % Start motor rotation
                    dataFrame = [obj.WRITE, obj.i2cAdr, regAdr, motCmd];            
                    %dataFrame = [obj.WRITE, obj.BOARD_ADR, regAdr, motCmd];            
                    obj.writeSerialData(dataFrame);
                    [isValid, registersData] = obj.getDeviceAck();
                    if ~isValid
                        error = '[ERROR] startMotorRotation(Start motor); Unexpected frame received';
                        disp('[ERROR] startMotorRotation(Start motor): Unexpected frame received');
                    end
                else
                    error = '[ERROR] startMotorRotation(Set motor speed); Unexpected frame received';
                    disp('[ERROR] startMotorRotation(Set motor speed): Unexpected frame received');                    
                end
            else
                error = '[ERROR] startMotorRotation(Set motor steps); Unexpected frame received';
                disp('[ERROR] startMotorRotation(Set motor steps): Unexpected frame received');
            end
        end

        function error = stopMotorRotation(obj, motorNb)
            switch motorNb
                case 0
                    reg_xstep_command = 0x0C;  % Select motor A ASTEP_ACTUAL_VALUE_LOW register
                case 1
                    reg_xstep_command = 0x0D;  % Select motor B BSTEP_ACTUAL_VALUE_LOW register
                otherwise
                   error = "[ERROR] stopMotorRotation: Unknown motor number";
            end

            dataFrame = [obj.WRITE, obj.i2cAdr, reg_xstep_command, 0x81];
            %dataFrame = [obj.WRITE, obj.BOARD_ADR, 0x0C, 0x81];
            obj.writeSerialData(dataFrame);
            [isValid, registersData] = obj.getDeviceAck();
            
            if ~isValid
                error = '[ERROR] stopMotorRotation: Unexpected frame received';
                disp('[ERROR] stopMotorRotation: Unexpected frame received');
            end

        end        

        function isRunning = isMotorRunning(obj, motorNb)
            reg_xstep_actual_value_low = 0x07;

            switch motorNb
                case 0
                    reg_xstep_actual_value_low = 0x07;  % Select motor A ASTEP_ACTUAL_VALUE_LOW register
                case 1
                    reg_xstep_actual_value_low = 0x09;  % Select motor B BSTEP_ACTUAL_VALUE_LOW register
                otherwise
                   disp('[ERROR] isMotorRunning: Unknown motor number');
            end
            
            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registre du module

            actual_value_low = obj.getDeviceRegisterValue(reg_xstep_actual_value_low);

            if bitand(actual_value_low, 0x80) > 0
                isRunning = true;
            else
                isRunning = false;
            end
        end

        function [P0, P1] = isEndStopsActive(obj, motorNb)
            P0 = false;
            P1 = false;
            reg_status = 0x07;
            
            switch motorNb
                case 0
                    reg_status = 0x07;  % Select motor A ASTEP_ACTUAL_VALUE_LOW register
                case 1
                    reg_status = 0x09;  % Select motor B BSTEP_ACTUAL_VALUE_LOW register
                otherwise
                   disp('[ERROR] isMotorRunning: Unknown motor number');
            end

            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registre du module

            estopStatus = obj.getDeviceRegisterValue(reg_status);
            
            % Endstops are active on low level
            if bitand(estopStatus, 0x01) == 0
                P0 = true;
            end

            if bitand(estopStatus, 0x02) == 0
                P1 = true;
            end            

           % if bitand(statusReg, 0x80) > 0
           %     isRunning = true;
           %     disp('DEBUG: RUN');
           % else
           %     isRunning = false;
           %     disp('DEBUG: NOT RUN');
           % end
        end        

        % Méthode pour fermer la connexion série proprement
        function close(obj)
            if ~isempty(obj.serialObj) && isvalid(obj.serialObj)
                disp('Closing serial connection...');
                delete(obj.serialObj); % Supprime l'objet série
                clear obj.serialObj; % Libère la variable de la mémoire
                disp('Serial connection closed.');
            else
                disp('Serial port was already closed or invalid.');
            end
        end
    end


    methods (Access = private)
        % Méthode pour écrire des données sur le port série
        function writeSerialData(obj, data)
            % Vérifiez si le tableau de données est vide
            if isempty(data)
                error('Aucune donnée à écrire sur le port série.');
            end
            
            % Écrire les données sur le port série
            write(obj.serialObj, data, "uint8");
            %disp(['Données écrites: ', sprintf('%02X ', data)]);
        end

        function data = readSerialData(obj, numBytesToRead, timeout)
            if nargin < 3
                timeout = 5; % Timeout par défaut de 5 secondes si non spécifié
            end
        
            data = uint8([]); % Initialiser comme un tableau vide de type uint8
            startTime = tic; % Début du timer
        
            % Boucle jusqu'à ce que le timeout soit atteint ou que le nombre d'octets requis soit lu
            while toc(startTime) < timeout && length(data) < numBytesToRead
                if obj.serialObj.NumBytesAvailable > 0
                    % Lecture des données disponibles dans le buffer
                    newData = read(obj.serialObj, obj.serialObj.NumBytesAvailable, "uint8");
                    data = [data; newData]; % Accumule les données
                    %disp(['#Data received: ', sprintf('%02X ', newData)]);
                else
                    % Si aucune donnée n'est disponible, faire une petite pause
                    pause(0.01);
                end
            end
        
            % Afficher un message si le nombre d'octets requis n'a pas été lu
            if length(data) < numBytesToRead
                disp('#Read timeout: Not all data received within the specified time.');
            end
        
            % Retourne les données accumulées
            data;
        end

        function value = getDeviceRegisterValue(obj, regAdr)
            value = -1;
            
            % Envoi d'une requête de lecture pour obtenir la valeur des
            % registres du module
            reqRegistersSeq = [0x01, obj.i2cAdr];
            obj.writeSerialData(reqRegistersSeq); % Utilisation de la méthode définie ici

            % Lecture de la réponse des registres et validité de de la
            % trame
            [isValid, registersData] = obj.getDeviceAck();

            if isValid
                value = uint8(registersData(regAdr +1));
            else
                disp('[ERROR] getDeviceRegisterValue: Invalid frame response');
            end
        end

        % Retourne la trame avec données (sans header et footer) si
        % reconnue comme étant valide (header et footer présents)
        function [isValid, registersData] = getDeviceAck(obj)
            % Initialiser les variables de retour
            isValid = false;    % Par défaut, on considère que la trame n'est pas valide
            registersData = []; % Tableau vide par défaut pour les valeurs des registres

            % Lecture de la réponse
            rxFrame = obj.readSerialData(obj.VALID_FRAME_BYTE_COUNT, 1);
    
            % Vérification de la longueur du tableau
            if length(rxFrame) < 10 % Au moins 10 octets (3 pour l'en-tête, 4 pour les données, et 3 pour la fin)
                disp('Le tableau doit contenir au moins 10 octets.');
                return; % Sortir de la fonction si le tableau est trop court
            end
            
            % Vérification de l'en-tête
            header = rxFrame(1:3);
            expectedHeader = [0x0D, 0x0A, 0x23]; % En-tête attendu en hexadécimal
        
            if isequal(header, expectedHeader)
                % Vérification de la chaîne de fin
                endFrame = rxFrame(end-2:end); % Les 3 derniers octets
                expectedEndFrame = [0x23, 0x0D, 0x0A]; % Chaîne de fin attendue
        
                if isequal(endFrame, expectedEndFrame)
                    % Si l'en-tête et la chaîne de fin sont valides, on marque comme valide
                    isValid = true;
        
                    % Extraction des registres (les octets entre l'en-tête et la fin)
                    % Ici, nous prenons tous les octets entre les indices 4 et length(hexArray)-3
                    registersData = rxFrame(4:end-3); % Extraire les données sans l'en-tête et la fin
                else
                    disp('Invalid end of frame');
                end
            else
                disp('Invalid frame header');
            end
        end

        function [boardInfo, boardTypeStr] = extractBoardInfos(obj, hexArray) 
            % Initialiser la variable de retour
            boardInfo = ''; % Chaîne vide par défaut
            boardTypeStr = '';

            % Vérification de la longueur du tableau
            if length(hexArray) < 10 % Au moins 10 octets (3 pour l'en-tête, 4 pour les données, et 3 pour la fin)
                disp('Le tableau doit contenir au moins 10 octets.');
                return; % Sortir de la fonction si le tableau est trop court
            end
            
            % Vérification de l'en-tête
            header = hexArray(1:3);
            expectedHeader = [0x0D, 0x0A, 0x23]; % En-tête attendu en hexadécimal
        
            if isequal(header, expectedHeader)
                % Extraction des 4 octets suivants
                boardType = bitand(hexArray(5), 0x0F);      % Ne garder que les 3 bits de poids faible (octet 2)
                i2cAddress = hexArray(4);                   % octet 1
                firmwareVersion = double(hexArray(6))/10;   % octet 3
                appVersion = hexArray(7);                    % octet 4
                
                % Vérification de la chaîne de fin
                endFrame = hexArray(end-2:end); % Les 3 derniers octets
                expectedEndFrame = [0x23, 0x0D, 0x0A]; % Chaîne de fin attendue
        
                if isequal(endFrame, expectedEndFrame)

                    % Déterminer le type de carte en fonction de la valeur de boardType
                    switch boardType
                        case 0x00
                            boardTypeStr = 'GATEWAY';
                        case 0x01
                            boardTypeStr = 'FEEDER';
                        case 0x02
                            boardTypeStr = 'WEIGHTMEAS';
                        case 0x03
                            boardTypeStr = 'SERVO';
                        case 0x04
                            boardTypeStr = 'NOSEPOKE';
                        case 0x05
                            boardTypeStr = 'LICKPORT';
                        case 0x06
                            boardTypeStr = 'CAMTRACKING';
                        case 0x08
                            boardTypeStr = 'STEPPER';
                        otherwise
                            boardTypeStr = 'UNKNOWN'; % Pour toute valeur non reconnue
                    end
                    
                    % Construction de la chaîne de résultat
                    boardInfo = sprintf('Board type=%s, I2C address=0x%02X, firmware=%.1f Application version=%d',...
                        boardTypeStr, i2cAddress, firmwareVersion, appVersion);  
                else
                    disp('Chaîne de fin invalide.');
                end
            else
                disp('En-tête invalide.');
            end
        end
        
    end
end
