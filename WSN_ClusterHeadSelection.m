% Parameters
numNodes = 500; % Number of sensor nodes
areaSize = 1000; % Network area (1000x1000 meters)
initialEnergy = 2; % Initial energy of each node (Joules)
baseStation = [500, 500]; % BS at the center of the area

% Random node deployment
nodes = rand(numNodes, 2) * areaSize; % Random node positions
nodeEnergy = initialEnergy * ones(numNodes, 1); % Initial energy for all nodes

% Feature extraction
features = zeros(numNodes, 3); % Columns: Energy, Distance to BS, Node Density

for i = 1:numNodes
    features(i, 1) = nodeEnergy(i); % Residual energy
    features(i, 2) = norm(nodes(i, :) - baseStation); % Distance to BS
    features(i, 3) = sum(pdist2(nodes(i, :), nodes) < 100); % Local density
end

% Cluster Head Selection
CH_threshold = 0.5; % Threshold for CH selection
CH_candidates = find(features(:, 1) > mean(features(:, 1)) & ...
                      features(:, 2) < mean(features(:, 2)) & ...
                      features(:, 3) > mean(features(:, 3)));

% Display the selected cluster heads
fprintf('Selected %d cluster heads.\n', length(CH_candidates));

% Routing optimization
routes = cell(length(CH_candidates), 1); % Routes for each CH
for i = 1:length(CH_candidates)
    % Direct routing from CH to BS
    routes{i} = [nodes(CH_candidates(i), :); baseStation];
end

% Energy consumption
energyConsumed = initialEnergy - nodeEnergy;
totalEnergyConsumed = sum(energyConsumed);

% Network lifetime
firstNodeDead = find(nodeEnergy <= 0, 1, 'first');
lastNodeDead = find(nodeEnergy <= 0, 1, 'last');

% Success rate
successRate = sum(nodeEnergy > 0) / numNodes;

% Latency (arbitrary example based on routing hops)
latency = mean(cellfun(@(route) size(route, 1), routes)) * 0.1; % 0.1 ms per hop

% Display results
fprintf('Total Energy Consumed: %.2f J\n', totalEnergyConsumed);
fprintf('First Node Dead at Round: %d\n', firstNodeDead);
fprintf('Network Lifetime (Last Node Dead): %d rounds\n', lastNodeDead);
fprintf('Success Rate: %.2f%%\n', successRate * 100);
fprintf('Latency: %.2f ms\n', latency);

