#include<pic.h>
#include<pic16c55.h>
#define uchar unsigned char
#define uint unsigned int

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
			delay(50);
			PORTB=PORTB<<1;
		}
		PORTB=0x80;
		for(i=8;i>0;i--)
		{
			delay(50);
			PORTB=PORTB>>1;
		}
	}
}