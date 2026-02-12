function durations = getSpoutStayTimes(Data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%----------------------------------------------------------------------
%%
%% 1. BUILD EVENT LOG (Vectorized Data Prep)
% Combines all Stimulus, PortIn, and PortOut events into one chronological list.
% Columns: [Time, EventType, PortID]
% EventType: 1=PortIn, 2=PortOut, 3=StimStart

Ntrials = max(Data.TrialNumber);
TrialStartTimes = Data.TrialStartTimestamp;
RawEvents = Data.RawEvents.Trial;

% Configuration
% [LeftPort RightPort] -> e.g. Mouse 1 uses 4 & 1, Mouse 2 uses 3 & 2
portids = [4 1; 3 2]; 
repoke_window = 0.5; % Max gap to merge pokes

% Estimate size and pre-allocate
EventLog = nan(Ntrials * 100, 4); 
ctr = 1;

for iT = 1:Ntrials
    t_abs = TrialStartTimes(iT);
    evs = RawEvents{iT}.Events;
    if isempty(evs), continue; end
    
    % A. Add Stimulus Start (Type 3)
    if isfield(evs, 'GlobalTimer1_Start')
        t = evs.GlobalTimer1_Start;
        n = numel(t);
        % [Time, Type=3, PortID=NaN, TrialID=iT]
        EventLog(ctr:ctr+n-1, :) = [t(:)+t_abs, ones(n,1)*3, nan(n,1), ones(n,1)*iT];
        ctr = ctr + n;
    end
    
    % B. Add Port Events (Type 1=In, Type 2=Out)
    % We scan ALL ports (1, 2, 3, 4) to catch opposite pokes reliably
    all_ports = unique(portids(:)); 
    for p = all_ports'
        % Port In
        fIn = sprintf('Port%dIn', p);
        if isfield(evs, fIn)
            t = evs.(fIn); n = numel(t);
            EventLog(ctr:ctr+n-1, :) = [t(:)+t_abs, ones(n,1)*1, ones(n,1)*p, ones(n,1)*iT];
            ctr = ctr + n;
        end
        % Port Out
        fOut = sprintf('Port%dOut', p);
        if isfield(evs, fOut)
            t = evs.(fOut); n = numel(t);
            EventLog(ctr:ctr+n-1, :) = [t(:)+t_abs, ones(n,1)*2, ones(n,1)*p, ones(n,1)*iT];
            ctr = ctr + n;
        end
    end
end

% Sort chronologically
EventLog = EventLog(1:ctr-1, :);
EventLog = sortrows(EventLog, 1);

% Matrix columns: 1:Time, 2:Type, 3:PortID, 4:TrialID

durations = nan(Ntrials, 2); % [Mouse1_Dur, Mouse2_Dur]

% Identify all Stimulus Start indices
stim_idxs = find(EventLog(:, 2) == 3);

for k = 1:length(stim_idxs)
    idx_stim = stim_idxs(k);
    t_stim = EventLog(idx_stim, 1);
    
    % Find the index of the NEXT stimulus (Hard Stop Condition)
    if k < length(stim_idxs)
        idx_next_stim = stim_idxs(k+1);
    else
        idx_next_stim = size(EventLog, 1);
    end
    
    % Process for each mouse/side (ii=1, ii=2)
    for ii = 1:2
        % Determine ports for this mouse
        my_ports = portids(ii, :); % e.g., [4 1]
        
        % Search window: From current Stimulus to Next Stimulus
        window_indices = (idx_stim+1) : idx_next_stim;
        events_window = EventLog(window_indices, :);
        
        % 1. Find FIRST PortIn at EITHER of the mouse's ports
        % We look for Type=1 (In) AND PortID is in my_ports
        is_my_in = events_window(:,2) == 1 & ismember(events_window(:,3), my_ports);
        first_in_idx = find(is_my_in, 1);
        
        if ~isempty(first_in_idx)
            % START of bout found
            row_idx = first_in_idx;
            t_start = events_window(row_idx, 1);
            active_port = events_window(row_idx, 3);
            
            % Identify the "Opposite" port for this specific trial choice
            opp_port = my_ports(my_ports ~= active_port);
            
            % 2. Find the END of bout (Scanning forward from start)
            t_end = nan;
            
            % Scan remaining events in this window (up to next stim)
            for j = (row_idx+1) : size(events_window, 1)
                ev_type = events_window(j, 2);
                ev_port = events_window(j, 3);
                ev_time = events_window(j, 1);
                
                % STOP CONDITION A: Opposite Port In
                if ev_type == 1 && ev_port == opp_port
                    % Choice switched. Stop immediately.
                    % If we haven't found a valid Out yet, use this In time as a clamp? 
                    % Or usually, we just take the last valid Out seen.
                    break; 
                end
                
                % CANDIDATE OUT: Same Port Out
                if ev_type == 2 && ev_port == active_port
                    % We found an OUT. Is it a jitter?
                    % Look for the NEXT 'IN' at this SAME port
                    
                    is_jitter = false;
                    
                    % Find next IN for same port (within the remaining window)
                    future_evs = events_window(j+1:end, :);
                    next_in_idx_local = find(future_evs(:,2)==1 & future_evs(:,3)==active_port, 1);
                    
                    if ~isempty(next_in_idx_local)
                        t_next_in = future_evs(next_in_idx_local, 1);
                        
                        % If gap is small, it's a head bob -> Ignore this Out
                        if (t_next_in - ev_time) < repoke_window
                            is_jitter = true;
                        end
                    end
                    
                    if ~is_jitter
                        % Valid Exit found!
                        t_end = ev_time;
                        break; % Stop scanning, we have our duration
                    end
                end
                
                % Note: We don't need to check "Next Stim" here because
                % 'events_window' is already sliced to end at idx_next_stim.
            end
            
            % Save duration if we found a valid end
            if ~isnan(t_end)
                durations(k, ii) = t_end - t_start;
            end
        end
    end
end
%%
% clf;
% xx = linspace(0,12,50);
% for imouse = 1:2
%     tcorr = Data.TrialOutcome(:,imouse)==1;
%     subplot(3,2,imouse)
%     histogram(durations(tcorr,imouse),xx); hold on;
%     histogram(durations(Data.TrialOutcome(:,imouse)==0,imouse),xx); hold on;
%     datause = durations(:,imouse);
%     datacorr = datause;
%     datacorr(~tcorr) = nan;
%     datawrong = datause;
%     datawrong(tcorr) = nan;
%     subplot(3,2,2+imouse)
%     tout = smoothdata(datacorr,'movmean',10, 'omitmissing');
%     twrong = smoothdata(datawrong,'movmean',10, 'omitmissing');
%     plot(1:numel(tout), tout, 1:numel(tout), twrong)
%     subplot(3,2,4+imouse)
%     chblue = Data.MouseChoice(:,imouse) == 1;
%     chred = Data.MouseChoice(:,imouse) == -1;
%     histogram(durations(tcorr&chblue,imouse),xx,'FaceColor','b'); hold on;
%     histogram(durations(tcorr&chred,imouse),xx,'FaceColor','r');
% end
% 
% 


%%

end



