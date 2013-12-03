function error = evaluateError(DS, DSG)


lengthOfTraj = numel(DS);

error = 0;
for i = 1:lengthOfTraj
    diff = DS{i} - DSG{i};
    diff = diff';
    diff = sqrt(sum(diff.^2));
    error = error + sum(diff);
end

error = error / lengthOfTraj/ size(DS{1},1)

