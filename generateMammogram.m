function generateMammogram(phantom3D, beamEnergy, phantomCenter, phantomToSource, phantomToFilm, xrayAngle)
    
    % Get dimensions of the phantom
    [height, width, depth] = size(phantom3D);

    % Define the X-ray source position
    xraySource = [phantomCenter(1), phantomCenter(2), phantomCenter(3) + phantomToSource];

    % Calculate the cone's base radius at the phantom
    coneRadiusAtPhantom = tan(deg2rad(xrayAngle / 2)) * phantomToSource;

    % Initialize the film (2D projection)
    filmProjection = zeros(height, width);

    % Loop over each pixel on the film and check if it's within the cone's scope
    for i = 1:height
        for j = 1:width
            % Calculate the position of the current pixel on the film
            pixelPosition = [i, j, phantomCenter(3) - phantomToFilm];

            % Calculate the vector from the X-ray source to the pixel
            vectorToPixel = pixelPosition - xraySource;

            % Project the vector onto the X-Y plane
            distanceToCenter = sqrt(vectorToPixel(1)^2 + vectorToPixel(2)^2);

            % Check if the pixel is within the X-ray cone
            if distanceToCenter <= coneRadiusAtPhantom
                % Integrate attenuation along the Z-axis through the phantom
                for z = 1:depth
                    filmProjection(i, j) = filmProjection(i, j) + phantom3D(i, j, z);
                end
            else
                % Outside the phantom, set the projection value to 0
                filmProjection(i, j) = NaN; % Represent as no signal
            end
        end
    end

    % Convert attenuation to intensity
    filmImage = exp(filmProjection); % Simulated X-ray intensity
    filmImage(isnan(filmImage)) = 0.5; % Set the background signal to 0

    % Display
    figure;
    imagesc(filmImage);
    colormap(gray);
    colorbar;
    title(['Simulated Mammogram within X-Ray Cone (Beam Energy: ', num2str(beamEnergy), ' keV)']);
    xlabel('X-axis (pixels)');
    ylabel('Y-axis (pixels)');
    axis equal;
    axis tight;
end
