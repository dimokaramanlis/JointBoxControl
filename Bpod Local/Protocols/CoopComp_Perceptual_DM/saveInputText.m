function saveInputText(src,sessionStart,BpodSystem)

    if ~isfield(BpodSystem.Data,'Notes')
        BpodSystem.Data.Notes = {};
    end

    current_time = datetime('now','Format','d-MMM-y HH:mm:ss');
    elapsed = current_time - sessionStart;   % duration since start

    entry = sprintf('[%s | +%s] %s', ...
        char(current_time), ...
        char(elapsed), ...
        src.Value);

    BpodSystem.Data.Notes{end+1} = entry;

    src.Value = '';
end