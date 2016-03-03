import urllib2
import lxml.html

HEROES_PAGE = "http://www.vainglorygame.com/heroes/"
HEROES_CLASS = "heroes-search-results"
HEROES_LIST_XPATH = "//div[contains(@class, '" + HEROES_CLASS + "')]//div[@class='result-body']/h5"
STATS_LIST_XPATH = "//div[@id='stats']//h4"
OUTPUT_FILENAME = "HeroStats.txt"
PRINT_PROCESSING = "Processing "
NUM_HERO_STATS = 10
EP_INDEX = 4
ATTACK_SPEED_INDEX = 10
DELIM = " "
NEW_LINE = "\n"

request = urllib2.Request(HEROES_PAGE)
response = urllib2.urlopen(request, timeout=300)
page = response.read()

dom = lxml.html.fromstring(page)
heroesList = dom.xpath(HEROES_LIST_XPATH)

heroNames = []
for hero in heroesList:
    heroNames.append(hero.text_content())
heroNames.sort()

heroProfiles = {}
with open(OUTPUT_FILENAME, 'w') as f:
    for name in heroNames:
        print PRINT_PROCESSING + name

        response = urllib2.urlopen(HEROES_PAGE + name)
        page = response.read()
        dom = lxml.html.fromstring(page)
        statsList = dom.xpath(STATS_LIST_XPATH)

        # heroSummary list will have NUM_HERO_STATS elements,
        # or NUM_HERO_STATS-2 elements for heroes with no EP info
        heroSummary = []
        for stats in statsList:
            stats = stats.text_content().strip()
            heroSummary.append(stats)

        heroProfiles[name] = [name]
        numHeroStats = len(heroSummary)
        outputStatsIndex = 0 # index for assigning values into the heroProfiles[name] list
        for inputStatsIndex in range(0,numHeroStats):
            baseValue = str(0) if outputStatsIndex != ATTACK_SPEED_INDEX else str(1) # default baseValue is 1 for ATTACK_SPEED and 0 otherwise
            increment = str(0)
            if numHeroStats < NUM_HERO_STATS and outputStatsIndex == EP_INDEX: # hero has no EP info
                heroProfiles[name].extend([baseValue, increment]) # add default EP info
                heroProfiles[name].extend([baseValue, increment]) # add default EP REGEN info
                outputStatsIndex = EP_INDEX + 4 # next output index skipping over EP and EP REGEN info
            heroInfo = heroSummary[inputStatsIndex].split(DELIM)
            # heroSummary[inputStatsIndex] is in the form of 'BASE_VALUE INCREMENT_VALUE'
            # e.g. '719 (+85)', '1 (+)' (Case 1)
            # or 'BASE_VALUE' for stats with no increment, e.g. '6.8' (Case 2)
            # or 'INCREMENT' for stats with no base value, e.g. '(+5)' (Case 3)
            # or 'N/A (+N/A)' (Case 4)
            # or '' (Case 5)
            # after split, heroInfo will be in the form of [BASE_VALUE, '', INCREMENT_VALUE]
            # e.g. ['719', '', '(+85)'], ['1', '', '(+)'] (Case 1)
            # or [BASE_VALUE] for stats with no increment, e.g. ['6.8'] (Case 2)
            # or ['(+5)'] (Case 3)
            # or ['N/A', '', '(+N/A)'] (Case 4)
            # or [''] (Case 5)
            if len(heroInfo[0]) > 0: # Cases 1,2,3,4
                if not heroInfo[0][0].isdigit(): # Cases 3 and 4
                    if len(heroInfo) == 1: # Case 3
                        increment = heroInfo[0][1:-1]
                    # else it's Case 4, don't update baseValue or increment
                else: # Cases 1 and 2
                    baseValue = heroInfo[0]
                    increment = heroInfo[2][2:-1] if len(heroInfo) > 1 and len(heroInfo[2][2:-1]) > 0 else str(0)
            # else it's Case 5, go with default baseValue and increment
            # now we append baseValue and increment to the heroProfile[name] list
            heroProfiles[name].extend([baseValue, increment])
            outputStatsIndex += 2
        print heroProfiles[name]
        f.write(DELIM.join(heroProfiles[name]) + NEW_LINE)
f.close()
