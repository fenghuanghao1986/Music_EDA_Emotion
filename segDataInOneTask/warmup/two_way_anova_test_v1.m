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

group = 10;

Y(:, 1) = a(:, 1);
Y(:, 2) = b(:, 1);
Y(:, 3) = c(:, 1);

[~, ~, stats] = anova2(Y, group);