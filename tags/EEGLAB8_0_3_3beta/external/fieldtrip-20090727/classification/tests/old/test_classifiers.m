% this script tests classification procedures; 
% add procedure below for benchmarking. 
%
% benchmarking saved as classifiers.log
% 
%   Copyright (c) 2009, Marcel van Gerven
%
%   $Log: not supported by cvs2svn $
%

fclose('all');
close all
clear all

%% add required definitions here

% custom pdf and mle for gnb
truncgauss = @(x,mu,sigma)(normpdf(x,mu,sigma)./(normcdf(500,mu,sigma)-normcdf(0,mu,sigma)));
truncmle = @(x)(mle(x,'pdf',truncgauss,...
  'start', [nanmean(x) nanstd(x)], ...
  'lower', [-2 -2]));

% custom pdf for gnb
vonmises = @(x,mu,k)((1/(2*pi*besseli(0,k)))*exp(k*cos(mod(x,2*pi)-mu))); %gives the density at that point


%% specify procedure here

procedures = {
  { preprocessor('prefun',@(x)(log10(x))) standardizer() randomclassifier() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() ensemble('procedures',{clfproc({lr()}) clfproc({nb()})},'combination','majority') } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() gnb('conditional','normal') } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() nb() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() lr() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() gp() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() nearestneighbour() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() pnn() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() da('disfun','quadratic') } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() rfda() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() rlda() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() kernelmethod() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() svmmethod() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() libsvm() } ...
  { preprocessor('prefun',@(x)(log10(x))) standardizer() gslr('maxgroup',100) } ...
  { preprocessor('prefun',@(x)(log10(x)))  standardizer() optimizer('validator',crossvalidator('procedure',{kernelmethod()}),'variables','C','values',1:2,'metric','accuracy','verbose',true)} ...
 % { preprocessor('prefun',@(x)(log10(x))) standardizer() rnb('lambas',[100],'tolerance',0,'epsilon',1e-2) } ...  
  % { preprocessor('prefun',@(x)(log10(x))) standardizer() mixtureclassifier('mixture',2) } ...
  % { preprocessor('prefun',@(x)(log10(x))) standardizer() gnb('conditional',truncgauss,'mle',truncmle) } ...
  % { preprocessor('prefun',@(x)(log10(x))) standardizer() gnb('conditional',vonmises,'mle',@mlemises) } ...  
  % { preprocessor('prefun',@(x)(log10(x))) standardizer() gnb('conditional','exponential') } ...
};

descriptions = { 
  'random classifier' ...
  'ensemble method' ...
  'gnb with normal distribution' ...
  'gaussian naive bayes' ...  
  'logistic regression' ...
  'gaussian process' ...
  'nearest neighbour classifier' ...
  'probabilistic neural network' ...
  'linear discriminant analysis with quadratic discrimination function' ...
  'regularized fished discriminant analysis' ...
  'regularized linear discriminant analysis' ...
  'kernel method (svm)' ...
  'svm method' ...
  'libsvm wrapper' ...
  'group-sparsifying logistic regression' ...
  'optimizer' 
};

%% start analysis

% iterate over all specified classification procedures
fid = fopen('classifiers.log','w+');
for c=1:length(procedures)

  tic;
  [acc,p] = test_procedure(procedures{c});
   
  fprintf(fid,'%f\t%f\t%f\t%s\n',acc,p,toc,descriptions{c});

end
fclose(fid);
