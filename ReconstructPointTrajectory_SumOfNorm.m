function  points3D = ReconstructPointTrajectory_SumOfNorm(C, camConnect, pointIdx)

numOfCameras = numel(C);

cameraCenterMatrix = zeros( 3, numOfCameras);
directionMatrix = zeros(3, numOfCameras);


for i = 1: numOfCameras
   cameraCenterMatrix(:, i) = C{i}.C;
   
%    compute the direction:
    K = C{i}.K; focalLength = (K(1,1) + K(2,2))/2;
    measure = [C{i}.m(pointIdx, :)'; 1];
    measure =  inv(K)*measure;
    measure = [C{i}.R',C{i}.C]*[measure; 1];
    
    direction = measure - C{i}.C;
    direction = direction/norm(direction);
    directionMatrix(:, i) = direction;    
end

cvx_begin
    variable x(numOfCameras,1);
    pts = cameraCenterMatrix + directionMatrix .* repmat(x', 3,1);
    allSum = 0;
    for i = 1:size(camConnect, 1)        
        allSum = allSum + sum( square(  pts(:, camConnect(i,1) ) - pts(:, camConnect(i,2))  ));    
%          allSum = allSum + norm( pts(:, camConnect(i,1) ) - pts(:, camConnect(i,2) ) );
    end
    minimize allSum;
%     subject to 
%         x>=0;
cvx_end
    
points3D = cameraCenterMatrix + directionMatrix .* repmat(x', 3,1);























