#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

int ahtoi(char ch)
{
	int tmp;
	tmp = toupper(ch);
	tmp = (ch - '0');
	if(tmp > 9)
		tmp = (tmp - 7);
	return tmp;
}

int main(void)
{
	char ch;
	int  i = 0;
	int  j = 0;
	char state = 0;
	int  rlen = 0;
	int  radd = 0;
	int  rtyp = 0;
	char rdat[4];
	printf("Please paste your hex code into teminal:\n");

	while(!feof(stdin)) {
		ch = fgetc(stdin);
		switch(state) {
			case 0 :
				if(ch == ':') {
					i = 2;
					j = 0;
					rlen  = 0;
					state = 1;
				}
			break;
			case 1 :
				rlen = (rlen << 4) + ahtoi(ch);
				i -= 1;
				if(i == 0) {
					i = 4;
					j = 0;
					rlen  = rlen / 2;
					radd  = 0;
					state = 2;
				}
			break;
			case 2 :
				radd = (radd << 4) + ahtoi(ch);
				i -= 1;
				j += 1;
				if(i == 0) {
					i = 2;
					j = 0;
					radd = radd / 2;
					rtyp  = 0;
					state = 3;
				}
			break;
			case 3 :
				rtyp = (rtyp << 4) + ahtoi(ch);
				i -= 1;
				if(i == 0) {
					i = 4;
					j = 0;
						if(rtyp == 0) {
						fprintf(stdout,
								"@%04X\n", radd);
						state = 4;
					}
					else {
						state = 0;
					}
				}
			break;
			case 4 :
				rdat[j] = ch;
				i -= 1;
				j += 1;
				if(i == 0) {
					i = 4;
					j = 0;
					fprintf(stdout, "%c%c%c\n", rdat[3], rdat[0], rdat[1]);
					rlen -= 1;
					if(rlen == 0) {
						state = 0;
					}
					else {
						state = 4;
					}
				}
			break;
			default : break;
		}
	}
	return 0;
}
