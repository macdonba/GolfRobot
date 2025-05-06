data = load('Measurement2.mat');
measurement = data.Measurement2;

trajectories = measurement.Trajectories.Labeled.Data;
frameRate = 100;

dt = 1 / frameRate;
time = (0:size(trajectories, 3)-1) * dt;

x_data = squeeze(trajectories(:,1,:));
y_data = squeeze(trajectories(:,2,:));
z_data = squeeze(trajectories(:,3,:));

figure;
hold on;
colors = lines(size(x_data, 1));
h = gobjects(size(x_data, 1), 1);
textHandle = text(min(x_data(:)), min(y_data(:)), max(z_data(:)), '', 'FontSize', 12, 'FontWeight', 'bold');

for i = 1:size(x_data, 1)
    h(i) = plot3(NaN, NaN, NaN, 'o', 'Color', colors(i, :), 'MarkerSize', 8, 'MarkerFaceColor', colors(i, :));
end

xlabel('X Position (mm)');
ylabel('Y Position (mm)');
zlabel('Z Position (mm)');
title('Marker Motion Animation');
grid on;
xlim([min(x_data(:)) max(x_data(:))]);
ylim([min(y_data(:)) max(y_data(:))]);
zlim([min(z_data(:)) max(z_data(:))]);

for frame = 1:size(x_data, 2)
    for i = 1:size(x_data, 1)
        set(h(i), 'XData', x_data(i, frame), 'YData', y_data(i, frame), 'ZData', z_data(i, frame));
    end
    set(textHandle, 'String', sprintf('Time: %.2f s', time(frame)));
    pause(0.01);
end

hold off;

