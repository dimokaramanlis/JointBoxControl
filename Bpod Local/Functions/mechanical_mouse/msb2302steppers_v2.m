% msb2302steppers_v2 - Refactored driver for MSB2302 Stepper Motor Controller
%
% This class provides an interface to control a stepper motor board
% communicating via a serial gateway (like CP210x USB-to-UART) using a
% specific serial protocol wrapping I2C-like commands.
%
% Incorporates improvements for speed and robustness based on best practices.
% Assumes MATLAB R2019b or later for 'arguments' block syntax.

classdef msb2302steppers_v2
    properties (SetAccess = private)
        serialObj;                  % Serial port object handle
    end
    properties (SetAccess = immutable)
       i2cAdr (1,1) uint8;         % I2C address of the target board
       defaultTimeout (1,1) double = 1.0; % Default serial read timeout in seconds
    end
    properties (Constant)
        BOARD_TYPE_LIBRARY = 'STEPPER'; % Expected board type for validation

        % --- Protocol Constants ---
        WRITE = 0x00;               % Protocol command code for writing registers
        READ = 0x01;                % Protocol command code for reading all registers

        % Expected Frame Structure (Device -> Host after a READ command)
        FRAME_HEADER = [0x0D, 0x0A, 0x23]; % Expected start bytes of a valid frame
        FRAME_FOOTER = [0x23, 0x0D, 0x0A]; % Expected end bytes of a valid frame
        FRAME_HEADER_LEN = 3;
        FRAME_FOOTER_LEN = 3;
        % IMPORTANT: This assumes the device *always* returns a fixed number
        % of bytes for a read acknowledgement frame. Verify with device spec.
        % Example: If device has 30 registers = 3 header + 30 data + 3 footer = 36 bytes
        VALID_FRAME_BYTE_COUNT = 36 ; % Total bytes expected in a valid data frame

        % --- Register Addresses (Example - Verify with device documentation!) ---
        REG_STATUS_A = 0x07; % Motor A Status / EndStop Info / Actual Value Low
        REG_STATUS_B = 0x09; % Motor B Status / EndStop Info / Actual Value Low
        REG_CMD_A = 0x0C;    % Motor A Command Register
        REG_CMD_B = 0x0D;    % Motor B Command Register
        REG_STEPS_A_LOW = 0x0E; % Motor A Steps Low Byte
        REG_STEPS_A_HIGH = 0x0F;% Motor A Steps High Byte
        REG_STEPS_B_LOW = 0x10; % Motor B Steps Low Byte
        REG_STEPS_B_HIGH = 0x11;% Motor B Steps High Byte
        REG_TOP_FREQ_A_LOW = 0x12; % Motor A Top Frequency Low
        REG_TOP_FREQ_A_HIGH = 0x13;% Motor A Top Frequency High
        REG_TOP_FREQ_B_LOW = 0x14; % Motor B Top Frequency Low
        REG_TOP_FREQ_B_HIGH = 0x15;% Motor B Top Frequency High
        REG_RAMP_A = 0x16;      % Motor A Ramp Up/Down Settings
        REG_RAMP_B = 0x17;      % Motor B Ramp Up/Down Settings
        REG_CONFIG_A = 0x18;    % Motor A Configuration Register
        REG_CONFIG_B = 0x19;    % Motor B Configuration Register
        REG_SPEED_A = 0x1A;     % Motor A Speed Register (%)
        REG_SPEED_B = 0x1B;     % Motor B Speed Register (%)
        REG_BOARD_INFO_I2C_ADR = 0; % Index within returned data frame for I2C Addr
        REG_BOARD_INFO_TYPE = 1;    % Index within returned data frame for Board Type/Flags
        REG_BOARD_INFO_FW_VER = 2;  % Index within returned data frame for Firmware Ver
        REG_BOARD_INFO_APP_VER = 3; % Index within returned data frame for App Ver

        % --- Command Bytes (Example - Verify!) ---
        CMD_MOTOR_STOP_ABRUPT = 0x81;
        CMD_MOTOR_START_CCW = 0x82; % Counter-Clockwise / Negative direction
        CMD_MOTOR_START_CW = 0x83;  % Clockwise / Positive direction
        CMD_CONFIG_RELOAD_BIT = 0x80; % Bit to set in config register to apply changes
    end

    methods
        % Constructor
        function obj = msb2302steppers_v2(portNameOrHandle, baudRate, boardAddr, options)
            % msb2302steppers_v2 Constructor for the stepper motor driver object.
            %
            % Syntax:
            %   obj = msb2302steppers_v2(port, baudRate, boardAddr)
            %   obj = msb2302steppers_v2(serialHandle, baudRate, boardAddr)
            %   obj = msb2302steppers_v2(..., Name=Value)
            %
            % Inputs:
            %   portNameOrHandle: String/char with serial port name (e.g., "COM3", "/dev/ttyUSB0")
            %                     OR an existing serialport object handle.
            %   baudRate:         Numeric baud rate (e.g., 115200, 921600). Use the highest
            %                     rate reliably supported by the device.
            %   boardAddr:        Numeric I2C address (0-127) of the target stepper board.
            %
            % Name-Value Pairs:
            %   DefaultTimeout:   Serial read timeout in seconds (default: 1.0).

            arguments
                portNameOrHandle
                baudRate (1,1) {mustBeNumeric, mustBePositive, mustBeInteger}
                boardAddr (1,1) {mustBeNumeric, mustBeInteger, mustBeInRange(boardAddr, 0, 127)}
                options.DefaultTimeout (1,1) double {mustBePositive} = 1.0 % Optional timeout override
            end

            obj.i2cAdr = uint8(boardAddr);
            obj.defaultTimeout = options.DefaultTimeout;

            try
                if isa(portNameOrHandle, 'matlab.io.SerialPort') % Check if it's a serialport object
                    obj.serialObj = portNameOrHandle;
                    fprintf('%s using existing GATEWAY serial communication handle on port %s\n', obj.BOARD_TYPE_LIBRARY, obj.serialObj.Port);
                elseif ischar(portNameOrHandle) || isstring(portNameOrHandle)
                    portName = char(portNameOrHandle);
                    % Check if port is already open by another MATLAB serialport object
                    existingPorts = serialportlist("available");
                    connectedObj = instrfind('Port', portName, 'Status', 'open'); % Check if *this* port is open
                     if ~isempty(connectedObj)
                        disp(['Warning: Serial port ' portName ' was already open. Closing it.']);
                        delete(connectedObj);
                        pause(0.5); % Brief pause after deleting
                    end

                    fprintf('%s: Initializing serial port %s at %d baud...\n', obj.BOARD_TYPE_LIBRARY, portName, baudRate);
                    obj.serialObj = serialport(portName, baudRate);
                    % Configure basic settings
                    configureTerminator(obj.serialObj, "CR/LF"); % Set based on device requirement, CR/LF is common
                    obj.serialObj.Timeout = obj.defaultTimeout; % Set the default read timeout
                    obj.serialObj.FlowControl = 'none'; % Explicitly set, change if device requires hardware/software flow control

                    fprintf('Serial port configured. Clearing buffer...\n');
                    flush(obj.serialObj); % Discard data in input/output buffers
                    % Optional: Short pause and read to clear potential startup messages from device
                    pause(0.2);
                    if obj.serialObj.NumBytesAvailable > 0
                       read(obj.serialObj, obj.serialObj.NumBytesAvailable, "uint8");
                       disp('Cleared initial data from serial buffer.');
                    end
                     fprintf('Setup complete for board address 0x%02X.\n', obj.i2cAdr);
                else
                    error('msb2302steppers_v2:InvalidInput', 'First argument must be a serial port name (string/char) or a serialport object handle.');
                end
            catch ME
                 error('msb2302steppers_v2:SerialSetupFailed', 'Failed to setup serial port %s: %s', char(portNameOrHandle), ME.message);
            end
        end

        % Check if the configured device is connected and responsive
        function [isReady, boardInfo] = isDeviceReady(obj)
            % isDeviceReady Checks communication with the device and verifies its type.
            %
            % Outputs:
            %   isReady:   logical true if the correct board type is detected and responding.
            %   boardInfo: string containing details of the detected board if successful.

            isReady = false; % Default state
            boardInfo = '';

            % --- Optional: Disable Verbose Mode ---
            % Uncomment if your device has a verbose mode that needs disabling for clean data frames
            % disp('Sending command to disable verbose mode (if applicable)...');
            % reqRegistersSeq = [obj.WRITE, obj.i2cAdr, 0x04, 0x00]; % Example register write
            % [writeSuccess] = obj.writeSerialData(reqRegistersSeq);
            % if writeSuccess
            %     pause(0.1); % Allow time for command processing
            %     % Clear any response from the verbose command
            %     if obj.serialObj.NumBytesAvailable > 0
            %        read(obj.serialObj, obj.serialObj.NumBytesAvailable, "uint8");
            %     end
            % else
            %     warning('msb2302steppers_v2:VerboseCmdFail', 'Failed to send disable verbose command.');
            %     % Decide whether to proceed or return
            % end
            % --- End Optional Verbose Disable ---

            fprintf('Trying to detect board at address 0x%02X...\n', obj.i2cAdr);
            reqRegistersSeq = [obj.READ, obj.i2cAdr]; % Command to read all registers

            [writeSuccess] = obj.writeSerialData(reqRegistersSeq);
            if ~writeSuccess
                warning('msb2302steppers_v2:ReadCmdFail', 'Failed to send read command during readiness check.');
                return;
            end

            pause(0.1); % Small pause to allow any previous messages to arrive fully
            if obj.serialObj.NumBytesAvailable > 0
                junk = read(obj.serialObj, obj.serialObj.NumBytesAvailable, "uint8");
                disp(['Cleared unexpected data before ACK read: ', sprintf('%02X ', junk)]);
            end
            pause(0.1); % Another small pause before trying to read the actual ACK

            % Read the expected frame using getDeviceAck (handles timeout and basic validation)
            [ackValid, registersData] = obj.getDeviceAck();

            if ~ackValid
                warning('msb2302steppers_v2:NoAck', 'No valid acknowledgement frame received during readiness check.');
                return; % Failed to get a valid response
            end

            % Parse the received data
            [parseSuccess, boardInfo, brdType] = obj.extractBoardInfos(registersData);

            if ~parseSuccess
                warning('msb2302steppers_v2:ParseFail', 'Failed to parse board information from received frame.');
                return; % Frame received but couldn't be parsed
            end

            % Validate board type
            if ~strcmp(brdType, obj.BOARD_TYPE_LIBRARY)
                warning('msb2302steppers_v2:WrongBoardType', 'Detected board type [%s] is incompatible with this library [%s].', brdType, obj.BOARD_TYPE_LIBRARY);
                return; % Wrong type of board detected
            end

            % If we got here, everything checks out
            fprintf('Device ready: %s\n', boardInfo);
            isReady = true;
        end

        % Set motor acceleration and deceleration ramps
        function setMotorAcceleration(obj, motorNb, rampUPvalue, rampDOWNvalue)
            % setMotorAcceleration Sets the acceleration/deceleration ramp values.
            % Max value for each ramp is typically 13 (check device spec).
            arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
                rampUPvalue (1,1) {mustBeNumeric, mustBeInteger, mustBeInRange(rampUPvalue, 0, 15)} % Allow 0-15 for 4 bits
                rampDOWNvalue (1,1) {mustBeNumeric, mustBeInteger, mustBeInRange(rampDOWNvalue, 0, 15)} % Allow 0-15 for 4 bits
            end

            if motorNb == 0
                rampReg = obj.REG_RAMP_A;
            else % motorNb == 1
                rampReg = obj.REG_RAMP_B;
            end

            % Combine ramp values: RampDown (4 MSB), RampUp (4 LSB)
            rampValues = bitor( uint8(rampUPvalue), bitshift(uint8(rampDOWNvalue), 4) );

            setRegistersSeq = [obj.WRITE, obj.i2cAdr, rampReg, rampValues];
            [writeSuccess] = obj.writeSerialData(setRegistersSeq);
            if ~writeSuccess
                 error('msb2302steppers_v2:WriteError', 'Failed to send setMotorAcceleration command for motor %d.', motorNb);
            end

            % Check Acknowledgement (Optional but recommended)
            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                 warning('msb2302steppers_v2:AckError', 'No valid ACK received after setMotorAcceleration for motor %d.', motorNb);
            end
        end

        % Set motor top frequency (related to max speed)
        function setMotorTopFrequency(obj, motorNb, frequency)
            % setMotorTopFrequency Sets the motor's top frequency (16-bit value).
            arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
                frequency (1,1) {mustBeNumeric, mustBeInteger, mustBeInRange(frequency, 0, 65535)} % 16-bit value
            end

            if motorNb == 0
                topFreqRegLow = obj.REG_TOP_FREQ_A_LOW;
                topFreqRegHigh = obj.REG_TOP_FREQ_A_HIGH; % Assumes High reg follows Low reg
            else % motorNb == 1
                topFreqRegLow = obj.REG_TOP_FREQ_B_LOW;
                topFreqRegHigh = obj.REG_TOP_FREQ_B_HIGH; % Assumes High reg follows Low reg
            end

            freqU16 = uint16(frequency);
            topFreqLowVal = uint8(bitand(freqU16, uint16(0x00FF)));          % LSB
            topFreqHighVal = uint8(bitand(bitshift(freqU16, -8), uint16(0x00FF))); % MSB

            % Assumes device allows writing multiple consecutive registers
            setRegistersSeq = [obj.WRITE, obj.i2cAdr, topFreqRegLow, topFreqLowVal, topFreqHighVal];
            [writeSuccess] = obj.writeSerialData(setRegistersSeq);
             if ~writeSuccess
                 error('msb2302steppers_v2:WriteError', 'Failed to send setMotorTopFrequency command for motor %d.', motorNb);
            end

            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                 warning('msb2302steppers_v2:AckError', 'No valid ACK received after setMotorTopFrequency for motor %d.', motorNb);
            end
        end

        % Configure motor behavior (ramps, endstops, braking)
        function setMotorConfig(obj, motorNb, AccelRampEnable, EndStopsEnable, CWbreakEnable, CCWbreakEnable)
            % setMotorConfig Configures various motor operational parameters.
            % Note: Reads current config, modifies, then writes back.
             arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
                AccelRampEnable (1,1) logical
                EndStopsEnable (1,1) logical
                CWbreakEnable (1,1) logical  % Clockwise / Positive direction braking
                CCWbreakEnable (1,1) logical % Counter-Clockwise / Negative direction braking
            end

            if motorNb == 0
                configReg = obj.REG_CONFIG_A;
            else % motorNb == 1
                configReg = obj.REG_CONFIG_B;
            end

            % Get the actual motor configuration from the device first for safety
            try
                currentConfigVal = obj.getDeviceRegisterValue(configReg);
            catch ME
                error('msb2302steppers_v2:ReadConfigError', 'Failed to read current config for motor %d before setting new config: %s', motorNb, ME.message);
            end

            newConfigValue = uint8(currentConfigVal); % Start with current value

            % --- Modify bits based on inputs (Verify bit positions with device spec!) ---
            % Bit 2: Acceleration Ramp Enable (0x04)
            if AccelRampEnable
                newConfigValue = bitor(newConfigValue, uint8(0x04));
            else
                newConfigValue = bitand(newConfigValue, bitcmp(uint8(0x04)));
            end
            % Bit 3: Endstops Enable (0x08)
            if EndStopsEnable
                newConfigValue = bitor(newConfigValue, uint8(0x08));
            else
                newConfigValue = bitand(newConfigValue, bitcmp(uint8(0x08)));
            end
             % Bit 4: CW/Positive Break Enable (0x10)
            if CWbreakEnable
                newConfigValue = bitor(newConfigValue, uint8(0x10));
            else
                newConfigValue = bitand(newConfigValue, bitcmp(uint8(0x10)));
            end
             % Bit 5: CCW/Negative Break Enable (0x20)
            if CCWbreakEnable
                newConfigValue = bitor(newConfigValue, uint8(0x20));
            else
                newConfigValue = bitand(newConfigValue, bitcmp(uint8(0x20)));
            end
             % Bit 6: Mode (0=Step Count, 1=Rotation Count) - Force Step Count (0x40)
            newConfigValue = bitand(newConfigValue, bitcmp(uint8(0x40))); % Force Step count mode

            % Bit 7: Config Reload Request (0x80) - Set this bit to apply changes
            newConfigValue = bitor(newConfigValue, obj.CMD_CONFIG_RELOAD_BIT);
            % -------------------------------------------------------------------------

            % Send the new configuration value
            setRegistersSeq = [obj.WRITE, obj.i2cAdr, configReg, newConfigValue];
            [writeSuccess] = obj.writeSerialData(setRegistersSeq);
             if ~writeSuccess
                 error('msb2302steppers_v2:WriteError', 'Failed to send setMotorConfig command for motor %d.', motorNb);
            end

            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                 warning('msb2302steppers_v2:AckError', 'No valid ACK received after setMotorConfig for motor %d.', motorNb);
            end
        end

        % Start motor rotation for a specific number of steps
        function startMotorRotation(obj, motorNb, steps, speedPercent, options)
            % startMotorRotation Commands the motor to rotate a specific number of steps.
            %
            % Inputs:
            %   motorNb:      0 or 1.
            %   steps:        Number of steps. Positive for CW/Default, Negative for CCW.
            %   speedPercent: Speed as percentage (0-100).
            % Name-Value Pairs:
            %   Verbose:      logical true (default) to print status message, false to suppress.
            arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
                steps (1,1) {mustBeNumeric, mustBeInteger} % Can be negative
                speedPercent (1,1) {mustBeNumeric, mustBeInRange(speedPercent, 0, 100)}
                options.Verbose (1,1) logical = true
            end

            if options.Verbose
                fprintf('Motor %d: Starting rotation for %d steps at %d%% speed.\n', motorNb, steps, speedPercent);
            end

            % Determine direction and command byte
            numSteps = abs(steps);
            if steps < 0
                motCmd = obj.CMD_MOTOR_START_CCW; % Negative steps -> CCW
            else
                motCmd = obj.CMD_MOTOR_START_CW;  % Positive or zero steps -> CW
            end

             % Clamp steps to 16-bit unsigned range
            if numSteps > 65535
                warning('msb2302steppers_v2:StepsOutOfRange', 'Number of steps (%d) exceeds 16-bit limit (65535). Clamping.', numSteps);
                numSteps = 65535;
            end
            stepsU16 = uint16(numSteps);

            % Get register addresses based on motor number
            if motorNb == 0
                regStepsLow = obj.REG_STEPS_A_LOW;
                regStepsHigh = obj.REG_STEPS_A_HIGH;
                regSpeed = obj.REG_SPEED_A;
                regCmd = obj.REG_CMD_A;
            else % motorNb == 1
                regStepsLow = obj.REG_STEPS_B_LOW;
                regStepsHigh = obj.REG_STEPS_B_HIGH;
                regSpeed = obj.REG_SPEED_B;
                regCmd = obj.REG_CMD_B;
            end

            % 1. Set Motor Steps (16-bit value)
            stepsL = uint8(bitand(stepsU16, uint16(0x00FF)));
            stepsH = uint8(bitand(bitshift(stepsU16, -8), uint16(0x00FF)));
            setStepsSeq = [obj.WRITE, obj.i2cAdr, regStepsLow, stepsL, stepsH]; % Assumes writing consecutive registers works

            [writeSuccess] = obj.writeSerialData(setStepsSeq);
            if ~writeSuccess
                error('msb2302steppers_v2:WriteError', 'Failed to send step count command for motor %d.', motorNb);
            end
            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                warning('msb2302steppers_v2:AckError', 'No valid ACK received after setting steps for motor %d.', motorNb);
                % Decide if we should stop here or try to continue
                % return; % Option: Stop if ACK fails
            end

            % 2. Set Motor Speed
            speedVal = uint8(speedPercent);
            setSpeedSeq = [obj.WRITE, obj.i2cAdr, regSpeed, speedVal];

            [writeSuccess] = obj.writeSerialData(setSpeedSeq);
             if ~writeSuccess
                error('msb2302steppers_v2:WriteError', 'Failed to send speed command for motor %d.', motorNb);
            end
            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                warning('msb2302steppers_v2:AckError', 'No valid ACK received after setting speed for motor %d.', motorNb);
                % return; % Option: Stop if ACK fails
            end

            % 3. Start Motor Rotation
            startCmdSeq = [obj.WRITE, obj.i2cAdr, regCmd, motCmd];
            [writeSuccess] = obj.writeSerialData(startCmdSeq);
             if ~writeSuccess
                error('msb2302steppers_v2:WriteError', 'Failed to send start rotation command for motor %d.', motorNb);
            end
            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                warning('msb2302steppers_v2:AckError', 'No valid ACK received after sending start command for motor %d.', motorNb);
            end

             if options.Verbose && ackValid % Only confirm if final ACK was okay (or adjust logic)
                fprintf('Motor %d: Start command sent.\n', motorNb);
            elseif options.Verbose && ~ackValid
                 fprintf('Motor %d: Start command sent, but final ACK was missing/invalid.\n', motorNb);
            end
        end

        % Stop motor rotation abruptly
        function stopMotorRotation(obj, motorNb)
            % stopMotorRotation Sends an abrupt stop command to the motor.
            arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
            end

            if motorNb == 0
                regCmd = obj.REG_CMD_A;
            else % motorNb == 1
                regCmd = obj.REG_CMD_B;
            end

            stopCmdSeq = [obj.WRITE, obj.i2cAdr, regCmd, obj.CMD_MOTOR_STOP_ABRUPT];
            [writeSuccess] = obj.writeSerialData(stopCmdSeq);
             if ~writeSuccess
                error('msb2302steppers_v2:WriteError', 'Failed to send stop command for motor %d.', motorNb);
            end

            [ackValid, ~] = obj.getDeviceAck();
            if ~ackValid
                warning('msb2302steppers_v2:AckError', 'No valid ACK received after sending stop command for motor %d.', motorNb);
            end
        end

        % Check if a motor is currently running
        function isRunning = isMotorRunning(obj, motorNb)
            % isMotorRunning Checks the status register to see if the motor is active.
             arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
            end

            if motorNb == 0
                statusReg = obj.REG_STATUS_A;
            else % motorNb == 1
                statusReg = obj.REG_STATUS_B;
            end

            try
                statusValue = obj.getDeviceRegisterValue(statusReg);
                % Check Bit 7 (0x80) for running status (Verify bit with device spec!)
                isRunning = bitand(statusValue, uint8(0x80)) > 0;
            catch ME
                warning('msb2302steppers_v2:StatusReadError', 'Could not read status for motor %d: %s', motorNb, ME.message);
                isRunning = false; % Assume not running if status cannot be read
            end
        end

        % Check the state of the end stops for a motor
        function [P0_active, P1_active] = isEndStopsActive(obj, motorNb)
            % isEndStopsActive Checks the status register for end stop activation state.
            % Assumes endstops are Active LOW (0 = active, 1 = inactive). Verify!
             arguments
                obj msb2302steppers_v2
                motorNb (1,1) {mustBeInteger, mustBeMember(motorNb, [0, 1])}
            end

            P0_active = false; % Default inactive
            P1_active = false; % Default inactive

            if motorNb == 0
                statusReg = obj.REG_STATUS_A;
            else % motorNb == 1
                statusReg = obj.REG_STATUS_B;
            end

            try
                statusValue = obj.getDeviceRegisterValue(statusReg);
                % Check Bit 0 (0x01) for P0 (Active Low)
                P0_active = bitand(statusValue, uint8(0x01)) == 0;
                % Check Bit 1 (0x02) for P1 (Active Low)
                P1_active = bitand(statusValue, uint8(0x02)) == 0;
            catch ME
                warning('msb2302steppers_v2:EndStopReadError', 'Could not read end stop status for motor %d: %s', motorNb, ME.message);
                % Return default false values
            end
        end

        % Close the serial connection properly
        function close(obj)
            % close Closes the serial port connection.
            if ~isempty(obj.serialObj) && isvalid(obj.serialObj)
                fprintf('Closing serial connection to %s...\n', obj.serialObj.Port);
                try
                    delete(obj.serialObj);
                     fprintf('Serial connection closed.\n');
                catch ME
                    warning('msb2302steppers_v2:CloseError', 'Error encountered while closing serial port %s: %s', obj.serialObj.Port, ME.message);
                end
                % Clear the handle (optional, as delete should invalidate)
                % obj.serialObj = [];
            else
                disp('Serial port object was already invalid or empty. No action taken.');
            end
        end

        % Destructor - ensure port is closed when object is deleted
        function delete(obj)
             obj.close();
        end

    end % End Public Methods

    methods (Access = private)

        % Write data to the serial port with error handling
        function [success] = writeSerialData(obj, data)
            arguments
                obj msb2302steppers_v2
                data (1,:) uint8 % Row vector of bytes to send
            end
            success = false; % Default to failure
            if isempty(data)
                 error('msb2302steppers_v2:EmptyWriteData', 'No data provided to writeSerialData.');
            end
            if isempty(obj.serialObj) || ~isvalid(obj.serialObj)
                 error('msb2302steppers_v2:InvalidSerialObj', 'Serial port object is invalid or not initialized.');
            end

            try
                % Optional: Display data being written for debugging
                % disp(['DEBUG TX: ', sprintf('%02X ', data)]);
                write(obj.serialObj, data, "uint8");
                success = true; % Write command succeeded
            catch ME
                warning('msb2302steppers_v2:WriteError', 'Failed to write to serial port %s: %s', obj.serialObj.Port, ME.message);
                % Consider additional error handling: attempt reconnect? flag object state?
            end
        end

        % Read and validate a device acknowledgement/data frame
        function [isValid, registersData] = getDeviceAck(obj)
            % getDeviceAck Reads the expected fixed-size frame and validates header/footer.
            % Assumes obj.serialObj.Timeout is set appropriately.

            isValid = false;        % Default: Frame is not valid
            registersData = uint8([]); % Default: Empty data

            if isempty(obj.serialObj) || ~isvalid(obj.serialObj)
                 warning('msb2302steppers_v2:InvalidSerialObj', 'Serial port object is invalid for getDeviceAck.');
                 return;
            end

            try
                % Read exactly the expected number of bytes
                rxFrame = read(obj.serialObj, obj.VALID_FRAME_BYTE_COUNT, "uint8");

                % Optional: Display raw received data for debugging
                % disp(['DEBUG RX: ', sprintf('%02X ', rxFrame)]);

                % Basic Length Check (read should guarantee this if no timeout, but double check)
                if length(rxFrame) ~= obj.VALID_FRAME_BYTE_COUNT
                    warning('msb2302steppers_v2:AckWrongLength', 'Received %d bytes, expected %d.', length(rxFrame), obj.VALID_FRAME_BYTE_COUNT);
                    % Possible partial read before timeout, or wrong VALID_FRAME_BYTE_COUNT constant
                    flush(obj.serialObj); % Clear potentially incomplete frame
                    return;
                end

                % Validate Header
                if ~isequal(rxFrame(1:obj.FRAME_HEADER_LEN), uint8(obj.FRAME_HEADER))
                    warning('msb2302steppers_v2:AckInvalidHeader', 'Invalid frame header received: %s', sprintf('%02X ', rxFrame(1:obj.FRAME_HEADER_LEN)));
                    return;
                end

                 % Validate Footer
                if ~isequal(rxFrame(end - obj.FRAME_FOOTER_LEN + 1 : end), uint8(obj.FRAME_FOOTER))
                    warning('msb2302steppers_v2:AckInvalidFooter', 'Invalid frame footer received: %s', sprintf('%02X ', rxFrame(end-obj.FRAME_FOOTER_LEN+1:end)));
                    return;
                end

                % If all checks pass:
                isValid = true;
                % Extract the data payload (bytes between header and footer)
                registersData = rxFrame(obj.FRAME_HEADER_LEN + 1 : end - obj.FRAME_FOOTER_LEN);

            catch ME
                if contains(ME.identifier, 'Timeout') || contains(ME.message, 'timeout', 'IgnoreCase', true)
                    warning('msb2302steppers_v2:AckTimeout', 'Timeout waiting for acknowledgement frame on port %s.', obj.serialObj.Port);
                else
                     warning('msb2302steppers_v2:AckReadError', 'Error reading acknowledgement frame from %s: %s', obj.serialObj.Port, ME.message);
                     % Consider more drastic action if read errors persist
                end
                % Ensure outputs reflect failure
                isValid = false;
                registersData = uint8([]);
            end
        end

        % Get the value of a single register from the device
        function value = getDeviceRegisterValue(obj, regAdr)
            % getDeviceRegisterValue Reads all registers and returns the value of one.
            % Note: This is potentially inefficient if the device supports reading
            % single registers directly.

            arguments
                obj msb2302steppers_v2
                regAdr (1,1) {mustBeNumeric, mustBeInteger, mustBeNonnegative}
            end

            % --- Read all registers ---
            readCmdSeq = [obj.READ, obj.i2cAdr];
            [writeSuccess] = obj.writeSerialData(readCmdSeq);
            if ~writeSuccess
                 error('msb2302steppers_v2:WriteError', 'Failed to send read command for getDeviceRegisterValue.');
            end

            [ackValid, registersData] = obj.getDeviceAck();

            if ~ackValid
                error('msb2302steppers_v2:ReadAckError', 'No valid ACK received when trying to read registers.');
            end
            % --- End Read all registers ---

            % --- Check if requested register address is valid ---
            % Register addresses are 0-based, indices are 1-based in MATLAB
            registerIndex = regAdr + 1;
            if registerIndex > length(registersData)
                error('msb2302steppers_v2:InvalidRegAddress', 'Register address 0x%02X (index %d) is out of bounds for received data length %d.', regAdr, registerIndex, length(registersData));
            end
            % --- End Check ---

            value = registersData(registerIndex);
        end

         % Extract board information from the data payload of a received frame
        function [success, boardInfo, boardTypeStr] = extractBoardInfos(obj, registersData)
            % extractBoardInfos Parses board details from the register data block.
            % Assumes specific register indices for info (adjust REG_BOARD_INFO_* constants if needed).

            arguments
                obj msb2302steppers_v2
                registersData (1,:) uint8
            end

            success = false;
            boardInfo = '';
            boardTypeStr = 'UNKNOWN'; % Default

            % Check if we have enough data for the info fields we need to parse
            requiredIndices = [obj.REG_BOARD_INFO_I2C_ADR, obj.REG_BOARD_INFO_TYPE, obj.REG_BOARD_INFO_FW_VER, obj.REG_BOARD_INFO_APP_VER];
            maxRequiredIndex = max(requiredIndices) + 1; % +1 for 1-based indexing

            if length(registersData) < maxRequiredIndex
                 warning('msb2302steppers_v2:ParseDataShort', 'Register data length (%d) is too short to extract board info (need at least %d bytes).', length(registersData), maxRequiredIndex);
                 return;
            end

            try
                % Extract data using 1-based indexing and defined constants
                i2cAddress      = registersData(obj.REG_BOARD_INFO_I2C_ADR + 1);
                boardTypeFlags  = registersData(obj.REG_BOARD_INFO_TYPE + 1);
                firmwareVersion = double(registersData(obj.REG_BOARD_INFO_FW_VER + 1)) / 10.0; % Assuming value is FW * 10
                appVersion      = registersData(obj.REG_BOARD_INFO_APP_VER + 1);

                % Extract board type from lower nibble (Verify logic with device spec!)
                 boardType = bitand(boardTypeFlags, uint8(0x0F));

                 % Determine board type string
                 switch boardType
                     case 0x00; boardTypeStr = 'GATEWAY';
                     case 0x01; boardTypeStr = 'FEEDER';
                     case 0x02; boardTypeStr = 'WEIGHTMEAS';
                     case 0x03; boardTypeStr = 'SERVO';
                     case 0x04; boardTypeStr = 'NOSEPOKE';
                     case 0x05; boardTypeStr = 'LICKPORT';
                     case 0x06; boardTypeStr = 'CAMTRACKING';
                     case 0x08; boardTypeStr = 'STEPPER';
                     otherwise; boardTypeStr = sprintf('UNKNOWN (0x%02X)', boardType);
                 end

                 % Construct the information string
                 boardInfo = sprintf('Type=%s, I2C=0x%02X, FW=%.1f, App=%d', ...
                     boardTypeStr, i2cAddress, firmwareVersion, appVersion);
                 success = true;

            catch ME
                warning('msb2302steppers_v2:ParseError', 'Error parsing board info from register data: %s', ME.message);
                % Ensure outputs reflect failure
                success = false;
                boardInfo = '';
                boardTypeStr = 'UNKNOWN';
            end
        end

    end % End Private Methods

end % End Class Definition