function Phantom2DProject(beamEnergy, xrayAngle, phantomToFilm, phantomToSource)
    arguments % Parameter Initialization
        beamEnergy = 15; % Beam energy in keV (15,19,26)
        xrayAngle = 50; % X-ray cone angle in degrees (40-60)
        phantomToFilm = 30; % Distance of the film from the phantom in cm (0-60)
        phantomToSource = 40; % Distance of the x-ray source from the phantom in cm (0-60)
    end
    
    gridSize = 120; 
    phantomCenter = [60, 70]; 
    radiusBreast = 20; 
    radiusLesion = 8; 
    
    % Get µ Values Based on Beam Energy
    [breastIntensity, lesionIntensity] = getAttenuationCoefficients(beamEnergy);
    
    % X-Ray Source Position
    xraySource = [60, phantomCenter(2) + phantomToSource]; 
    
    % Beam Geometry (Cone)
    coneBaseWidth = 2 * (tan(deg2rad(xrayAngle / 2)) * phantomToSource); 
    coneBaseX = [xraySource(1) - coneBaseWidth/2, xraySource(1) + coneBaseWidth/2]; 
    coneBaseZ = [phantomCenter(2) - phantomToFilm, phantomCenter(2) - phantomToFilm]; 
    
    % Film 
    filmX = [coneBaseX(1), coneBaseX(2)]; 
    filmZ = [coneBaseZ(1), coneBaseZ(1)];
    
    % Visualization
    figure;
    hold on;
    
    % X-Ray Cone
    fill([xraySource(1), coneBaseX(1), coneBaseX(2)], ...
         [xraySource(2), coneBaseZ(1), coneBaseZ(2)], ...
         [0.8, 0.8, 0.8], 'FaceAlpha', 0.2, 'EdgeColor', 'none'); 
    
    % Breast Circle (Vertically Split)
    theta = linspace(0, 2*pi, 100);
    xBreast = phantomCenter(1) + radiusBreast * cos(theta);
    zBreast = phantomCenter(2) + radiusBreast * sin(theta);
    
    % Left Half: Solid Outer Sphere
    fill(xBreast(xBreast <= phantomCenter(1)), zBreast(xBreast <= phantomCenter(1)), ...
         [breastIntensity, breastIntensity, breastIntensity], 'FaceAlpha', 1, 'EdgeColor', 'none'); 
    
    % Right Half: Transparent Outer Sphere with Lesion
    fill(xBreast(xBreast > phantomCenter(1)), zBreast(xBreast > phantomCenter(1)), ...
         [breastIntensity, breastIntensity, breastIntensity], 'FaceAlpha', 0.2, 'EdgeColor', 'none'); 
    
    % Lesion Circle: Inner Sphere on Right Side Only
    theta = linspace(0, 2*pi, 100);
    xLesion = phantomCenter(1) + radiusLesion * cos(theta);
    zLesion = phantomCenter(2) + radiusLesion * sin(theta);
    fill(xLesion(xLesion > phantomCenter(1)), zLesion(xLesion > phantomCenter(1)), ...
         [lesionIntensity, lesionIntensity, lesionIntensity], 'EdgeColor', 'none');
    fill(xLesion(xLesion < phantomCenter(1)), zLesion(xLesion < phantomCenter(1)), ...
         [lesionIntensity, lesionIntensity, lesionIntensity], 'EdgeColor', 'none'); 
    
    % Film
    plot(filmX, filmZ, 'k-', 'LineWidth', 3); 
    
    % X-Ray Source
    plot(xraySource(1), xraySource(2), 'ko', 'MarkerSize', 8, 'MarkerFaceColor', [0.5, 0.5, 0.5]); 
    
    % Adjust Visualization
    axis equal;
    xlim([0, gridSize]);
    ylim([0, gridSize + 20]);
    axis on; 
    title(['2D Phantom with Vertically Split Sphere (Beam Energy: ', num2str(beamEnergy), ' keV)']);
    
    % Function to Get Intensity values (I = I0 * exp(-attenuation coefficient * thickness)
    function [breastIntensity, lesionIntensity] = getAttenuationCoefficients(beamEnergy)
        if beamEnergy == 15
            breastIntensity = 15 * exp(-0.794 * 40); 
            lesionIntensity = 15 * exp(-1.608 * 16); 
        elseif beamEnergy == 19
            breastIntensity = 19 * exp(-0.488 * 40); 
            lesionIntensity = 19 * exp(-0.920 * 16); 
        elseif beamEnergy == 26
            breastIntensity = 26 * exp(-0.303 * 40); 
            lesionIntensity = 26 * exp(-0.483 * 16); 
        else
            error('Beam energy must be 15, 19, or 26 keV.');
        end
    end
end
