% Step 1: Generate Synthetic Dataset
numSamples = 1000; % Number of samples
inputSize = 3; % Number of input features
outputClasses = 2; % Number of classes (e.g., CH or non-CH)

% Features: Random values for energy, distance to base station, and node density
energy = rand(numSamples, 1) * 2; % Energy (0 to 2 Joules)
distanceToBS = rand(numSamples, 1) * 1000; % Distance to BS (0 to 1000 meters)
density = randi([1, 10], numSamples, 1); % Node density (1 to 10 nodes nearby)

% Labels: Binary classification (CH = 1, non-CH = 0) based on synthetic rules
labels = double((energy > 1) & (distanceToBS < 500) & (density > 5));

% Combine features into a single matrix
features = [energy, distanceToBS, density];
labelsCategorical = categorical(labels); % Convert labels to categorical

% Step 2: Split Data into Training and Validation Sets
trainRatio = 0.8; % 80% for training
valRatio = 0.2;   % 20% for validation

% Calculate indices
numTrainSamples = round(trainRatio * numSamples);
idx = randperm(numSamples);
trainIdx = idx(1:numTrainSamples);
valIdx = idx(numTrainSamples+1:end);

% Training data
featuresTrain = features(trainIdx, :);
labelsTrain = labelsCategorical(trainIdx);

% Validation data
featuresVal = features(valIdx, :);
labelsVal = labelsCategorical(valIdx);

% Step 3: Define Neural Network Architecture
layers = [
    featureInputLayer(inputSize, 'Name', 'input')
    fullyConnectedLayer(16, 'Name', 'fc1') % Hidden layer with 16 neurons
    reluLayer('Name', 'relu1') % ReLU activation function
    fullyConnectedLayer(outputClasses, 'Name', 'fc2') % Output layer
    softmaxLayer('Name', 'softmax') % Softmax for classification
    classificationLayer('Name', 'output') % Classification layer
];

% Step 4: Specify Training Options
options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 50, ...
    'MiniBatchSize', 32, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', false, ...
    'Plots', 'training-progress', ...
    'ValidationData', {featuresVal, labelsVal});

% Step 5: Train the Neural Network
deepLearningModel = trainNetwork(featuresTrain, labelsTrain, layers, options);

% Step 6: Save the Trained Model
save('deepLearningModel.mat', 'deepLearningModel');
disp('Model saved as deepLearningModel.mat');
