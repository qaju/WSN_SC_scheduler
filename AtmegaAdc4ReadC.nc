generic configuration AtmegaAdc4ReadC()
{
	provides interface Read<uint16_t>;
}
implementation
{
	components new AdcReadClientC(),AtmegaAdc4ReadP;
	
	Read = AdcReadClientC;
	
	AdcReadClientC.Atm128AdcConfig -> AtmegaAdc4ReadP; 
}