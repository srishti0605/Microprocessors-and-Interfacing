# Microprocessors-and-Interfacing
Complete implementation of an automatic washing machine


Description: An Automatic washing machine with Dryer.

The Washing Machine can handle three different types of load: Light, Medium and Heavy. The Washing Machine has three different cycles: Rinse, Wash and Dry.
Depending on the load the number of times a cycle is done and the duration of the cycle varies.

L ight L oad : Rinse- 2 mins, Wash- 3 mins, Rinse – 2 mins, Dry Cycle –2 mins
Medi um L oad : Rinse- 3 mins, Wash- 5 mins and Rinse – 3 mins Dry Cycle –4 mins
Hea vy l oad : Rinse - 3 mins, Wash- 5 mins and Rinse – 3 mins, Wash- 5 mins and Rinse – 3 mins, Dry Cycle – 4 mins

· The Washing Machine is a single tub machine.
· The Washing machine is made of a Revolving Tub and an Agitator. 

The Agitator is activated during the Rinse and Wash cycle; revolving tub is active only during the Dry cycle. The door of the washtub should remain closed as long as the agitator is active.

· Before each cycle the water, level is sensed. At the beginning of the cycle the water level should be at the maximum possible level, the water should be completely drained during dry cycle. The cycle should begin only when the water level is correct.

· At the end of each cycle a buzzer is activated. The user should drain the water at the end of the rinse/wash cycle and refill the water for the next cycle; once this has been completed the user can press the resume button.

· At the beginning of the wash cycle the user should add the detergent.

· At the end of the complete wash process the Buzzer is sounded.

· User can turn off system by pressing STOP Button

· Different sounds are used for different events.

· Display the load selected using a seven-segment display.

User Interface: 

The number of times the load button is pressed determines load: 
1press- light; 
2 presses- medium 
3 presses –heavy.

To begin washing process START is pressed. Pressing STOP can stop the process.


PROBLEM STATEMENT:

SYSTEM TO BE DESIGNED – AUTOMATIC WASHING MACHINE

· 74LS138
· 74LS245
· 74LS273
· 2732
· 6116
· 74LS447
· 7404(Not gate)
· 7432(2 input OR gate)
· 4072(4 input OR gate)
· 4078 (8 input NOR gate)

COMPONENTS USED:
· 8255
· Led
· Buzzer
· Button
· Resistor
· Agitator, Revolving Tub(Motor)
· Sw-spst
· 8086
· Sw-spdt-mom
· Relay
· Water level max or min is modelled using switches (SWSPST).

In reality they will be pressure sensitive switches (as water reaches max level the switch will automatically be pressed). Here we will be manually pressing the water - max/water - min switch.

· Before every wash cycle, the user is given 1 minute to put detergent.

· Assume that the door is locked when the agitator is running. Before the agitator starts running, the program checks if door is locked or not.
· Agitator and revolving tub are modelled by DC motors. 

ASSUMPTIONS:

I/O MAPPING : 8255(Programmable peripheral interface)- 00H to 06H

MEMORY MAPPING :

ROM chip used: 2732
RAM chip used: 6116
ROM:8KB = 4KB(even)+4KB(o dd )
· ROM (Even Bank):00000H,00002H, ..........,01FFCH,01FFEH
· ROM (Odd Bank):00001H,00003H, ..........,01FFDH,01FFFH
  RAM:4KB = 2KB( even)+2KB( odd )
· RAM (Even Bank):02000H,02002H, ..........,02FFCH,02FFEH
· RAM (Odd Bank):00001H,00003H, ..........,02FFDH,02FFFH


IVT:
· INT 2H (NMI) is used.


PORT A
PA0- Start Button; PA1- Stop Button; PA2- Load Button;
PA3- Resume Button; PA4- Door Lock Switch; PA5-
Water Max Switch; PA6- Water Min Switch

PORT B
PB0- Agitator; PB1- Revolving tub; PB2- Buzzer - Dry;
PB3- Buzzer - Wash; PB4-Buzzer - Rinse

PORT C
PC0-PC3: input to BCD to 7 segment decoder.

IVT:
· INT 2H (NMI) is used.
