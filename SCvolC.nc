generic configuration SCvolC()
{
	provides interface Read<uint16_t>;
}
implementation
{
	components new AtmegaAdc4ReadC() as SCvol;
	
	Read = SCvol; 
	
	
}