#include "mbed.h"

Serial serial(p13, p14);
Serial pc(USBTX, USBRX);
DigitalOut cmdpin(p16);

#define BUF_LEN 128
char buf[BUF_LEN];
char c;
int  i;

int main()
{
    pc.baud(115200);
    serial.baud(115200);
    cmdpin = 0;
    i = 0;

    pc.puts("\n\nMBED SERIAL TUNNEL\n");

    for (;;)
    {
        while (pc.readable())
        {
            c = pc.getc();
            buf[i++] = c;
            if (c == '\r')
            {
                //buf[i] = '\n';
                //buf[i+1] = '\0';
                buf[i] = '\0';

                //cmdpin = 0;
                serial.puts(buf);
                //cmdpin = 1;

                pc.putc('\n');
                i = 0;
            }
            else
            {
                pc.putc(c);
            }
        }

        while (serial.readable())
            pc.putc(serial.getc());
    }
}
