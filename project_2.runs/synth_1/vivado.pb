
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2
create_project: 2

00:00:092

00:00:122	
500.0272	
200.707Z17-268h px� 
�
Command: %s
1870*	planAhead2�
�read_checkpoint -auto_incremental -incremental C:/Users/conor/SOC1/project_2/project_2.srcs/utils_1/imports/synth_1/JTAG_TAP_CONTROLLER.dcpZ12-2866h px� 
�
;Read reference checkpoint from %s for incremental synthesis3154*	planAhead2^
\C:/Users/conor/SOC1/project_2/project_2.srcs/utils_1/imports/synth_1/JTAG_TAP_CONTROLLER.dcpZ12-5825h px� 
T
-Please ensure there are no constraint changes3725*	planAheadZ12-7989h px� 
n
Command: %s
53*	vivadotcl2=
;synth_design -top JTAG_TAP_CONTROLLER -part xc7k70tfbv676-1Z4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
z
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2	
xc7k70tZ17-347h px� 
j
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2	
xc7k70tZ17-349h px� 

VNo compile time benefit to using incremental synthesis; A full resynthesis will be run2353*designutilsZ20-5440h px� 
�
�Flow is switching to default flow due to incremental criteria not met. If you would like to alter this behaviour and have the flow terminate instead, please set the following parameter config_implementation {autoIncr.Synth.RejectBehavior Terminate}2229*designutilsZ20-4379h px� 
o
HMultithreading enabled for synth_design using a maximum of %s processes.4828*oasys2
2Z8-7079h px� 
a
?Launching helper process for spawning children vivado processes4827*oasysZ8-7078h px� 
N
#Helper process launched with PID %s4824*oasys2
18408Z8-7075h px� 
�
%s*synth2u
sStarting Synthesize : Time (s): cpu = 00:00:07 ; elapsed = 00:00:09 . Memory (MB): peak = 963.191 ; gain = 452.793
h px� 
�
cfound '%s' definitions of operator %s, cannot determine exact overloaded matching definition for %s5751*oasys2
02
"&"2
"&"2K
GC:/Users/conor/SOC1/project_2/project_2.srcs/sources_1/new/JTAG_TAP.vhd2
2768@Z8-9493h px� 
�
+unit '%s' is ignored due to previous errors7513*oasys2

behavioral2K
GC:/Users/conor/SOC1/project_2/project_2.srcs/sources_1/new/JTAG_TAP.vhd2
2878@Z8-11252h px� 
�
'VHDL file '%s' is ignored due to errors6704*oasys2I
GC:/Users/conor/SOC1/project_2/project_2.srcs/sources_1/new/JTAG_TAP.vhdZ8-10443h px� 
�
synthesizing module '%s'638*oasys2
JTAG_TAP_CONTROLLER2K
GC:/Users/conor/SOC1/project_2/project_2.srcs/sources_1/new/JTAG_TAP.vhd2
348@Z8-638h px� 
�
%done synthesizing module '%s' (%s#%s)256*oasys2
JTAG_TAP_CONTROLLER2
02
12K
GC:/Users/conor/SOC1/project_2/project_2.srcs/sources_1/new/JTAG_TAP.vhd2
348@Z8-256h px� 
�
%s*synth2v
tFinished Synthesize : Time (s): cpu = 00:00:10 ; elapsed = 00:00:12 . Memory (MB): peak = 1071.727 ; gain = 561.328
h px� 
C
Releasing license: %s
83*common2
	SynthesisZ17-83h px� 
~
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
132
02
02
2Z4-41h px� 
<

%s failed
30*	vivadotcl2
synth_designZ4-43h px� 
N
Command failed: %s
69*common2
Vivado Synthesis failedZ17-69h px� 
\
Exiting %s at %s...
206*common2
Vivado2
Fri Oct 11 12:13:22 2024Z17-206h px� 


End Record