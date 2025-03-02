function Phantom3DProject(beamEnergy, xrayAngle, phantomToFilm, phantomToSource)
    arguments% Parameter Initialization
        beamEnergy = 15; % Beam energy in keV (15,19,26)
        xrayAngle = 40; % X-ray cone angle in degrees (40-60)
        phantomToFilm = 60; % Distance of the film from the phantom in cm (0-60)
        phantomToSource = 60; % Distance of the x-ray source from the phantom in cm (0-60)
    end

    wallHeight = 120; 
    wallWidth = 120; 
    wallThickness = 10; 
    phantomCenter = [60, 60, 70]; 
    radiusBreast = 20; 
    radiusLesion = 8; 
    filmSize = [wallWidth, wallHeight]; 
    
    % Get µ Values Based on Beam Energy
    [breastIntensity, lesionIntensity] = getAttenuationCoefficients(beamEnergy);
    
    wall3D = zeros(wallHeight, wallWidth, wallThickness); 
    
    [x, y, z] = ndgrid(1:wallWidth, 1:wallHeight, 1:wallThickness + 100); 
    distanceBreast = sqrt((x-phantomCenter(1)).^2 + (y-phantomCenter(2)).^2 + (z-phantomCenter(3)).^2);
    distanceLesion = sqrt((x-phantomCenter(1)).^2 + (y-phantomCenter(2)).^2 + (z-phantomCenter(3)).^2);
    
    % Create 3D Phantom
    phantom3D = zeros(size(distanceBreast)); 
    
    % Left Side
    phantom3D(distanceBreast <= radiusBreast & x <= phantomCenter(1)) = breastIntensity;
    phantom3D(distanceLesion <= radiusLesion & x <= phantomCenter(1)) = lesionIntensity;   
    
    % Right Side
    phantom3D(distanceBreast <= radiusBreast & x > phantomCenter(1)) = breastIntensity; 
    phantom3D(distanceLesion <= radiusLesion & x > phantomCenter(1)) = lesionIntensity;     
    
    % Visualization
    figure;
    hold on;
    
    % Wall (background)
    [xWall, yWall, zWall] = ndgrid(1:wallWidth, 1:wallHeight, 1:wallThickness);
    isosurface(xWall, yWall, zWall, wall3D, 0.1);
    p = patch(isosurface(xWall, yWall, zWall, wall3D, 0.1));
    set(p, 'FaceColor', [0.9, 0.9, 0.9], 'EdgeColor', 'none'); 
    
    % Breast Sphere
    breastSurf = isosurface(x, y, z, distanceBreast, radiusBreast);
    
    % Extract Vertices and Faces
    vertices = breastSurf.vertices;
    faces = breastSurf.faces;
    
    % Left Side
    leftVerticesIdx = find(vertices(:, 1) <= phantomCenter(1));
    leftVertices = vertices(leftVerticesIdx, :);
    [~, newIdx] = ismember(faces, leftVerticesIdx); 
    leftFaces = newIdx(all(newIdx > 0, 2), :); 
    pLeft = patch('Vertices', leftVertices, 'Faces', leftFaces, 'FaceColor', [breastIntensity, breastIntensity, breastIntensity], ...
        'EdgeColor', 'none', 'FaceAlpha', 1); 
    
    % Right Side
    rightVerticesIdx = find(vertices(:, 1) > phantomCenter(1));
    rightVertices = vertices(rightVerticesIdx, :);
    [~, newIdx] = ismember(faces, rightVerticesIdx);
    rightFaces = newIdx(all(newIdx > 0, 2), :); 
    pRight = patch('Vertices', rightVertices, 'Faces', rightFaces, 'FaceColor', [breastIntensity, breastIntensity, breastIntensity], ...
        'EdgeColor', 'none', 'FaceAlpha', 0.2); 
    
    % Lesion Sphere
    lesionSurf = isosurface(x, y, z, distanceLesion, radiusLesion); 
    pLesion = patch(lesionSurf);
    set(pLesion, 'FaceColor', [lesionIntensity, lesionIntensity, lesionIntensity], 'EdgeColor', 'none', 'FaceAlpha', 1.0); 
    
    % Film (visualized as a flat plane)
    [xFilm, yFilm] = meshgrid(1:filmSize(1), 1:filmSize(2));
    zFilm = ones(size(xFilm)) * (phantomCenter(3) - phantomToFilm); 
    surf(xFilm, yFilm, zFilm, 'FaceColor', [0.3, 0.3, 0.3], 'EdgeColor', 'none'); 
    
    % X-Ray Source (Adjust for Distance)
    xraySourceZ = phantomCenter(3) + phantomToSource; 
    plot3(phantomCenter(1), phantomCenter(2), xraySourceZ, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', [0.5, 0.5, 0.5]); 
    
    % X-Ray Cone (Touches Film as Base)
    coneBaseRadius = tan(deg2rad(xrayAngle/2)) * (phantomToSource + phantomToFilm); 
    [xCone, yCone, zCone] = cylinder([0, coneBaseRadius], 50); 
    zCone = -zCone * (phantomToSource + phantomToFilm) + xraySourceZ; 
    xCone = xCone + phantomCenter(1);
    yCone = yCone + phantomCenter(2);
    surf(xCone, yCone, zCone, 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'FaceColor', [0.5, 0.5, 0.5]);

    % Adjust View and Lighting
    view(3);
    axis equal;
    grid on;
    xlabel('X-axis');
    ylabel('Y-axis');
    zlabel('Z-axis');
    title(['3D Phantom Breast (Beam Energy: ', num2str(beamEnergy), ' keV)']);
    lighting gouraud;
    camlight;

    generateMammogram(phantom3D, beamEnergy, phantomCenter, phantomToSource, phantomToFilm, xrayAngle);

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