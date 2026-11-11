# An Exact Discrete-Time Small-Signal Model and PI Current Control of a Triple-Phase-Shift Dual Active Bridge for EV Charging (G2V / V2G)

An exact discrete-time model of a dual active bridge with triple-phase-shift (TPS) modulation, its small-signal model, and a PI current controller for the battery-side current, for charging (G2V) and discharging (V2G). One formulation covers all twelve TPS operating modes. The exact model matches a Simscape Electrical switching model to within 0.12 % of peak in all five states; the small-signal model matches the exact model to within 1.14 % in a step test in every mode; one PI design per power direction is stable in all six V2G modes and in five of the six G2V modes.

## Skills Used

- Power Electronics Modelling (Dual Active Bridge, Triple-Phase-Shift)
- EV Charging Power Conversion (G2V / V2G)
- Discrete-Time and State-Space Modelling
- Small-Signal Analysis and Linearisation
- Digital Control (PI current loop)
- Stability Analysis (margins, closed-loop poles)
- Circuit Simulation and Verification (Simulink / Simscape Electrical)
- MATLAB (Control System Toolbox)

## Project Overview

The converter is a dual active bridge between an 800 V DC link and a battery, with LC filters on both sides and the link inductance on the primary side. It transfers power in both directions: charging the battery (G2V) and feeding power back (V2G). Triple-phase-shift modulation sets the eight switching edges of each period through three phase shifts: D1 inside the primary bridge, D2 inside the secondary bridge and D3 between the bridges. The current to the battery is controlled through D3.

Targets of the work:

- One model for all twelve TPS modes (six G2V, six V2G), with no mode-by-mode equations
- Exact switching behaviour over a period, including the input and output filters
- The small-signal model from D1, D2, D3 and both port voltages to the battery-side current
- A PI current controller designed on that model and checked across all twelve modes
- Verification against a circuit-level Simscape model

| Parameter | Symbol | Value |
|---|---|---|
| DC-link voltage | V<sub>1</sub> | 800 V |
| Battery voltage (analysis point) | V<sub>2</sub> | 800 V |
| Switching frequency | f<sub>s</sub> | 50 kHz |
| Transformer turns ratio | n = N<sub>p</sub>/N<sub>s</sub> | 1.7 |
| Link inductance (primary side) | L<sub>s</sub> | 15 µH |
| Link resistance | R<sub>s</sub> | 25 mΩ |
| Input filter | L<sub>i</sub>, R<sub>i</sub>, C<sub>i</sub> | 10 µH, 100 mΩ, 30 µF |
| Output filter | L<sub>o</sub>, R<sub>o</sub>, C<sub>o</sub> | 10 µH, 100 mΩ, 44 µF |

*Table 1: Converter parameters.*

## The Exact Discrete-Time Model

The approach follows the exact switching-period small-signal model of Krismer and Kolar for a phase-shift DAB, here applied over one full switching period and to all twelve TPS modes.

The converter has five states: the link current, the input and output filter-inductor currents and the two bus-capacitor voltages,

```math
\mathbf{x} = \begin{bmatrix} i_p & i_{Li} & i_{Lo} & v_{Ci} & v_{Co} \end{bmatrix}^T . \tag{1}
```

Between two switching edges the circuit is linear, $`\dot{\mathbf{x}} = \mathbf{A}_k\mathbf{x} + \mathbf{f}`$, with

```math
\mathbf{A}_k = \begin{bmatrix}
-\frac{R_s}{L_s} & 0 & 0 & \frac{s_1^{(k)}}{L_s} & -\frac{n s_2^{(k)}}{L_s} \\
0 & -\frac{R_i}{L_i} & 0 & -\frac{1}{L_i} & 0 \\
0 & 0 & -\frac{R_o}{L_o} & 0 & -\frac{1}{L_o} \\
-\frac{s_1^{(k)}}{C_i} & \frac{1}{C_i} & 0 & 0 & 0 \\
\frac{n s_2^{(k)}}{C_o} & 0 & \frac{1}{C_o} & 0 & 0
\end{bmatrix}, \tag{2}
```

```math
\mathbf{f} = \begin{bmatrix} 0 & \frac{V_i}{L_i} & \frac{V_o}{L_o} & 0 & 0 \end{bmatrix}^T . \tag{3}
```

The eight edges of a period are $`\theta \in \{0,\ \phi_1,\ \pi,\ \pi+\phi_1,\ \phi_3,\ \phi_3+\phi_2,\ \pi+\phi_3,\ \pi+\phi_3+\phi_2\} \pmod{2\pi}`$ with $`\phi_i = D_i\pi`$. They are sorted, which gives the eight interval lengths $`t_k = (\theta_{k+1}-\theta_k)/\omega`$, and the bridge switching functions are evaluated at each interval midpoint $`\bar\theta_k`$:

```math
s_1^{(k)} = \tfrac{1}{2}\left[\operatorname{sgn}\sin\bar\theta_k - \operatorname{sgn}\sin(\bar\theta_k-\phi_1)\right], \tag{4}
```

```math
s_2^{(k)} = \tfrac{1}{2}\left[\operatorname{sgn}\sin(\bar\theta_k-\phi_3) - \operatorname{sgn}\sin(\bar\theta_k-\phi_3-\phi_2)\right]. \tag{5}
```

Because the edges are sorted rather than listed per mode, the same expressions hold for every TPS mode and both power directions; a negative D3 (V2G) is placed in the period by the modulo. Over each interval the state moves as $`\mathbf{x}(t+t_k) = \mathbf{E}_k\mathbf{x}(t) + \boldsymbol{\psi}_k`$, and both blocks come from one augmented matrix exponential, which needs no inverse of $`\mathbf{A}_k`$ (singular whenever a bridge is clamped):

```math
\exp\!\left(\begin{bmatrix} \mathbf{A}_k & \mathbf{f} \\ \mathbf{0} & 0 \end{bmatrix} t_k\right) = \begin{bmatrix} \mathbf{E}_k & \boldsymbol{\psi}_k \\ \mathbf{0} & 1 \end{bmatrix}. \tag{6}
```

Chaining the eight interval maps gives the exact one-period map $`\mathbf{x}_{k+1} = \mathbf{G}_p\mathbf{x}_k + \mathbf{H}_p`$, with $`\mathbf{G}_p = \mathbf{E}_8\cdots\mathbf{E}_1`$. The periodic steady state follows in closed form, $`\mathbf{x}^\star = (\mathbf{I}-\mathbf{G}_p)^{-1}\mathbf{H}_p`$, without simulating a transient.

<p align="center"><img src="figures/fig_states.png" alt="All five states over two periods, G2V and V2G"></p>

*Figure 1: The five states over two switching periods in steady state, from the exact model. (a) Mode 1, G2V, D = [0.80, 0.30, 0.40]. (b) Mode 1′, V2G, D = [0.80, 0.30, −0.70]. Rows: link current i<sub>p</sub>, input-filter current i<sub>Li</sub>, battery-side current i<sub>Lo</sub>, input-capacitor voltage v<sub>Ci</sub>, output-capacitor voltage v<sub>Co</sub>. i<sub>Lo</sub> is counted positive into the converter, so charging (G2V) is negative: mean −41.0 A in (a), +14.7 A in (b).*

<p align="center"><img src="figures/fig_link_current.png" alt="Link current in all twelve modes"></p>

*Figure 2: Link current i<sub>p</sub> over two periods in all twelve operating points of Table 2. (a)–(f) G2V Modes 1–6; (g)–(l) V2G Modes 1′–6′.*

## Validation Against Simulink

The exact model was compared with a Simscape Electrical model of the same circuit: ideal MOSFETs with the same gate timing, no dead time, the parameters of Table 1, a 0.5 µs solver step and a 10 ms run, of which the last period is compared. The operating point is Mode 1, G2V. The off-state conductance of the Simscape switches was set to 10<sup>−9</sup> S.

| State | Mean, Simulink | Mean, exact model | RMS difference (% of peak) |
|---|---|---|---|
| i<sub>p</sub> | −0.047 A | −0.047 A | 0.003 % |
| i<sub>Li</sub> | 41.666 A | 41.616 A | 0.120 % |
| i<sub>Lo</sub> | −40.952 A | −40.982 A | 0.074 % |
| v<sub>Ci</sub> | 795.009 V | 795.014 V | 0.002 % |
| v<sub>Co</sub> | 804.740 V | 804.742 V | 0.001 % |

<p align="center"><img src="figures/fig_simulink_validation.png" alt="Five states, Simulink against the exact model"></p>

*Figure 3: One switching period of the five states, Mode 1 G2V: Simulink (solid) and the exact discrete-time model (dashed). (a) i<sub>p</sub>, (b) i<sub>Li</sub>, (c) i<sub>Lo</sub>, (d) v<sub>Ci</sub>, (e) v<sub>Co</sub>.*

## The Small-Signal Model

Since the one-period map is affine in the state, its state Jacobian is the monodromy matrix itself, $`\mathbf{A}_d = \mathbf{G}_p`$, exactly. The input Jacobians $`\mathbf{B}`$ (for D1, D2, D3) and $`\mathbf{C}`$ (for V<sub>i</sub>, V<sub>o</sub>) are central differences of the exact map about $`\mathbf{x}^\star`$. In the form of Krismer and Kolar, sampled once per period instead of once per half period,

```math
\hat{\mathbf{x}}_{k+1} = \mathbf{A}_d\,\hat{\mathbf{x}}_k + \mathbf{B}\,\hat{\mathbf{d}}_k + \mathbf{C}\,\hat{\mathbf{v}}_{g,k} , \tag{7}
```

and the control path used for the current loop is

```math
G_{i_{Lo},D_3}(z) = \mathbf{E}_y\,(z\mathbf{I}-\mathbf{A}_d)^{-1}\,\mathbf{B}_{:,3} = \frac{\delta i_{Lo}}{\delta D_3}(z), \qquad \mathbf{E}_y = \begin{bmatrix} 0 & 0 & 1 & 0 & 0 \end{bmatrix}. \tag{8}
```

Its value at z = 1 is the DC gain K<sub>dc</sub>, the change of battery current per unit of D3 (Table 2).

| Operating point | D1 | D2 | D3 | K<sub>dc</sub> (A) | Largest Floquet multiplier | Step-test error |
|---|---|---|---|---|---|---|
| Mode 1, G2V | 0.80 | 0.30 | 0.40 | −272.61 | 0.96792 | 0.012 % |
| Mode 2, G2V | 0.30 | 0.60 | 0.80 | 283.20 | 0.96803 | 0.013 % |
| Mode 3, G2V | 0.35 | 0.30 | 0.50 | 1.57 | 0.96760 | 0.215 % |
| Mode 4, G2V | 0.40 | 0.50 | 0.60 | 95.82 | 0.96793 | 0.491 % |
| Mode 5, G2V | 0.70 | 0.40 | 0.35 | −315.13 | 0.96800 | 0.152 % |
| Mode 6, G2V | 0.80 | 0.70 | 0.50 | −75.58 | 0.96849 | 1.142 % |
| Mode 1′, V2G | 0.80 | 0.30 | −0.70 | 276.49 | 0.96792 | 0.005 % |
| Mode 2′, V2G | 0.60 | 0.80 | −0.10 | −551.97 | 0.96850 | 0.015 % |
| Mode 3′, V2G | 0.35 | 0.30 | −0.40 | −4.37 | 0.96760 | 0.116 % |
| Mode 4′, V2G | 0.40 | 0.50 | −0.45 | −51.20 | 0.96793 | 0.775 % |
| Mode 5′, V2G | 0.70 | 0.40 | −0.50 | 178.91 | 0.96800 | 0.273 % |
| Mode 6′, V2G | 0.80 | 0.70 | −0.40 | −90.26 | 0.96849 | 1.004 % |

*Table 2: The twelve operating points, their DC gain from D3 to i<sub>Lo</sub>, the largest Floquet multiplier (eigenvalue of G<sub>p</sub>) and the step-test error of Fig. 4. All multipliers are below 1: every operating point is stable in open loop.*

<p align="center"><img src="figures/fig_step_validation.png" alt="Step in D3, small-signal model against the exact model"></p>

*Figure 4: Response of i<sub>Lo</sub> to a step of 0.001 in D3 at t = 1 ms, sampled once per period, in the twelve operating points of Table 2 ((a)–(f) G2V Modes 1–6, (g)–(l) V2G Modes 1′–6′): exact discrete-time model (solid) and small-signal model (dashed).*

<p align="center"><img src="figures/fig_bode.png" alt="Magnitude of the control path in all twelve modes"></p>

*Figure 5: Magnitude of G<sub>iLo,D3</sub>(z) up to f<sub>s</sub>/2 in the twelve operating points, (a)–(l) as in Fig. 4. The low-frequency gain ranges from about 4 dB (Mode 3, (c)) to about 55 dB (Mode 2′, (h)); every mode has a resonance peak near 7–8 kHz.*

<p align="center"><img src="figures/fig_poles_zeros.png" alt="Poles and zeros of the control path"></p>

*Figure 6: (a) Poles and (b) zeros of G<sub>iLo,D3</sub>(z) for the twelve operating points; G2V blue, V2G red. The poles of all twelve modes nearly coincide: a real pole at z ≈ 0.97 and two complex pairs at |z| ≈ 0.9. The zeros move from mode to mode, from about −7.7 to 0.98 on the real axis.*

The twelve control paths have nearly the same poles, while their DC gain spans more than two orders of magnitude and changes sign from mode to mode.

## PI Current Control

The current is sampled once per period and a new D3 takes effect one period later, so the plant seen by the controller is

```math
G_{\mathrm{plant}}(z) = G_{i_{Lo},D_3}(z)\, z^{-N}, \qquad N = 1 . \tag{9}
```

A discrete PI (forward Euler) was tuned on each mode's plant divided by its own K<sub>dc</sub>, for a crossover of 300 Hz. Within each power direction, each of the six resulting gain pairs was tried on all six modes, and the pair that kept the most modes stable with the largest worst-case gain margin was kept: K<sub>p,n</sub> = 0.01445, K<sub>i,n</sub> = 1445 for both directions (from Mode 6 for G2V and Mode 4′ for V2G). Each mode then uses K<sub>p</sub> = K<sub>p,n</sub>/K<sub>dc</sub> and K<sub>i</sub> = K<sub>i,n</sub>/K<sub>dc</sub>, so the sign of the gains follows the sign of the plant.

| Operating point | K<sub>p</sub> | K<sub>i</sub> | Crossover (Hz) | Gain margin (dB) | Phase margin (°) | Unity crossings | Largest closed-loop pole | Stable |
|---|---|---|---|---|---|---|---|---|
| Mode 1, G2V | −5.30×10<sup>−5</sup> | −5.30 | 230 | 21.5 | 86.9 | 1 | 0.970 | yes |
| Mode 2, G2V | 5.10×10<sup>−5</sup> | 5.10 | 218 | 22.5 | 83.4 | 1 | 0.971 | yes |
| Mode 3, G2V | 9.17×10<sup>−3</sup> | 917.4 | 8622 | −5.3 | −58.8 | 3 | 1.069 | **no** |
| Mode 4, G2V | 1.51×10<sup>−4</sup> | 15.08 | 206 | 25.4 | 77.3 | 1 | 0.974 | yes |
| Mode 5, G2V | −4.58×10<sup>−5</sup> | −4.58 | 230 | 21.6 | 86.9 | 1 | 0.970 | yes |
| Mode 6, G2V | −1.91×10<sup>−4</sup> | −19.11 | 300 | 16.6 | 97.1 | 1 | 0.984 | yes |
| Mode 1′, V2G | 5.23×10<sup>−5</sup> | 5.23 | 230 | 21.0 | 87.2 | 1 | 0.970 | yes |
| Mode 2′, V2G | −2.62×10<sup>−5</sup> | −2.62 | 235 | 20.8 | 88.2 | 1 | 0.975 | yes |
| Mode 3′, V2G | −3.31×10<sup>−3</sup> | −331.1 | 231 | 3.2 | 95.4 | 1 | 0.972 | yes |
| Mode 4′, V2G | −2.82×10<sup>−4</sup> | −28.22 | 300 | 17.8 | 96.2 | 1 | 0.984 | yes |
| Mode 5′, V2G | 8.08×10<sup>−5</sup> | 8.08 | 230 | 21.5 | 86.7 | 1 | 0.970 | yes |
| Mode 6′, V2G | −1.60×10<sup>−4</sup> | −16.01 | 290 | 16.9 | 95.9 | 1 | 0.984 | yes |

*Table 3: The deployed PI gains and the resulting current loop in each operating point. "Unity crossings" counts how often the loop gain crosses 0 dB; with a single crossing the margins describe the loop directly.*

All six V2G modes are stable, with one crossing each, phase margins of 86.7–96.2° and gain margins of 16.9–21.5 dB, except Mode 3′ at 3.2 dB. Five of the six G2V modes are stable, with gain margins of 16.6–25.4 dB and phase margins of 77–97°.

Mode 3, G2V, is not stabilised. Its DC gain, 1.57 A per unit D3, is two orders of magnitude below most other modes, while its resonance near 7.5 kHz is about 36 dB above its low-frequency gain (Fig. 5c). Dividing by the small K<sub>dc</sub> lifts that resonance above 0 dB: the loop crosses unity three times, the gain margin is −5.3 dB and a closed-loop pole lies at 1.069. No G2V gain pair tried as reference, including the one tuned on Mode 3 itself, gave more than five stable G2V modes.

The loop was also run in Simulink, in Mode 1 G2V: the Simscape model of the validation section, D1 and D2 fixed, D3 equal to its nominal value plus the PI output (limited to ±0.08), the measured current delayed by one period, and the gains of Table 3.

<p align="center"><img src="figures/figsimulink.png" alt="PI step response in Simulink"></p>

*Figure 7: Simulink, Mode 1 G2V, closed loop: current reference (yellow) stepped from −41.3 A to −46.3 A at t = 5 ms, and i<sub>Lo</sub> as sampled by the controller (blue). The current follows the step without overshoot, passes −45 A about 1 ms after it and settles on the new reference.*

## Implementation

| File | Purpose |
|---|---|
| `dab_params.m` | Parameters of Table 1 and the twelve operating points of Table 2 |
| `dab_period_map.m` | Exact one-period map: sorted edges, switching functions, augmented matrix exponential (eqs. 1–6) |
| `dab_linearize.m` | Steady state, A<sub>d</sub>, B, C and G<sub>iLo,D3</sub>(z) for one operating point (eqs. 7–8) |
| `five_state_calculator.m` | Fig. 1 |
| `run_waveforms.m` | Fig. 2 |
| `run_smallsignal.m` | Table 2, Figs. 4–6 |
| `run_pi.m` | PI design and Table 3 |
| `openloopDAB.slx`, `validate_exact_model.m` | Simscape model and comparison of Fig. 3 |
| `closedloopDAB.slx`, `closedloop_init.m` | Closed-loop Simscape model and its parameters, Fig. 7 |

Requirements: MATLAB with the Control System Toolbox; Simulink and Simscape Electrical for the two models. To reproduce the closed-loop run, run `closedloop_init`, then run `closedloopDAB.slx`.

Reference: F. Krismer and J. W. Kolar, "Accurate Small-Signal Model for an Automotive Bidirectional Dual Active Bridge Converter," IEEE, 2008.
