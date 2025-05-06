heel =  939.1761 / 665.45;
midheel =  1054.1 / 651.64;
middle =  1099.8 / 653.758;
midtoe =  1074.2 / 650.06;
toe =  991 / 662.89;

heel1 =  1092.3 / 801.97;
midheel1 =  1243.8 / 766.09;
middle1 =  1351.9 / 785.51;
midtoe1 =  1258.8 / 785.09;
toe1 =  1055.45 / 794.83;

putter1 = [heel midheel middle midtoe toe];
putter2 = [heel1 midheel1 middle1 midtoe1 toe1];
x = linspace(1, 11, 5);

% Generate finer x values for smooth plot
xq = linspace(1, 11, 100);

% Interpolate using spline method
putter1_smooth = interp1(x, putter1, xq, 'spline');
putter2_smooth = interp1(x, putter2, xq, 'spline');

% Plot
figure
hold on
%plot(xq, putter1_smooth, 'b-', 'LineWidth', 2)
plot(xq, putter2_smooth, 'r-', 'LineWidth', 2)
legend('putter 2')
title('Smash Factor of putter 2')
xlabel('Position')
ylabel('Smash Factor')
grid on
