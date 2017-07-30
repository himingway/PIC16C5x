#include<pic.h>
#include<pic16c55.h>
#define uchar unsigned char
#define uint unsigned int
#pragma config OSC = RC         // Oscillator selection bits (RC oscillator)
#pragma config WDT = OFF        // Watchdog timer enable bit (WDT disabled)
#pragma config CP = OFF         // Code protection bit (Code protection off)
void delay(uint x)
{
	uint a,b;        
	for(a=x;a>0;a--)
		for(b=110;b>0;b--);
}
void main()
{
	uchar i;
	TRISA=0x00;
    TRISB=0x0F;
	while(1)
	{
        if(!RB0){
            PORTA=0x01;
            for(i=4;i>0;i--)
            {
                delay(500);
                PORTA=PORTA<<1;
            }
        }
        if(!RB1){
            PORTA=0x08;
            for(i=4;i>0;i--)
            {
                delay(500);
                PORTA=PORTA>>1;
            }
        }
	}
}