package com.gabe.cpu;

@SuppressWarnings("unused SpellCheckingInspection")
class MicroInstructions {
    public static final int WAIT_FOR_RAM_UPDATE = 0b0;
    /*========================-= LOAD INSTRUCTIONS =-==============================*/
    public static final int LOAD_R1         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0001;
    public static final int LOAD_R2         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0010;
    public static final int LOAD_R3         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0011;
    public static final int LOAD_R4         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0100;
    public static final int LOAD_R5         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0101;
    public static final int LOAD_R6         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0110;
    public static final int LOAD_R7         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0111;
    public static final int LOAD_R8         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1000;
    public static final int LOAD_RAM        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1001;
    public static final int LOAD_INS        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1010;
    public static final int LOAD_ADDR       = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1011;
    public static final int LOAD_PC         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1100;
    public static final int LOAD_BP         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1110;
    public static final int LOAD_SP         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_1111;
    /*=======================-= STORE INSTRUCTIONS =-==============================*/
    public static final int STORE_ALU_OUT   = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int STORE_R1        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0001_0000;
    public static final int STORE_R2        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0010_0000;
    public static final int STORE_R3        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0011_0000;
    public static final int STORE_R4        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0100_0000;
    public static final int STORE_R5        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0101_0000;
    public static final int STORE_R6        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0110_0000;
    public static final int STORE_R7        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0111_0000;
    public static final int STORE_R8        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1000_0000;
    public static final int STORE_RAM       = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1001_0000;
    public static final int STORE_LIT       = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1010_0000;
    public static final int STORE_ADDR      = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1011_0000;
    public static final int STORE_PC        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1100_0000;
    public static final int STORE_CONST     = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1101_0000;
    public static final int STORE_BP        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1110_0000;
    public static final int STORE_SP        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_1111_0000;
    /*=============================-= CONSTANTS =-================================*/
    public static final int CONSTANT_0      = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int CONSTANT_1      = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_01_0000_0000;
    public static final int CONSTANT_NEG1   = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0000_10_0000_0000;
    /*===========================-= ALU OPERATIONS =-=============================*/
    public static final int ALU_ADD         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0001_00_0000_0000;
    public static final int ALU_SUB         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0010_00_0000_0000;
    public static final int ALU_MUL         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0011_00_0000_0000;
    public static final int ALU_NEG         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0100_00_0000_0000;
    public static final int ALU_SHIFT_LL    = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0101_00_0000_0000;
    public static final int ALU_SHIFT_LR    = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0110_00_0000_0000;
    public static final int ALU_SHIFT_AR    = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_0111_00_0000_0000;
    public static final int ALU_ROL         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1000_00_0000_0000;
    public static final int ALU_ROR         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1001_00_0000_0000;
    public static final int ALU_CMP         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1010_00_0000_0000;
    public static final int ALU_AND         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1011_00_0000_0000;
    public static final int ALU_OR          = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1100_00_0000_0000;
    public static final int ALU_NOT         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1101_00_0000_0000;
    public static final int ALU_XOR         = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1110_00_0000_0000;
    public static final int ALU_NAND        = 0b0_0_000_0_0_0_0_0_0_0_0_0_0_1111_00_0000_0000;
    /*===========================-= MISC =-=======================================*/
    public static final int PC_COUNT        = 0b0_0_000_0_0_0_0_0_0_0_0_0_1_0000_00_0000_0000;
    public static final int MC_END          = 0b0_0_000_0_0_0_0_0_0_0_0_1_0_0000_00_0000_0000;
    public static final int SP_COUNT        = 0b0_0_000_0_0_0_0_0_0_0_1_0_0_0000_00_0000_0000;
    public static final int STORE_INS_A     = 0b0_0_000_0_0_0_0_0_0_1_0_0_0_0000_00_0000_0000;
    public static final int STORE_INS_B     = 0b0_0_000_0_0_0_0_0_1_0_0_0_0_0000_00_0000_0000;
    public static final int LOAD_INS_A      = 0b0_0_000_0_0_0_0_1_0_0_0_0_0_0000_00_0000_0000;
    public static final int LOAD_INS_B      = 0b0_0_000_0_0_0_1_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int SP_DEC          = 0b0_0_000_0_0_1_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int UPDATE_FLAGS    = 0b0_0_000_0_1_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int HALT            = 0b0_0_000_1_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    /*===========================-= FLAG STUFF =-=======================================*/
    public static final int RESET_NOT0      = 0b0_0_001_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int RESET_EQ0       = 0b0_0_010_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int RESET_LESS      = 0b0_0_011_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int RESET_GREATER   = 0b0_0_100_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int RESET_EQUAL     = 0b0_0_101_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int RESET_NOT_EQUAL = 0b0_0_110_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int RESET_CARRY     = 0b0_0_111_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int USE_INS_LIT_B   = 0b0_1_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
    public static final int USE_CONST_AS_B  = 0b1_0_000_0_0_0_0_0_0_0_0_0_0_0000_00_0000_0000;
}

