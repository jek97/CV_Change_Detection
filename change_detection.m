%% Task 1: work on the videosurveillance sequence using a simple background obtained as an 
% average between two empty frames

% load two empty images
B1 = double(rgb2gray(imread('EmptyScene01.jpg')));
B2 = double(rgb2gray(imread('EmptyScene02.jpg')));

% compute a simple background model
B = 0.5*(B1 + B2);

% load each image in the sequence, perform the change detection
% show the frame, the background and the binary map
% Observe how the results change as you vary the threshold

tau = 20;

FIRST_IDX = 250; %index of first image
LAST_IDX = 320; % index of last image

for t = FIRST_IDX : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - B) > tau);
    
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(B));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    pause(0.5)

end

%% Task 2: working again on the videosurveillance sequence, use now a background model based 
% on running average to incorporate scene changes

% Let's use the first N  frames to initialize the background

FIRST_IDX = 250; %index of first image
LAST_IDX = 320; % index of last image

N = 5;

filename = sprintf('videosurveillance/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Play with these parameters
TAU = 20; 
ALPHA = 0.1;

% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;

for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);
    nMt = ones(size(Mt,1),size(Mt,2)) - Mt;
    
    % Implement the background update as a running average
    %Bcurr = % ... FILL HERE ...
    Bcurr =  nMt .* ((1-ALPHA)*Bprev+double(ALPHA*Ig)) + Mt .* Bprev;
    
    %keyboard
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(Bcurr));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    pause(0.3)
    Bprev = Bcurr;
    
end

%% Task 3: Repeat the above experiment with the sequence frames_evento1 observing what happens as you change 
% the parameters TAU and ALPHA
TAU = 15; 
ALPHA = 0.1;

% Let's use the first N  frames to initialize the background

FIRST_IDX = 4728; %index of first image
LAST_IDX = 6698; % index of last image

N = 5;

filename = sprintf('frames_evento1/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('frames_evento1/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;

for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('frames_evento1/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);
    nMt = ones(size(Mt,1),size(Mt,2)) - Mt;
    
    % Implement the background update as a running average
    %Bcurr = % ... FILL HERE ...
    Bcurr =  nMt .* ((1-ALPHA)*Bprev+double(ALPHA*Ig)) + Mt .* Bprev;
    
    %keyboard
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(Bcurr));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    pause(0.1)
    Bprev = Bcurr;
    
end

%% Task 4: Design a simple tracking system according to the following guidelines
% a. Initialize the background model 
% b. Initialize the tracking history to empty
% b. At each time instant
%       i. Apply the change detection to obtain the binary map
%      ii. Update the background model
%     iii. Identify the connected components in the binary map (see e.g.
%          the matlab function bwconncomp)
%      iv. Try to associate each connected component with a previously seen
%          target
% Hint 1 - It would be good to keep track of the entire trajectory and produce a visualization 
% that can be done either frame by frame (so you should see the trajectory built
% incrementally) or only at the end (in this case you will see the entire final trajectory)
% Hint 2 - How to decide that a trajectory is closed?
% on running average to incorporate scene changes

clc
clear all

% initialize the obj struct:
obj.center = [];
obj.bb = [];
obj.ID = "ID0";
obj.frame = 0;
obj_id = [];

% initialize the counters:
id_count = 1;
counter = 1;
count_id = 1;

FIRST_IDX = 250; %index of first image
LAST_IDX = 320; % index of last image

N = 5;

filename = sprintf('videosurveillance/frame%4.4d.jpg', FIRST_IDX);
B = double(rgb2gray(imread(filename)));
for t = FIRST_IDX+1 : FIRST_IDX + N-1
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    B = B + double(rgb2gray(imread(filename)));
    
end

B = B / N;

% Play with these parameters
TAU = 20; 
ALPHA = 0.1;

% Now start the change detection while updating the background with the
% running average. For that you have to set the values for TAU and ALPHA

Bprev = B;

for t = FIRST_IDX+N : LAST_IDX
    
    filename = sprintf('videosurveillance/frame%4.4d.jpg', t);
    
    It = imread(filename);
    Ig = rgb2gray(It);
    
    Mt = (abs(double(Ig) - Bprev) > TAU);
    nMt = ones(size(Mt,1),size(Mt,2)) - Mt;
    
    % Implement the background update as a running average
    %Bcurr = % ... FILL HERE ...
    Bcurr =  nMt .* ((1-ALPHA)*Bprev+double(ALPHA*Ig)) + Mt .* Bprev;
    % obtain the connected components of the scene
    CC = bwconncomp(Mt);
    obj_prop = regionprops(CC,"Centroid","BoundingBox","Area");

    % recognize the objects:
    for j = 1:size(obj_prop)
        if obj_prop(j).Area >= 400
            if counter == 1
                obj(counter).center = obj_prop(j).Centroid;
                obj(counter).bb = obj_prop(j).BoundingBox;
                obj(counter).ID = id_count;
                obj(counter).frame = t;
                id_count = id_count + 1;
                counter = counter + 1;
            else
                obj(counter).center = obj_prop(j).Centroid;
                obj(counter).bb = obj_prop(j).BoundingBox;
                obj(counter).frame = t;
                for i = 1:counter-1
                    dist(i) = abs(sqrt(((obj(counter).center(1)-obj(i).center(1))^2)-((obj(counter).center(2)-obj(i).center(2))^2)))/(obj(counter).frame - obj(i).frame);
                    [min_d, min_d_counter] = min(dist);
                end
                if min_d < 50
                    obj(counter).ID = min_d_counter;
                    counter = counter + 1;
                else
                    obj(counter).ID = id_count;
                    id_count = id_count + 1;
                    counter = counter + 1;
                end
            end
        end
    end
    subplot(1, 3, 1), imshow(It);
    subplot(1, 3, 2), imshow(uint8(Bcurr));
    subplot(1, 3, 3), imshow(uint8(Mt*255));
    hold on;
    for i = 1 : size(obj, 2)
        if obj(i).frame == t
            plot(obj(i).center(1,1),obj(i).center(1,2), 'r+', 'LineWidth', 1, 'MarkerSize', 5);
            rectangle("Position", obj(i).bb, "EdgeColor", 'r');
            text(obj(i).bb(1,1)+5, obj(i).bb(1,2)+5, ['ID' num2str(obj(i).ID,'%d')],'color', 'r','FontSize',5);
            hold on;
        end
    end
    pause(0.5)
    hold off;
end
