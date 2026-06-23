package com.gabe.assembler;

import com.gabe.cpu.CPUInstruction;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.gabe.assembler.TokenType.*;

public class Parser {
    private static List<Token> tokens;
    private static int current = 0;

    public record ASMLine(String label, CPUInstruction i, OperationHeader header, List<Operand> operands, AssemblerDirectives directive, List<Object> directiveData) {}


    public static List<ASMLine> parse(List<Token> t){
        List<ASMLine> lines = new ArrayList<>();
        tokens = t;

        while(!isAtEnd()){
            System.out.println(peek());
            String label = null;
            if(match(IDENTIFIER)){
                Token a = prev();
                consume(COLON, "Expect colon after ident '" + a.lexeme() + "'");
                // label define
                label = a.lexeme();
            }

            if(match(MNEMONICS, DIRECTIVES)){
                Token token = prev();
                if(token.tokenType() == MNEMONICS) {
                    List<Operand> operands = new ArrayList<>();
                    Operand o = operand();
                    if(o != null){
                        operands.add(o);
                        while(match(COMMA)){
                            operands.add(operand());
                        }
                    }

                    OperandType[] locations =
                            operands.stream()
                                    .map(Operand::type)
                                    .toArray(OperandType[]::new);


                    AssemblerMnemonic n = AssemblerMnemonic.valueOf(token.lexeme().toUpperCase());
                    OperationHeader header = new OperationHeader(locations);
                    CPUInstruction c = n.getInstruction(header);

                    if (c == null)
                        throw new RuntimeException(token.line() + ": " + n.name() + ": Invalid operands for this instruction (" + c + "): " + header + "  " + operands);

                    lines.add(new ASMLine(label, c, header, operands, null, null));
                }else {
                    AssemblerDirectives d = AssemblerDirectives.valueOf(token.lexeme().toUpperCase().substring(1));
                    List<Object> directiveData = new ArrayList<>();
                    Object o = literal();
                    if(o != null){
                        directiveData.add(o);
                        while(match(COMMA)){
                            directiveData.add(literal());
                        }
                    }
                    lines.add(new ASMLine(label, null, null, null, d, directiveData));
                }

            }else{
                lines.add(new ASMLine(label, null, null, null, null, null));
            }

        }
        System.out.println("done!");
        return lines;
    }

    public record Operand(OperandType type, Object literal){
        public String toString(HashMap<String, Integer> labels) {
            switch (type){
                case REGISTER, REGISTER_IND -> {
                    return Assembler.toBinaryString(Assembler.getRegister((String) literal), 4);
                }
                case REGISTER_IND_OFFSET -> {

                    return Assembler.toBinaryString(Assembler.getRegister(((RegisterOffset) literal).reg), 4);
                }
                case IMD, MEM, MEM_IND -> {
                    return Assembler.toBinaryString((int)((double)literal), 16);
                }
                case LABEL -> {
                    if(labels.containsKey((String) literal))
                     return Assembler.toBinaryString(labels.get((String) literal), 16);

                    throw new RuntimeException("Label not defined: " + literal);
                }
                case LABEL_IMD -> {
                    if(labels.containsKey((String) literal))
                        return Assembler.toBinaryString(labels.get((String) literal), 16);

                    throw new RuntimeException("Imd label not defined: " + literal);
                }
            }

            return null;
        }
    }

    public record RegisterOffset(String reg, Token op, Object offset){}

    /**
     * Consumes an operand for an instruction
     * @return the operand, or {@code null} if there is not one
     * @see Operand
     * @see OperandType
     */
    public static Operand operand(){
        if(match(HASH)){
            System.out.println("pref: " + prev());
            System.out.println("next: " + peek());
            if(check(CHAR)){

                consume(CHAR, "Expect char");
                return new Operand(OperandType.IMD, prev().literal());
            }

            // literal label address
            if(check(IDENTIFIER)){
                consume(IDENTIFIER, "Expect label");
                System.out.println("IMD LABEL: " + prev().lexeme());
                return new Operand(OperandType.LABEL_IMD, prev().lexeme());
            }

            consume(NUMBER, "Expected number");
            return new Operand(OperandType.IMD, prev().literal());
        } else if(check(IDENTIFIER) && !checkNext(COLON)){
            //TODO differentiate register and label
            Token t = consume(IDENTIFIER, "Expect identifier");
            return new Operand(Assembler.isRegister(t.lexeme()) ?  OperandType.REGISTER : OperandType.LABEL, t.lexeme());
        } else if(match(LEFT_BRAC)){
            if(match(NUMBER)){
                Token t = prev();
                consume(RIGHT_BRAC, "Expected closing paren");
                return new Operand(OperandType.MEM_IND, t.literal());
            }else if(match(IDENTIFIER)){
                Token reg = prev();
                if(match(PLUS, MINUS)){
                    Token op = prev();
                    Object offset;
                        if(check(IDENTIFIER)){
                            offset = consume(IDENTIFIER, "Expect offset").lexeme();
                        }else {
                            offset = ((double)consume(NUMBER, "Expect offset").literal()) * (op.tokenType() == PLUS ? 1 : -1);


                        }
                        consume(RIGHT_BRAC, "Expected closing paren");
                        return new Operand(OperandType.REGISTER_IND_OFFSET, new RegisterOffset(reg.lexeme(), op, offset));
                    }
                consume(RIGHT_BRAC, "Expected closing paren");

                return new Operand(OperandType.REGISTER_IND, reg.lexeme());
            }
            return null;
        } else if(match(NUMBER)) {
            return new Operand(OperandType.MEM, prev().literal());
        }
        return null;
    }



    public static Object literal(){
        if(match(NUMBER)){
            return prev().literal();
        }else if(match(STRING)) {
            return prev().literal();
        }
        return null;
    }



    public static boolean match(TokenType... types){
        for(TokenType t : types){
            if(check(t)){
                advance();
                return true;
            }
        }

        return false;
    }

    private static Token consume(TokenType type, String err){
        if(match(type)) return prev();

        throw new RuntimeException(err + "\ngot: " + tokens.get(current).tokenType());
    }

    private static void advance() {
        if (!isAtEnd()) current++;
    }

    private static boolean check(TokenType t) {
        if(isAtEnd()) return false;
        return tokens.get(current).tokenType() == t;
    }
    @SuppressWarnings("SameParameterValue")
    private static boolean checkNext(TokenType t) {
        if(isAtEnd()) return false;

        return tokens.get(current + 1).tokenType() == t;
    }

    private static boolean isAtEnd() {
        return peek().tokenType() == EOF;
    }

    private static Token peek(){
        return tokens.get(current);
    }
    private static Token prev(){
        return tokens.get(current - 1);
    }

}
