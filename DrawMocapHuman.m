function h = DrawMocapHuman(X, marker, h)

for j = 1 : 13
    p(j,:) = [X(j, 1), X(j, 2), X(j, 3)];
end
x1 = [p(9,:); p(8,:); p(7,:); p(2,:); p(4,:); p(5,:); p(6,:)];
x2 = [p(3,:); p(2,:); p(1,:); p(10,:); p(11,:)];
x3 = [p(1,:); p(12,:); p(13,:)];
if nargin < 3
    hold on,
    h(1) = plot3(x1(:,1), x1(:,2), x1(:,3), marker, 'LineWidth', 3, 'MarkerSize',8); hold on,
    h(2) = plot3(x2(:,1), x2(:,2), x2(:,3), marker, 'LineWidth', 3, 'MarkerSize',8); hold on,
    h(3) = plot3(x3(:,1), x3(:,2), x3(:,3), marker, 'LineWidth', 3, 'MarkerSize',8);
else
    set(h(1), 'XData', x1(:,1), 'YData', x1(:,2), 'ZData', x1(:,3));
    set(h(2), 'XData', x2(:,1), 'YData', x2(:,2), 'ZData', x2(:,3));
    set(h(3), 'XData', x3(:,1), 'YData', x3(:,2), 'ZData', x3(:,3));
end