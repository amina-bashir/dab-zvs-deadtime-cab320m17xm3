%% ======================================================================
%  coss_setup.m
%
%  Datasheet Coss of the Wolfspeed CAB320M17XM3 for the Simulink Coss blocks
%  (+zvslib/coss_datasheet.ssc). Smoothing IDENTICAL to the T1/T4 evaluators:
%    digitized points -> 70 log-spaced bins (median), forced non-increasing,
%    pchip in log-log, 5 mV table over 0-1700 V (held constant below the first bin)
%  The Simscape block gets a 1000-point version of that table:
%    COSS_V = [0, 999 log-spaced points 0.01-1700 V],  COSS_C = C at COSS_V
%  (linear interpolation in the block; vs the 5 mV table: C within 0.06 %,
%   charge within 0.001 %). Set in all 8 Coss blocks: Vtab = COSS_V, Ctab = COSS_C.
%
%  Needs : CAB320M17XM3_Coss.csv
%  Output: COSS_V [V], COSS_C [F], COSS_TAB (5 mV table, for the checks) in the workspace
% ======================================================================
d  = readmatrix('CAB320M17XM3_Coss.csv');   Vd = d(:,1);   Cd = d(:,2)*1e-9;
ed = [min(Vd), logspace(0, log10(max(Vd)), 70)];
vb = [];  cb = [];
for k = 1:numel(ed)-1
    m = Vd >= ed(k) & Vd < ed(k+1);
    if nnz(m) >= 2, vb(end+1) = median(Vd(m)); cb(end+1) = median(Cd(m)); end %#ok<SAGROW>
end
cb = cummin(cb);
COSS_TAB.dV = 0.005;   COSS_TAB.V = 0:COSS_TAB.dV:1700;
COSS_TAB.C  = exp(pchip(log(vb), log(cb), log(min(max(COSS_TAB.V, vb(1)), vb(end)))));
COSS_TAB.Q  = cumtrapz(COSS_TAB.V, COSS_TAB.C);                 % charge Qc(v) = int_0^v Coss
COSS_V = [0, logspace(log10(0.01), log10(1700), 999)];   COSS_V(end) = 1700;
COSS_C = interp1(COSS_TAB.V, COSS_TAB.C, COSS_V);
clear d Vd Cd ed vb cb k m
fprintf('Coss table for the Simulink blocks: %d points | 10 V %.3f nF, 100 V %.3f nF, 400 V %.3f nF, 800 V %.3f nF, 1000 V %.3f nF\n', ...
        numel(COSS_V), 1e9*interp1(COSS_V,COSS_C,[10 100 400 800 1000]));
