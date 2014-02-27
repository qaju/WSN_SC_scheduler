configuration SCschedulerTestApp{}




implementation
{
	components SCschedulerTestC, MainC, ActiveMessageC, LedsC,
	new TimerMilliC() as Timer1,                 //scheduler timer, to measure V1, T = 1 s
	new TimerMilliC() as Timer2,                 //scheduler timer, to measure V2, T = 10 s
	new TimerMilliC() as Timer3,                 //main scheduler timer, to assign tasks inside period
	new TimerMilliC() as Timer4,                 // system timer to trigger ADC reading, to measure Vsc and Vref
	new TimerMilliC() as Timer5,                 // Timer to implement lazy scheduling
	new SCvolC() as SCVsensor,                  // ADC reading of SC terminal voltage
	new DemoSensorC() as RefVsensor,                   // ADC reading of internal ref voltage, 1V for iris
	new AMSenderC(SC_SCH_TEST) , 
	new AMReceiverC(SC_SCH_TEST);
	
	SCschedulerTestC.Boot -> MainC;
	SCschedulerTestC.RadioControl -> ActiveMessageC;
	SCschedulerTestC.AMSend -> AMSenderC;
	SCschedulerTestC.Receive -> AMReceiverC;
	SCschedulerTestC.SCTerminalV -> SCVsensor;
	SCschedulerTestC.RefV -> RefVsensor;
	SCschedulerTestC.Timer1 -> Timer1;
	SCschedulerTestC.Timer2 -> Timer2;
	SCschedulerTestC.Timer3 -> Timer3;
	SCschedulerTestC.Timer4 -> Timer4;
	SCschedulerTestC.Timer5 -> Timer5;
	SCschedulerTestC.Leds -> LedsC;
	
	
}