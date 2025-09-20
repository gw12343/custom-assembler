package com.gabe.assembler;

/**
 * Different types of operands
 */
public enum OperandType {
    /**
     * GPR or SPR
     */
    REGISTER,
    /**
     * Register storing pointer
     */
    REGISTER_IND,
    /**
     * Register storing pointer with offset
     */
    REGISTER_IND_OFFSET,
    /**
     * Immediate value
     */
    IMD,
    /**
     * Memory location
     */
    MEM,
    /**
     * Memory location of pointer
     */
    MEM_IND,
    /**
     * A label, later substituted with MEM
     */
    LABEL
}
