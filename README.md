# About this repo

VHDL implementation of the CORDIC algorithm, with an uncertainty in the rotation angle of 0.02 degrees.

The CORDIC module allows both to compute with rotation and vectorization modes.

## Synthesizing

Synthesize each module with the `simulate.sh` file.

You can execute it by running in the terminal:

`./simulate.sh <PATH_TO_SRC_FILE> <ENTITY_NAME> <PATH_TO_SAVE_VCD_FILE>`

More precisely, to execute this repo follow these commands from the repo main folder:

`./simulate.sh /components/atan_rom/atan_rom.vhd atan_rom`

`./simulate.sh /components/cordic_kernel/cordic_kernel.vhd cordic_kernel`

`./simulate.sh /components/cordic_processor/cordic_processor.vhd cordic_processor`

`./simulate.sh /components/cordic/cordic.vhd cordic`

Notice that each synthesization opens the simulator. You can close it if you're not trying to synthesize a test bench.

## Testing

The testing folder contains a python script that generates test data for the module.

To test any module, synthesize all of them and then run:

`./simulate.sh /components/cordic/cordic_tb.vhd cordic_tb`

Replace `cordic_tb` with any equivalent module that you want to test.