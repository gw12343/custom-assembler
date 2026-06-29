package com.gabe.cpu;

import java.util.ArrayList;
import java.util.List;

import static com.gabe.cpu.MicroInstructions.*;


/**
 * Enum representing the CPU's instructions.
 * Each instruction is associated with a list of micro-instructions, an opcode,
 * and specific instruction data.
 *
 * @author Gabriel West
 * @Date 7/1/2024
 */
@SuppressWarnings("SpellCheckingInspection")
public enum CPUInstruction {
    NO_OPERATION(new ArrayList<>(), 0xea, InstructionData.empty()),
    HLT(List.of(HALT), 0x99,  InstructionData.empty()),

    JMP(List.of(
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe1, InstructionData.op1lit()),


    JMP_REG(List.of(
            STORE_INS_A | LOAD_PC,
            MC_END
    ), 0xf1, InstructionData.register1()),

    JNZ(List.of(
            RESET_NOT0,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe2, InstructionData.op1lit()),

    JZ(List.of(
            RESET_EQ0,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe3, InstructionData.op1lit()),

    JL(List.of(
            RESET_LESS,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe4, InstructionData.op1lit()),

    JG(List.of(
            RESET_GREATER,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe5, InstructionData.op1lit()),

    JE(List.of(
            RESET_EQUAL,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe6, InstructionData.op1lit()),

    JNE(List.of(
            RESET_NOT_EQUAL,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe7, InstructionData.op1lit()),

    JC(List.of(
            RESET_NOT_EQUAL,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0xe8, InstructionData.op1lit()),


    CALL(List.of(
            STORE_SP | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            STORE_PC | LOAD_RAM | SP_COUNT | SP_DEC,
            STORE_LIT | LOAD_PC,
            MC_END
    ), 0x30, InstructionData.op1lit()),

    RET(List.of(
            SP_COUNT,
            STORE_SP | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            STORE_RAM | LOAD_PC,
            MC_END
    ), 0x31, InstructionData.empty()),


    PUSH(List.of(
            STORE_SP | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            STORE_INS_A | LOAD_RAM | SP_COUNT | SP_DEC,
            MC_END
    ), 0x33, InstructionData.register1()),

    POP(List.of(
            SP_COUNT,
            STORE_SP | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            LOAD_INS_A | STORE_RAM,
            MC_END
    ), 0x34, InstructionData.register1()),





    MOV(List.of(
            STORE_INS_B | LOAD_INS_A,
            MC_END
    ), 0x45, InstructionData.register1and2()),

    MOVI(List.of(
            STORE_LIT | LOAD_INS_A,
            MC_END
    ), 0x46, InstructionData.register1lit2()),

    MOVFROMABS(List.of(
            STORE_LIT | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            LOAD_INS_A | STORE_RAM,
            MC_END
    ), 0x47, InstructionData.register1lit2()),

    MOVFROMIND(List.of(
            STORE_LIT | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            LOAD_ADDR | STORE_RAM,
            LOAD_INS_A | STORE_RAM,
            MC_END
    ), 0x48, InstructionData.register1lit2()),
    MOVTOABS(List.of(
            STORE_LIT | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            STORE_INS_A | LOAD_RAM,
            MC_END
    ), 0x49, InstructionData.lit1register2()),

    MOVTOIND(List.of(
            STORE_LIT | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            LOAD_ADDR | STORE_RAM,
            WAIT_FOR_RAM_UPDATE,
            STORE_INS_A | LOAD_RAM,
            MC_END
    ), 0x50, InstructionData.lit1register2()),

    MOVFROMREGIND(List.of(
            STORE_INS_B | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            LOAD_INS_A | STORE_RAM,
            MC_END
    ), 0x51, InstructionData.register1and2()),

    MOVTOREGIND(List.of(
            STORE_INS_A | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            STORE_INS_B | LOAD_RAM,
            MC_END
    ), 0x52, InstructionData.register1and2()),

    MOVTOREGINDOFFSET(List.of(
            USE_INS_LIT_B | ALU_ADD | STORE_ALU_OUT | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            STORE_INS_B | LOAD_RAM,
            MC_END
    ), 0x53, InstructionData.register1and2andoffset1()),

    MOVFROMREGINDOFFSET(List.of(
            USE_INS_LIT_B | ALU_ADD | STORE_ALU_OUT | LOAD_ADDR,
            WAIT_FOR_RAM_UPDATE,
            LOAD_INS_B | STORE_RAM,
            MC_END
    ), 0x54, InstructionData.register2and1andoffset2()),




    SHR(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_SHIFT_LR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x70, InstructionData.register1()),

    SHL(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_SHIFT_LL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x71, InstructionData.register1()),

    ASR(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_SHIFT_AR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x72, InstructionData.register1()),

    ROL(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_ROL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x73, InstructionData.register1()),

    ROR(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_ROR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x74, InstructionData.register1()),



    // bit shift immediates  =================
    SHR_IM(List.of(
            USE_INS_LIT_B | ALU_SHIFT_LR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x80, InstructionData.register1lit2()),

    SHL_IM(List.of(
            USE_INS_LIT_B | ALU_SHIFT_LL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x81, InstructionData.register1lit2()),

    ASR_IM(List.of(
            USE_INS_LIT_B | ALU_SHIFT_AR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x82, InstructionData.register1lit2()),

    ROL_IM(List.of(
            USE_INS_LIT_B | ALU_ROL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x83, InstructionData.register1lit2()),

    ROR_IM(List.of(
            USE_INS_LIT_B | ALU_ROR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x84, InstructionData.register1lit2()),

    // bit shift 2 regs  =================
    SHR_REG(List.of(
            ALU_SHIFT_LR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x90, InstructionData.register1and2()),

    SHL_REG(List.of(
            ALU_SHIFT_LL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x91, InstructionData.register1and2()),

    ASR_REG(List.of(
            ALU_SHIFT_AR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x92, InstructionData.register1and2()),

    ROL_REG(List.of(
            ALU_ROL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x93, InstructionData.register1and2()),

    ROR_REG(List.of(
            ALU_ROR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x94, InstructionData.register1and2()),







    INC(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_ADD | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x10, InstructionData.register1()),

    DEC(List.of(
            USE_CONST_AS_B | CONSTANT_1 | ALU_SUB | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x11, InstructionData.register1()),



    CMP(List.of(
            ALU_CMP | UPDATE_FLAGS,
            MC_END
    ), 0x13, InstructionData.register1and2()),
    ADD(List.of(
            ALU_ADD | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x14, InstructionData.register1and2()),
    SUB(List.of(
            ALU_SUB | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x15, InstructionData.register1and2()),

    MUL(List.of(
            ALU_MUL | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x16, InstructionData.register1and2()),

    AND(List.of(
            ALU_AND | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x17, InstructionData.register1and2()),

    OR(List.of(
            ALU_OR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x18, InstructionData.register1and2()),

    NOT(List.of(
            ALU_NOT | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x19, InstructionData.register1and2()),

    XOR(List.of(
            ALU_XOR | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x20, InstructionData.register1and2()),

    NAND(List.of(
            ALU_NAND | STORE_ALU_OUT | LOAD_INS_A,
            MC_END
    ), 0x21, InstructionData.register1and2()),




    CMP_IM(List.of(
            ALU_CMP | UPDATE_FLAGS | USE_INS_LIT_B,
            MC_END
    ), 0xa3, InstructionData.register1lit2()),
    ADD_IM(List.of(
            ALU_ADD | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa4, InstructionData.register1lit2()),
    SUB_IM(List.of(
            ALU_SUB | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa5, InstructionData.register1lit2()),

    MUL_IM(List.of(
            ALU_MUL | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa6, InstructionData.register1lit2()),

    AND_IM(List.of(
            ALU_AND | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa7, InstructionData.register1lit2()),

    OR_IM(List.of(
            ALU_OR | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa8, InstructionData.register1lit2()),

    XOR_IM(List.of(
            ALU_XOR | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa0, InstructionData.register1lit2()),

    NAND_IM(List.of(
            ALU_NAND | STORE_ALU_OUT | LOAD_INS_A | USE_INS_LIT_B,
            MC_END
    ), 0xa1, InstructionData.register1lit2()),

    ;


    private final int opcode;
    private final InstructionData data;
    private final List<Integer> microInstructions;

    /**
     * Constructor for the CPUInstruction enum.
     *
     * @param microInstructions the list of micro-instructions associated with the instruction
     * @param opcode the opcode for the instruction
     * @param data the data associated with the instruction
     * @see MicroInstructions
     * @see InstructionData
     */
    CPUInstruction(List<Integer> microInstructions, int opcode, InstructionData data) {
        this.opcode = opcode;
        this.microInstructions = microInstructions;
        this.data = data;
    }


    /**
     * Gets the list of micro-instructions for the instruction.
     *
     * @return the list of micro-instructions
     */
    public List<Integer> getMicroInstructions() {
        return microInstructions;
    }

    /**
     * Gets the opcode for the instruction.
     *
     * @return the opcode
     */
    public int getOpcode() {
        return this.opcode;
    }

    /**
     * Gets the data associated with the instruction.
     *
     * @return the data
     */
    public InstructionData getData() {
        return this.data;
    }
}

