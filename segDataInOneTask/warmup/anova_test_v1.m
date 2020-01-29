%% ANOVA test

clc;
clear all;
close all;

% load data
a = load('vec_warm_intro1.mat');
a = a.output;
b = load('vec_warm_listen1.mat');
b = b.output;
c = load('vec_warm_play1.mat');
c = c.output;

group = {'intro', 'listen', 'play'};

Y(:, 1) = a(:, 1);
Y(:, 2) = b(:, 1);
Y(:, 3) = c(:, 1);

[p, table, stats] = anova1(Y, group, 'on');