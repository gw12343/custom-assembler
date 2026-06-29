package com.gabe.assembler;

import com.gabe.cpu.CPUInstruction;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import static com.gabe.assembler.OperandType.*;

/**
 * Enum representing assembler mnemonics and their corresponding CPU instructions.
 * Each mnemonic is associated with a map of operation headers to their
 * respective CPU instructions.
 */
@SuppressWarnings("SpellCheckingInspection")
public enum AssemblerMnemonic {

    NOP(Map.of(new OperationHeader(), CPUInstruction.NO_OPERATION)),
    HLT(Map.of(new OperationHeader(), CPUInstruction.HLT)),

    JMP(Map.of(new OperationHeader(MEM), CPUInstruction.JMP,
            new OperationHeader(REGISTER), CPUInstruction.JMP_REG)),

    JNZ(Map.of(new OperationHeader(MEM), CPUInstruction.JNZ)),
    JZ(Map.of(new OperationHeader(MEM), CPUInstruction.JZ)),
    JL(Map.of(new OperationHeader(MEM), CPUInstruction.JL)),
    JG(Map.of(new OperationHeader(MEM), CPUInstruction.JG)),
    JE(Map.of(new OperationHeader(MEM), CPUInstruction.JE)),
    JNE(Map.of(new OperationHeader(MEM), CPUInstruction.JNE)),
    JC(Map.of(new OperationHeader(MEM), CPUInstruction.JC)),


    CALL(Map.of(new OperationHeader(MEM), CPUInstruction.CALL)),
    RET(Map.of(new OperationHeader(), CPUInstruction.RET)),


    PUSH(Map.of(new OperationHeader(REGISTER), CPUInstruction.PUSH)),
    POP(Map.of(new OperationHeader(REGISTER), CPUInstruction.POP)),


    SHR(Map.of(new OperationHeader(REGISTER), CPUInstruction.SHR,
                new OperationHeader(REGISTER, IMD), CPUInstruction.SHR_IM,
                new OperationHeader(REGISTER, REGISTER), CPUInstruction.SHR_REG)),

    SHL(Map.of(new OperationHeader(REGISTER), CPUInstruction.SHL,
            new OperationHeader(REGISTER, IMD), CPUInstruction.SHL_IM,
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.SHL_REG)),

    ASR(Map.of(new OperationHeader(REGISTER), CPUInstruction.ASR,
            new OperationHeader(REGISTER, IMD), CPUInstruction.ASR_IM,
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.ASR_REG)),

    ROL(Map.of(new OperationHeader(REGISTER), CPUInstruction.ROL,
            new OperationHeader(REGISTER, IMD), CPUInstruction.ROL_IM,
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.ROL_REG)),

    ROR(Map.of(new OperationHeader(REGISTER), CPUInstruction.ROR,
            new OperationHeader(REGISTER, IMD), CPUInstruction.ROR_IM,
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.ROR_REG)),


    INC(Map.of(new OperationHeader(REGISTER), CPUInstruction.INC)),
    DEC(Map.of(new OperationHeader(REGISTER), CPUInstruction.DEC)),

    CMP(Map.of(
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.CMP,
            new OperationHeader(REGISTER, IMD), CPUInstruction.CMP_IM
    )),

    ADD(Map.of(
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.ADD,
            new OperationHeader(REGISTER, IMD), CPUInstruction.ADD_IM
    )),
    SUB(Map.of(
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.SUB,
            new OperationHeader(REGISTER, IMD), CPUInstruction.SUB_IM
    )),

    MUL(Map.of(
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.MUL,
            new OperationHeader(REGISTER, IMD), CPUInstruction.MUL_IM
    )),

    AND(Map.of(
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.AND,
            new OperationHeader(REGISTER, IMD), CPUInstruction.AND_IM
    )),

    OR(Map.of(new OperationHeader(REGISTER, REGISTER), CPUInstruction.OR,
            new OperationHeader(REGISTER, IMD), CPUInstruction.OR_IM)),

    XOR(Map.of(new OperationHeader(REGISTER, REGISTER), CPUInstruction.XOR,
            new OperationHeader(REGISTER, IMD), CPUInstruction.XOR_IM)),

    NAND(Map.of(new OperationHeader(REGISTER, REGISTER), CPUInstruction.NAND,
            new OperationHeader(REGISTER, IMD), CPUInstruction.NAND_IM)),


    NOT(Map.of(new OperationHeader(REGISTER), CPUInstruction.NOT)),

    MOV(Map.of(
            new OperationHeader(REGISTER, REGISTER), CPUInstruction.MOV,
            new OperationHeader(REGISTER, IMD), CPUInstruction.MOVI,
            new OperationHeader(REGISTER, MEM), CPUInstruction.MOVFROMABS,
            new OperationHeader(REGISTER, MEM_IND), CPUInstruction.MOVFROMIND,
            new OperationHeader(MEM, REGISTER), CPUInstruction.MOVTOABS,
            new OperationHeader(MEM_IND, REGISTER), CPUInstruction.MOVTOIND,
            new OperationHeader(REGISTER, REGISTER_IND), CPUInstruction.MOVFROMREGIND,
            new OperationHeader(REGISTER_IND, REGISTER), CPUInstruction.MOVTOREGIND,
            new OperationHeader(REGISTER_IND_OFFSET, REGISTER), CPUInstruction.MOVTOREGINDOFFSET,
            new OperationHeader(REGISTER, REGISTER_IND_OFFSET), CPUInstruction.MOVFROMREGINDOFFSET
    ));

    static {
        int numMnemonics = Arrays.stream(AssemblerMnemonic.values()).map(v -> v.headers.size()).reduce(0, Integer::sum);
        int numCpuInstructions = CPUInstruction.values().length;

        if(numMnemonics != numCpuInstructions) {

            System.err.println("Invalid number of Mnemonics.    m: " + numMnemonics + "  i: " + numCpuInstructions);

            System.exit(-1);
        }
    }


    private final Map<OperationHeader, CPUInstruction> headers;

    /**
     * Constructor for the AssemblerMnemonic enum.
     *
     * @param headers the map of operation headers to CPU instructions
     */
    AssemblerMnemonic(Map<OperationHeader, CPUInstruction> headers) {
        this.headers = headers;

    }

    /**
     * Gets the CPU instruction associated with the given operation header.
     *
     * @param header the operation header
     * @return the CPU instruction
     */
    public CPUInstruction getInstruction(OperationHeader header){
        return headers.get(header);
    }

    /**
     * Generates a regex pattern to match any mnemonic in a case-insensitive manner.
     *
     * @return the regex pattern as a string
     */
    public static String getRegex(){
        StringBuilder s = new StringBuilder();
        for (AssemblerMnemonic mnemonics : AssemblerMnemonic.values()) {
            s.append("^(");
            // Allow upper or lower case for each character
            for(char c : mnemonics.name().toCharArray()){
                s.append("[");
                s.append(Character.toUpperCase(c));
                s.append(Character.toLowerCase(c));
                s.append("]");
            }
            s.append(")").append("|");
        }
        return s.deleteCharAt(s.length() - 1).toString();
    }
}

