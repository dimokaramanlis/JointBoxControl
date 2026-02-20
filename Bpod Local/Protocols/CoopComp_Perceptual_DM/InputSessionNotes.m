function InputSessionNotes(BpodSystem)

%window for comments
fig = uifigure('Name','My Text Logger','Position',[500 500 400 200]);

fig.UserData = {};

sessionStart = datetime('now');

txt = uieditfield(fig,'text', ...
    'Position',[50 100 300 30], ...
    'ValueChangedFcn', @(src,event) saveInputText(src,sessionStart,BpodSystem));


end
