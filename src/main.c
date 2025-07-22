#include <ch32v00x.h>
#include <debug.h>

// This program blinks an LED on GPIO C4 port.
// It uses PD5 port for USART TX, Make sure to connect that
// to your WCH-LinkE's RX pin.

// I am not sure how printf would work on non-wch toolchains.
#ifdef NO_WCH_TOOLCHAIN
	#define printf(fmt, ...)
#endif

int main(void) {
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);
	SystemCoreClockUpdate();
	Delay_Init();

#if (SDI_PRINT == SDI_PR_OPEN)
	SDI_Printf_Enable();
#else
	USART_Printf_Init(115200);
#endif

	GPIO_InitTypeDef GPIO_InitStructure = {0};
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE);
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOC, &GPIO_InitStructure);

	// Let our host-system catch up
	Delay_Ms(2500);

	printf("SystemClk: %ld\n", SystemCoreClock);
	printf("ChipID: %08lx\n", DBGMCU_GetCHIPID());

	uint32_t counter = 0;

	while (1) {
		Delay_Ms(500);
		int isON = GPIO_ReadOutputDataBit(GPIOC, GPIO_Pin_4) == Bit_SET;

		isON ? GPIO_ResetBits(GPIOC, GPIO_Pin_4) : GPIO_SetBits(GPIOC, GPIO_Pin_4);

		printf("State: %d - Counter: %lu\n", isON, counter);
		counter++;
	}

	return 0;
}
