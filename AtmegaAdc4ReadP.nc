module AtmegaAdc4ReadP
{
	provides interface Atm128AdcConfig; 
}
implementation
{

	async command uint8_t Atm128AdcConfig.getRefVoltage()
	{
		return ATM128_ADC_PRESCALE;
		// TODO Auto-generated method stub
	}

	async command uint8_t Atm128AdcConfig.getPrescaler()
	{
		return ATM128_ADC_VREF_OFF;
		// TODO Auto-generated method stub
	}

	async command uint8_t Atm128AdcConfig.getChannel()
	{
		return ATM128_ADC_SNGL_ADC4;
		// TODO Auto-generated method stub
	}
}