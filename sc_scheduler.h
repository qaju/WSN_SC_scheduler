#ifndef SC_SCHEDULER_H
#define SC_SCHEDULER_H




enum {
	V1INTERVAL = 1000,
	
	
	V2INTERVAL = 10000,
	ADCINTERVAL = 50,
	
	NREADINGsc = 4,                   // # of SC terminal voltage readings
	NREADINGref = 4,          
	
	TASKINTERVAL= 1000,
	LAZYDELAY = 500,
	
	SC_SCH_TEST = 0x93
};


typedef nx_struct scscheduler {
	nx_uint16_t version;
	nx_uint16_t intervalV1;
	nx_uint16_t intervalV2;
	nx_uint16_t intervalTask;
	nx_uint16_t intervalADC;
	nx_uint16_t PC;                   // period count
	nx_uint16_t thdsoft;              // software threshold for SC terminal voltage 
	nx_uint16_t id;
	nx_uint16_t countV1;
	nx_uint16_t countV2;
	nx_uint16_t	Vsc;
	nx_uint16_t	Vref;
}scscheduler;


#endif /* SC_SCHEDULER_H */