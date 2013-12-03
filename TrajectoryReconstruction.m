function [Traj, Beta] = TrajectoryReconstruction(C, K)

% Trajectory reconstruction algorithm from 2D projections
% Paper: "3D Reconstruction of a Moving Point from a Series of 2D Projections (ECCV)"
% Authors: Hyun Soo Park, Takaaki Shiratori, Iain Matthews, and Yaser Sheikh
% Please refer to http://www.andrew.cmu.edu/user/hyunsoop/eccv2010/eccv_project_page.html
% 
% This function takes cells of camera projection information C and prior weight parameter w for selecting the number of basis.
% 
% INPUT:
% Each cell C contains camera projection matrix, time instance, and 2D correspondences.
%     C{i}.P: 3 x 4 projection matrix
%     C{i}.t: time instance that the image is taken
%     C{i}.m: p x 2 matrix where p is the number of correspondences, i.e, m = [x(1) y(1); ... ; x(p) y(p)]
%     if there is a missing correspondence, you should set the corresponding point as [x y] = [NaN NaN]
% K is the number of basis (optional, default = automatic selection -- let the algorithm decide)
%
% 
% OUTPUT:
% Traj is a set of the reconstructed trajectories.
% Each Traj{i} are F x 3 matrix, i.e, [X Y Z] where F is the number of time step specified by dT
% Beta is a set of the coeffient of a trajectory.
% Beta{i} is K x 3 dimensional vector, [beta_x beta_y beta_z], of the i-th trajectory where 1 <= i <= p. 
% 
% Written by Hyun Soo Park
% hyunsoop@cs.cmu.edu

if nargin < 1
    display('Error: No data');
    return;
elseif nargin < 2 || K == -1
    nFolds = 10;
    K = -1;
end

% Find sequence length
sequence_length = 0;
for iCamera = 1 : length(C)
    if (sequence_length < C{iCamera}.t)
        sequence_length = C{iCamera}.t;
    end
end
sequence_length = ceil(sequence_length)+1;

nPoints = size(C{1}.m,1);
if K ~= -1
    for iPoint = 1 : nPoints
        measurements = [];  P = [];  time_instants = [];
        for iCamera = 1 : length(C)
            if ~isnan(C{iCamera}.m(iPoint,1))
                P{end+1} = C{iCamera}.P;
                time_instants(end+1) = C{iCamera}.t;
                measurements(end+1,:) = C{iCamera}.m(iPoint,:);                
            end
        end
        Beta{iPoint} = ReconstructPointTrajectory(P, time_instants, measurements, sequence_length, K);
        theta = IDCTmappingMatrix(sequence_length);
        theta = theta(:,1:K);
        Traj{iPoint} = [theta*Beta{iPoint}(1:end/3) theta*Beta{iPoint}(1+end/3:2*end/3) theta*Beta{iPoint}(1+2*end/3:end)];
        
%         camConnect = zeros( numel(time_instants) -1 , 2);
%         camConnect(:,1) = time_instants(1:end-1)+1;
%         camConnect(:,2) = time_instants(2:end)+1; 
%         Traj{iPoint} = ReconstructPointTrajectory_SumOfNorm(C, camConnect, iPoint); 
%         Traj{iPoint} = Traj{iPoint}';
    end
else
    C = SortCameraInTimeOrder(C);
    for iPoint = 1 : nPoints
        measurements = [];  P = [];  time_instants = [];
        for iCamera = 1 : length(C)
            if ~isnan(C{iCamera}.m(iPoint,1))
                P{end+1} = C{iCamera}.P;
                time_instants(end+1) = C{iCamera}.t;
                measurements(end+1,:) = C{iCamera}.m(iPoint,:);                
            end
        end

        % Cross validation --- selection of the number of basis
        max_nBasis = min(sequence_length, floor(2*(size(measurements,1)-ceil(size(measurements,1)/nFolds))/3)); % Ensure overconstrained system
        for iBasis = 1 : max_nBasis
            e_r = 0;
            for iFold = 1 : nFolds
                % Divide training set and test set
                trainingSet = 1 : length(P);
                testingSet = iFold : nFolds : length(P);

                trainingSet(testingSet) = [];
                P_train = []; P_test = []; ti_train = []; ti_test = []; m_train = []; m_test = [];
                for iCamera = 1 : length(P)
                    if find(trainingSet == iCamera)
                        P_train{end+1} = P{iCamera};
                        ti_train(end+1) = time_instants(iCamera);
                        m_train(end+1,:) = measurements(iCamera,:);
                    else
                        P_test{end+1} = P{iCamera};
                        ti_test(end+1) = time_instants(iCamera);
                        m_test(end+1,:) = measurements(iCamera,:);
                    end                    
                end
                beta_train = ReconstructPointTrajectory(P_train, ti_train, m_train, sequence_length, iBasis);
                
                for iTest = 1 : length(P_test)
                    theta = IDCT_continuous(sequence_length, ti_test(iTest));
                    theta = theta(1:iBasis);
                    X = theta * beta_train(1:end/3);
                    Y = theta * beta_train(1+end/3:2*end/3);
                    Z = theta * beta_train(1+end/3*2:end); 
                    x = P_test{iTest} * [X;Y;Z;1];
                    x = [x(1)/x(3), x(2)/x(3)];
                    e_r = e_r + norm(m_test(iTest,:)-x)^2;
                end                        
            end
            reprojection_error(iBasis) = e_r;
        end
        [dummy, idx] = min(reprojection_error);
        K_star = idx;
        Beta{iPoint} = ReconstructPointTrajectory(P, time_instants, measurements, sequence_length, K_star);
        theta = IDCTmappingMatrix(sequence_length);
        theta = theta(:,1:K_star);
        Traj{iPoint} = [theta*Beta{iPoint}(1:end/3) theta*Beta{iPoint}(1+end/3:2*end/3) theta*Beta{iPoint}(1+2*end/3:end)];
    end
end

function C1 = SortCameraInTimeOrder(C)
for iCamera = 1 : length(C)
    time(iCamera) = C{iCamera}.t;
end
[dummy, idx] = sort(time);
for iCamera = 1 : length(idx)
    C1{iCamera} = C{idx(iCamera)};
end