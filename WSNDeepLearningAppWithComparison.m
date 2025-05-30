classdef WSNDeepLearningAppWithComparison < matlab.apps.AppBase

    % Properties for UI components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        RunSimulationButton    matlab.ui.control.Button
        NodesTable             matlab.ui.control.Table
        ResultsTable           matlab.ui.control.Table
        NodePositionsAxes      matlab.ui.control.UIAxes
        MetricsAxes            matlab.ui.control.UIAxes % For Metrics Visualization
        ComparisonAxes         matlab.ui.control.UIAxes % For Comparison Visualization
        NumNodesEditField      matlab.ui.control.NumericEditField
        AreaSizeEditField      matlab.ui.control.NumericEditField
        PopulationSizeEditField matlab.ui.control.NumericEditField
        NumClustersEditField   matlab.ui.control.NumericEditField
        SinkPositionEditField  matlab.ui.control.NumericEditField
    end

    % Properties for simulation and results
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
        simulationResults % Store results for analysis
        comparisonResults % Store results for baseline algorithms
    end

    % App initialization and UI components
    methods (Access = private)

        % Initialize components
        function createComponents(app)
            % UI Figure
            app.UIFigure = uifigure('Position', [100, 100, 1200, 700]);
            app.UIFigure.Name = 'WSN Deep Learning Optimization with Comparison';
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
            app.NodePositionsAxes = uiaxes(app.UIFigure, 'Position', [300, 300, 300, 250]);
            title(app.NodePositionsAxes, 'Node Positions');
            xlabel(app.NodePositionsAxes, 'X');
            ylabel(app.NodePositionsAxes, 'Y');
            % Comparison Visualization Axes
            app.ComparisonAxes = uiaxes(app.UIFigure, 'Position', [800, 300, 350, 250]);
            title(app.ComparisonAxes, 'Comparison with Baseline Systems');
            xlabel(app.ComparisonAxes, 'Algorithms');
            ylabel(app.ComparisonAxes, 'Performance Metrics');
            
             % Metrics Visualization Axes
            app.MetricsAxes = uiaxes(app.UIFigure, 'Position', [650, 300, 300, 250]);
            title(app.MetricsAxes, 'Performance Metrics');
            xlabel(app.MetricsAxes, 'Metrics');
            ylabel(app.MetricsAxes, 'Value');

             % Tables
            uilabel(app.UIFigure, 'Position', [50, 200, 120, 20], 'Text', 'Nodes Table');
            app.NodesTable = uitable(app.UIFigure, 'Position', [50, 50, 200, 150]);

            uilabel(app.UIFigure, 'Position', [300, 200, 120, 20], 'Text', 'Results Table');
            app.ResultsTable = uitable(app.UIFigure, 'Position', [300, 50, 400, 150]);

        end

        % Run simulation and collect results
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

            % Optimize using bio-inspired algorithm
            fitnessFunction = @(CH) calculateFitness(CH, app.nodePositions, app.sink, app.nodeEnergy);
            [app.bestCH, app.bestFitness] = cuckooSearch(fitnessFunction, ...
                app.numClusters, 1:app.numNodes, app.populationSize, 100);

            % Calculate Performance Metrics
            app.simulationResults = struct( ...
                'TotalEnergy', sum(app.nodeEnergy), ...
                'NetworkLifetime', 1 / (1 + app.bestFitness), ...
                'Latency', app.bestFitness);

            % Generate and Compare with Baseline Systems
            app.compareWithBaselines();

            % Visualizations
            app.plotMetrics();
            app.plotComparison();
        end

        % Compare proposed system with baseline systems
        function compareWithBaselines(app)
            baselineAlgorithms = {'EPOA-CHS', 'ASFO', 'FSMO', 'E-CERP'};
            baselineMetrics = zeros(length(baselineAlgorithms), 3); % [TotalEnergy, NetworkLifetime, Latency]

            for i = 1:length(baselineAlgorithms)
                % Simulate baseline algorithms (replace with real logic)
                baselineMetrics(i, :) = [rand * 10, rand * 100, rand * 0.1];
            end

            % Store comparison results
            app.comparisonResults = struct( ...
                'Algorithms', ['Proposed System', baselineAlgorithms], ...
                'Metrics', [app.simulationResults.TotalEnergy, ...
                            app.simulationResults.NetworkLifetime, ...
                            app.simulationResults.Latency; baselineMetrics]);
        end

        % Plot performance metrics
        function plotMetrics(app)
            metrics = {'Total Energy', 'Network Lifetime', 'Latency'};
            values = [app.simulationResults.TotalEnergy, ...
                      app.simulationResults.NetworkLifetime, ...
                      app.simulationResults.Latency];

            bar(app.MetricsAxes, values);
            set(app.MetricsAxes, 'XTickLabel', metrics);
            title(app.MetricsAxes, 'Performance Metrics');
        end

        % Plot comparison with baseline systems
        function plotComparison(app)
            algorithms = app.comparisonResults.Algorithms;
            metrics = app.comparisonResults.Metrics;

            bar(app.ComparisonAxes, metrics);
            legend(app.ComparisonAxes, {'Total Energy', 'Network Lifetime', 'Latency'}, 'Location', 'northwest');
            set(app.ComparisonAxes, 'XTickLabel', algorithms);
            title(app.ComparisonAxes, 'Comparison with Baseline Systems');
        end
    end

    % App construction
    methods (Access = public)
        function app = WSNDeepLearningAppWithComparison()
            createComponents(app);
        end
    end
end
