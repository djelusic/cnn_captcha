function [opttheta] = minFuncSGD(funObj,theta,data,labels,...
                        testImages, testLabels, numClasses, filterDim, numFilters, poolDim, options)
% Runs stochastic gradient descent with momentum to optimize the
% parameters for the given objective.
%
% Parameters:
%  funObj     -  function handle which accepts as input theta,
%                data, labels and returns cost and gradient w.r.t
%                to theta.
%  theta      -  unrolled parameter vector
%  data       -  stores data in m x n x numExamples tensor
%  labels     -  corresponding labels in numExamples x 1 vector
%  options    -  struct to store specific options for optimization
%
% Returns:
%  opttheta   -  optimized parameter vector
%
% Options (* required)
%  epochs*     - number of epochs through data
%  alpha*      - initial learning rate
%  minibatch*  - size of minibatch
%  momentum    - momentum constant, defualts to 0.9


%%======================================================================
%% Setup
assert(all(isfield(options,{'epochs','alpha','minibatch'})),...
        'Some options not defined');
if ~isfield(options,'momentum')
    options.momentum = 0.9;
end;
epochs = options.epochs;
alpha = options.alpha;
minibatch = options.minibatch;
m = length(labels); % training set size
% Setup for momentum
mom = 0.5;
momIncrease = 20;
test_interval_iterations = 10;
numSamples = length(labels);
velocity = zeros(size(theta));

%%======================================================================
%% SGD loop
graph = 1;
iteration = 0;
test_results.iterations = zeros(0);
test_results.accuracies = zeros(0);
for e = 1:epochs
    % randomly permute indices of data for quick minibatch sampling
    rp = randperm(m);
    
    for s=1:minibatch:(m-minibatch+1)
        iteration = iteration + 1;
		tic;
        % increase momentum after momIncrease iterations
        if iteration == momIncrease
            mom = options.momentum;
        end;

        % get next randomly selected minibatch
        mb_data = data(:,:,rp(s:s+minibatch-1));
        mb_labels = labels(rp(s:s+minibatch-1));

        % evaluate the objective function on the next minibatch
        [cost grad] = funObj(theta,mb_data,mb_labels);
        
        % Instructions: Add in the weighted velocity vector to the
        % gradient evaluated above scaled by the learning rate.
        % Then update the current weights theta according to the
        % sgd update rule
        
        %%% YOUR CODE HERE %%%
        velocity = (mom.*velocity) + (alpha.*grad);
        theta = theta - velocity;
        
        
        fprintf('Epoch %d: Cost on iteration %d is %f\n',e,iteration,cost);
		if graph == 1
		if mod(iteration, test_interval_iterations) == 0 || (e == epochs && s == (numSamples - minibatch + 1))
            [~, ~, preds]=cnnCost(theta, testImages, testLabels, ...
                numClasses, filterDim, numFilters, poolDim, true);
            
            acc = 100 * sum(preds==testLabels) / length(preds);
            test_results.iterations = [test_results.iterations iteration];
            test_results.accuracies = [test_results.accuracies acc];
            % Accuracy should be around 97.4% after 3 epochs
            fprintf('Accuracy is %f\n',acc);
            
            sfigure(1);
            subplot(1, 1, 1);
            plot(test_results.iterations, test_results.accuracies);
            drawnow;
        end
		end
		toc;
    end;

    % aneal learning rate by factor of two after each epoch
    alpha = alpha/2.0;

end;
opttheta = theta;

end