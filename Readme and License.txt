This project was created as a project for scouts completing the Electronics merit badge with the help and supervision of a qualified counselor.  It was meant to be as simple as possible and still be useful.  Extension of the project (such as adding a method to adjust the time) was purposely left open-ended.

The hours and minutes are binary coded decimal.  The seconds LEDs are ordinary binary (6 LEDs which count up to 59 seconds).  The program as included only counts up the seconds LEDs every 5 minutes.

As built, the start time for the clock is hard-coded in the software at 5:42.  The clock does not indicate AM or PM so this could be either.  Twice a day, if you power up the clock at the right time, it will be correct.  But consequently, if the power supply is household AC (?the grid?) and the power is interrupted, the time will reset and will be incorrect.  I?ve found this easily managed by setting the reset time to a few minutes after the morning alarm clock goes off.

Other users are welcome to use and modify the project.  I welcome feedback if you successfully build this project and any comments, issues, improvements, etc.

My experience has been that it keeps time well to within seconds per week.  I do not know if this will vary among multiple clocks/builders.  I have adjusted the timing with the number of extra cycles in the software.

FILE LIST - Listed in order that they may be needed to complete the project:

Readme and license.txt - Other info and license/legal stuff.  Text file. (This file.)
Readme and license.doc - Other info and license/legal stuff.  Word document.  (This file.)

Parts List BOM.xls - Parts list (bill of materials) to complete the project.  See also Build Instructions.doc for possible alternate LEDs.
Build Instructions.doc - Word document describing how to build the project.

PCB Image v5.pdf - Picture of PCB.  Compare to PCB board to check for defects.
Top Side Component Placement.doc - Top view.  May be needed to help with placement of components during project construction.

FullSolderComic_EN.pdf - Instructions on how to solder.
Solder comic.pdf - Instructions on how to solder.

BinClk_v7.X.production.hex - Hex file from MPLab IDE v2.30 for PIC16F57.

Bin Clk Sch_PCB_Combo.jpg - Image of circuit schematic and PCB layout.
BinaryClock_Timing_4MHz.xls - Calculation of timing.  Used to adjust software if needed to adjust timing (if clock loses or gains time).
BinaryClock-v5.brd - Eagle Cadsoft (v7.2.0) file for pcb.
BinaryClock-v5.sch - Eagle Cadsoft (v7.2.0) file for schematic.
BinClkv7.txt ? A text version of the assembler program if users wish to look at the code.  
BinClkv7.asm - Program (written in assembler) for the PIC16F57 to operate the clock.  Modify this program to change how the clock operates.  I used MPLAB X IDE v2.30.
Notes on color change LEDs.txt - Notes on possible use of color change LEDs.
LED Calculations.xls - Calculations to determine resistor sizes for various LEDs.


This project/work consists of a electronic circuit, an associated circuit board design, microcontroller program (software) and supporting documents & information.  Users are free to modify and/or utilize this project for any non-commercial use.  THERE IS NO WARRANTY.  ANY PART OF OR THE ENTIRE PROJECT/WORK, AS-IS OR AFTER MODIFICATION, MAY BE UNFIT FOR USE, UNSAFE OR DANGEROUS.  USE AT YOUR OWN RISK!  This project/work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

