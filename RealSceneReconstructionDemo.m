function RealSceneReconstructionDemo(filename)

% Real scene demo
% Paper: "3D Reconstruction of a Moving Point from a Series of 2D Projections (ECCV)"
% Authors: Hyun Soo Park, Takaaki Shiratori, Iain Matthews, and Yaser Sheikh
% Please refer to
% http://www.andrew.cmu.edu/user/hyunsoop/eccv2010/eccv_project_page.html

% This script reads motion capture data, generates a random camera trajectory, reconstructs point trajectories, and animate the motion.
% Ex> RealSceneReconstructionDemo('CameraData_Speech.txt')
% You can set the number of basis.
% When you do not know the number of basis, you can set nBasis = -1. (Let the system decide.)

nBasis = 15;
C = LoadCameraData('CameraData_RockClimbing.txt');

% Reconstruct point trajectories
[Traj] = TrajectoryReconstruction(C, nBasis);

for i = 1 : size(Traj{1},1)
    ds = [];
    for j = 1 : length(Traj)
        ds = [ds; Traj{j}(i,:)];
    end
    DS{i} = ds;
end

% Animate result
figure(1), clf;
for i = 1 : length(DS)
    if i == 1
        h = plot3(DS{i}(:,1),DS{i}(:,2),DS{i}(:,3), 'bx');
    else
        set(h, 'XData', DS{i}(:,1), 'YData', DS{i}(:,2), 'ZData', DS{i}(:,3));
    end
    axis off, axis equal
    drawnow
    pause(0.5);
end

function C = LoadCameraData(filename)
fid = fopen(filename, 'r');
fscanf(fid, '%s', 1); nC = fscanf(fid, '%d', 1);
fscanf(fid, '%s', 1); nPoints = fscanf(fid, '%d', 1);
for iC = 1 : nC
    C{iC}.id = fscanf(fid, '%s', 1);
    C{iC}.t = fscanf(fid, '%f', 1);
    c = fscanf(fid, '%f', 3);
    R = fscanf(fid, '%f %f %f', [3,3])';
    K = fscanf(fid, '%f %f %f', [3,3])';
    C{iC}.P = K*R*[eye(3) -c];
    m = fscanf(fid, '%f', 2*nPoints);
    idx = find(m == -1);
    m(idx) = NaN;
    C{iC}.m = reshape(m,2,nPoints)';
end
fclose(fid);
