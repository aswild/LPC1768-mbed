#include "mbed.h"

Serial serial(p13, p14);
Serial pc(USBTX, USBRX);

int main()
{
    pc.baud(115200);
    serial.baud(115200);

    pc.printf("\n\nMBED SERIAL TUNNEL\n");

    for (;;)
    {
        while (pc.readable())
            serial.putc(pc.getc());
        while (serial.readable())
            pc.putc(serial.getc());
    }
}
