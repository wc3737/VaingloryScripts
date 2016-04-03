# VaingloryScripts
## Overview
Two scripts that generate hero stats comparison charts in Vainglory.

GetHeroInfo.py, written in Python, retrieves hero stats from the Vainglory website (www.vainglorygame.com), processes the data, then writes the formatted information to HeroStats.txt.

ShowHeroStatsComparisonCharts.m is a MATLAB script that reads HeroStats.txt and plots all the comparison graphs.

GenerateHeroStatsFiles.m is another MATLAB script that reads HeroStats.txt to create separate hero stats files to be used as inputs for HighCharts (cloud.highcharts.com).

## Update Notes
* 04/02/16 Updated for V1.16 of the game by k3tchup (wc3737)
 * updated HeroStats.txt with V1.16 base stats changes and new hero Alpha (manually, since information on website didn't reflect new numbers yet)
 * added GenerateHeroStatsFiles.m
* 03/05/16 Updated for V1.15 of the game by k3tchup (wc3737)
 * updated HeroStats.txt with V1.15 base stats changes
 * added partial fix for overlapping names
* 03/01/16 Updated for V1.14 of the game by k3tchup (wc3737)
 * initial commits of GetHeroInfo.py, ShowHeroStatsComparisonCharts.m, HeroStats.txt