%% (Patrick Stadler)
clear; 
clc; 
Tlist;

%% integrating "InterpolateNan" and "RemoveOutlier" (Patrick Stadler)

% Interpolate missing values in the traces
[Xr, Yr] = InterpolateNan(Xr, Yr);
[Xy, Yy] = InterpolateNan(Xy, Yy);
[Xw, Yw] = InterpolateNan(Xw, Yw);

% Remove outliers from the traces
[Xr, Yr] = RemoveOutlier(Xr, Yr);
[Xy, Yy] = RemoveOutlier(Xy, Yy);
[Xw, Yw] = RemoveOutlier(Xw, Yw);

%% invert  (Patrick Stadler)
H = 480;
Yr = H - Yr;
Yy = H - Yy;
Yw = H - Yw;

%% integrating "GetFramme" (Patrick Stadler)

[Xmin, Xmax, Ymin, Ymax] = GetFrame(Xr, Yr, Xy, Yy, Xw, Yw);


%% creat trace for frame (Patrick Stadler)

xf = [Xmin Xmax Xmax Xmin Xmin];
yf = [Ymin Ymin Ymax Ymax Ymin];

%% integrating "GetBallPathLength" and "GetFirstMoveIdx" (Patrick Stadler)
MoveDistPx = 9;
Lr = GetBallPathLength(Xr, Yr);
Ly = GetBallPathLength(Xy, Yy);
Lw = GetBallPathLength(Xw, Yw);

[idxFirstR, DistMoveR] = GetFirstMoveIdx(Xr, Yr, MoveDistPx);
[idxFirstY, DistMoveY] = GetFirstMoveIdx(Xy, Yy, MoveDistPx);
[idxFirstW, DistMoveW] = GetFirstMoveIdx(Xw, Yw, MoveDistPx);

%% integrating "GetTouchIdx" and "GetBallMoveOrder" (Patrick Stadler)

BallBorderDist = 9;
IdxTouchR = GetTouchIdx(Xr, Yr, Xmin, Xmax, Ymin, Ymax, BallBorderDist);
IdxTouchY = GetTouchIdx(Xy, Yy, Xmin, Xmax, Ymin, Ymax, BallBorderDist);
IdxTouchW = GetTouchIdx(Xw, Yw, Xmin, Xmax, Ymin, Ymax, BallBorderDist);

[FirstBall, SecondBall, LastBall, NbBallsMoved] = GetBallMoveOrder(Xr, Yr, Xy, Yy, Xw, Yw, MoveDistPx);

if FirstBall == 1
    Xfirst = Xr;
    Yfirst = Yr;
    IdxTouchfirst = IdxTouchR;
    ColorScore = 'red';
elseif FirstBall == 2
    Xfirst = Xy;
    Yfirst = Yy;
    IdxTouchfirst = IdxTouchY;
    ColorScore = 'yellow';
else 
    Xfirst = Xw;
    Yfirst = Yw;
    IdxTouchfirst = IdxTouchW;
    ColorScore = 'white';
end

%% determin Win/lose (Patrick Stadler)

Score = GetWinnerScore(idxFirstR, idxFirstY, idxFirstW, IdxTouchfirst, NbBallsMoved);

if strcmp(Score, 'win')
    

colortouches = [1 0 0];
else
colortouches = [0 1 0];
end
%% Display the frame and traces (Patrick Stadler)

fig = figure('Color','k'); % dark background
ax = axes(fig);
set(ax,'Color','k'); 
hold(ax,'on'); 

% Frame in gray
plot(ax, xf, yf, '-', 'LineWidth', 1.5, 'Color', [0.6 0.6 0.6]);

% Traces: R, Y, W
plot(ax, Xr, Yr, 'o-', 'LineWidth', 1.6, 'Color', [1 0 0]);   % red
plot(ax, Xy, Yy, 'o-', 'LineWidth', 1.6, 'Color', [1 1 0]);   % yellow
plot(ax, Xw, Yw, 'o-', 'LineWidth', 1.6, 'Color', 'b');       % white ball (blue trace)

% Plot touches for first ball
plot(ax, Xfirst(IdxTouchfirst), Yfirst(IdxTouchfirst), 'o', ...
     'MarkerSize', 30, 'Color', colortouches);

% Plot origins
plot(ax, Xr(1), Yr(1), 'hexagram', 'MarkerSize', 20, 'Color', [1 0 0]);
plot(ax, Xy(1), Yy(1), 'hexagram', 'MarkerSize', 20, 'Color', [1 1 0]);
plot(ax, Xw(1), Yw(1), 'hexagram', 'MarkerSize', 20, 'Color', 'b');

% Design: frame sizing
axis(ax,'equal');
axis(ax,[Xmin Xmax Ymin Ymax]);

axis(ax,'off');   

title(ax, ['Scores sheet -T1 - ' datestr(now,'yyyy-mm-dd - HH:MM')], ...
    'Color', 'w', 'FontSize', 14);


%% Legend area below the frame (Patrick Stadler)

padBottom = 0.20*(Ymax - Ymin);   
axis(ax,[Xmin Xmax Ymin - padBottom Ymax]);

xl = xlim(ax);
yl = ylim(ax);

xLeft   = xl(1) + 0.05*(xl(2)-xl(1));
xCenter = xl(1) + 0.40*(xl(2)-xl(1));
xRight  = xl(1) + 0.80*(xl(2)-xl(1));
yBase   = yl(1) + 0.15*(Ymax - Ymin);

NbBandsTouched = numel(IdxTouchfirst);

% Winner section
V = [idxFirstR idxFirstY idxFirstW];
Vsort = sort(V);

if NbBallsMoved == 3   % only then Vsort has 3 elements
    count = IdxTouchfirst( (Vsort(2) < IdxTouchfirst) & (IdxTouchfirst < Vsort(3)) );
    NbBandsWin = numel(count);
else
    NbBandsWin = 0;
end

if NbBallsMoved == 3 && NbBandsWin >= 3
    Score = 'win';
else
    Score = 'lose';
end


text(xLeft, yBase, sprintf('Score sheet for "%s"', ColorScore), 'Color', 'w', 'FontSize', 12);
text(xLeft, yBase-30, sprintf('--- %s ---', Score), 'Color', 'w', 'FontSize', 12);

% Distances
text(xLeft,   yBase-80, sprintf('red_d : %.0fpx',   Lr), 'Color', 'w', 'FontSize', 12);
text(xCenter, yBase-80, sprintf('yellow_d : %.0fpx', Ly), 'Color', 'w', 'FontSize', 12);
text(xRight,  yBase-80, sprintf('white_d : %.0fpx', Lw), 'Color', 'w', 'FontSize', 12);

% Ball & band stats
text(xRight, yBase,   sprintf('%d ball(s) moved',   NbBallsMoved),   'Color', 'w', 'FontSize', 12);
text(xRight, yBase-30, sprintf('%d band(s) touched', NbBandsTouched), 'Color', 'w', 'FontSize', 12);

%% PDF (Patrick Stadler)
SeqName = 'T1';   

pdfName = sprintf('ScoreSheet%s.pdf', SeqName);
exportgraphics(fig, pdfName, 'ContentType','vector');

%% Summary (Patrick Stadler)

% Map ColorScore to char: f:[w,y,r]
switch lower(ColorScore)
    case 'white'
        fChar = 'w';
    case 'yellow'
        fChar = 'y';
    case 'red'
        fChar = 'r';
    otherwise
        fChar = 'x';   % unknown, for safety
end

% Map Score 'win'/'lose' to s:[w,l]
if strcmpi(Score, 'win')
    sChar = 'w';
else
    sChar = 'l';
end

% Round distances to integers
rb = round(Lr);
yb = round(Ly);
wb = round(Lw);

summaryStr = sprintf('f:%c; s:%c; n:%d; b:%d; rb:%d; yb:%d; wb:%d;', ...
    fChar, sChar, NbBallsMoved, NbBandsTouched, rb, yb, wb);

SummaryName = sprintf('Summary%s.txt', SeqName);

fid = fopen(SummaryName, 'w');
fprintf(fid, '%s\n', summaryStr);
fclose(fid);

%% function InterpolateNan  (Adarsh Ravikumar)

function [X, Y] = InterpolateNan(X, Y)

    if isnan(X(1)),  X(1)  = 0; end
    if isnan(X(end)),X(end)= 0; end

    defX = ~isnan(X);
    idX = 1:numel(X);
    idx_defX = find(defX);
    X =interp1(idx_defX,X(defX),idX,'next');

    if isnan(Y(1)),  Y(1)  = 0; end
    if isnan(Y(end)),Y(end)= 0; end

    defY = ~isnan(Y);
    idY = 1:numel(Y);
    idx_defY = find(defY);
    Y =interp1(idx_defY,Y(defY),idY,'next');
end
%% function RemoveOutlier  (Adarsh Ravikumar)

function [X, Y] = RemoveOutlier(X, Y)
    OX =isoutlier(X,'movmedian',10);
    OY =isoutlier(Y,'movmedian',10);

    O = OX & OY;
    idx = find(O);
    idx = idx(idx > 1);
    
    X(idx) = X(idx - 1);
    Y(idx) = Y(idx - 1);
end

%% function GetFrame  (Patrick Stadler)

function [Xmin, Xmax, Ymin, Ymax] = GetFrame(Xr, Yr, Xy, Yy, Xw, Yw)
    Xmin = min([Xr(:); Xy(:); Xw(:)], [], 'omitnan');
    Xmax = max([Xr(:); Xy(:); Xw(:)], [], 'omitnan');
    Ymin = min([Yr(:); Yy(:); Yw(:)], [], 'omitnan');
    Ymax = max([Yr(:); Yy(:); Yw(:)], [], 'omitnan');
end

%% function GetBallPathLenght (Patrick Stadler)

function PathLength = GetBallPathLength(X, Y)
    dx = diff(X); 
    dy = diff(Y);
    PathLength = sum( sqrt(dx.^2 + dy.^2) );
end

%% function GetFirstMoveIdx (Patrick Stadler)

function [FirstMoveIdx, MoveDist] = GetFirstMoveIdx(X, Y, MoveDistPx)

    X = X(:); 
    Y = Y(:);

    % 1) Distances per segment 
    MoveDist = hypot(diff(X), diff(Y));     % length = N-1

    % 2) Distance from initial position 
    DistFromStart = hypot(X - X(1), Y - Y(1));  % length = N

    FirstMoveIdx = find(DistFromStart > MoveDistPx, 1, 'first');
    if isempty(FirstMoveIdx)
        FirstMoveIdx = [];  % as required: return [] if never moved
    end
end


%% function GetTouchIdx (Leon Kesselring)

function IdxTouch = GetTouchIdx(X, Y, Xmin, Xmax, Ymin, Ymax, BallBorderDist)
%GETTOUCHIDX  Return time indices where the ball first touches a cushion.
% A "touch" happens when the ball is closer than BallBorderDist to any
% table border. Only the *first* index of each consecutive run is kept.

    if nargin < 7 || isempty(BallBorderDist)      
    BallBorderDist = 9;            
    end

    % Ensure column vectors
    X = X(:);  Y = Y(:);

    % Logical masks: near each border
    nearLeft   = (X - Xmin) < BallBorderDist;
    nearRight  = (Xmax - X) < BallBorderDist;
    nearBottom = (Y - Ymin) < BallBorderDist;
    nearTop    = (Ymax - Y) < BallBorderDist;

    % Helper: first index of every 0->1 transition (start of a "touch" run)
    firstRunIdx = @(m) find(diff([false; m(:)]) == 1);

    % Indices per border
    idxL = firstRunIdx(nearLeft);
    idxR = firstRunIdx(nearRight);
    idxB = firstRunIdx(nearBottom);
    idxT = firstRunIdx(nearTop);

    % Merge borders, sort, deduplicate
    IdxTouch = unique([idxL; idxR; idxB; idxT]);

    % Omit index 1 if present (spec requirement)
    IdxTouch(IdxTouch == 1) = [];

    % If nothing touched, IdxTouch will naturally be []
end

%% function GetBallMoveOrder (Leon Kesselring)

function [FirstBall, SecondBall, LastBall, NbBallsMoved] = ...
    GetBallMoveOrder(Xr, Yr, Xy, Yy, Xw, Yw, MoveDistPx)
%GETBALLMOVEORDER  Determine which ball moves first, second, and third.
% Balls: Red=1, Yellow=2, White=3.
%
% Ranking rules:
%   1) Primary key  : earliest FirstMoveIdx
%   2) Tie-breaker  : larger first segment distance (MoveDist(1))
%   3) Non-movers   : get index length(X)+1 (sorted to the end)
%
% Outputs:
%   FirstBall, SecondBall, LastBall : labels 1/2/3
%   NbBallsMoved : number of balls that actually moved

    % --- Gather features for each ball (idx, firstSeg, len) ---
    [idxR, segR, nR] = FirstMoveFeatures_NoNest(Xr, Yr, MoveDistPx); % Red   -> 1
    [idxY, segY, nY] = FirstMoveFeatures_NoNest(Xy, Yy, MoveDistPx); % Yellow-> 2
    [idxW, segW, nW] = FirstMoveFeatures_NoNest(Xw, Yw, MoveDistPx); % White -> 3

    ids   = [1;      2;      3     ];
    idxs  = [idxR;   idxY;   idxW  ];
    segs  = [segR;   segY;   segW  ];
    lens  = [nR;     nY;     nW    ];

    % Count movers (idx <= actual length of that ball's track)
    NbBallsMoved = sum(idxs <= lens);

    % Sort by (idx ascending, firstSeg descending)
    sortMat = [idxs, -segs];
    [~, order] = sortrows(sortMat, [1 2]);

    orderedIds = ids(order);

    FirstBall  = orderedIds(1);
    SecondBall = orderedIds(2);
    LastBall   = orderedIds(3);
end

%% helper for GetBallMoveOrder (Leon Kesselring)

function [idx, firstSeg, n] = FirstMoveFeatures_NoNest(X, Y, MoveDistPx)
%FIRSTMOVEFEATURES_NONEST Return (firstMoveIdx, firstSegmentDistance, trackLength)
% Non-movers are assigned idx = n+1 so they sort last.

    n = numel(X);

    [idxFound, moveDist] = GetFirstMoveIdx(X, Y, MoveDistPx);

    % Non-mover handling
    if isempty(idxFound) || ~isfinite(idxFound) || idxFound < 1
        idx = n + 1;   % treated as non-mover
    else
        idx = idxFound;
    end

    % Tie-breaker: first segment distance
    if isempty(moveDist)
        firstSeg = 0;
    else
        firstSeg = moveDist(1);
    end
end

%% Winner function (Patrick Stadler)

function Score = GetWinnerScore(idxFirstR, idxFirstY, idxFirstW, IdxTouchfirst, NbBallsMoved)
    V = [idxFirstR idxFirstY idxFirstW];
    Vsort = sort(V);
    
    if NbBallsMoved == 3   % only when Vsort has 3 elements
        count = IdxTouchfirst(( Vsort(2) < IdxTouchfirst) & (IdxTouchfirst < Vsort(3)) );
        NbBandsWin = numel(count);
    else
        NbBandsWin = 0;
    end
    
    if NbBallsMoved == 3 && NbBandsWin >= 3
        Score = 'win';
    else
        Score = 'lose';
    end
end
