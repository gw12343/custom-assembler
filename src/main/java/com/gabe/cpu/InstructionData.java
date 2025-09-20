package com.gabe.cpu;

import com.gabe.assembler.Assembler;
import com.gabe.assembler.OperandType;
import com.gabe.assembler.Parser;
import com.gabe.assembler.TokenType;

import java.util.HashMap;

/**
 * The instruction data record represents a mapping between the operation
 * arguments from the assembler, and their ordering in the outputted opcode.
 * <p>
 * An instruction will look like this:
 * <blockquote>{@code
 * ----opcode---- --r1-- --r2-- -------------literal-------------
 * }</blockquote>
 *</p>
 *  @param r1 the source of the first 4 bits of the instruction following the opcode
 * @param r2 the source of the next 4 bits of the instruction following the opcode
 * @param lit the source of the remaining 16 bits of the instruction following the registers
 * @see DataSource
 *
 * @author Gabriel West
 * @Date 7/1/2024
 */
public record InstructionData(DataSource r1, DataSource r2, DataSource lit) {
    public static InstructionData empty(){
        return new InstructionData(DataSource.EMPTY, DataSource.EMPTY, DataSource.EMPTY);
    }

    public static InstructionData op1lit(){
        return new InstructionData(DataSource.EMPTY, DataSource.EMPTY, DataSource.OPERAND1);
    }


    public static InstructionData register1(){
        return new InstructionData(DataSource.OPERAND1, DataSource.EMPTY, DataSource.EMPTY);
    }
    public static InstructionData register1and2(){
        return new InstructionData(DataSource.OPERAND1, DataSource.OPERAND2, DataSource.EMPTY);
    }
    public static InstructionData register1and2andoffset1(){
        return new InstructionData(DataSource.OPERAND1, DataSource.OPERAND2, DataSource.OPERAND1_OFFSET);
    }
    public static InstructionData register2and1andoffset2(){
        return new InstructionData(DataSource.OPERAND2, DataSource.OPERAND1, DataSource.OPERAND2_OFFSET);
    }
    public static InstructionData register1lit2(){
        return new InstructionData(DataSource.OPERAND1, DataSource.EMPTY, DataSource.OPERAND2);
    }
    public static InstructionData lit1register2(){
        return new InstructionData(DataSource.OPERAND2, DataSource.EMPTY, DataSource.OPERAND1);
    }

    /**
     * Assemble this instruction
     * @param instruction the opcode of the instruction
     * @param labels map of the labels with their locations
     * @param operands list of operands passed
     * @return A string containing the binary form of the instruction
     */
    public String generateBin(CPUInstruction instruction, HashMap<String, Integer> labels, Parser.Operand... operands){
        String reg1 = "0000";
        String reg2 = "0000";
        if(instruction.getData().r1.equals(DataSource.OPERAND1)){
            if(operands.length > 0 && (
                    operands[0].type() == OperandType.REGISTER ||
                    operands[0].type() == OperandType.REGISTER_IND ||
                    operands[0].type() == OperandType.REGISTER_IND_OFFSET)){
                reg1 = operands[0].toString(labels);
            }
        }else if(instruction.getData().r1.equals(DataSource.OPERAND2)){
            if(operands.length > 1 && (
                            operands[1].type() == OperandType.REGISTER ||
                            operands[1].type() == OperandType.REGISTER_IND ||
                            operands[1].type() == OperandType.REGISTER_IND_OFFSET)){
                reg1 = operands[1].toString(labels);
            }
        }

        if(instruction.getData().r2.equals(DataSource.OPERAND1)){
            if(operands.length > 0 &&(
                            operands[0].type() == OperandType.REGISTER ||
                            operands[0].type() == OperandType.REGISTER_IND ||
                            operands[0].type() == OperandType.REGISTER_IND_OFFSET)){
                reg2 = operands[0].toString(labels);
            }
        }else if(instruction.getData().r2.equals(DataSource.OPERAND2)){
            if((operands.length > 1) && (
                            operands[1].type() == OperandType.REGISTER ||
                            operands[1].type() == OperandType.REGISTER_IND ||
                            operands[1].type() == OperandType.REGISTER_IND_OFFSET)){
                reg2 = operands[1].toString(labels);
            }
        }

        String opcode = Assembler.toBinaryString(instruction.getOpcode(), 8);
        String lit = "0000000000000000";

        if(instruction.getData().lit == DataSource.OPERAND1){
            lit = operands[0].toString(labels);
        }else if(instruction.getData().lit == DataSource.OPERAND2){
            lit = operands[1].toString(labels);
        }else if(instruction.getData().lit == DataSource.OPERAND1_OFFSET){
            lit = Assembler.toBinaryString(getOffset((Parser.RegisterOffset)operands[0].literal(), labels), 16);
        }else if(instruction.getData().lit == DataSource.OPERAND2_OFFSET){
            lit = Assembler.toBinaryString(getOffset((Parser.RegisterOffset)operands[1].literal(), labels), 16);
        }else if(instruction.getData().lit != DataSource.EMPTY){
            lit = "huh";
            System.out.println("WAS: " + instruction.getData().lit);
        }
        //System.out.println(opcode + "  " + reg1 + "  " +reg2 + "  " +lit);
        return opcode + reg1 + reg2 + lit;
    }

    private int getOffset(Parser.RegisterOffset o, HashMap<String, Integer> labels){
        if(o.offset() instanceof String){
            return labels.get(o.offset()) * (o.op().tokenType() == TokenType.PLUS ? 1 : -1);
        }else{
            return (int)(double)o.offset();
        }
    }
}
