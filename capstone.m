% MATLAB script to load and process Qualisys motion capture data

data = load('toe_putter2.mat');
measurement = data.toe_putter2;

trajectories = measurement.Trajectories.Labeled.Data;
frameRate = 100;
dt = 1 / frameRate;

x_data = squeeze(trajectories(:,1,:));
y_data = squeeze(trajectories(:,2,:));
z_data = squeeze(trajectories(:,3,:));
time = (0:size(x_data, 2)-1) * dt;

% Compute velocity components
vx = diff(x_data, 1, 2) / dt;
vy = diff(y_data, 1, 2) / dt;
vz = diff(z_data, 1, 2) / dt;

% Velocity magnitude and smoothing
velocity_magnitude = sqrt(vx.^2 + vy.^2 + vz.^2);
velocity_magnitude = smoothdata(velocity_magnitude, 2, 'movmean', 3);
time_velocity = time(1:end-1);

% Acceleration magnitude and smoothing
ax = diff(vx, 1, 2) / dt;
ay = diff(vy, 1, 2) / dt;
az = diff(vz, 1, 2) / dt;
acceleration_magnitude = sqrt(ax.^2 + ay.^2 + az.^2);
acceleration_magnitude = smoothdata(acceleration_magnitude, 2, 'movmean', 3);
time_acceleration = time(1:end-2);

% Impact Detection Using Peak Ball Velocity
ball_markers = [1, 2];
ball_velocity = velocity_magnitude(ball_markers, :);
ball_speed = max(ball_velocity, [], 1);  % max speed of either ball marker at each frame

[~, impact_index] = max(ball_speed);
true_impact_frame = impact_index;
true_impact_time = time_velocity(impact_index);

fprintf('Detected impact frame from peak ball velocity: %d (time = %.3f s)\n', ...
    true_impact_frame, true_impact_time);

% Compute Putter Avg Velocity Before and Ball Velocity at Impact
club_markers = 3:size(x_data, 1);
frames_to_average = 5;
start_frame = max(1, true_impact_frame - frames_to_average + 1);
putter_velocity_segment = velocity_magnitude(club_markers, start_frame:true_impact_frame);
putter_avg_velocity_before_impact = mean(putter_velocity_segment, 2);

ball_velocity_at_impact = velocity_magnitude(ball_markers, true_impact_frame);

fprintf('\nPutter Average Velocity (last %d frames before and including impact):\n', frames_to_average);
disp(putter_avg_velocity_before_impact);

fprintf('Ball Velocity at Impact:\n');
disp(ball_velocity_at_impact);

% Plotting

colors = lines(size(x_data, 1));

% 3D marker positions at impact only
figure;
hold on;
for i = 1:size(x_data, 1)
    scatter3(x_data(i, true_impact_frame), ...
             y_data(i, true_impact_frame), ...
             z_data(i, true_impact_frame), ...
             100, colors(i, :), 'filled');
end
xlabel('X Position (mm)');
ylabel('Y Position (mm)');
zlabel('Z Position (mm)');
title(sprintf('Marker Positions at Impact (Frame %d, Time %.3f s)', ...
    true_impact_frame, true_impact_time));
grid on;
legend(arrayfun(@(i) sprintf('Marker %d', i), 1:size(x_data, 1), 'UniformOutput', false));
hold off;

% Velocity magnitude (excluding ball)
figure;
hold on;
for i = club_markers
    plot(time_velocity, velocity_magnitude(i, :), 'Color', colors(i, :), 'LineWidth', 1.5);
end
scatter(time_velocity(true_impact_frame), ...
    velocity_magnitude(club_markers(1), true_impact_frame), 100, 'r', 'filled');
xlabel('Time (s)'); ylabel('Velocity (mm/s)');
title('Velocity of Club Markers with Impact Highlighted');
grid on;
xlim([0 5.5]);  % Limit x-axis to 5.5 seconds
legend([arrayfun(@(i) sprintf('Marker %d', i), club_markers, 'UniformOutput', false), {'Detected Impact'}]);
hold off;

% Acceleration magnitude (excluding ball)
figure;
hold on;
for i = club_markers
    plot(time_acceleration, acceleration_magnitude(i, :), 'Color', colors(i, :), 'LineWidth', 1.5);
end
impact_frame_in_accel = min(true_impact_frame, size(acceleration_magnitude, 2));
scatter(time_acceleration(impact_frame_in_accel), ...
    max(acceleration_magnitude(club_markers, impact_frame_in_accel), [], 1), 100, 'r', 'filled');
xlabel('Time (s)'); ylabel('Acceleration (mm/s²)');
title('Smoothed Acceleration of Club Markers with Impact Highlighted');
grid on;
legend([arrayfun(@(i) sprintf('Marker %d', i), club_markers, 'UniformOutput', false), {'Detected Impact'}]);
hold off;

% Velocity (ball only)
figure;
hold on;
for i = ball_markers
    plot(time_velocity, velocity_magnitude(i, :), 'Color', colors(i, :), 'LineWidth', 1.5);
end
for i = ball_markers
    scatter(time_velocity(true_impact_frame), velocity_magnitude(i, true_impact_frame), 100, 'r', 'filled');
end
xlabel('Time (s)'); ylabel('Velocity (mm/s)');
title('Smoothed Velocity of Golf Ball Markers');
grid on;
legend(arrayfun(@(i) sprintf('Marker %d (Ball)', i), ball_markers, 'UniformOutput', false));
hold off;

% Acceleration (ball only)
figure;
hold on;
for i = ball_markers
    plot(time_acceleration, acceleration_magnitude(i, :), 'Color', colors(i, :), 'LineWidth', 1.5);
end
for i = ball_markers
    scatter(time_acceleration(impact_frame_in_accel), acceleration_magnitude(i, impact_frame_in_accel), 100, 'r', 'filled');
end
xlabel('Time (s)'); ylabel('Acceleration (mm/s²)');
title('Smoothed Acceleration of Golf Ball Markers');
grid on;
legend(arrayfun(@(i) sprintf('Marker %d (Ball)', i), ball_markers, 'UniformOutput', false));
hold off;

% Print velocity and acceleration at impact
fprintf('\nVelocity Magnitude at Impact (mm/s):\n');
disp(velocity_magnitude(:, true_impact_frame));

fprintf('Acceleration Magnitude at Impact (mm/s²):\n');
disp(acceleration_magnitude(:, impact_frame_in_accel));
