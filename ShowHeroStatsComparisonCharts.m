% Constants
VERSION = 1.15;
NUM_STATS = 10;
NUM_LEVELS = 12;
GRAPH_WIDTH = 1080;
GRAPH_HEIGHT = 720;
DELIM = ' ';

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

% Plot graphs
close all
titles = {'HP', 'HP REGEN', 'EP', 'EP REGEN', 'WEAPON DAMAGE', 'ATTACK SPEED', ...
    'ARMOR', 'SHIELD', 'ATTACK RANGE', 'MOVE SPEED'};
numHeroes = length(names);
numStats = length(stats(1,:));
% Randomly generate one color to represent each hero
% Since background will be black, slightly skew the random color generation
% and use a set of predefined colors to boost readability
predefinedColors = [1,0,0;0,1,0;0,0,1;1,1,0;0,1,1;1,0,1;1,1,1];
colors = min(0.1+rand(numHeroes,3),1);
predefColorAssignments = randperm(numHeroes);
colors(predefColorAssignments(1:length(predefinedColors)),:) = predefinedColors;

% Plot growable stats as line graphs
for i = 1:numStats-2
    fig = figure;
    whitebg(fig, 'k')
    set(fig, 'Position', [0 0 GRAPH_WIDTH GRAPH_HEIGHT]);
    set(gca, 'OuterPosition', [-0.075 0 0.9 1]) % move plot left in window
    title(['Vainglory ' num2str(VERSION) ' Hero ', titles{i}, ...
        ' Comparison Graph \fontsize{10}by k3tchup'], 'FontSize', 15)
    hold on
    minVal = inf;
    maxVal = -inf;
    maxes = zeros(numHeroes,1);
    sortedNames = {}; % a cell array of cell array of names
    for r = 1:numHeroes
        if increments(r,i) > 0
            progress = stats(r,i):increments(r,i):stats(r,i)+increments(r,i)*(NUM_LEVELS-1);
        else
            progress = stats(r,i)*ones(1,NUM_LEVELS);
        end
        minVal = min(minVal, progress(1));
        maxVal = max(maxVal, progress(NUM_LEVELS));
        maxes(r) = progress(NUM_LEVELS);
        % graphic commands
        plot(1:NUM_LEVELS, progress, '-o', 'Color', colors(r,:))
        text(0,progress(1),names{r}, 'Color', colors(r,:), 'FontSize', 10) % names at level 1
    end
    [sorted, idx] = sort(maxes);
    sortedNamesIdx = 0;
    sortedColors = colors(idx,:);
    duplicateIdx = [];
    newIdx = 1;
    % if three or more heroes have the same values at level 12, shorten their
    % display names
    for s = 1:numHeroes
        if newIdx == s
            % compute shouldShortenName
            newIdx = s+1; % index to next unique value in "sorted"
            while newIdx <= numHeroes && sorted(newIdx) == sorted(newIdx - 1)
                newIdx = newIdx + 1;
            end
            shouldShortenName = newIdx - s > 2; % if three or more heroes have same stats
        end
        if shouldShortenName
            name = names{idx(s)}(1:2);
        else
            name = names{idx(s)};
        end
        nameStr = ['{\color[rgb]{' num2str(sortedColors(s,:)) '}' name '}'];
        if s > 1 && sorted(s) == sorted(s-1)
            sortedNames{sortedNamesIdx} = [sortedNames{sortedNamesIdx} ', ' nameStr];
            duplicateIdx = [duplicateIdx s];
        else
            sortedNamesIdx = sortedNamesIdx + 1;
            sortedNames{sortedNamesIdx} = nameStr;
        end
    end
    sorted(duplicateIdx) = []; % dedupe
    for c = 1:length(sortedNames)
        text(NUM_LEVELS+0.1,sorted(c),sortedNames{c}, 'FontSize', 10) % names at level 12
    end
    % graphic commands
    axis([0 NUM_LEVELS minVal maxVal])
    xlabel('Level')
    ylabel(titles{i});
    l = legend(names);
    set(l,'location','northwestoutside');
    set(gca,'XTick',1:1:NUM_LEVELS)
    set(gcf,'PaperPositionMode','auto', 'InvertHardCopy', 'off');
    print(titles{i},'-dpng','-r100')
    hold off
end

% Plot the others as bar graphs
for j = numStats-1:numStats
    fig = figure;
    whitebg(fig, 'k')
    set(fig,'Position', [5 5 GRAPH_WIDTH GRAPH_HEIGHT]);
    title(['Vainglory ' num2str(VERSION) ' Hero ', titles{j}, ...
        ' Comparison Graph \fontsize{10}by k3tchup'], 'FontSize', 15)
    hold on
    maxVal = -inf;
    for r = 1:numHeroes
        value = stats(r,j);
        h = bar(r,value);
        set(h,'facecolor',colors(r,:))
        text(r-0.25,value+0.15,num2str(value), 'Color', colors(r,:))
        text(r-0.25,-0.15,names{r}, 'Color', colors(r,:))
        minVal = min(minVal, value);
        maxVal = max(maxVal, value);
    end
    axis([0 numHeroes+1 0 maxVal+0.5])
    ylabel(titles{j})
    set(gca,'XTick',[])
    set(gcf,'PaperPositionMode','auto', 'InvertHardCopy', 'off');
    print(titles{j},'-dpng','-r100')
    hold off
end