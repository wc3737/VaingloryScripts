%%% Create one file for each hero stat as the input to HighCharts %%%

% Constants
VERSION = 1.16;
NUM_STATS = 10;
NUM_LEVELS = 12;
DELIM = ' ';
COMMA = ',';
NEW_LINE = '\n';
STATS = {'HP', 'HP REGEN', 'EP', 'EP REGEN', 'WEAPON DAMAGE', 'ATTACK SPEED', ...
    'ARMOR', 'SHIELD', 'ATTACK RANGE', 'MOVE SPEED'};

% Parse info
fid = fopen('HeroStats.txt', 'r');
names = {};
stats = double(zeros(1,NUM_STATS));
increments = double(zeros(1,NUM_STATS));
counter = 1;
while ~feof(fid)
   line = fgetl(fid);
   line = strsplit(line, DELIM);
   % save name
   names{counter} = line{1};
   % save stats and increments
   len = length(line);
   stats(counter,:) = str2double(line(2:2:len));
   increments(counter,:) = str2double(line(3:2:len));
   counter = counter + 1;
end
fclose(fid);

numHeroes = length(names);
outMatrix = zeros(NUM_LEVELS,numHeroes+1,NUM_STATS-2); % stores growable stats by hero
titles = ['Level,', strjoin(names,COMMA), NEW_LINE];
% generate files for growable stats
for s = 1:NUM_STATS-2
    outMatrix(:,1,s) = 1:NUM_LEVELS;
    for h = 1:numHeroes
        if increments(h,s) > 0
            outMatrix(:,h+1,s) = stats(h,s):increments(h,s):stats(h,s)+(NUM_LEVELS-1)*increments(h,s);
        else
            outMatrix(:,h+1,s) = stats(h,s)*ones(1,NUM_LEVELS);
        end
    end
    fid = fopen([num2str(VERSION),'_',STATS{s},'.txt'], 'w');
    fprintf(fid,titles);
    for l = 1:NUM_LEVELS
        line = ['Level ',regexprep(num2str(outMatrix(l,:,s)),[DELIM '*'],COMMA),NEW_LINE];
        fprintf(fid,line);
    end
    fclose(fid);
end
% generate files for static stats
for s = NUM_STATS-1:NUM_STATS
    fid = fopen([num2str(VERSION),'_',STATS{s},'.txt'], 'w');
    fprintf(fid,['Hero,',STATS{s},NEW_LINE]);
    for h = 1:numHeroes
        line = [names{h},COMMA,num2str(stats(h,s)),NEW_LINE];
        fprintf(fid,line);
    end
end