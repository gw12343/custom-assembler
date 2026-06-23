package com.gabe.cpu;

import com.gabe.FileUtils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;

import static com.gabe.cpu.MicroInstructions.*;

public class MicrocodeRomGenerator {
    static final int size = 4096;

    public static void exportROM(String path){
        String[] data = generateDefaultData();;
        FileUtils.writePlainHexFile(data, path);
        FileUtils.writeHexMemFile(data, "C:\\Users\\Gabe\\Documents\\GitHub\\custom-emulator\\microcode.mem");
        FileUtils.writeHexMemFile(data, "C:\\Users\\Gabe\\Documents\\VivadoProjects\\32BitCPU\\32BitCPU.srcs\\sources_1\\new\\microcode.mem");
    }

    private static  String[] generateDefaultData() {
        String[] data = new String[size];
        Arrays.fill(data, String.format("%08X", 0));

        addMicrocodeToAllInstruction(data, STORE_PC | LOAD_ADDR, "0000");
        addMicrocodeToAllInstruction(data, 0, "0001");
        addMicrocodeToAllInstruction(data, STORE_RAM | LOAD_INS | PC_COUNT, "0010");
        addMicrocodeToAllInstruction(data, MC_END, "0011");


        for(CPUInstruction instruction : CPUInstruction.values()){
            for(int i = 3; i < instruction.getMicroInstructions().size() + 3; i++){
                String instructionStep = String.format("%4s", Integer.toBinaryString(i)).replaceAll(" ", "0");
                String instructionBinary = String.format("%8s", Integer.toBinaryString(instruction.getOpcode())).replaceAll(" ", "0");
                String finalAddress = instructionBinary + instructionStep;
                int index = Integer.parseInt(finalAddress, 2);
                writeMicrocode(data, index, instruction.getMicroInstructions().get(i-3));
            }
        }
        return data;
    }

    public static void exportTruthTable(String path){
        System.out.println("Exporting truth table...");
        String[] data = generateDefaultData();;

        // List of binary
        LinkedHashMap<String, String> truthTable = new LinkedHashMap<>();
        for(int i = 0 ; i < data.length; i++){
            String left = Integer.toBinaryString(i);
            if(left.length() < 12){
                left = "0".repeat(12 - left.length()) + left;
            }
            String right = Integer.toBinaryString(Integer.parseInt(data[i], 16));

            if(right.equals("0")) right = "-".repeat(29);

            if(right.length() < 29){
                right = "0".repeat(29 - right.length()) + right;
            }

            truthTable.put(left, right);
        }
        FileUtils.writeTable(truthTable, path);
    }

    public static void addMicrocodeToAllInstruction(String[] data, int code, String microstep){
        for(int ins = 0; ins < 256; ins++){
            String instructionBinary = String.format("%8s", Integer.toBinaryString(ins)).replaceAll(" ", "0");
            String finalAddress = "0000" + instructionBinary + microstep;
            int index = Integer.parseInt(finalAddress, 2);
            writeMicrocode(data, index, code);
        }
    }

    public static void writeMicrocode(String[] data, int address, int value){
        data[address] = String.format("%8x", value).replaceAll(" ", "0");
    }
}
