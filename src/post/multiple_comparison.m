% function multiple_comparison(data, tag)
% uses the Bonferroni multiple comparison test of means at 95% confidence
% interval, which is provided by the multcompare function in the
% MATLAB statistics toolbox (The MathWorks, Natick, MA).

% Copyright: Shaoying Lu and Yingxiao Wang 2011-2016
function m = multiple_comparison(data, tag, varargin)
para_name = {'alpha'};
default_value = {0.05};
alpha = parse_parameter(para_name, default_value, varargin);
[p,~,stat] = anova1(data, tag);
[c,m,h,nms]=multcompare(stat, 'ctype', 'bonferroni', 'alpha', alpha);
p
c
m
h
nms
