include ../../../Fleet.mk

INC=-I../../../src/ -I../../../src/Inference -I../../../src/Hypotheses -I../../../src/VirtualMachine -I../../../src/Statistics


all:
	g++ Main.cpp -o main -lm -O3 $(FLEET_FLAGS) $(INC)

debug:
	g++ Main.cpp -o main -lm -g $(FLEET_FLAGS) $(INC)
	
