function PrintTrialType(DataEngagement, graphics, Ntrials)

engagementTypes = fieldnames(DataEngagement);      
%engagementTypes = {'FullEngagement','HalfEngagement','ChangeOfMind','Disengagement'}
Outcome = {'Wrong','Correct'};

if nargin < 3
    Ntrials = size(DataEngagement.(engagementTypes{1}),1);
end
                 
%First recover trial type
OutcomeType = {sprintf('Error'),sprintf('Error')};

for imouse =1:2
    for iOutcome = 1:length(engagementTypes)            
        this_Outcome = DataEngagement.(engagementTypes{iOutcome})(Ntrials,imouse);
        if ~isnan(this_Outcome)
            if strcmp(engagementTypes{iOutcome},'Disengagement')
                OutcomeType{imouse} = sprintf('M%d: %s',imouse, engagementTypes{iOutcome});
            else
                OutcomeType{imouse} = sprintf('M%d: %s,%s',imouse, engagementTypes{iOutcome},Outcome{this_Outcome+1});  
            end
        end
    end
end

TrialTypeFig = figure(101);  clf;               % use figure 1
set(TrialTypeFig, 'Position',[500 1100 300 150], 'Color','w');
axis off
xlim([0 1])
ylim([0 1])
y=0.65;
for imouse = 1:2
    mousecol = graphics.mouseColor(imouse, :);
    text(0.5,y, OutcomeType(imouse), 'HorizontalAlignment','center','FontSize',14,'Color',mousecol)
    y=y-0.3;
end
end
