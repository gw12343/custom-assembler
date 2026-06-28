package com.gabe.assembler;

import com.gabe.FileUtils;
import com.gabe.cpu.CPUInstruction;
import com.gabe.cpu.InstructionData;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.List;
import java.util.Scanner;

public class Assembler {
    public static void main(String[] args) throws FileNotFoundException {

        String s = new Scanner(new File(args[0])).useDelimiter("\\Z").next();
        List<Token> tokens = Tokenizer.tokenize(s, true);
        System.out.println(tokens);
        List<Parser.ASMLine> lines = Parser.parse(tokens);
        System.out.println("Parsing complete");
        int adr = 0;
        HashMap<String, Integer> labels = new HashMap<>();

        for (Parser.ASMLine line : lines) {
            if (line.label() != null) {
                if(labels.containsKey(line.label())){
                    //error, duplicate label
                    System.err.println("Duplicate label: " + line.label());
                    return;
                }
                labels.put(line.label(), adr);
            }
            if (line.i() != null) {
                adr++;
            }else if(line.directive() != null){
                switch (line.directive()){
                    case RESW, FLOAT -> {
                        adr++;
                    }
                    case ASCIIZ -> {
                        adr += ((String)line.directiveData().get(0)).length() + 1;
                    }
                    case ASCII -> {
                        adr += ((String)line.directiveData().get(0)).length();
                    }
                    case ORG -> {
                        adr = (int)(double) line.directiveData().get(0);
                        System.out.println("org: " + adr);
                    }
                }
            }

        }

        int size = 65536;
        String[] dat = new String[size];
        int a = 0;
        for (Parser.ASMLine line : lines) {

            //System.out.println("i: " + line.i() + "    dir: " + line.directive() + "   label: " + line.label());

//            if(line.directive() != null && line.directive() == AssemblerDirectives.ORG){
//                int newAdr = (int)(double) line.directiveData().get(0);
//                System.out.println("hit org: " + newAdr);
//                while(a < newAdr){
//                    dat[a++] = "0000";
//                }
//
//            }

            if(line.i() != null) {
                CPUInstruction c = line.i();
                InstructionData data = c.getData();
                String code = data.generateBin(c, labels, line.operands().toArray(new Parser.Operand[0]));
                String st = toHexString(Long.parseLong(code, 2), 8);
                //System.out.println(st);
                dat[a] = st;
                a++;
            }else if(line.directive() != null){
                switch (line.directive()){

                    case FLOAT -> {
                        var v = toHexString(Float.floatToIntBits((float)(double) line.directiveData().get(0)), 8);
                        System.out.println("float dir: " + v + "       f: " + line.directiveData().get(0));
                        dat[a++] = v;
                    }
                    case RESW -> {
                        System.out.println("resw: " + line);
                        var v = toHexString((long)(double)line.directiveData().get(0), 8);
                        System.out.println(v);
                        dat[a++] = v;
                    }
                    case ASCIIZ -> {
                        String str = ((String)line.directiveData().get(0));
                        for(int i = 0 ; i < str.length(); i++){
                            dat[a++] = toHexString((int)str.charAt(i), 8);
                        }
                        dat[a++] = toHexString(0, 8);
                    }
                    case ASCII -> {
                        String str = ((String)line.directiveData().get(0));
                        for(int i = 0 ; i < str.length(); i++){
                            dat[a++] = toHexString((int)str.charAt(i), 8);
                        }
                    }
                }
            }
        }

        int addr = 0x8000;
        for(int i =0 ;i < a; i++){

            System.out.print(toHexString(addr++, 4) + "=" + dat[i]);
        }
        System.out.println("j8000");

        for(int j = a; j < size; j++) {
            dat[j] = "00000000";
        }
        FileUtils.writePlainHexFile(dat, "C:\\Users\\Gabe\\Documents\\GitHub\\custom-emulator\\program.rom");
        FileUtils.writeHexMemFile(dat, "C:\\Users\\Gabe\\Documents\\GitHub\\custom-emulator\\program.mem");
        FileUtils.writeHexMemFile(dat, "C:\\Users\\Gabe\\Documents\\VivadoProjects\\32BitCPU\\32BitCPU.srcs\\sources_1\\new\\program.mem");
    }

    public static int getRegister(String s){
        return switch (s) {
            case "r1" -> 1;
            case "r2" -> 2;
            case "r3" -> 3;
            case "r4" -> 4;
            case "r5" -> 5;
            case "r6" -> 6;
            case "r7" -> 7;
            case "r8" -> 8;
            case "pc" -> 12;
            case "bp" -> 14;
            case "sp" -> 15;
            default -> -1;
        };
    }

    public static boolean isRegister(String s){
        return getRegister(s) != -1;
    }

    public static String toBinaryString(int i, int digits){
        if (i >= 0) {
            String s = Integer.toBinaryString(i);
            if(s.length() > digits) {
                return s.substring(0, digits);
            }
            return "0".repeat(digits - s.length()) + s;
        }else{
            String b = Integer.toBinaryString(i);
            b = b.substring(16, 32);

            StringBuilder twosComplement = toTwosComplement(b);

            return "1".repeat(digits - twosComplement.length()) + twosComplement;
        }
    }

    private static StringBuilder toTwosComplement(String binary) {
        StringBuilder onesComplement = new StringBuilder();
        for (int j = 0; j < binary.length(); j++) {
            if (binary.charAt(j) == '0') {
                onesComplement.append("1");
            } else {
                onesComplement.append("0");
            }
        }

        StringBuilder twosComplement = new StringBuilder();
        for (int j = 0; j < onesComplement.length(); j++) {
            if (onesComplement.charAt(j) == '0') {
                twosComplement.append("1");
            } else {
                twosComplement.append("0");
            }
        }
        return twosComplement;
    }

    public static String toHexString(long i, int digits){
        String s = Long.toUnsignedString(i, 16);
        if(s.length() > digits) {
            throw new RuntimeException("Literal size exceeds word length!");
        }
        return "0".repeat(digits - s.length()) + s;
    }
}
