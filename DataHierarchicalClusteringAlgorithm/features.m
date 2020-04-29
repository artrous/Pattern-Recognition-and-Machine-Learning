% Initialize workspace
clc
clear all
load('feature1.mat');
load('feature2.mat');

% We have three different feelings
feeling1 = [feature1(1,:);feature2(1,:)]';
feeling2 = [feature1(2,:);feature2(2,:)]';
feeling3 = [feature1(3,:);feature2(3,:)]';
 
% Store both sets of points in a single matrix
X = [feeling1;feeling2;feeling3];

% Plot the labeled data points
figure('Name','Labeled Data Points')
hold on
plot(feeling1(:,1),feeling1(:,2),'*r','LineWidth',1.4);
plot(feeling2(:,1),feeling2(:,2),'*b','LineWidth',1.4);
plot(feeling3(:,1),feeling3(:,2),'*g','LineWidth',1.4);
xlabel('x1');
ylabel('x2');
grid on
hold off

% Plot the unlabeled data points
figure('Name','Unlabeled Data Points')
hold on
plot(X(:,1),X(:,2),'*k','LineWidth',1.4);
xlabel('x1');
ylabel('x2');
grid on
hold off

% Create the hierarchical clustering dendrogram
Y = pdist(X,'euclidean');   % Pairwise distance between pairs of objects
Z = linkage(Y,'average');   % Agglomerative hierarchical cluster tree
figure('Name','Hierarchical Dendrogram')
[H,T] = dendrogram(Z,0,'ColorThreshold','default');   % Create a hierarchical cluster tree using linkage. Then, plot the dendrogram using the default color threshold.
set(H,'LineWidth',2);   % Return handles to the lines so you can change the dendrogram line widths.

% Cluster data in three clusters
T = clusterdata(X,'linkage','average',3);   % Agglomerative clusters from data
figure('Name','Identified Clusters')
scatter(X(:,1),X(:,2),10,T,'filled')   % Create a scatter plot and fill in the markers. Scatter fills each marker using the color of the marker edge.
grid on