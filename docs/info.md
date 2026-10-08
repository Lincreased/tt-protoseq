<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

The design is a hardcoded UART transmitter. After reset it keeps the TX line high for 434 clock cycles, then sends the character 'A' (0x41) in 8N1 format (start bit 0, eight data bits LSB first, no parity, one stop bit), waits 434 cycles at idle level, and repeats forever.

With a 50 MHz clock one bit lasts 434 cycles (8.680 us), which is 115200 baud within +0.0064 %. One frame takes 4340 cycles, and the frame period including the pause is 4774 cycles (95.48 us). The TX signal is on uo[4]; all other outputs are 0.

The bit time and the pause are parameters of the transmitter core.

## How to test

Apply a 50 MHz clock to clk, hold rst_n low for a few cycles and release it. Probe uo[4] with a UART receiver set to 115200 baud, 8N1: it should print the character 'A' repeatedly. A logic analyzer on uo[4] should show a start bit of 8.68 us, the data bits 1,0,0,0,0,0,1,0 (LSB first) and a stop bit, with 95.48 us between frame starts.

## External hardware

A UART receiver connected to uo[4], for example a USB-UART adapter or a logic analyzer.
