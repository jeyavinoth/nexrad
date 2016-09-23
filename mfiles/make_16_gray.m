%
% Takes the default JET colormap and creates
% a new one with no blue, and white for small values
% 
% Should be useful for plotting vprime data.
%

colormap('default')
colormap('jet')

map4 = colormap;

map4 = map4(1:3:end, :);

clear map44
map44(1:16,:) =  map4(end-15:end,:);

temp = map44(1:8,:);
map44(5,:)=[.25 1 .75];
map44(4,:)=[0 0.75 .8];
map44(3,:)=[.25 .5 1];
map44(2,:)=[0 0 1];
map44(1,:) = [.7 .7 .7];


colormap(map44)
