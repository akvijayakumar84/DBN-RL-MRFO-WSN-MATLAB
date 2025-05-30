classdef WSNDeepLearningApp < matlab.apps.AppBase

    % Properties for UI components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        RunSimulationButton    matlab.ui.control.Button
        NodesTable             matlab.ui.control.Table
        ResultsTable           matlab.ui.control.Table
        NodePositionsAxes      matlab.ui.control.UIAxes
        NumNodesEditField      matlab.ui.control.NumericEditField
        AreaSizeEditField      matlab.ui.control.NumericEditField
        PopulationSizeEditField matlab.ui.control.NumericEditField
        NumClustersEditField   matlab.ui.control.NumericEditField
        SinkPositionEditField  matlab.ui.control.NumericEditField
    end

    % Properties for simulation
    properties (Access = private)
        nodePositions % WSN node positions
        nodeEnergy    % WSN node energy
        sink          % Sink position
        numNodes      % Number of nodes
        areaSize      % Area size of the WSN
        numClusters   % Number of clusters
        populationSize % Cuckoo Search population size
        bestCH        % Best cluster head indices
        bestFitness   % Best fitness value
    end

    % App initialization and UI components
    methods (Access = private)

        % Initialize components
        function createComponents(app)
            % UI Figure
            app.UIFigure = uifigure('Position', [100, 100, 1000, 1000]);
            app.UIFigure.Name = 'WSN Deep Learning Optimization';

            % Input Fields
            uilabel(app.UIFigure, 'Position', [50, 550, 120, 20], 'Text', 'Number of Nodes');
            app.NumNodesEditField = uieditfield(app.UIFigure, 'numeric', 'Position', [180, 550, 100, 22], 'Value', 100);

            uilabel(app.UIFigure, 'Position', [50, 500, 120, 20], 'Text', 'Area Size');
            app.AreaSizeEditField = uieditfield(app.UIFigure, 'numeric', 'Position', [180, 500, 100, 22], 'Value', 1000);

            uilabel(app.UIFigure, 'Position', [50, 450, 120, 20], 'Text', 'Sink Position');
            app.SinkPositionEditField = uieditfield(app.UIFigure, 'numeric', 'Position', [180, 450, 100, 22], 'Value', 500);

            uilabel(app.UIFigure, 'Position', [50, 400, 120, 20], 'Text', 'Population Size');
            app.PopulationSizeEditField = uieditfield(app.UIFigure, 'numeric', 'Position', [180, 400, 100, 22], 'Value', 20);

            uilabel(app.UIFigure, 'Position', [50, 350, 120, 20], 'Text', 'Number of Clusters');
            app.NumClustersEditField = uieditfield(app.UIFigure, 'numeric', 'Position', [180, 350, 100, 22], 'Value', 5);

            % Run Button
            app.RunSimulationButton = uibutton(app.UIFigure, 'push', ...
                'Position', [50, 300, 100, 30], ...
                'Text', 'Run Simulation', ...
                'ButtonPushedFcn', @(~, ~) runSimulation(app));

            % Axes for Visualization
            app.NodePositionsAxes = uiaxes(app.UIFigure, 'Position', [300, 300, 400, 300]);
            title(app.NodePositionsAxes, 'Node Positions');
            xlabel(app.NodePositionsAxes, 'X');
            ylabel(app.NodePositionsAxes, 'Y');

             % Axes for Visualization
            app.NodePositionsAxes = uiaxes(app.UIFigure, 'Position', [300, 300, 400, 300]);
            title(app.NodePositionsAxes, 'Node Positions');
            xlabel(app.NodePositionsAxes, 'X');
            ylabel(app.NodePositionsAxes, 'Y');

            % Tables
            uilabel(app.UIFigure, 'Position', [50, 200, 120, 20], 'Text', 'Nodes Table');
            app.NodesTable = uitable(app.UIFigure, 'Position', [50, 50, 200, 150]);

            uilabel(app.UIFigure, 'Position', [300, 200, 120, 20], 'Text', 'Results Table');
            app.ResultsTable = uitable(app.UIFigure, 'Position', [300, 50, 400, 150]);
        end
    end

    % Callback for running the simulation
    methods (Access = private)
     function runSimulation(app)
    % Load parameters
    app.numNodes = app.NumNodesEditField.Value;
    app.areaSize = app.AreaSizeEditField.Value;
    app.sink = [app.SinkPositionEditField.Value, app.SinkPositionEditField.Value];
    app.populationSize = app.PopulationSizeEditField.Value;
    app.numClusters = app.NumClustersEditField.Value;

    % Generate random node positions and energies
    app.nodePositions = rand(app.numNodes, 2) * app.areaSize;
    app.nodeEnergy = rand(app.numNodes, 1) * 2;

    % Display nodes on axes
    scatter(app.NodePositionsAxes, app.nodePositions(:, 1), app.nodePositions(:, 2), 'b');
    hold(app.NodePositionsAxes, 'on');
    scatter(app.NodePositionsAxes, app.sink(1), app.sink(2), 'r', 'filled');
    hold(app.NodePositionsAxes, 'off');

    % Populate the Nodes Table
    nodeIDs = (1:app.numNodes)';
    nodeEnergies = app.nodeEnergy;
    nodePositionsX = app.nodePositions(:, 1);
    nodePositionsY = app.nodePositions(:, 2);
    app.NodesTable.Data = table(nodeIDs, nodePositionsX, nodePositionsY, nodeEnergies, ...
        'VariableNames', {'NodeID', 'PosX', 'PosY', 'Energy'});

    % Call bio-inspired optimization
    fitnessFunction = @(CH) calculateFitness(CH, app.nodePositions, app.sink, app.nodeEnergy);
    [app.bestCH, app.bestFitness] = cuckooSearch(fitnessFunction, ...
        app.numClusters, 1:app.numNodes, app.populationSize, 100);

    % Prepare results table data
    clusterHeads = app.bestCH(:);
    fitnessValues = repmat(app.bestFitness, numel(clusterHeads), 1);
    app.ResultsTable.Data = table(clusterHeads, fitnessValues, 'VariableNames', {'ClusterHeads', 'Fitness'});
end


    end

    % App construction
    methods (Access = public)

        % Constructor
        function app = WSNDeepLearningApp()
            createComponents(app);
        end
    end
end
