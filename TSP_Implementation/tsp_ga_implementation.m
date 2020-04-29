function varargout = tsp_ga(xy,dmat,popSize,numIter,showProg,showResult)

% Revenue Processing, Initializing Price and Checks
nargs = 6;
for k = nargin:nargs-1
    switch k
        case 0
            xy = 10*rand(50,2);
        case 1
            N = size(xy,1);
            a = meshgrid(1:N);
            dmat = reshape(sqrt(sum((xy(a,:)-xy(a',:)).^2,2)),N,N);
        case 2
            popSize = 100;
        case 3
            numIter = 1e4;
        case 4
            showProg = 1;
        case 5
            showResult = 1;
        otherwise
    end
end

% Input Price Check/Confirmation
[N,dims] = size(xy);
[nr,nc] = size(dmat);
if N ~= nr || N ~= nc
    error('Invalid XY or DMAT inputs!')
end
n = N;
 
% Logical Controls
popSize = 4*ceil(popSize/4);
numIter = max(1,round(real(numIter(1))));
showProg = logical(showProg(1));
showResult = logical(showResult(1));

% Population Initialization (Step 1)
pop = zeros(popSize,n);
pop(1,:) = (1:n);
for k = 2:popSize
    pop(k,:) = randperm(n);   % Installation of Cities by Random Transfer
end

% Execution of a Genetic Algorithm
globalMin = Inf;
totalDist = zeros(1,popSize);
distHistory = zeros(1,numIter);
tmpPop = zeros(4,n);
newPop = zeros(popSize,n);
if showProg
    pfig = figure('Name','TSP_GA | Current Best Solution','Numbertitle','off');
end
for iter = 1:numIter   % Initiation of Genetic Algorithm Repetitions
% Evaluation of each Population Member (Total Distance Calculation)
    for p = 1:popSize
        d = dmat(pop(p,n),pop(p,1));   % Closed Path, for p = 1 we have Initialization with City distance 1 from city n
        for k = 2:n
            d = d + dmat(pop(p,k-1),pop(p,k));   % Add Selected Distance Distances
        end
        totalDist(p) = d;   % Total Route Storage p
    end

    % Finding the Optimal Route from the Population
    [minDist,index] = min(totalDist);
    distHistory(iter) = minDist;
    if minDist < globalMin
        globalMin = minDist;
        optRoute = pop(index,:);   % Best Route Storage
        if showProg
            % Display Plot of the Best Route
            figure(pfig);
            rte = optRoute([1:n 1]);
            if dims > 2, plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-');
            else plot(xy(rte,1),xy(rte,2),'r.-');
            end
            title(sprintf('Total Distance = %1.4f, Iteration = %d',minDist,iter));
        end
    end

    % Genetic Algorithm Operators (Step 3)
    randomOrder = randperm(popSize);
    for p = 4:4:popSize
        rtes = pop(randomOrder(p-3:p),:);
        dists = totalDist(randomOrder(p-3:p));
        [ignore,idx] = min(dists);
        bestOf4Route = rtes(idx,:);
        routeInsertionPoints = sort(ceil(n*rand(1,2)));
        I = routeInsertionPoints(1);
        J = routeInsertionPoints(2);
        for k = 1:4   % Mutation of the Best Route to produce three new routes
            tmpPop(k,:) = bestOf4Route;
            switch k
                case 2   % Flip (Inversion)
                    tmpPop(k,I:J) = tmpPop(k,J:-1:I);
                case 3   % Swap (Exchange)
                    tmpPop(k,[I J]) = tmpPop(k,[J I]);
                case 4   % Slide (Turns the points to the right (Slide))
                    tmpPop(k,I:J) = tmpPop(k,[I+1:J I]);
                otherwise   % Do Nothing (No change)
            end
        end
        newPop(p-3:p,:) = tmpPop;
    end
    pop = newPop;
end
% Completion of Genetic Algorithm Repetitions (Step 4)

if showResult
    % Displays the Diagrams of the Results of the Genetic Algorithm
    figure('Name','TSP_GA | Results','Numbertitle','off');
    subplot(2,2,1);
    pclr = ~get(0,'DefaultAxesColor');
    if dims > 2, plot3(xy(:,1),xy(:,2),xy(:,3),'.','Color',pclr);
    else plot(xy(:,1),xy(:,2),'.','Color',pclr);
    end
    title('City Locations');
    subplot(2,2,2);
    imagesc(dmat(optRoute,optRoute));
    title('Distance Matrix');
    subplot(2,2,3);
    rte = optRoute([1:n 1]);
    if dims > 2, plot3(xy(rte,1),xy(rte,2),xy(rte,3),'r.-');
    else plot(xy(rte,1),xy(rte,2),'r.-');
    end
    title(sprintf('Total Distance = %1.4f',minDist));
    subplot(2,2,4);
    plot(distHistory,'b','LineWidth',2);
    title('Best Solution History');
    set(gca,'XLim',[0 numIter+1],'YLim',[0 1.1*max([1 distHistory])]);
end

% Return of Results (Exits)
if nargout
    varargout{1} = optRoute;
    varargout{2} = minDist;
end