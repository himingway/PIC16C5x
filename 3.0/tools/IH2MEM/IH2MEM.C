#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>

int ahtoi(char ch)
{
    int tmp;

    tmp = toupper(ch);

    tmp = (ch - '0');
    if(tmp > 9) tmp = (tmp - 7);

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
    printf("hello\n");
    
    while(!feof(stdin)) {

        ch = fgetc(stdin);

        switch(state) {
           case 0 :                     // Find start of record

                if(ch == ':') {         // Read record length - 2 chars
                     i = 2;
                     j = 0;
                     rlen  = 0;
                     state = 1;
                }

                break;

           case 1 :                     // Read and convert record length field

                rlen = (rlen << 4) + ahtoi(ch);

                i -= 1;

                if(i == 0) {            // Capture record address field
                     i = 4;
                     j = 0;
                     rlen  = rlen / 2;
                     radd  = 0;
                     state = 2;
                }

                break;

           case 2 :                     // Read and convert record address field

                radd = (radd << 4) + ahtoi(ch);

                i -= 1;
                j += 1;

                if(i == 0) {            // Read record type
                     i = 2;             // read two (2) chars
                     j = 0;

                     radd = radd / 2;

                     rtyp  = 0;
                     state = 3;
                }

                break;

           case 3 :                     // Read and convert record type

                rtyp = (rtyp << 4) + ahtoi(ch); // Convert to integer

                i -= 1;

                if(i == 0) {            // ((rtype) ? 0 : 4)
                     i = 4;
                     j = 0;

                     if(rtyp == 0) {    // Read and print data records
                         radd = (radd * 3);
                         if(radd & 1) {
                            radd = (radd - 2) / 2; // emit address with padding
                            fprintf(stdout, "@%04X\n000\n", radd);
                         } else {
                            radd = radd / 2;     // 1.5 bytes per instruction
                            fprintf(stdout, "@%04X\n", radd);    // emit address
                         }
                         state = 4;
                     } else {           // Skip to next record or EOF
                         state = 0;
                     }
                }

                break;

           case 4 :                     // Read and output sorted data - 4 chars

                rdat[j] = ch;

                i -= 1;
                j += 1;

                if(i == 0) {
                     i = 4;
                     j = 0;

                     //fprintf(stdout, "%c%c%c\n", rdat[1], rdat[0], rdat[3]);
                     fprintf(stdout, "%c%c%c\n", rdat[3], rdat[0], rdat[1]);

                     rlen -= 1;      // Decrement record length

                     if(rlen == 0) {
                         state = 0;  // End of data, skip to next record/EOF
                     } else {
                         state = 4;  // Data available, read next data word
                     }
                }

                break;

           default : break;
        }
    }
    return 0;
}