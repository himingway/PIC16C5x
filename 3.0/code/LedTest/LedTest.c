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
	TRISB=0x00;
	while(1)
	{
		PORTB=0x01;
		for(i=8;i>0;i--)
		{
			delay(500);
			PORTB=PORTB<<1;
		}
		PORTB=0x80;
		for(i=8;i>0;i--)
		{
			delay(500);
			PORTB=PORTB>>1;
		}
	}
}