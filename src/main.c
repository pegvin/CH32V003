#include <ch32v00x.h>
#include <debug.h>

#define BLINK_GPIO_PORT    GPIOC
#define BLINK_GPIO_PIN     GPIO_Pin_1
#define BLINK_CLOCK_ENABLE RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOC, ENABLE)

int main(void) {
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);
	SystemCoreClockUpdate();
	Delay_Init();

	GPIO_InitTypeDef GPIO_InitStructure = {0};

	BLINK_CLOCK_ENABLE;
	GPIO_InitStructure.GPIO_Pin = BLINK_GPIO_PIN;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(BLINK_GPIO_PORT, &GPIO_InitStructure);

	uint8_t ledState = 0;
	while (1) {
		GPIO_WriteBit(BLINK_GPIO_PORT, BLINK_GPIO_PIN, ledState);
		ledState ^= 1; // invert for the next run
		Delay_Ms(1000);
	}

	return 0;
}
