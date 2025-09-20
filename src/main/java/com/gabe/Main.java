package com.gabe;


import com.gabe.assembler.Assembler;
import com.gabe.cpu.MicrocodeRomGenerator;

public class Main {
    public static void main(String[] args) {
        switch (args[0]) {
            case "rom" -> {
                MicrocodeRomGenerator.exportROM(args.length > 1 ? args[1] : "C:\\Users\\Gabe\\CLionProjects\\CPU32Emulator\\microcode.rom");
                return;
            } case "table" -> {
                MicrocodeRomGenerator.exportTruthTable(args.length > 1 ? args[1] : "C:\\Users\\Gabe\\CLionProjects\\CPU32Emulator\\truth_table_export.txt");
                return;
            } case "asm" -> {
                return;
            }
        }
        System.err.println("Invalid usage!");
        System.err.println("$ java gcpu <rom/asm> file");
    }

}