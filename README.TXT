######################################################################################################################################################
3D trajectory reconstuction code
Written by Hyun Soo Park
hyunsoop@cs.cmu.edu
######################################################################################################################################################
Paper: "3D Reconstruction of a Moving Point from a Series of 2D Projections (ECCV 2010)"
Authors: Hyun Soo Park, Takaaki Shiratori, Iain Matthews, and Yaser Sheikh
Project page: http://www.andrew.cmu.edu/user/hyunsoop/eccv2010/eccv_project_page.html
######################################################################################################################################################
- Core algorithm
[Traj, Beta] = TrajectoryReconstruction(C, K)

INPUT:
Each cell C contains camera projection matrix, time instance, and 2D correspondences.
    C{i}.P: 3 x 4 projection matrix
    C{i}.t: time instance that the image is taken
    C{i}.m: p x 2 matrix where p is the number of correspondences, i.e, m = [x(1) y(1); ... ; x(p) y(p)]
    if there is a missing correspondence, you should set the corresponding point as [x y] = [NaN NaN]
K is the number of basis (optional, default = -1 (automatic selection) -- let the algorithm decide)
OUTPUT:
Traj is a set of the reconstructed trajectories.
Each Traj{i} are F x 3 matrix, i.e, [X Y Z] where F is the number of time step specified by dT
Beta is a set of the coeffient of a trajectory.
Beta{i} is K x 3 dimensional vector, [beta_x beta_y beta_z], of the i-th trajectory where 1 <= i <= p. 

######################################################################################################################################################
- Motion capture data demo 
Availalble data: stand_data.mat, walk_data.mat, and 
ex) MotionCaptureReconstructionDemo('stand_data.mat')

######################################################################################################################################################
- Real scene data demo
Available data: CameraData_RockClimbing.txt, CameraData_Meeting.txt, CameraData_Speech.txt, CameraData_Dance.txt, and CameraData_HandWave.txt
Ex> RealSceneReconstructionDemo('CameraData_Speech.txt')

######################################################################################################################################################
CameraData format
1st line: The number of projections (images or cameras)
2nd line: The number of moving points
rest line:
(image_ID) (time instant)
(camera center position in 3D)
(camera rotation matrix 3x3)
(camera intrinsic matrix 3x3)
(u_1 v_1) (u_2 v_2) (u_3 v_3) ... (u_nPoints v_nPoints)

image_ID: this ID corresponds to image file name, ex> 2_1 corresponds 2_1.jpg
time instant: time instant the image was taken (extracted from EXIF data)
camera center position in 3D: 3D coordinate of camera center
camera rotation matrix: 3x3 orthogonal matrix
camera intrinsic matrix: 3x3 intrinsic parameter (focal length and principle coordinates)
(u_1 v_1) (u_2 v_2) (u_3 v_3) ... (u_nPoints v_nPoints): 2D projections (image measurements of moving points, 2xnPoints, If the point is invisible, u, v are set to -1.)
