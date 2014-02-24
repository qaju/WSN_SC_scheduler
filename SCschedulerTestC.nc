#include "Timer.h"
#include "sc_scheduler.h"

//Created by Qianao Ju to test SC based task scheduling algorithm version 1.0
module SCschedulerTestC
{
	uses {
		interface Boot;
		interface SplitControl as RadioControl;
		interface AMSend;
		interface Receive;
		interface Timer<TMilli> as Timer1;
		interface Timer<TMilli> as Timer2;
		interface Timer<TMilli> as Timer3;
		interface Timer<TMilli> as Timer4;
		interface Timer<TMilli> as Timer5;
		interface Read<uint16_t> as SCTerminalV;
		interface Read<uint16_t> as RefV;
		interface Leds;
			
		
		}
}
implementation
{
	message_t sendBuf;
	bool sendBusy = FALSE;
	scscheduler local;
	uint8_t readn_sc;
	uint8_t readn_ref;
	
	uint8_t Vsc_raw;                         // raw data of SC terminal vol from ADC pin 4
	uint8_t Vref_raw;                        // raw data of Vref of Atmega 1281 MCU
	
	bool suppressCountChange;
	bool v1_available;                       //
	bool v2_available;
	
	float Vsc_fp = 0.f;                            //floating point of SC terminal vol
	float Vpow_fp = 0.f;                           //floating point of node's power vol
	
	float V1, V2;                            //
	float V1_0 = 1.5f;                          //*_0 is initial condition
	float V2_0 = 1.5f;
	bool assign = FALSE;                             //not used yet
	
	
	// parameters for Panasonic 22F SC
	float r1c0 = 0.93257f;
	float r1kv = 0.3705f;
	float r2c2 = 329.9943f;
	
	
	void report_problem(){ call Leds.led0Toggle(); }
	void report_sent() { call Leds.led1Toggle(); }
	void report_receive() { call Leds.led2Toggle();  }
	
	
	void RFmsg()
	{
		if (!sendBusy && sizeof(local) <= call AMSend.maxPayloadLength())
		{
			memcpy(call AMSend.getPayload(&sendBuf, sizeof(local)),&local, sizeof local);
			if ( call AMSend.send( AM_BROADCAST_ADDR, &sendBuf, sizeof local ) == SUCCESS)
				sendBusy = TRUE;
		}
		
		if ( !sendBusy )
			report_problem();
		
		
		if ( call SCTerminalV.read() != SUCCESS )
			report_problem();
		
		if ( call RefV.read() != SUCCESS )
			report_problem();
		
	}
	
	
	event void Boot.booted()
	{
		local.intervalTask = TASKINTERVAL;
		local.intervalV1 = V1INTERVAL;
		local.intervalV2 = V2INTERVAL;
		local.intervalADC = ADCINTERVAL;
		local.PC = 0x0000;               // period counter
		
		v1_available = v2_available = FALSE;
		V1 = V1_0;
		V2 = V2_0;
		
		local.id = TOS_NODE_ID;
		
		if ( call RadioControl.start() != SUCCESS )
		{
			report_problem();
		}
		
		// TODO Auto-generated method stub
	}
	
	void StartTimer()
	{
		call Timer1.startPeriodic( local.intervalV1 );              // measure v1
		call Timer2.startPeriodic( local.intervalV2 );              // measure V2 
		call Timer3.startPeriodic( local.intervalTask );            //schedule task
		call Timer4.startPeriodic( local.intervalADC);
	}
	
	

	event void RadioControl.startDone(error_t error)
	{
		StartTimer();	
		// TODO Auto-generated method stub
	}

	event void RadioControl.stopDone(error_t error){
		// TODO Auto-generated method stub
	}

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		// TODO Auto-generated method stub
		if ( error == SUCCESS )
			report_sent();
		else
			report_problem();
		
		sendBusy = FALSE;	
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		scscheduler *omsg = payload;
		
		
		if ( omsg->version > local.version )
		{
			local.version = omsg->version;
			local.intervalTask = omsg ->intervalTask;
			local.intervalV1 = omsg ->intervalV1;
			local.intervalV2 = omsg ->intervalV2;
			local.intervalADC = omsg ->intervalADC;
		}
		
		
		return msg;
		// TODO Auto-generated method stub
	}

	

	
    // compute V1, needs to keep track every 1 s
	event void Timer1.fired()                      
	{
		if ( Vsc_fp > 1.05f )
		{
			V1 = V1 + ((float)(local.intervalV1 / 1000)) * (Vpow_fp - V1)/ (r1c0 +r1kv * V1);
			
			//compute V1
			v1_available = TRUE;
		}
		else
		{
			v1_available = FALSE;
		}
		// TODO Auto-generated method stub
	}


    // compute v2, needs to keep track every 10 s
	event void Timer2.fired()                      
	{
		if ( Vsc_fp > 1.05f )
		{
			V2 = V2 + ((float)(local.countV2 / 1000)) / r2c2 * (Vpow_fp - V2 );
			//compute V2
			v2_available = TRUE;
		}
		else
		{
			v2_available = FALSE;
		}
		// TODO Auto-generated method stub
	}

    // main task scheduler, assign tasks according to SC charge redistribution status
	event void Timer3.fired()                    
	{
		if ( v1_available && v2_available )
		{
			if ( V1 > V2 )        // greedy scheduling
			{
				RFmsg();				
			}
			else
			{
				call Timer5.startOneShot(500);
			}
		}
		// TODO Auto-generated method stub
	}


	//system timer to trigger ADC readings
	event void Timer4.fired()
	{
		if ( readn_sc == NREADINGsc  && readn_ref == NREADINGref)
		{
			local.Vref = local.Vref / NREADINGsc;
			local.Vsc = local.Vsc / NREADINGsc;
			
			//compute SC terminal voltage and node's power voltage
			Vpow_fp = 0.1f + 1.095f * 1023.f/ (float)local.Vref;
			Vsc_fp = (float)local.Vsc * Vpow_fp / 1023.f;
			
			
		}
		// TODO Auto-generated method stub
	}

	event void SCTerminalV.readDone(error_t result, uint16_t val)
	{
		// TODO Auto-generated method stub
		if ( result != SUCCESS )
		{
			val = 0xffff;
			report_problem();
		}	
		else if ( readn_sc < NREADINGsc )
		{
			local.Vsc += val;
			readn_sc ++;
		}
		
	}

	event void RefV.readDone(error_t result, uint16_t val)
	{
		// TODO Auto-generated method stub
		if ( result != SUCCESS)
		{
			val = 0xffff;
			report_problem();
		}
		else if ( readn_ref < NREADINGref )
		{
			local.Vref += val;
			readn_ref ++;
		}	
		
	}

	event void Timer5.fired()
	{
		// TODO Auto-generated method stub
		RFmsg();
	}
}