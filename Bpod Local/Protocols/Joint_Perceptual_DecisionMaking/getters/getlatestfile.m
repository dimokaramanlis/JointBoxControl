function latestfile = getlatestfile(directory)
%This function returns the latest file from the directory passsed as input
%argument

%Get the directory contents
dirc = dir(directory);

%Filter out all the folders.
dirc = dirc(find(~cellfun(@isfolder,{dirc(:).name})));

relevantFileNames = [];
relevantDateNum = [];
for counter = 1:length(dirc)
    if contains(dirc(counter).name,".mat")
    relevantFileNames = [relevantFileNames; dirc(counter).name];
    relevantDateNum = [relevantDateNum dirc(counter).datenum];
    end
end

%I contains the index to the biggest number which is the latest file
[A,I] = max(relevantDateNum);

if ~isempty(I)
    latestfile = relevantFileNames(I,:);
else
    latestfile = [];
end

end