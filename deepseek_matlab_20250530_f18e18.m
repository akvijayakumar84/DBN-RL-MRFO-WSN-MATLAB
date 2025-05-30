function createNetwork_500n()
    rng(42);  % For reproducibility
    
    %% Network Parameters (3GPP-compliant)
    numNodes = 500;              % 500-node network
    areaSize = 1000;             % 1000m x 1000m area
    maxEnergy = 0.25;            % Initial energy (Joules) - LEACH benchmark
    txEnergy = 50e-9;            % 50 nJ/bit transmission energy
    
    %% 1. Node Deployment (Uniform Random)
    positions = areaSize * rand(numNodes, 2);  % [x, y] coordinates
    
    %% 2. Energy Model (Heterogeneous)
    % 30% nodes have 2x energy (mimicking solar-powered nodes)
    energyLevels = maxEnergy * ones(numNodes, 1);
    highEnergyNodes = randperm(numNodes, floor(0.3*numNodes));
    energyLevels(highEnergyNodes) = 2 * maxEnergy;
    
    %% 3. Traffic Patterns (Poisson Process)
    % 3GPP TS 23.501 traffic profiles
    trafficTypes = {'periodic', 'event-driven', 'bursty'};
    trafficParams = struct(...
        'periodic',       struct('interval', 10, 'packetSize', 100), ...  % 10s interval
        'event-driven',   struct('lambda', 0.1, 'packetSize', 500), ...   % λ=0.1
        'bursty',        struct('burstLength', 5, 'packetSize', 200));    % 5-packet bursts
    
    traffic = cell(numNodes, 1);
    for i = 1:numNodes
        type = trafficTypes{randi(3)};
        traffic{i} = generateTraffic(type, trafficParams.(type));
    end
    
    %% 4. Save to MAT-file
    save('Network_500n.mat', 'positions', 'energyLevels', 'traffic', 'txEnergy');
    disp('Dataset saved as Network_500n.mat');
end

%% Helper: Traffic Generator
function packets = generateTraffic(type, params)
    switch type
        case 'periodic'
            packets = struct(...
                'time', 0:params.interval:3600, ...  % 1-hour simulation
                'size', params.packetSize * ones(1, 3600/params.interval));
        case 'event-driven'
            events = poissrnd(params.lambda * 3600);  % Events per hour
            packets = struct(...
                'time', sort(rand(1, events) * 3600), ...
                'size', params.packetSize * ones(1, events));
        case 'bursty'
            bursts = randi([1, 10], 1);  % 1-10 bursts/hour
            packets = struct();
            for b = 1:bursts
                startTime = rand * 3600;
                packets(b).time = startTime + (0:params.burstLength-1);
                packets(b).size = params.packetSize * ones(1, params.burstLength);
            end
    end
end