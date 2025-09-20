package com.gabe.assembler;

/**
 * A single lexical unit of the program
 * Stores any literal value associated with the
 * token, as well as the line and character
 * number it was on.
 *
 * @author Gabriel West
 * @Date 7/1/2024
 */
public class Token {
    private final TokenType tokenType;
    private final String lexeme;
    private final int line;
    private final int horizontal;
    public Object literal;


    /**
     * Constructs a Token instance.
     *
     * @param tokenType the type of the token
     * @param lexeme the string representation of the token
     * @param literal the literal value associated with the token (if there is one)
     * @param line the line number where the token is located
     * @param horizontal the character position on the line where the token starts
     * @see TokenType
     */
    public Token(TokenType tokenType, String lexeme, Object literal, int line, int horizontal){
        this.tokenType = tokenType;
        this.lexeme = lexeme;
        this.literal = literal;
        this.line = line;
        this.horizontal = horizontal;
    }

    /**
     * Gets the type of the token.
     *
     * @return the token type
     */
    public TokenType tokenType() {
        return tokenType;
    }

    /**
     * Gets the string representation of the token.
     *
     * @return the lexeme
     */
    public String lexeme() {
        return lexeme;
    }

    /**
     * Gets the line number where the token is located.
     *
     * @return the line number
     */
    public int line() {
        return line;
    }

    /**
     * Gets the character position on the line where the token starts.
     *
     * @return the horizontal position
     */
    public int horizontal() {
        return horizontal;
    }

    /**
     * Gets the literal value associated with the token.
     *
     * @return the literal value
     */
    public Object literal() {
        return literal;
    }

    /**
     * Returns a string representation of the token.
     *
     * @return the string representation
     */
    @Override
    public String toString() {
        return String.format("[ %s %s %s]",
                tokenType.toString(),
                (tokenType == TokenType.EMPTY ? "" : lexeme),
                (literal == null ? "" : literal + " ")
        );
    }
}
