function A = Vec2Skew(a)
% 3 x 1 vector to 3 x 3 skew-symmetric matrix for the cross product
A = [0 -a(3) a(2);
    a(3) 0 -a(1);
    -a(2) a(1) 0];